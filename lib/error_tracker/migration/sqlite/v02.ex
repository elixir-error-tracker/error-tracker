defmodule ErrorTracker.Migration.SQLite.V02 do
  @moduledoc false

  use Ecto.Migration

  def up do
    create table(:error_tracker_meta, primary_key: [name: :key, type: :string]) do
      add :value, :string, null: false
    end

    create table(:error_tracker_errors, primary_key: [name: :id, type: :bigserial]) do
      add :kind, :string, null: false
      add :reason, :text, null: false
      add :source_line, :text, null: false
      add :source_function, :text, null: false
      add :status, :string, null: false
      add :fingerprint, :string, null: false
      add :last_occurrence_at, :utc_datetime_usec, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:error_tracker_errors, [:fingerprint])

    create table(:error_tracker_occurrences, primary_key: [name: :id, type: :bigserial]) do
      add :context, :map, null: false
      add :reason, :text, null: false
      add :stacktrace, :map, null: false

      add :error_id, references(:error_tracker_errors, on_delete: :delete_all, type: :bigserial),
        null: false

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create index(:error_tracker_occurrences, [:error_id])
  end

  def down do
    drop table(:error_tracker_occurrences)
    drop table(:error_tracker_errors)
    drop table(:error_tracker_meta)
  end
end
