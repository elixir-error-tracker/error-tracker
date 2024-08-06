defmodule ErrorTracker.Migration.Postgres.V01 do
  @moduledoc false

  use Ecto.Migration

  import Ecto.Query

  def up(opts = %{create_schema: create_schema, prefix: prefix}) do
    # Prior to V02 the migration version was stored in table comments.
    # As of now the migration version is stored in a new table (created in V02).
    #
    # However, systems migrating to V02 may think they need to run V01 too, so
    # we need to check for the legacy version storage to avoid running this
    # migration twice.
    if current_version_legacy(opts) == 0 do
      if create_schema, do: execute("CREATE SCHEMA IF NOT EXISTS #{prefix}")

      create table(:error_tracker_meta,
               primary_key: [name: :key, type: :string],
               prefix: prefix
             ) do
        add :value, :string, null: false
      end

      create table(:error_tracker_errors,
               primary_key: [name: :id, type: :bigserial],
               prefix: prefix
             ) do
        add :kind, :string, null: false
        add :reason, :text, null: false
        add :source_line, :text, null: false
        add :source_function, :text, null: false
        add :status, :string, null: false
        add :fingerprint, :string, null: false
        add :last_occurrence_at, :utc_datetime_usec, null: false

        timestamps(type: :utc_datetime_usec)
      end

      create unique_index(:error_tracker_errors, [:fingerprint], prefix: prefix)

      create table(:error_tracker_occurrences,
               primary_key: [name: :id, type: :bigserial],
               prefix: prefix
             ) do
        add :context, :map, null: false
        add :reason, :text, null: false
        add :stacktrace, :map, null: false

        add :error_id,
            references(:error_tracker_errors, on_delete: :delete_all, type: :bigserial),
            null: false

        timestamps(type: :utc_datetime_usec, updated_at: false)
      end

      create index(:error_tracker_occurrences, [:error_id], prefix: prefix)
    else
      :noop
    end
  end

  def down(%{prefix: prefix}) do
    drop table(:error_tracker_occurrences, prefix: prefix)
    drop table(:error_tracker_errors, prefix: prefix)
    drop_if_exists table(:error_tracker_meta, prefix: prefix)
  end

  def current_version_legacy(opts) do
    query =
      from pg_class in "pg_class",
        left_join: pg_description in "pg_description",
        on: pg_description.objoid == pg_class.oid,
        left_join: pg_namespace in "pg_namespace",
        on: pg_namespace.oid == pg_class.relnamespace,
        where: pg_class.relname == "error_tracker_errors",
        where: pg_namespace.nspname == ^opts.escaped_prefix,
        select: pg_description.description

    case repo().one(query, log: false) do
      version when is_binary(version) -> String.to_integer(version)
      _other -> 0
    end
  end
end
