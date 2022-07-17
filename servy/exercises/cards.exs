defmodule Cards do
  @ranks ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

  @suits ["♣", "♦", "♥", "♠"]

  def create_deck do
    for rank <- @ranks, suit <- @suits do
      {rank, suit}
    end
  end

  def shuffle_cards do
    create_deck()
    |> Enum.shuffle()
    |> Enum.chunk_every(13)
  end
end
