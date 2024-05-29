defmodule ErrorTracker.Repo.Migrations.CreateErrorTrackerTables do
  use Ecto.Migration

  def change do
    create table(:error_tracker_errors) do
      add :kind, :string, null: false
      add :reason, :text, null: false
      add :source, :text, null: false
      add :status, :string, null: false
      add :fingerprint, :string, null: false

      timestamps()
    end

    create unique_index(:error_tracker_errors, :fingerprint)

    create table(:error_tracker_occurrences) do
      add :context, :map, null: false
      add :stacktrace, :map, null: false
      add :error_id, references(:error_tracker_errors, on_delete: :delete_all), null: false

      timestamps(updated_at: false)
    end

    create index(:error_tracker_occurrences, :error_id)
  end
end
