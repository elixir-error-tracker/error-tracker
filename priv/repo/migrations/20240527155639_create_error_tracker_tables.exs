defmodule ErrorTracker.Repo.Migrations.CreateErrorTrackerTables do
  use Ecto.Migration

  defdelegate up, to: ErrorTracker.Migration
  defdelegate down, to: ErrorTracker.Migration
end
