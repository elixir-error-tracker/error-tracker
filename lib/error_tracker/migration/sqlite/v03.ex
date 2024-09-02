defmodule ErrorTracker.Migration.SQLite.V03 do
  @moduledoc false

  use Ecto.Migration

  def up(_opts) do
    create_if_not_exists index(:error_tracker_errors, [:last_occurrence_at])
  end

  def down(_opts) do
    drop_if_exists index(:error_tracker_errors, [:last_occurrence_at])
  end
end
