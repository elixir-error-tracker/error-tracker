defmodule ErrorTracker.Migration do
  @moduledoc """
  Create and modify the database tables for ErrorTracker.

  ## Usage

  To use ErrorTracker migrations in your application you will need to generate
  a regular `Ecto.Migration` that performs the relevant calls to `ErrorTracker.Migration`.

  ```bash
  mix ecto.gen.migration add_error_tracker
  ```

  Open the generated migration file and call the `up` and `down` functions on
  `ErrorTracker.Migration`.

  ```elixir
  defmodule MyApp.Repo.Migrations.AddErrorTracker do
    use Ecto.Migration

    def up, do: ErrorTracker.Migration.up()
    def down, do: ErrorTracker.Migration.down()
  end
  ```

  This will run every ErrorTracker migration for your database. You can now run the migration
  and perform the database changes:

  ```bash
  mix ecto.migrate
  ```

  As new versions of ErrorTracker are released you may need to run additional migrations.
  To do this you can follow the previous process and create a new migration:

  ```bash
  mix ecto.gen.migration update_error_tracker_to_vN
  ```

  Open the generated migration file and call the `up` and `down` functions on the
  `ErrorTracker.Migration` passing the desired `version`.

  ```elixir
  defmodule MyApp.Repo.Migrations.UpdateErrorTrackerToVN do
    use Ecto.Migration

    def up, do: ErrorTracker.Migration.up(version: N)
    def down, do: ErrorTracker.Migration.down(version: N)
  end
  ```

  Then run the migrations to perform the database changes:

  ```bash
  mix ecto.migrate
  ```

  ## Custom prefix - PostgreSQL only

  ErrorTracker supports namespacing its own tables using PostgreSQL schemas, also known
  as "prefixes" in Ecto. With prefixes your error tables can reside outside of your primary
  schema (which is usually named "public").

  To use a prefix you need to specify it in your configuration:

  ```elixir
  config :error_tracker, :prefix, "custom_prefix"
  ```

  Migrations will automatically create the database schema for you. If the schema does already exist
  the migration may fail when trying to recreate it. In such cases you can instruct ErrorTracker
  not to create the schema again:

  ```elixir
  defmodule MyApp.Repo.Migrations.AddErrorTracker do
    use Ecto.Migration

    def up, do: ErrorTracker.Migration.up(create_schema: false)
    def down, do: ErrorTracker.Migration.down()
  end
  ```

  You can also override the configured prefix in the migration:

  ```elixir
  defmodule MyApp.Repo.Migrations.AddErrorTracker do
    use Ecto.Migration

    def up, do: ErrorTracker.Migration.up(prefix: "custom_prefix")
    def down, do: ErrorTracker.Migration.down(prefix: "custom_prefix")
  end
  ```
  """

  @callback up(Keyword.t()) :: :ok
  @callback down(Keyword.t()) :: :ok
  @callback current_version(Keyword.t()) :: non_neg_integer()

  def up(opts \\ []) when is_list(opts) do
    migrator().up(opts)
  end

  def down(opts \\ []) when is_list(opts) do
    migrator().down(opts)
  end

  def migrated_version(opts \\ []) when is_list(opts) do
    migrator().migrated_version(opts)
  end

  defp migrator do
    case ErrorTracker.Repo.__adapter__() do
      Ecto.Adapters.Postgres -> ErrorTracker.Migration.Postgres
      Ecto.Adapters.SQLite3 -> ErrorTracker.Migration.SQLite
      adapter -> raise "ErrorTracker does not support #{adapter}"
    end
  end
end
