defmodule ErrorTracker.Migration.Postgres.V01 do
  @moduledoc false

  use Ecto.Migration

  def up(%{create_schema: create_schema, prefix: prefix}) do
    if create_schema, do: execute("CREATE SCHEMA IF NOT EXISTS #{prefix}")

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

      add :error_id, references(:error_tracker_errors, on_delete: :delete_all, type: :bigserial),
        null: false

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create index(:error_tracker_occurrences, [:error_id], prefix: prefix)
  end

  def down(%{prefix: prefix}) do
    drop table(:error_tracker_occurrences, prefix: prefix)
    drop table(:error_tracker_errors, prefix: prefix)
  end
end
