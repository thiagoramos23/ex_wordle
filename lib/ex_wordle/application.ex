defmodule ExWordle.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ExWordleWeb.Telemetry,
      # Start the Ecto repository
      ExWordle.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ExWordle.PubSub},
      # Start Finch
      {Finch, name: ExWordle.Finch},
      # Start the Endpoint (http/https)
      ExWordleWeb.Endpoint,
      # Start a worker by calling: ExWordle.Worker.start_link(arg)
      # {ExWordle.Worker, arg}
      {ExWordle.StateAgent, name: ExWordle.StateAgent}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExWordle.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExWordleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
