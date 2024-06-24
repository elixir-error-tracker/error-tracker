defmodule ErrorTracker.DevRepo do
  use Ecto.Repo,
    otp_app: :error_tracker,
    adapter: Ecto.Adapters.Postgres

  def setup_database do
    _ = Ecto.Adapters.Postgres.storage_up(__MODULE__.config())

    Ecto.Migrator.run(__MODULE__, [{0, Migration0}], :up,
      all: true,
      log_migrations_sql: :debug
    )
  end
end

defmodule Migration0 do
  use Ecto.Migration

  def up, do: ErrorTracker.Migrations.up(prefix: "private")
  def down, do: ErrorTracker.Migrations.down(prefix: "private")
end
