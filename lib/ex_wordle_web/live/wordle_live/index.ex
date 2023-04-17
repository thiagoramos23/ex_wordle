defmodule ExWordleWeb.WordleLive.Index do
  use ExWordleWeb, :live_view

  alias ExWordleWeb.WordleComponents
  alias ExWordle.Game

  def mount(_params, _session, socket) do
    game = %Game{}

    {:ok,
     socket
     |> assign(:game, game)}
  end

  def handle_event("write-guess", %{"key" => "BACKSPACE"}, socket) do
    game = remove_character(socket.assigns.game)

    {:noreply,
     socket
     |> assign(:game, game)}
  end

  def handle_event("write-guess", %{"key" => key}, socket) do
    game = populate_attempts(socket.assigns.game, key)

    {:noreply,
     socket
     |> assign(:game, game)}
  end

  defp populate_attempts(game, "ENTER") do
    Game.confirm_attempt(game)
  end

  defp populate_attempts(game, key) do
    Game.add_key_attempted(game, key)
  end

  defp remove_character(game) do
    Game.remove_key_attempted(game)
  end
end
