defmodule ErrorTracker.Migration.Postgres do
  @moduledoc false

  @behaviour ErrorTracker.Migration

  use Ecto.Migration

  import Ecto.Query

  @initial_version 1
  @current_version 1
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
      from pg_class in "pg_class",
        left_join: pg_description in "pg_description",
        on: pg_description.objoid == pg_class.oid,
        left_join: pg_namespace in "pg_namespace",
        on: pg_namespace.oid == pg_class.relnamespace,
        where: pg_class.relname == "error_tracker_errors",
        where: pg_namespace.nspname == ^opts.escaped_prefix,
        select: pg_description.description

    case repo.one(query, log: false) do
      version when is_binary(version) -> String.to_integer(version)
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

  defp record_version(%{prefix: prefix}, version) do
    case version do
      0 -> :ok
      _other -> execute "COMMENT ON TABLE #{inspect(prefix)}.error_tracker_errors IS '#{version}'"
    end
  end

  defp with_defaults(opts, version) do
    opts = Enum.into(opts, %{prefix: @default_prefix, version: version})

    opts
    |> Map.put_new(:create_schema, opts.prefix != @default_prefix)
    |> Map.put_new(:escaped_prefix, String.replace(opts.prefix, "'", "\\'"))
  end
end
