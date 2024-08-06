defmodule ErrorTracker.Migration.Postgres.V02 do
  @moduledoc false

  use Ecto.Migration

  def up(%{prefix: prefix}) do
    # For systems which executed versions without this migration they may not
    # have the error_tracker_meta table, so we need to create it conditionally
    # to avoid errors.
    create_if_not_exists table(:error_tracker_meta,
                           primary_key: [name: :key, type: :string],
                           prefix: prefix
                         ) do
      add :value, :string, null: false
    end

    execute "COMMENT ON TABLE #{inspect(prefix)}.error_tracker_errors IS ''"
  end

  def down(%{prefix: prefix}) do
    # We do not delete the `error_tracker_meta` table because it's creation and
    # deletion are controlled by V01 migration.
    execute "COMMENT ON TABLE #{inspect(prefix)}.error_tracker_errors IS '1'"
  end
end
