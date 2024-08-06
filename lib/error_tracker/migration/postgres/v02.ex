defmodule ErrorTracker.Migration.Postgres.V02 do
  @moduledoc false

  use Ecto.Migration

  def up(%{prefix: prefix}) do
    create table(:error_tracker_meta,
             primary_key: [name: :key, type: :string],
             prefix: prefix
           ) do
      add :value, :string, null: false
    end

    execute "COMMENT ON TABLE #{inspect(prefix)}.error_tracker_errors IS ''"
  end

  def down(%{prefix: prefix}) do
    drop table(:error_tracker_meta, prefix: prefix)
    execute "COMMENT ON TABLE #{inspect(prefix)}.error_tracker_errors IS '1'"
  end
end
