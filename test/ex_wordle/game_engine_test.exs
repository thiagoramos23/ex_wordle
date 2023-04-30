defmodule ExWordle.GameEngineTest do
  use ExUnit.Case

  alias ExWordle.GameEngine

  describe "new/0" do
    test "it initializes with default values" do
      assert %GameEngine{row_index: 0, keys_attempted: "", attempts: ["", "", "", "", "", ""]} =
               GameEngine.new()
    end
  end

  describe "valid_key?/1" do
    test "returns true when key is between A to Z" do
      for key <- ~w(Q W E R T Y U I O P A S D F G H J K L Z X C V B N M) do
        assert GameEngine.valid_key?(key)
      end
    end

    test "returns false when key is invalid" do
      refute GameEngine.valid_key?("1")
    end
  end

  describe "add_key_attempted/2" do
    test "add_key_attempted/2 will add a key and update the attempts state" do
      new_game = new_game()
      game = GameEngine.add_key_attempted(new_game, "K")
      assert game.keys_attempted == "K"
      assert game.attempts == ["K", "", "", "", "", ""]
    end

    test "does not add any more keys when there is already 5 key attempts" do
      new_game = new_game(%{keys_attempted: "PASTO", attempts: ["PASTO", "", "", "", "", ""]})
      game = GameEngine.add_key_attempted(new_game, "A")
      assert game.keys_attempted == "PASTO"
      assert game.attempts == ["PASTO", "", "", "", "", ""]
    end
  end

  describe "confirm_attempt/1" do
    test "will move all next key attempts to the next row" do
      new_game =
        new_game(%{
          keys_attempted: "WORDS",
          attempts: ["WORDS", "", "", "", "", ""],
          word: "TESTS"
        })

      {:ok, game} = GameEngine.confirm_attempt(new_game)
      assert game.row_index == 1
      assert game.last_attempted_row == 1
    end

    test "can't confirm when there are less than 5 key attempts in the row" do
      new_game = new_game(%{keys_attempted: "PAST", attempts: ["PAST", "", "", "", "", ""]})
      assert {:error, :row_not_completed} = GameEngine.confirm_attempt(new_game)
    end

    test "will keep state as playing when the user didn't finish the attempts nor match the word" do
      new_game =
        new_game(%{keys_attempted: "PASTE", attempts: ["PAST", "", "", "", "", ""], word: "PASTO"})

      assert new_game.state == :playing

      {:ok, game} = GameEngine.confirm_attempt(new_game)
      assert game.state == :playing
    end

    test "will set the state to win when the user hit the word" do
      new_game =
        new_game(%{keys_attempted: "WORDS", attempts: ["WORD", "", "", "", "", ""], word: "WORDS"})

      assert new_game.state == :playing

      {:ok, game} = GameEngine.confirm_attempt(new_game)
      assert game.state == :win
    end

    test "will set the state to loose when the user does not hit the word after all 6 attempts" do
      new_game =
        new_game(%{
          keys_attempted: "NESTS",
          attempts: ["PASTI", "MASTI", "TASTE", "PASTE", "TESTS", "NESTS"],
          word: "WORDS"
        })

      assert new_game.state == :playing

      {:ok, game} = GameEngine.confirm_attempt(new_game)
      assert game.state == :loose
    end
  end

  describe "remove_key_attempted/1" do
    test "remove_key_attempted/1 will remove a key from the key attempts for the active row" do
      new_game = new_game(%{keys_attempted: "PASTO", attempts: ["PASTO", "", "", "", "", ""]})
      game = GameEngine.remove_key_attempted(new_game)
      assert game.keys_attempted == "PAST"
      assert game.attempts == ["PAST", "", "", "", "", ""]
    end

    test "does nothing when there is no key to remove" do
      new_game = new_game()
      assert game = GameEngine.remove_key_attempted(new_game)
      assert new_game.keys_attempted == game.keys_attempted
      assert new_game.attempts == game.attempts
      assert new_game.row_index == game.row_index
    end
  end

  describe "key_states/1" do
    test "when the confirms attempts it gets the key states" do
      new_game = new_game(%{word: "TESTS", keys_attempted: "GUESS", attempts: ["GUESS"]})
      {:ok, game} = GameEngine.confirm_attempt(new_game)

      assert %{
               "G" => :not_found,
               "U" => :not_found,
               "E" => :misplaced,
               "S" => :found
             } = GameEngine.key_states(game)
    end
  end

  defp new_game(attrs \\ nil) do
    game = %GameEngine{
      row_index: 0,
      keys_attempted: "",
      attempts: ["", "", "", "", "", ""],
      word: "PASTO"
    }

    if attrs, do: Map.merge(game, attrs), else: game
  end
end
