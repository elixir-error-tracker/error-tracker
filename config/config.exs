import Config

config :error_tracker, ErrorTracker.Repo,
  name: ErrorTracker.Repo,
  priv: "test/support/repo",
  stacktrace: true,
  url:
    System.get_env("DATABASE_URL") ||
      "postgres://postgres:postgres@localhost:5432/error_tracker_test"

config :error_tracker, ecto_repos: [ErrorTracker.Repo]
