defmodule Timer do
  def remind(reminder, seconds) do
    spawn(fn ->
      :timer.sleep(seconds * 1000)
      IO.puts(reminder)
    end)
  end
end

Timer.remind("Stand Up", 5)
Timer.remind("Sit Down", 10)
Timer.remind("Fight, Fight, Fight", 15)
