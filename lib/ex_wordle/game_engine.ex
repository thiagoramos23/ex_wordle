defmodule ExWordle.GameEngine do
  defstruct row_index: 0, keys_attempted: "", attempts: ["", "", "", "", "", ""], word: ""

  @keyboard_lines [
    ~w(Q W E R T Y U I O P),
    ~w(A S D F G H J K L),
    ~w(ENTER Z X C V B N M BACKSPACE)
  ]

  def new() do
    __struct__()
  end

  def get_keyboard_lines, do: @keyboard_lines

  def confirm_attempt(game) do
    if valid_attempt?(game) do
      {:ok,
       %{
         game
         | attempts: update_attempts(game, game.keys_attempted),
           row_index: game.row_index + 1,
           keys_attempted: ""
       }}
    else
      {:error, :row_not_completed}
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

  def key_states(game) do
    for attempt <- game.attempts do
      attempt
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce([], fn {key_attempted, index}, acc ->
        state = letter_state(key_attempted, game.word, index)
        [{key_attempted, state} | acc]
      end)
    end
    |> List.flatten()
    |> Enum.reduce(Map.new(), fn {key, state}, acc ->
      case state do
        :found ->
          Map.put(acc, key, :found)

        :misplaced ->
          Map.update(acc, key, :misplaced, fn value ->
            if value == :found, do: value, else: :misplaced
          end)

        :not_found ->
          Map.put_new(acc, key, :not_found)
      end
    end)
  end

  def letter_state(guess_char, word, column_index) do
    cond do
      guess_char == String.at(word, column_index) -> :found
      guess_char in String.graphemes(word) -> :misplaced
      true -> :not_found
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
