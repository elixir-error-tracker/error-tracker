defmodule ErrorTracker.Test.LiteRepo do
  @moduledoc false
  use Ecto.Repo, otp_app: :error_tracker, adapter: Ecto.Adapters.SQLite3
end
