defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear
  import Servy.View, only: [render: 3]

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    render(conv, "index.html", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.html", bear: bear)
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end

  def delete(conv, %{"id" => id}) do
    %{conv | status: 200, resp_body: "Bears with id #{id} deleted!"}
  end
end
