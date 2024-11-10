defmodule ErrorTracker.Migration.MySQL.V04 do
  @moduledoc false

  use Ecto.Migration

  def up(_opts) do
    alter table(:error_tracker_occurrences) do
      add :breadcrumbs, :json, null: true
    end
  end

  def down(_opts) do
    alter table(:error_tracker_occurrences) do
      remove :breadcrumbs
    end
  end
end
