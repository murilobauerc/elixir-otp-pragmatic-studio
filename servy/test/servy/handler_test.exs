defmodule Test.Servy.ServyTest do
  use ExUnit.Case
  doctest Servy

  @successful_request """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

  @malformed_request """
WRONG_PATH /random_url HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

  test "it parses a request successfully" do
    %{method: method, path: path, resp_body: resp_body, status: status} =
      Servy.Handler.parse(@successful_request)

    assert method == "GET"
    assert path == "/wildthings"
    assert resp_body == ""
    assert status == nil

  end

  test "fails when tries to parse a malformed request" do
    Servy.Handler.parse(@malformed_request) |> IO.inspect()
  end
end
