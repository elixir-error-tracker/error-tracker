defmodule ErrorTracker.Migration.Postgres.V03 do
  @moduledoc false

  use Ecto.Migration

  def up(%{prefix: prefix}) do
    create_if_not_exists index(:error_tracker_errors, [:last_occurrence_at], prefix: prefix)
  end

  def down(%{prefix: prefix}) do
    drop_if_exists index(:error_tracker_errors, [:last_occurrence_at], prefix: prefix)
  end
end
