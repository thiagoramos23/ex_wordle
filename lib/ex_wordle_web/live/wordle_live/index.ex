defmodule ExWordleWeb.WordleLive.Index do
  use ExWordleWeb, :live_view

  alias ExWordleWeb.ModalGameOver
  alias ExWordleWeb.WordleComponents
  alias ExWordle.StateAgent
  alias ExWordle.GameEngine
  alias ExWordle.GameServer

  @rand_size 96

  def mount(_params, session, socket) do
    socket = socket |> PhoenixLiveSession.maybe_subscribe(session) |> put_session_assigns(session)
    game = get_game_or_new(socket)

    {:ok,
     socket
     |> assign(:game, game)
     |> assign(:confirm_attempt, false)}
  end

  def handle_event("handle_keydown", %{"key" => "Backspace"}, socket) do
    game = remove_character(socket.assigns.game)
    {:noreply, socket |> assign(:game, game)}
  end

  def handle_event("handle_keydown", %{"key" => "Enter"}, socket) do
    {:noreply, confirm_attempt(socket)}
  end

  def handle_event("handle_keydown", %{"key" => key}, socket) do
    key = String.upcase(key)

    if GameEngine.valid_key?(key) do
      game = populate_attempts(socket.assigns.game, String.upcase(key))

      {:noreply,
       socket
       |> assign(:game, game)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("handle_key_clicked", %{"key" => "ENTER"}, socket) do
    {:noreply, confirm_attempt(socket)}
  end

  def handle_event("handle_key_clicked", %{"key" => "BACKSPACE"}, socket) do
    game = remove_character(socket.assigns.game)

    {:noreply,
     socket
     |> assign(:game, game)}
  end

  def handle_event("handle_key_clicked", %{"key" => key}, socket) do
    game = populate_attempts(socket.assigns.game, key)
    {:noreply, socket |> assign(:game, game)}
  end

  def handle_info({:live_session_updated, session}, socket) do
    socket = put_session_assigns(socket, session)
    StateAgent.save_game_state(socket.assigns.session_id, socket.assigns.game)
    {:noreply, socket}
  end

  defp confirm_attempt(socket) do
    game = socket.assigns.game

    %{row_id: row_id, column_ids: column_ids} = extract_row_and_column_ids(game)

    case GameEngine.confirm_attempt(game) do
      {:ok, game} ->
        socket =
          column_ids
          |> Enum.reduce(socket, fn key_id, acc ->
            acc
            |> push_event("rotate", %{id: key_id})
          end)

        socket
        |> upsert_session()
        |> assign(:game, game)

      {:error, :word_does_not_exist} ->
        socket
        |> push_event("loose", %{id: row_id})

      {:error, :row_not_completed} ->
        socket
        |> push_event("loose", %{id: row_id})

      {:error, :game_over} ->
        socket
    end
  end

  defp extract_row_and_column_ids(game) do
    row_index = extract_row_index(game)
    row_id = "row-#{row_index}"

    column_ids = [
      "guess-tile-#{row_index}0",
      "guess-tile-#{row_index}1",
      "guess-tile-#{row_index}2",
      "guess-tile-#{row_index}3",
      "guess-tile-#{row_index}4"
    ]

    %{row_id: row_id, column_ids: column_ids}
  end

  defp extract_row_index(game) do
    length_attempts =
      game.attempts
      |> Enum.reject(&(&1 == ""))
      |> Enum.count()

    length_attempts - 1
  end

  defp populate_attempts(game, key) do
    if GameEngine.valid_key?(key),
      do: GameEngine.add_key_attempted(game, key),
      else: game
  end

  defp remove_character(game) do
    GameEngine.remove_key_attempted(game)
  end

  defp get_game_or_new(socket) do
    session_id = socket.assigns.session_id
    game = StateAgent.get_game_state(session_id)
    word = GameServer.get_daily_word()

    game =
      if is_nil(game) || word != game.word do
        GameEngine.new(word)
      else
        game
      end

    game
  end

  defp put_session_assigns(socket, session) do
    socket
    |> assign(:session_id, Map.get(session, :session_id, nil))
  end

  defp upsert_session(socket) do
    PhoenixLiveSession.put_session(
      socket,
      :session_id,
      :crypto.strong_rand_bytes(@rand_size)
    )
  end
end
