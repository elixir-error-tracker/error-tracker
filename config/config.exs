import Config

if config_env() == :dev do
  config :tailwind,
    version: "3.4.3",
    default: [
      args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/app.css
    ),
      cd: Path.expand("../assets", __DIR__)
    ]

  config :bun,
    version: "1.1.18",
    default: [
      args: ~w(build app.js --outdir=../../priv/static),
      cd: Path.expand("../assets/js", __DIR__),
      env: %{}
    ]
end

if config_env() == :test do
  config :error_tracker, ErrorTracker.Test.Repo,
    url: "ecto://crbelaus:@127.0.0.1/error_tracker_test",
    pool: Ecto.Adapters.SQL.Sandbox,
    log: false

  config :error_tracker, ecto_repos: [ErrorTracker.Test.Repo]

  config :error_tracker, repo: ErrorTracker.Test.Repo, otp_app: :error_tracker
end
