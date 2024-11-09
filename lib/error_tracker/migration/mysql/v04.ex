defmodule ErrorTracker.Migration.MySQL.V04 do
  @moduledoc false

  use Ecto.Migration

  def change(_opts) do
    alter table(:error_tracker_occurrences) do
      add :bread_crumbs, {:array, :string}, default: [], null: false
    end
  end
end
