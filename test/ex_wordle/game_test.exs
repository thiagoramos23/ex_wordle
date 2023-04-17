defmodule ExWordle.GameTest do
  use ExUnit.Case

  alias ExWordle.Game

  defp new_game() do
    %Game{row_index: 0, keys_attempted: "", attempts: ["", "", "", "", "", ""]}
  end

  describe "new/0" do
    test "it initializes with default values" do
      assert %Game{row_index: 0, keys_attempted: "", attempts: ["", "", "", "", "", ""]} =
               Game.new()
    end
  end

  describe "add_key_attempted/2" do
    test "add_key_attempted/2 will add a key and update the attempts state" do
      new_game = new_game()
      game = Game.add_key_attempted(new_game, "K")
      assert game.keys_attempted == "K"
      assert game.attempts == ["K", "", "", "", "", ""]
    end

    test "does not add any more keys when there is already 5 key attempts" do
      new_game = new_game()
      new_game = %{new_game | keys_attempted: "PASTO", attempts: ["PASTO", "", "", "", "", ""]}
      game = Game.add_key_attempted(new_game, "A")
      assert game.keys_attempted == "PASTO"
      assert game.attempts == ["PASTO", "", "", "", "", ""]
    end
  end

  describe "confirm_attempt/1" do
    test "will move all next key attempts to the next row" do
    end

    test "can't confirm when there are less than 5 key attempts in the row" do
    end
  end

  describe "remove_key_attempted/1" do
    test "remove_key_attempted/1 will remove a key from the key attempts for the active row" do
    end

    test "does nothing when there is no key to remove" do
    end
  end
end
