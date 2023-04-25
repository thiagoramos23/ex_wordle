defmodule ExWordleWeb.WordleComponents do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  alias ExWordle.GameEngine

  def guess_row(assigns) do
    ~H"""
    <div
      id={"row-#{@row_index}"}
      class="pl-10 grid grid-cols-6 col-span-1 gap-x-0"
      data-wiggle={animate_event("animate-wiggle", "#row-#{@row_index}")}
      data-loose={animate_event("animate-loose", "#row-#{@row_index}")}
    >
      <%= for index <- 0..4 do %>
        <.guess_tile
          word={@game.word}
          guess={@guess}
          guess_char={guess_at(@guess, index)}
          row_index={@row_index}
          column_index={index}
          last_attempted_row={@game.last_attempted_row}
        />
      <% end %>
    </div>
    """
  end

  def keyboard(assigns) do
    key_states = GameEngine.key_states(assigns.game)
    assigns = assign(assigns, :key_states, key_states)

    ~H"""
    <div class="flex flex-col items-center space-y-1 md:space-y-2">
      <%= for key_line <- GameEngine.get_keyboard_lines() do %>
        <div class="flex items-center space-x-1 md:space-x-2">
          <%= for key <- key_line do %>
            <.key
              key={key}
              word={@game.word}
              attempts={@game.attempts}
              key_states={@key_states}
              last_attempted_row={@game.last_attempted_row}
            />
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp key(assigns) do
    assigns = assigns_keyboard_background_state(assigns)

    ~H"""
    <button
      phx-click="handle_key_clicked"
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

  defp assigns_keyboard_background_state(assigns) do
    result =
      Enum.find(assigns.key_states, fn {attempted_key, _state} ->
        attempted_key == assigns.key
      end)

    background_color =
      case result do
        nil ->
          "bg-gray-500"

        {_, :not_found} ->
          "bg-gray-800"

        {_, :misplaced} ->
          "bg-yellow-600"

        {_, :found} ->
          "bg-green-600"
      end

    assign(assigns, :background, background_color)
  end

  defp guess_at(guess, index) do
    guess
    |> String.split("", trim: true)
    |> Enum.at(index)
  end

  defp animate_event(event_name, element_id) do
    JS.transition(%JS{}, event_name, to: element_id, time: 500)
  end

  defp guess_tile(assigns) do
    id = "guess-tile-#{assigns.row_index}#{assigns.column_index}"

    column_state =
      if assigns.row_index < assigns.last_attempted_row do
        letter_state =
          GameEngine.letter_state(assigns.guess_char, assigns.word, assigns.column_index)

        "#{background_for_state(letter_state, assigns.guess, assigns.column_index)} text-gray-300"
      else
        "bg-transparent text-gray-900"
      end

    assigns =
      assigns
      |> assign(:column_state, column_state)
      |> assign(:id, id)

    ~H"""
    <div id={@id} class="w-16 h-16" data-event={animate_event("animate-rotate", "##{@id}")}>
      <button class={["h-16 w-16 border border-gray-400", @column_state]}>
        <span class="text-extrabold text-3xl subpixel-antialiased"><%= @guess_char %></span>
      </button>
    </div>
    """
  end

  defp background_for_state(state, guess, column_index) do
    case state do
      :found ->
        "bg-green-600"

      :misplaced ->
        "bg-yellow-600"

      :not_found ->
        if column_has_guess?(guess, column_index), do: "bg-gray-600", else: "bg-transparent"
    end
  end

  defp column_has_guess?(guess, column_index) do
    guess
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.find(fn {_guess_char, index} -> index == column_index end)
  end
end
