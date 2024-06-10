# ErrorTracker

En Elixir based built-in error tracking solution.

## Configuration

Set up the repository:

```elixir
config :error_tracker,
  repo: MyApp.Repo
```

And you are ready to go!

By default Phoenix and Oban integrations will start registering exceptions.

If you want to also catch exceptions before your Phoenix Router (in plugs used
on your Endpoint) or your application just use `Plug` but not `Phoenix`, you can
attach to those errors with:

```elixir
defmodule MyApp.Endpoint do
  use ErrorTracker.Integrations.Plug
end
```
