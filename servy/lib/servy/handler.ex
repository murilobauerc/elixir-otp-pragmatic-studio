defmodule Servy.Handler do
  @moduledoc """
    Handles HTTP requests.
  """
  alias Servy.Utils.RequestHandlerSamples.Sample
  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam

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

  def route(%Conv{method: "GET", path: "/snapshots"} = conv) do
    parent = self() # the request-handling process

    for cam_number <- 1..3 do
      spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-#{cam_number}")}) end)
    end

    snapshot1 = receive do {:result, filename} -> filename end
    snapshot2 = receive do {:result, filename} -> filename end
    snapshot3 = receive do {:result, filename} -> filename end

    snapshots = [snapshot1, snapshot2, snapshot3]

    %{conv | status: 200, resp_body: inspect(snapshots)}
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = _conv) do
    time |> String.to_integer |> :timer.sleep
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    serves_html_page(conv, "/form.html")
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "DELETE", path: "/bears" <> id} = conv) do
    id = Map.put(conv.params, "id", id)
    BearController.delete(conv, id)
  end

  @pages_path Path.expand("pages", File.cwd!())

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
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

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_content_type}\r
    Content-Length: #{String.length(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end

  def perform_sample_requests() do
    Sample.post_bears_request()
    |> handle()
    |> IO.puts()

    Sample.delete_bear_request()
    |> handle()
    |> IO.puts()

    # Sample.create_new_bears_request()
    # |> handle()
    # |> IO.puts()

    # Sample.get_about_request()
    # |> handle()
    # |> IO.puts()

    # Sample.get_bears_param_request()
    # |> handle()
    # |> IO.puts()

    # Sample.get_wildthings_request()
    # |> handle()
    # |> IO.puts()

    # Sample.get_bears_request()
    # |> handle()
    # |> IO.puts()

    # Sample.get_bear_by_id_request()
    # |> handle()
    # |> IO.puts()

    # Sample.delete_bear_by_id_request()
    # |> handle()
    # |> IO.puts()
  end
end
