defmodule ExWordle.GameServer do
  use GenServer
  require Logger

  alias ExWordle.Constants

  def start_link(initial_state) do
    Logger.info("Game Server started")
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def get_daily_word do
    GenServer.call(__MODULE__, :get_word)
  end

  def init(initial_state) do
    schedule_work()
    {:ok, initial_state, {:continue, :set_word}}
  end

  def handle_call(:get_word, _from, %{word: word} = state) do
    {:reply, word, state}
  end

  def handle_continue(:set_word, _state) do
    {:noreply, %{date: Date.utc_today(), word: get_word()}}
  end

  def handle_info(:check_new_day, state) do
    updated_state =
      if state.date != Date.utc_today() do
        %{date: Date.utc_today(), word: get_word()}
      else
        state
      end

    schedule_work()
    Logger.info("Word updated: #{updated_state}")
    {:noreply, updated_state}
  end

  defp schedule_work do
    Process.send_after(self(), :check_new_day, 60_000)
  end

  defp get_word do
    Constants.words()
    |> Enum.random()
  end
end
