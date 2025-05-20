defmodule ErrorTracker.Test.MariaDBRepo do
  @moduledoc false
  use Ecto.Repo, otp_app: :error_tracker, adapter: Ecto.Adapters.MyXQL
end
