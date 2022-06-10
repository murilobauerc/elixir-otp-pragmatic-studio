defmodule Servy.BearController do
  alias Servy.Wildthings

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.filter(fn bear -> bear.type == "Grizzly" end)
      |> Enum.sort(fn bear1, bear2 -> bear1.name <= bear2.name end)
      |> Enum.map(fn bear -> "<li>#{bear.name} - #{bear.type}</li>" end)
      |> Enum.join

    # TODO: Transform bears to an HTML list
    %{conv | status: 200, resp_body: "<ul><li>Name</li></ul>"}
  end

  def show(conv, %{"id" => id}) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{ conv | status: 201,
              resp_body: "Created a #{type} bear named #{name}!" }
  end

end
