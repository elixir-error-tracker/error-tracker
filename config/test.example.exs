import Config

config :error_tracker, ErrorTracker.Test.Repo,
  url: "ecto://postgres:postgres@127.0.0.1/error_tracker_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false

config :error_tracker, ErrorTracker.Test.MariaDBRepo,
  url: "ecto://root:root@127.0.0.1:3306/error_tracker_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false,
  # Use the same migrations as the PostgreSQL repo
  priv: "priv/repo"

config :error_tracker, ErrorTracker.Test.MySQLRepo,
  url: "ecto://root:root@127.0.0.1:3307/error_tracker_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false,
  # Use the same migrations as the PostgreSQL repo
  priv: "priv/repo"

config :error_tracker, ErrorTracker.Test.LiteRepo,
  database: "priv/lite_repo/test.db",
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false,
  # Use the same migrations as the PostgreSQL repo
  priv: "priv/repo"

config :error_tracker, ecto_repos: [ErrorTracker.Test.Repo]

# Repo is selected in the test_helper.exs based on the given ENV vars
config :error_tracker, otp_app: :error_tracker
