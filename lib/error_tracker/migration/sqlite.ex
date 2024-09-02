defmodule ErrorTracker.Migration.SQLite do
  @moduledoc false

  @behaviour ErrorTracker.Migration

  use Ecto.Migration
  alias ErrorTracker.Migration.SQLMigrator

  @initial_version 2
  @current_version 3

  @impl ErrorTracker.Migration
  def up(opts) do
    opts = with_defaults(opts, @current_version)
    SQLMigrator.migrate_up(__MODULE__, opts, @initial_version)
  end

  @impl ErrorTracker.Migration
  def down(opts) do
    opts = with_defaults(opts, @initial_version)
    SQLMigrator.migrate_down(__MODULE__, opts, @initial_version)
  end

  @impl ErrorTracker.Migration
  def current_version(opts) do
    opts = with_defaults(opts, @initial_version)
    SQLMigrator.current_version(opts)
  end

  defp with_defaults(opts, version) do
    Enum.into(opts, %{version: version})
  end
end
