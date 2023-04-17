defmodule ExWordle.Game do
  defstruct row_index: 0, keys_attempted: "", attempts: ["", "", "", "", "", ""]

  def new() do
    __struct__()
  end

  def confirm_attempt(game) do
    if valid_attempt?(game) do
      %{
        game
        | attempts: update_attempts(game, game.keys_attempted),
          row_index: game.row_index + 1,
          keys_attempted: ""
      }
    else
      game
    end
  end

  def add_key_attempted(game, key) do
    updated_keys_attempted = "#{game.keys_attempted}#{key}"

    if String.length(game.keys_attempted) < 5 do
      %{
        game
        | attempts: update_attempts(game, updated_keys_attempted),
          keys_attempted: updated_keys_attempted
      }
    else
      game
    end
  end

  def remove_key_attempted(game) do
    keys_size = String.length(game.keys_attempted)

    if keys_size == 0 do
      game
    else
      index = keys_size - 1

      updated_keys_attempted =
        game.keys_attempted
        |> String.graphemes()
        |> List.delete_at(index)
        |> Enum.join()

      %{
        game
        | attempts: update_attempts(game, updated_keys_attempted),
          keys_attempted: updated_keys_attempted
      }
    end
  end

  defp valid_attempt?(game) do
    String.length(game.keys_attempted) == 5
  end

  defp update_attempts(game, updated_keys_attempted) do
    game.attempts
    |> List.replace_at(game.row_index, updated_keys_attempted)
  end
end
