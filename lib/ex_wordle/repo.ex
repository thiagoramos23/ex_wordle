defmodule ExWordle.Repo do
  use Ecto.Repo,
    otp_app: :ex_wordle,
    adapter: Ecto.Adapters.Postgres
end
