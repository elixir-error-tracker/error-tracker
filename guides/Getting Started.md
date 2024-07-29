# Getting Started

This guide is an introduction to the ErrorTracker, an Elixir based built-in error tracking solution. The ErrorTracker provides a basic and free error-tracking solution integrated in your own application. It is designed to be easy to install and easy to use so you can integrate it in your existing project with minimal changes. The only requirement is a relational database in which errors will be tracked.

In this guide we will learn how to install the ErrorTracker in an Elixir project so you can start reporting errors as soon as possible. We will also cover more advanced topics such as how to report custom errors and how to add extra context to reported errors.

**This guide requires you to have setup Ecto with PostgreSQL beforehand.**

## Installing the ErrorTracking as a dependency

The first step add the ErrorTracker to your application is to declare the package as a dependency in your `mix.exs` file:

```elixir
# mix.exs
defp deps do
  [
    {:error_tracker, "~> 1.0"}
  ]
end
```

Once the ErrorTracker is declared as a dependency of your application, you can install it with the following command:

```bash
mix deps.get
```

## Configuring the ErrorTracker

The ErrorTracker needs a few configuration options to work. This configuration should be added in your `config/config.exs` file:

```elixir
config :error_tracker,
  repo: MyApp.Repo,
  otp_app: :my_app
```

The `:repo` option specifies the repository that will be used by the ErrorTracker. You can use your regular application repository, or a different one if you prefer to keep errors in a different database.

The `:otp_app` option specifies your application name. When an error happens the ErrorTracker will use this information to understand which parts of the stacktrace belong to your application and which parts belong to third party dependencies. This allows you to filter in-app vs third-party frames when viewing errors.

## Setting up the database

Since the ErrorTracker stores errors in the database you must create a database migration to add the required tables:

```
mix ecto.gen.migration add_error_tracker
```

Open the generated migration and call the `up` and `down` functions on `ErrorTracker.Migration`:

```elixir
defmodule MyApp.Repo.Migrations.AddErrorTracker do
  use Ecto.Migration

  def up, do: ErrorTracker.Migration.up()
  def down, do: ErrorTracker.Migration.down()
end
```

You can run the migration and perform the database changes with the following command:

```bash
mix ecto.migrate
```

For more information about how to handle migrations take a look at the `ErrorTracker.Migration` module docs.

## Automatic error tracking

At this point, the ErrorTracker is ready to track errors. It will automatically start when your application boots and track errors that happen in your Phoenix controllers, Phoenix LiveViews and Oban jobs. The `ErrorTracker.Integrations.Phoenix` and `ErrorTracker.Integrations.Oban` provide detailed information about how this works.

If your application uses Plug but not Phoenix, you will need to add the relevant integration in your `Plug.Builder` or `Plug.Router` module.

```elixir
defmodule MyApp.Router do
  use Plug.Router
  use ErrorTracker.Integrations.Plug

  # Your code here
end
```

This is also required if you want to track errors that happen in your Phoenix endpoint, before the Phoenix router starts handling the request. Keep in mind that this won't be needed in most cases as endpoint errors are very infrequent.

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

In certain cases you may want to include some additional information when tracking errors. For example it may be useful to track the user ID that was using the application when an error happened. Fortunately, the ErrorTracker allows you to enrich the default context with custom information.

The `ErrorTracker.set_context/1` function stores the given context in the current process so any errors that happen in that process (for example a Phoenix request or an Oban job) will include this given context along with the default integration context.

```elixir
ErrorTracker.set_context(%{user_id: conn.assigns.current_user.id})
```

## Manual error tracking

If you want to report custom errors that fall outside the default integrations scope you may use `ErrorTracker.report/2`. This allows you to report an exception by yourself:

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

The ErrorTracker also provides a dashboard built with Phoenix LiveView that can be used to see and manage the recorded errors.

This is completely optional and you can find more information about it in the `ErrorTracker.Web` module documentation.
