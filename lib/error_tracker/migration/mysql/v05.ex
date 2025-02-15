defmodule ErrorTracker.Migration.MySQL.V05 do
  @moduledoc false

  use Ecto.Migration

  def up(_opts) do
    alter table(:error_tracker_errors) do
      add :muted, :boolean, default: false, null: false
    end
  end

  def down(_opts) do
    alter table(:error_tracker_errors) do
      remove :muted
    end
  end
end
