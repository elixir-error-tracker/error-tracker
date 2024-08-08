import Config

config :error_tracker, ErrorTracker.Test.Repo,
  url: "ecto://postgres:postgres@127.0.0.1/error_tracker_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false

config :error_tracker, ecto_repos: [ErrorTracker.Test.Repo]

config :error_tracker, repo: ErrorTracker.Test.Repo, otp_app: :error_tracker
