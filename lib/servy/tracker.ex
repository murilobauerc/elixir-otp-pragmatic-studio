defmodule Servy.Tracker do
  @doc """
  Simulates sending a request to an external API
  to get the gps coordinates of a wildthing.
  """
  def get_location(wildthing) do
    # CODE GOES HERE TO SEND A REQUEST TO THE EXTERNAL API

    # Sleep to simulate the API Delay:
    :timer.sleep(500)

    # Example responses returned from the API:
    locations = %{
      "roscoe" => %{ lat: "44.4280N", lng: "110.5885 W"},
      "smokey" => %{ lat: "48.7596N", lng: "113.7870 W"},
      "brutus" => %{ lat: "43.7904N", lng: "110.6818 W"},
      "bigfoot" =>%{ lat: "29.0469N", lng: "98.8667 W"}
    }

    Map.get(locations, wildthing)
  end
end
