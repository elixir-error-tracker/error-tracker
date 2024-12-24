defmodule ErrorTracker.Migration.Postgres.V04 do
  @moduledoc false

  use Ecto.Migration

  def up(%{prefix: prefix}) do
    alter table(:error_tracker_occurrences, prefix: prefix) do
      add :breadcrumbs, {:array, :string}, default: [], null: false
    end
  end

  def down(%{prefix: prefix}) do
    alter table(:error_tracker_occurrences, prefix: prefix) do
      remove :breadcrumbs
    end
  end
end
