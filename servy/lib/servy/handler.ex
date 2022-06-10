defmodule Servy.Handler do
  @moduledoc """
    Handles HTTP requests.
  """
  alias Servy.Utils.RequestHandlerSamples.Sample
  alias Servy.Conv
  require Logger
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1, emojify: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

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

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    serves_html_page(conv, "/form.html")
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%Conv{method: "DELETE", path: "/bears" <> id} = conv) do
    %{conv | status: 403, resp_body: "Bears with #{id} must be never deleted!"}
  end

  @pages_path Path.expand("pages", File.cwd!())

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    %{conv | status: 201, resp_body: "Created a #{conv.params["type"]} bear named #{conv.params["name"]}!"}
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    serves_html_page(conv, "/about.html")
  end

  def route(%Conv{method: "GET", path: "/pages/" <> file = conv}) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  defp serves_html_page(%Conv{} = conv, page) do
    @pages_path
    |> Path.join(page)
    |> File.read()
    |> handle_file(conv)
  end

  def format_response(%Conv{method: _, path: _, resp_body: resp_body, status: _} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(resp_body)}

    #{resp_body}
    """
  end

  def perform_sample_requests() do
    Sample.post_bears_request()
    |> handle()
    |> IO.puts()

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
