defmodule Servy.PledgeServer do
  @name :pledge_server

  use GenServer

  def start do
    IO.puts("Starting the pledge server...")
    GenServer.start(__MODULE__, [], name: @name)
  end

  def create_pledge(name, amount) do
    GenServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenServer.call(@name, :recent_pledges)
  end

  def total_pledged do
    GenServer.call(@name, {:total_pledged})
  end

  def clear do
    GenServer.cast(@name, :clear)
  end

  # Server callbacks
  def handle_cast(:clear, _state) do
    {:noreply, []}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {:reply, id, new_state}
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Servy.PledgeServer
{:ok, _pid} = PledgeServer.start()

IO.inspect(PledgeServer.create_pledge("John", 100))
IO.inspect(PledgeServer.create_pledge("Jane", 200))
IO.inspect(PledgeServer.create_pledge("Jack", 300))
IO.inspect(PledgeServer.create_pledge("Jill", 400))
IO.inspect(PledgeServer.create_pledge("Jen", 500))
