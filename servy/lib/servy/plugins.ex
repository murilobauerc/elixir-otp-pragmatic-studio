defmodule Servy.Plugins do
  alias Servy.Conv

  @doc "Logs 404 errors."
  def track(%Conv{status: 404, path: path} = conv) do
    Logger.warn("#{path} is on the loose!")
    conv
  end

  def track(%Conv{} = conv), do: conv

  def emojify(%Conv{status: 200, resp_body: resp_body} = conv) do
    %{conv | resp_body: "🎉 " <> resp_body <> " 🎉"}
  end

  def emojify(%Conv{} = conv), do: conv

  def rewrite_path(%Conv{path: "/bears?id=" <> id} = conv) do
    %{conv | path: "/bears/#{id}"}
  end

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def log(conv), do: IO.inspect(conv)
end
