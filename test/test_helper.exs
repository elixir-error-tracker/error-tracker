# Use the appropriate repo for the desired database
repo =
  case System.get_env("DB") do
    "sqlite" -> ErrorTracker.Test.LiteRepo
    "postgres" -> ErrorTracker.Test.Repo
    _other -> raise "Please run either `DB=sqlite mix test` or `DB=postgres mix test`"
  end

Application.put_env(:error_tracker, :repo, repo)

# Create the database and start the repo
repo.__adapter__().storage_up(repo.config())
repo.start_link()

# Run migrations
Ecto.Migrator.run(repo, :up, all: true, log_migrations_sql: false, log: false)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(repo, :manual)
