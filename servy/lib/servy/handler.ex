defmodule Servy.Handler do

  @moduledoc """
    Handles HTTP requests.
  """
  alias Servy.Utils.RequestHandlerSamples.Sample

  require Logger
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1, emojify: 1]

  @doc """
    Transforms the request into a response.
  """
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

  def route(%{method: "GET", path: "/bears/new"} = conv) do
    serves_html_page(conv, "/form.html")
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

  def route(%{method: "DELETE", path: "/bears" <> id} = conv) do
    %{conv | status: 403, resp_body: "Bears with #{id} must be never deleted!"}
  end

  @pages_path Path.expand("../../pages", __DIR__)

  def route(%{method: "GET", path: "/about"} = conv) do
    serves_html_page(conv, "/about.html")
  end

  def route(%{method: "GET", path: "/pages/" <> file = conv}) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  defp serves_html_page(conv, page) do
    @pages_path
    |> Path.join(page)
    |> File.read()
    |> handle_file(conv)
  end

  def handle_file({:ok, content}, conv) do
    %{conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found!"}
  end

  def handle_file({:error, reason}, conv) do
    %{conv | status: 500, resp_body: "File error: #{reason}"}
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
    Sample.create_new_bears_request()
    |> handle()
    |> IO.puts()

    Sample.get_about_request()
    |> handle()
    |> IO.puts()

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
