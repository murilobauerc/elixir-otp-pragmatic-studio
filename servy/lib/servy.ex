defmodule Servy do
  def hello(name) do
    "Hello, #{name}!"
  end

  def triple(list) do
    list
    |> Enum.map(& &1 * 3)
    |> IO.inspect(label: "All numbers tripled")
  end

  def recursive_triple([head | tail]) do
    [head * 3 | recursive_triple(tail)]
  end

  def recursive_triple([]), do: []

end
