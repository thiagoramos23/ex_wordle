defmodule ExWordle.GameEngine do
  defstruct attempts: ["", "", "", "", "", ""],
            keys_attempted: "",
            key_states: %{},
            last_attempted_row: 0,
            row_index: 0,
            state: :playing,
            word: ""

  @valid_keys ~w(Q W E R T Y U I O P A S D F G H J K L Z X C V B N M)
  @keyboard_lines [
    ~w(Q W E R T Y U I O P),
    ~w(A S D F G H J K L),
    ~w(ENTER Z X C V B N M BACKSPACE)
  ]

  def new(word) do
    game = __struct__()
    %{game | word: String.upcase(word)}
  end

  def valid_key?(key), do: key in @valid_keys

  def get_keyboard_lines, do: @keyboard_lines

  def confirm_attempt(%{state: state}) when state != :playing, do: {:error, :game_over}

  def confirm_attempt(game) do
    case valid_attempt?(game) do
      :ok ->
        game =
          update_game_state(game, %{
            attempts: get_attempts(game, game.keys_attempted),
            last_attempted_row: game.row_index + 1,
            row_index: game.row_index + 1,
            keys_attempted: "",
            key_states: get_key_states(game)
          })

        game = check_win(game)
        {:ok, game}

      {:error, message} ->
        {:error, message}
    end
  end

  def add_key_attempted(%{state: state} = game, _) when state != :playing, do: game

  def add_key_attempted(game, key) do
    updated_keys_attempted = "#{game.keys_attempted}#{key}"

    if String.length(game.keys_attempted) < 5 do
      update_game_state(
        game,
        %{
          attempts: get_attempts(game, updated_keys_attempted),
          keys_attempted: updated_keys_attempted
        }
      )
    else
      game
    end
  end

  def remove_key_attempted(%{state: state} = game, _) when state != :playing, do: game

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

      update_game_state(game, %{
        attempts: get_attempts(game, updated_keys_attempted),
        keys_attempted: updated_keys_attempted
      })
    end
  end

  def key_states(game), do: game.key_states

  def letter_state(guess_char, word, column_index) do
    cond do
      guess_char == String.at(word, column_index) -> :found
      guess_char in String.graphemes(word) -> :misplaced
      true -> :not_found
    end
  end

  def win?(game), do: game.state == :win

  defp get_key_states(game) do
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

  defp check_win(game) do
    cond do
      match_the_word(game) ->
        update_game_state(game, %{state: :win})

      number_of_plays(game) == 6 && !match_the_word(game) ->
        update_game_state(game, %{state: :loose})

      true ->
        update_game_state(game, %{state: :playing})
    end
  end

  defp match_the_word(game), do: Enum.any?(game.attempts, &(&1 == game.word))
  defp number_of_plays(game), do: game.attempts |> Enum.reject(&(&1 == "")) |> Enum.count()

  defp valid_attempt?(game) do
    attempt = String.downcase(game.keys_attempted)

    cond do
      String.length(attempt) < 5 -> {:error, :row_not_completed}
      attempt not in ExWordle.Constants.words() -> {:error, :word_does_not_exist}
      true -> :ok
    end
  end

  defp get_attempts(game, updated_keys_attempted) do
    game.attempts
    |> List.replace_at(game.row_index, updated_keys_attempted)
  end

  defp update_game_state(game, attrs) do
    Map.merge(game, attrs)
  end
end
