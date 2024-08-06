defmodule ErrorTracker.Migration.Postgres do
  @moduledoc false

  @behaviour ErrorTracker.Migration

  use Ecto.Migration

  import Ecto.Query

  @initial_version 1
  @current_version 2
  @default_prefix "public"

  @impl ErrorTracker.Migration
  def up(opts) do
    opts = with_defaults(opts, @current_version)
    initial = current_version(opts)

    cond do
      initial == 0 ->
        change(@initial_version..opts.version, :up, opts)

      initial < opts.version ->
        change((initial + 1)..opts.version, :up, opts)

      true ->
        :ok
    end
  end

  @impl ErrorTracker.Migration
  def down(opts) do
    opts = with_defaults(opts, @initial_version)
    initial = max(current_version(opts), @initial_version)

    if initial >= opts.version do
      change(initial..opts.version, :down, opts)
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

    with true <- meta_table_exists?(repo, opts),
         version when is_binary(version) <- repo.one(query, log: false, prefix: opts[:prefix]) do
      String.to_integer(version)
    else
      _other -> 0
    end
  end

  defp change(versions_range, direction, opts) do
    for version <- versions_range do
      padded_version = String.pad_leading(to_string(version), 2, "0")

      migration_module = Module.concat(__MODULE__, "V#{padded_version}")
      apply(migration_module, direction, [opts])
    end

    case direction do
      :up -> record_version(opts, Enum.max(versions_range))
      :down -> record_version(opts, Enum.min(versions_range) - 1)
    end
  end

  defp record_version(_opts, 0), do: :ok

  defp record_version(%{prefix: prefix}, version) do
    execute """
    INSERT INTO #{prefix}.error_tracker_meta (key, value) VALUES ('migration_version', '#{version}')
    ON CONFLICT (key) DO UPDATE SET value = '#{version}'
    """
  end

  defp with_defaults(opts, version) do
    opts = Enum.into(opts, %{prefix: @default_prefix, version: version})

    opts
    |> Map.put_new(:create_schema, opts.prefix != @default_prefix)
    |> Map.put_new(:escaped_prefix, String.replace(opts.prefix, "'", "\\'"))
  end

  defp meta_table_exists?(repo, opts) do
    Ecto.Adapters.SQL.query!(
      repo,
      "SELECT TRUE FROM information_schema.tables WHERE table_name = 'error_tracker_meta' AND table_schema = $1",
      [opts.prefix],
      log: false
    )
    |> Map.get(:rows)
    |> Enum.any?()
  end
end
