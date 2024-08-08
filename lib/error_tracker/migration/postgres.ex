defmodule ErrorTracker.Migration.Postgres do
  @moduledoc false

  @behaviour ErrorTracker.Migration

  use Ecto.Migration
  alias ErrorTracker.Migration.SQLMigrator

  @initial_version 1
  @current_version 2
  @default_prefix "public"

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
    configured_prefix = Application.get_env(:error_tracker, :prefix, "public")
    opts = Enum.into(opts, %{prefix: configured_prefix, version: version})

    opts
    |> Map.put_new(:create_schema, opts.prefix != @default_prefix)
    |> Map.put_new(:escaped_prefix, String.replace(opts.prefix, "'", "\\'"))
  end
end
