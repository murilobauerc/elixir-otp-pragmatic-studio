defmodule Servy.Handler do

  alias Servy.Utils.RequestHandlerSamples

  def handle(request) do
    request
    |> parse()
    |> log()
    |> route()
    |> format_response()
  end

  def log(conv), do: IO.inspect(conv)

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

      %{method: method, path: path, resp_body: ""}
  end

  def route(%{method: method, path: path, resp_body: _} = conv) do
    route(conv, method, path)
  end

  def route(conv, "GET", "/wildthings") do
    %{conv | resp_body: "Bears, Lions, Tigers"}
  end

  def route(conv, "GET", "/bears") do
    %{conv | resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(conv, _method, path) do
    %{conv | resp_body: "No #{path} here!"}
  end

  def format_response(%{method: _, path: _, resp_body: resp_body} = _conv) do
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{String.length(resp_body)}

    #{resp_body}
    """
  end

  def perform_sample_requests() do
  RequestHandlerSamples.get_wildthings_request()
    |> handle()
    |> IO.puts()

  RequestHandlerSamples.get_bears_request()
    |> handle()
    |> IO.puts()

  RequestHandlerSamples.get_bigfoot_request()
    |> handle()
    |> IO.puts()
  end
end
