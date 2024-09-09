defmodule ErrorTracker.Test.MySQLRepo do
  @moduledoc false
  use Ecto.Repo, otp_app: :error_tracker, adapter: Ecto.Adapters.MyXQL
end
