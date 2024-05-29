# ErrorTracker

En Elixir based built-in error tracking solution.

## Configuration

Set up the repository:

```elixir
config :error_tracker,
  repo: MyApp.Repo
```

Attach to Oban events:

```elixir
defmodule MyApp.Application do
  def start(_type, _args) do
    ErrorTracker.Integrations.Oban.attach()
  end
end
```

Attach to Plug errors:

```elixir
defmodule MyApp.Endpoint do
  use ErrorTracker.Plug
end
```
