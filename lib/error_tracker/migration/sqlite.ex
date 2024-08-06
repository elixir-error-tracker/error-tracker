defmodule ErrorTracker.Migration.SQLite do
  @moduledoc false

  @behaviour ErrorTracker.Migration

  use Ecto.Migration

  import Ecto.Query

  @initial_version 2
  @current_version 2

  @impl ErrorTracker.Migration
  def up(opts) do
    opts = with_defaults(opts, @current_version)
    initial = current_version(opts)

    cond do
      initial == 0 -> change(@initial_version..opts.version, :up)
      initial < opts.version -> change((initial + 1)..opts.version, :up)
      true -> :ok
    end
  end

  @impl ErrorTracker.Migration
  def down(opts) do
    opts = with_defaults(opts, @initial_version)
    initial = max(current_version(opts), @initial_version)

    if initial >= opts.version do
      change(initial..opts.version, :down)
    end
  end

  @impl ErrorTracker.Migration
  def current_version(opts) do
    opts = with_defaults(opts, @initial_version)
    repo = Map.get_lazy(opts, :repo, fn -> repo() end)

    query =
      from meta in "error_tracker_meta",
        where: meta.key == "migration_version",
        select: meta.value

    with true <- meta_table_exists?(repo),
         version when is_binary(version) <- repo.one(query, log: false) do
      String.to_integer(version)
    else
      _other -> 0
    end
  end

  defp change(versions_range, direction) do
    for version <- versions_range do
      padded_version = String.pad_leading(to_string(version), 2, "0")

      migration_module = Module.concat(__MODULE__, "V#{padded_version}")
      apply(migration_module, direction, [])
    end

    case direction do
      :up -> record_version(Enum.max(versions_range))
      :down -> record_version(Enum.min(versions_range) - 1)
    end
  end

  defp record_version(0), do: :ok

  defp record_version(version) do
    execute "INSERT OR REPLACE INTO error_tracker_meta(key, value) VALUES('migration_version', '#{version}');"
  end

  defp with_defaults(opts, version) do
    Enum.into(opts, %{version: version})
  end

  defp meta_table_exists?(repo) do
    Ecto.Adapters.SQL.table_exists?(repo, "error_tracker_meta", log: false)
  end
end
