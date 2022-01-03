defmodule Account do
  defstruct user: User, balance: 1000
  @accounts "Accounts.txt"

  def signup(user) do
    case search_by_email(user.email) do
      nil ->
        binary =
          ([%__MODULE__{user: user}] ++ search_accounts())
          |> :erlang.term_to_binary()

        File.write(@accounts, binary)

      _ ->
        {:error, "Account already exists!"}
    end
  end

  defp search_accounts do
    {:ok, binary} = File.read(@accounts)

    if binary != "", do: :erlang.binary_to_term(binary), else: []
  end

  defp search_by_email(email),
    do: Enum.find(search_accounts(), &(&1.user.email == email))

  def transfer(from, to, value) do
    from = search_by_email(from)
    to = search_by_email(to)

    cond do
      validate_balance(from.balance, value) ->
        {:error, "Insufficient balance!"}

      true ->
        accounts = delete([from, to])

        from = %__MODULE__{from | balance: from.balance - value}
        to = %__MODULE__{to | balance: to.balance + value}

        accounts = accounts ++ [from, to]

        Transaction.record("Transfer", Date.utc_today(), from.user.email, to.user.email, value)
        File.write(@accounts, :erlang.term_to_binary(accounts))
    end
  end

  defp delete(accounts) do
    Enum.reduce(accounts, search_accounts(), fn c, acc -> List.delete(acc, c) end)
  end

  def withdraw(account, value) do
    account = search_by_email(account)

    cond do
      validate_balance(account.balance, value) ->
        {:error, "Insufficient balance"}

      true ->
        accounts = delete([account])
        account = %__MODULE__{account | balance: account.balance - value}
        accounts = accounts ++ [account]
        File.write(@accounts, :erlang.term_to_binary(accounts))
        {:ok, account, "Email message send!"}
    end
  end

  defp validate_balance(balance, amount), do: balance < amount
end
