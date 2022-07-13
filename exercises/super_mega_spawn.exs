defmodule SuperMegaSpawn do
  def thousand_of_processes() do
    Enum.map(1..10_000, fn (x) -> spawn(fn -> IO.puts x * x end) end)
  end
end

SuperMegaSpawn.thousand_of_processes()
