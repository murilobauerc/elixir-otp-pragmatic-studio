defmodule PowerNapper do
  power_nap = fn ->
    time = :rand.uniform(10000)
    :timer.sleep(time)
    time
  end

  parent = self()

  spawn(fn -> send(parent, {:slept, power_nap.()}) end)

  receive do
    {:slept, time} -> IO.puts "Slept #{time} ms"
  end
end
