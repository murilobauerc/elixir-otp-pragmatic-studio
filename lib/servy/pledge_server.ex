defmodule Servy.PledgeServer do
  @name :pledge_server

  # Client interface functions
  def start do
    IO.puts("Starting the pledge server...")
    # MFA
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @name)
  end

  def create_pledge(name, amount) do
    send(@name, {self(), :create_pledge, name, amount})

    receive do
      {:response, status} -> status
    end
  end

  def recent_pledges do
    send(@name, {self(), :recent_pledges})

    receive do
      {:response, pledges} -> pledges
    end
  end

  def total_pledged do
    send(@name, {self(), :total_pledged})

    receive do
      {:response, total} -> total
    end
  end

  # Server

  def listen_loop(state) do
    IO.puts("\nWaiting for a message...")

    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]
        send(sender, {:response, id})
        IO.puts("#{name} pledged #{amount}!")
        IO.puts("New state is #{inspect(new_state)}")
        listen_loop(new_state)

      {sender, :recent_pledges} ->
        send(sender, {:response, state})
        listen_loop(state)

      {sender, :total_pledged} ->
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
        send(sender, {:response, total})
        listen_loop(state)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state)
    end
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
