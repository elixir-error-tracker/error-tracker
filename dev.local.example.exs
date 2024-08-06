# PostgreSQL adapter
#
# To use SQLite3 on your local development machine uncomment these lines and
# comment the lines of other adapters.

Application.put_env(:error_tracker, :ecto_adapter, :postgres)

Application.put_env(
  :error_tracker,
  ErrorTrackerDev.Repo,
  url: "ecto://postgres:postgres@127.0.0.1/error_tracker_dev"
)

# SQlite3 adapter
#
# To use SQLite3 on your local development machine uncomment these lines and
# comment the lines of other adapters.

# Application.put_env(:error_tracker, :ecto_adapter, :sqlite3)

# sqlite_db = System.get_env("SQLITE_DB") || "dev.db"
# Application.put_env(:error_tracker, ErrorTrackerDev.Repo, database: sqlite_db)
