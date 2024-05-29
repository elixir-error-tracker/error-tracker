defmodule ErrorTracker.Repo do
  use Ecto.Repo,
    otp_app: :error_tracker,
    adapter: Ecto.Adapters.Postgres
end
