defmodule ErrorTracker.Migration.SQLMigrator do
  @moduledoc false

  use Ecto.Migration

  import Ecto.Query

  def migrate_up(migrator, opts, initial_version) do
    initial = current_version(opts)

    cond do
      initial == 0 ->
        change(migrator, initial_version..opts.version, :up, opts)

      initial < opts.version ->
        change(migrator, (initial + 1)..opts.version, :up, opts)

      true ->
        :ok
    end
  end

  def migrate_down(migrator, opts, initial_version) do
    initial = max(current_version(opts), initial_version)

    if initial >= opts.version do
      change(migrator, initial..opts.version//-1, :down, opts)
    end
  end

  def current_version(opts) do
    repo = Map.get_lazy(opts, :repo, fn -> repo() end)

    query =
      from meta in "error_tracker_meta",
        where: meta.key == "migration_version",
        select: meta.value

    with true <- meta_table_exists?(repo, opts),
         version when is_binary(version) <- repo.one(query, log: false, prefix: opts[:prefix]) do
      String.to_integer(version)
    else
      _other -> 0
    end
  end

  defp change(migrator, versions_range, direction, opts) do
    for version <- versions_range do
      padded_version = String.pad_leading(to_string(version), 2, "0")

      migration_module = Module.concat(migrator, "V#{padded_version}")
      apply(migration_module, direction, [opts])
    end

    case direction do
      :up -> record_version(opts, Enum.max(versions_range))
      :down -> record_version(opts, Enum.min(versions_range) - 1)
    end
  end

  defp record_version(_opts, 0), do: :ok

  defp record_version(opts, version) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()

    ErrorTracker.Repo.with_adapter(fn
      :postgres ->
        prefix = opts[:prefix]

        execute """
        INSERT INTO #{prefix}.error_tracker_meta (key, value)
        VALUES ('migration_version', '#{version}'), ('migration_timestamp', '#{timestamp}')
        ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value
        """

      :mysql ->
        execute """
        INSERT INTO error_tracker_meta (`key`, value)
        VALUES ('migration_version', '#{version}'), ('migration_timestamp', '#{timestamp}')
        ON DUPLICATE KEY UPDATE value = VALUES(value)
        """

      _other ->
        execute """
        INSERT INTO error_tracker_meta (key, value)
        VALUES ('migration_version', '#{version}'), ('migration_timestamp', '#{timestamp}')
        ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value
        """
    end)
  end

  defp meta_table_exists?(repo, opts) do
    ErrorTracker.Repo.with_adapter(fn
      :postgres ->
        Ecto.Adapters.SQL.query!(
          repo,
          "SELECT TRUE FROM information_schema.tables WHERE table_name = 'error_tracker_meta' AND table_schema = $1",
          [opts.prefix],
          log: false
        )
        |> Map.get(:rows)
        |> Enum.any?()

      _other ->
        Ecto.Adapters.SQL.table_exists?(repo, "error_tracker_meta", log: false)
    end)
  end
end
