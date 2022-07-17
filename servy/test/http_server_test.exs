defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer
  alias Servy.HttpClient

  @max_concurrent_requests 5

  test "accepts a request on a socket and sends back a response" do
    spawn(HttpServer, :start, [4000])

    parent = self()

    for _ <- 1..@max_concurrent_requests do
      spawn(fn ->
        # Send the request
        {:ok, response} = HTTPoison.get "http://localhost:4000/wildthings"

        # Send the response back to the parent
        send(parent, {:ok, response})
      end)
    end

    # Await all {:handled, response} messages from spawned processes.
    for _ <- 1..@max_concurrent_requests do
      receive do
        {:ok, response} ->
          assert response.status_code == 200
          assert response.body == "🎉 Bears, Lions, Tiger"
      end
    end

  end
end
