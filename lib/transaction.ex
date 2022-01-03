defmodule Transaction do
  defstruct date: Date.utc_today(), type: nil, amount: 0, to: nil, from: nil
  @transactions "Transactions.txt"

  def record(type, date, from, to, amount) do
    transactions =
      search_transactions() ++
        [%__MODULE__{type: type, amount: amount, from: from, to: to, date: date}]

    File.write(@transactions, :erlang.term_to_binary(transactions))
  end

  def search_all(), do: search_transactions()

  defp search_transactions() do
    {:ok, binary} = File.read(@transactions)

    if binary != "", do: binary |> :erlang.binary_to_term(), else: []
  end
end
