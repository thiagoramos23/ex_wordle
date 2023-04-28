defmodule ExWordle.StateAgent do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def save_game_state(key, session_state) do
    Agent.get_and_update(__MODULE__, fn old_state ->
      {old_state, Map.put(old_state, key, session_state)}
    end)
  end

  def get_game_state(session_id) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, session_id, nil)
    end)
  end
end
