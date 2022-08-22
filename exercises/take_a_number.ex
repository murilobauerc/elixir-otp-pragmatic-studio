defmodule TakeANumber do
  def start(), do: spawn(fn -> loop() end)

  defp loop(state \\ 0) do
    receive do
       {:report_state,sender_pid} -> send(sender_pid, state) |> loop
       {:take_a_number,sender_pid} -> send(sender_pid, state+1) |> loop
       {:api,sender_pid} -> send(sender_pid, 99) |> loop
       :stop ->  nil
       _ -> loop(state)
    end
  end
end
