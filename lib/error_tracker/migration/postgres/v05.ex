defmodule ErrorTracker.Migration.Postgres.V05 do
  @moduledoc false

  use Ecto.Migration

  def up(%{prefix: prefix}) do
    alter table(:error_tracker_errors, prefix: prefix) do
      add :muted, :boolean, default: false, null: false
    end
  end

  def down(%{prefix: prefix}) do
    alter table(:error_tracker_errors, prefix: prefix) do
      remove :muted
    end
  end
end
