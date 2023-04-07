defmodule Servy.KickStarter do
  use GenServer

  def start_link(_args) do
    IO.puts("Starting the kickstarter...")

    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    server_pid = start_server()
    {:ok, server_pid}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("HttpServer exited (#{inspect(reason)})")
    server_pid = start_server()
    Process.link(server_pid)

    Process.register(server_pid, :http_server)
    {:noreply, server_pid}
  end

  def start_server do
    IO.puts("Starting the HTTP server...")
    server_pid = spawn_link(Servy.HttpServer, :start, [4000])
    Process.register(server_pid, :http_server)
  end
end
