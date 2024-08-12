import Config

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

# PostgreSQL adapter
#
# To use SQLite3 on your local development machine uncomment these lines and
# comment the lines of other adapters.

config :error_tracker, :ecto_adapter, :postgres

config :error_tracker, ErrorTrackerDev.Repo,
  url: "ecto://postgres:postgres@127.0.0.1/error_tracker_dev"

# SQlite3 adapter
#
# To use SQLite3 on your local development machine uncomment these lines and
# comment the lines of other adapters.

# config :error_tracker, :ecto_adapter, :sqlite3

# config :error_tracker, ErrorTrackerDev.Repo,
#   database: System.get_env("SQLITE_DB") || "dev.db"
