defmodule Servy.Handler do

  alias Servy.Utils.RequestHandlerSamples.Sample

  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    |> emojify()
    |> track()
    |> format_response()
  end

  def track(%{status: 404, path: path} = conv) do
    IO.puts("Warning: #{path} is on the loose!")
    conv
  end

  def track(conv), do: conv

  def emojify(%{status: 200, resp_body: resp_body} = conv) do
    %{conv | resp_body: "🎉 " <> resp_body <> " 🎉"}
  end

  def emojify(conv), do: conv

  def rewrite_path(%{path: "/bears?id=" <> id} = conv) do
    %{conv | path: "/bears/#{id}"}
  end

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv

  def log(conv), do: IO.inspect(conv)

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

      %{ method: method,
        path: path,
        resp_body: "",
        status: nil
      }
  end

  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%{method: "GET", path: "/bears" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%{method: "DELETE", path: "bears" <> id} = conv) do
    %{conv | status: 403, resp_body: "Bears must be never deleted!"}
  end

  def route(%{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def format_response(%{method: _, path: _, resp_body: resp_body, status: status} = _conv) do
    """
    HTTP/1.1 #{status} #{status_reason(status)}
    Content-Type: text/html
    Content-Length: #{String.length(resp_body)}

    #{resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

  def perform_sample_requests() do
  Sample.get_bears_param_request()
    |> handle()
    |> IO.puts()

  Sample.get_wildthings_request()
    |> handle()
    |> IO.puts()

  Sample.get_bears_request()
    |> handle()
    |> IO.puts()

  Sample.get_bear_by_id_request()
  |> handle()
  |> IO.puts()

  Sample.delete_bear_by_id_request()
  |> handle()
  |> IO.puts()

  end
end
