defmodule Servy.FourOhFourCounter do
  @name :counter_server

  # Client interface functions
  def start do
    IO.puts("Starting the 404 counter server...")
    # MFA
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @name)
  end

  def bump_count(path) do
    send(@name, {self(), :bump_count, path})

    receive do
      {:response, status} -> status
    end
  end

  def get_count(path) do
    send(@name, {self(), :get_count, path})

    receive do
      {:response, count} -> count
    end
  end

  def get_counts() do
    send(@name, {self(), :get_counts})

    receive do
      {:response, counts} -> counts
    end
  end

  # Server
  def listen_loop(state) do
    IO.puts("\nWaiting for a message...")

    receive do
      {sender, :bump_count, path} ->
        new_state = [{path, 1} | state]
        send(sender, {:response, new_state})
        IO.puts("#{path} bumped!")
        IO.puts("New state is #{inspect(new_state)}")
        listen_loop(new_state)

      {sender, :get_count, _path} ->
        count = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
        send(sender, {:response, count})
        listen_loop(state)

      {sender, :get_counts} ->
        send(sender, {:response, state})
        listen_loop(state)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state)
    end
  end
end
