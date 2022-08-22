defmodule PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  test "caches only 3 most recents pledges and their total amounts" do
    PledgeServer.start()

    # Create some pledges
    PledgeServer.create_pledge("Bob", "100")
    PledgeServer.create_pledge("Alice", "200")
    PledgeServer.create_pledge("Charlie", "300")
    PledgeServer.create_pledge("Dave", "400")
    PledgeServer.create_pledge("Eve", "500")
    PledgeServer.create_pledge("Frank", "600")

    most_recent_pledges = [{"Frank", 600}, {"Eve", 500}, {"Dave", 400}]

    # Check that the most recent pledges are cached
    assert most_recent_pledges = PledgeServer.recent_pledges()

    # Get the recent pledges
    pledges = PledgeServer.recent_pledges()
    assert_equal(3, pledges.length())
  end
end
