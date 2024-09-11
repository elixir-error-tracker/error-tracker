# Getting Started

This guide is an introduction to ErrorTracker, an Elixir-based built-in error tracking solution. ErrorTracker provides a basic and free error-tracking solution integrated in your own application. It is designed to be easy to install and easy to use so you can integrate it in your existing project with minimal changes. The only requirement is a relational database in which errors will be tracked.

In this guide we will learn how to install ErrorTracker in an Elixir project so you can start reporting errors as soon as possible. We will also cover more advanced topics such as how to report custom errors and how to add extra context to reported errors.

**This guide requires you to have set up Ecto with PostgreSQL, MySQL/MariaDB or SQLite3 beforehand.**

## Installing ErrorTracker as a dependency

The first step to add ErrorTracker to your application is to declare the package as a dependency in your `mix.exs` file:

```elixir
# mix.exs
defp deps do
  [
    {:error_tracker, "~> 0.3"}
  ]
end
```

Once ErrorTracker is declared as a dependency of your application, you can install it with the following command:

```bash
mix deps.get
```

## Configuring ErrorTracker

ErrorTracker needs a few configuration options to work. This configuration should be added to your `config/config.exs` file:

```elixir
config :error_tracker,
  repo: MyApp.Repo,
  otp_app: :my_app,
  enabled: true
```

The `:repo` option specifies the repository that will be used by ErrorTracker. You can use your regular application repository or a different one if you prefer to keep errors in a different database.

The `:otp_app` option specifies your application name. When an error occurs, ErrorTracker will use this information to understand which parts of the stack trace belong to your application and which parts belong to third-party dependencies. This allows you to filter in-app vs third-party frames when viewing errors.

The `:enabled` option (defaults to `true` if not present) allows to disable the ErrorTracker on certain environments. This is useful to avoid filling your dev database with errors, for example.

## Setting up the database

Since ErrorTracker stores errors in the database you must create a database migration to add the required tables:

```
mix ecto.gen.migration add_error_tracker
```

Open the generated migration and call the `up` and `down` functions on `ErrorTracker.Migration`:

```elixir
defmodule MyApp.Repo.Migrations.AddErrorTracker do
  use Ecto.Migration

  def up, do: ErrorTracker.Migration.up(version: 3)

  # We specify `version: 1` in `down`, to ensure we remove all migrations.
  def down, do: ErrorTracker.Migration.down(version: 1)
end
```

You can run the migration and apply the database changes with the following command:

```bash
mix ecto.migrate
```

For more information about how to handle migrations, take a look at the `ErrorTracker.Migration` module docs.

## Automatic error tracking

At this point, ErrorTracker is ready to track errors. It will automatically start when your application boots and track errors that occur in your Phoenix controllers, Phoenix LiveViews and Oban jobs. The `ErrorTracker.Integrations.Phoenix` and `ErrorTracker.Integrations.Oban` provide detailed information about how this works.

If your application uses Plug but not Phoenix, you will need to add the relevant integration in your `Plug.Builder` or `Plug.Router` module.

```elixir
defmodule MyApp.Router do
  use Plug.Router
  use ErrorTracker.Integrations.Plug

  # Your code here
end
```

This is also required if you want to track errors that happen in your Phoenix endpoint, before the Phoenix router starts handling the request. Keep in mind that this won't be needed in most cases as endpoint errors are infrequent.

```elixir
defmodule MyApp.Endpoint do
  use Phoenix.Endpoint
  use ErrorTracker.Integrations.Plug

  # Your code here
end
```

You can learn more about this in the `ErrorTracker.Integrations.Plug` module documentation.

## Error context

The default integrations include some additional context when tracking errors. You can take a look at the relevant integration modules to see what is being tracked out of the box.

In certain cases, you may want to include some additional information when tracking errors. For example it may be useful to track the user ID that was using the application when an error happened. Fortunately, ErrorTracker allows you to enrich the default context with custom information.

The `ErrorTracker.set_context/1` function stores the given context in the current process so any errors that occur in that process (for example, a Phoenix request or an Oban job) will include this given context along with the default integration context.

```elixir
ErrorTracker.set_context(%{user_id: conn.assigns.current_user.id})
```

There are some requirements on the type of data that can be included in the context, so we recommend taking a look at `set_context/1` documentation

## Manual error tracking

If you want to report custom errors that fall outside the default integration scope, you may use `ErrorTracker.report/2`. This allows you to report an exception yourself:

```elixir
try do
  # your code
catch
  e ->
    ErrorTracker.report(e, __STACKTRACE__)
end
```

You can also use `ErrorTracker.report/3` and set some custom context that will be included along with the reported error.

## Web UI

ErrorTracker also provides a dashboard built with Phoenix LiveView that can be used to see and manage the recorded errors.

This is completely optional, and you can find more information about it in the `ErrorTracker.Web` module documentation.

## Notifications

Currently ErrorTracker does not support notifications out of the box.

However, it provides some detailed Telemetry events that you may use to implement your own notifications following your custom rules and notification channels.

If you want to take a look at the events you can attach to, take a look at `ErrorTracker.Telemetry` module documentation.

## Pruning resolved errors

By default errors are kept in the database indefinitely. This is not ideal for production
environments where you may want to prune old errors that have been resolved.

The `ErrorTracker.Plugins.Pruner` module provides automatic pruning functionality with a configurable
interval and error age.

## Ignoring errors

ErrorTracker tracks every error by default. In certain cases some errors may be expected or just not interesting to track.
ErrorTracker provides functionality that allows you to ignore errors based on their attributes and context.

Take a look at the `ErrorTracker.Ignorer` behaviour for more information about how to implement your own ignorer.
