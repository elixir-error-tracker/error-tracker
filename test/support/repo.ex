defmodule ErrorTracker.Test.Repo do
  @moduledoc false
  use Ecto.Repo, otp_app: :error_tracker, adapter: Ecto.Adapters.Postgres
end
