defmodule ExWordleWeb.WordleComponents do
  use Phoenix.Component

  def guess_row(assigns) do
    ~H"""
    <div class="grid grid-cols-5 gap-1">
      <%= for index <- 0..4 do %>
        <.guess_tile
          word={@word}
          guess={@guess}
          guess_char={guess_at(@guess, index)}
          row_index={@row_index}
          column_index={index}
        />
      <% end %>
    </div>
    """
  end

  def keyboard(assigns) do
    key_states = key_states(assigns.word, assigns.attempts)
    assigns = assign(assigns, :key_states, key_states)

    ~H"""
    <div class="flex flex-col items-center space-y-1 md:space-y-2">
      <%= for key_line <- key_lines() do %>
        <div class="flex items-center space-x-1 md:space-x-2">
          <%= for key <- key_line do %>
            <.key key={key} word={@word} attempts={@attempts} key_states={@key_states} />
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  # phx-click={JS.dispatch("keyboard:clicked", to: "#keyboard-input", detail: %{ key: @key })}
  defp key(assigns) do
    result =
      Enum.find(assigns.key_states, fn {attempted_key, _state} ->
        attempted_key == assigns.key
      end)

    assigns =
      case result do
        nil ->
          assign(assigns, :background, "bg-gray-500")

        {_, :not_found} ->
          assign(assigns, :background, "bg-gray-800")

        {_, :misplaced} ->
          assign(assigns, :background, "bg-yellow-600")

        {_, :found} ->
          assign(assigns, :background, "bg-green-600")
      end

    ~H"""
    <button
      phx-click="write-guess"
      phx-value-key={@key}
      class={[
        "p-4 rounded text-gray-200 text-md flex font-bold justify-center items-center uppercase focus:ring-2",
        @background
      ]}
    >
      <%= @key %>
    </button>
    """
  end

  defp key_lines do
    [
      ~w(Q W E R T Y U I O P),
      ~w(A S D F G H J K L),
      ~w(ENTER Z X C V B N M BACKSPACE)
    ]
  end

  defp guess_at(guess, index) do
    guess
    |> String.split("", trim: true)
    |> Enum.at(index)
  end

  def guess_tile(assigns) do
    letter_state = letter_state(assigns.guess_char, assigns.word, assigns.column_index)
    background_state = background_for_state(letter_state)

    assigns = assign(assigns, :background_state, background_state)

    ~H"""
    <%= if column_has_guess?(@guess, @column_index) do %>
      <button class={["h-20 w-20 border border-gray-400", @background_state]}>
        <span class="text-white text-bold text-3xl antialised"><%= @guess_char %></span>
      </button>
    <% else %>
      <button class="h-20 w-20 border border-gray-200 bg-gray-300">
        <span class="text-white text-bold text-3xl antialised"><%= @guess_char %></span>
      </button>
    <% end %>
    """
  end

  defp background_for_state(state) do
    case state do
      :found -> "bg-green-600"
      :misplaced -> "bg-yellow-600"
      _ -> "bg-gray-600"
    end
  end

  defp column_has_guess?(guess, column_index) do
    guess
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.find(fn {_guess_char, index} -> index == column_index end)
  end

  defp key_states(word, attempts) do
    for attempt <- attempts do
      attempt
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce([], fn {key_attempted, index}, acc ->
        state = letter_state(key_attempted, word, index)
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

  defp letter_state(guess_char, word, column_index) do
    letters = word |> String.split("", trim: true)

    letters
    |> Enum.with_index()
    |> Enum.reduce_while(:not_found, fn {letter, letter_index}, _acc ->
      cond do
        letter == guess_char && letter_index == column_index -> {:halt, :found}
        letter == guess_char && letter_index != column_index -> {:halt, :misplaced}
        true -> {:cont, :not_found}
      end
    end)
  end
end
