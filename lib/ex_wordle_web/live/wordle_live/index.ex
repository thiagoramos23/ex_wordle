defmodule ExWordleWeb.WordleLive.Index do
  use ExWordleWeb, :live_view

  alias ExWordleWeb.WordleComponents
  alias ExWordle.GameEngine

  def mount(_params, _session, socket) do
    game = %GameEngine{word: "PASTO"}

    {:ok,
     socket
     |> assign(:game, game)}
  end

  def handle_event("handle_keydown", %{"key" => "Backspace"}, socket) do
    game = remove_character(socket.assigns.game)
    {:noreply, socket |> assign(:game, game)}
  end

  def handle_event("handle_keydown", %{"key" => "Enter"}, socket) do
    {:noreply, confirm_attempt(socket)}
  end

  def handle_event("handle_keydown", %{"key" => key}, socket) do
    game = populate_attempts(socket.assigns.game, String.upcase(key))
    {:noreply, socket |> assign(:game, game)}
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

  defp confirm_attempt(socket) do
    case GameEngine.confirm_attempt(socket.assigns.game) do
      {:ok, game} ->
        socket |> assign(:game, game)

      {:error, _} ->
        socket |> put_flash(:error, "Still missing some keys")
    end
  end

  defp populate_attempts(game, key) do
    GameEngine.add_key_attempted(game, key)
  end

  defp remove_character(game) do
    GameEngine.remove_key_attempted(game)
  end
end
