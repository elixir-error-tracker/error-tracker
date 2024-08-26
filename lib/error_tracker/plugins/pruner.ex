defmodule ErrorTracker.Plugins.Pruner do
  @moduledoc """
  Periodically delete resolved errors based on their age.

  Pruning allows you to keep your database size under control by removing old errors that are not
  needed anymore.

  ## Using the pruner

  To enable the pruner you must register the plugin in the ErrorTracker configuration. This will use
  the default options, which is to prune errors resolved after 5 minutes.

      config :error_tracker,
        plugins: [ErrorTracker.Plugins.Pruner]

  You can override the default options by passing them as an argument when registering the plugin.

      config :error_tracker,
        plugins: [{ErrorTracker.Plugins.Pruner, max_age: :timer.minutes(30)}]

  ## Options

  - `:limit`  - the maximum number of errors to prune on each execution. Occurrences are removed
    along the errors. The default is 1000 to prevent timeouts and unnecesary database load.

  - `:max_age` - the number of milliseconds after a resolved error may be pruned. The default is 5
    minutes.

  - `:interval` - the interval in milliseconds between pruning runs. The default is 30 minutes.

  You may find the `:timer` module functions useful to pass readable values to the `:max_age` and
  `:interval` options.

  ## Manual pruning

  In certain cases you may prefer to run the pruner manually. This can be done by calling the
  `prune_errors/2` function from your application code. This function supports the `:limit` and
  `:max_age` options as described above.

  For example, you may call this function from an Oban worker so you can leverage Oban's cron
  capabilities and have a more granular control over when pruning is run.

      defmodule MyApp.ErrorPruner do
        use Oban.Job

        def perform(%Job{}) do
          ErrorTracker.Plugins.Pruner.prune_errors(limit: 10_000, max_age: :timer.minutes(60))
        end
      end
  """
  use GenServer

  import Ecto.Query

  alias ErrorTracker.Error
  alias ErrorTracker.Repo

  @type pruned_error :: %{
          id: :integer,
          kind: String.t(),
          source_line: String.t(),
          source_function: String.t()
        }

  @doc """
  Prunes resolved errors.

  You do not need to use this function if you activate the Pruner plugin. This function is exposed
  only for advanced use cases and Oban integration.

  ## Options

  - `:limit`  - the maximum number of errors to prune on each execution. Occurrences are removed
    along the errors. The default is 1000 to prevent timeouts and unnecesary database load.

  - `:max_age` - the number of milliseconds after a resolved error may be pruned. The default is 5
    minutes. You may find the `:timer` module functions useful to pass readable values to this option.
  """
  @spec prune_errors(keyword()) :: {:ok, list(pruned_error())}
  def prune_errors(opts \\ []) do
    limit = opts[:limit] || 1000
    max_age = opts[:max_age] || :timer.minutes(5)
    time = DateTime.add(DateTime.utc_now(), max_age, :millisecond)

    to_prune_query =
      from error in Error,
        select: map(error, [:id, :kind, :source_line, :source_function]),
        where: error.status == :resolved,
        where: error.last_occurrence_at >= ^time,
        limit: ^limit

    {_count, pruned} = Repo.delete_all(to_prune_query)

    {:ok, pruned}
  end

  @impl GenServer
  @doc false
  def init(state) do
    state = %{
      limit: state[:limit] || 1000,
      max_age: state[:max_age] || :timer.minutes(5),
      interval: state[:interval] || :timer.minutes(30)
    }

    {:ok, schedule_prune(state)}
  end

  @impl GenServer
  @doc false
  def handle_info(:prune, state) do
    {:ok, _pruned} = prune_errors(state)

    {:noreply, schedule_prune(state)}
  end

  defp schedule_prune(state = %{interval: interval}) do
    Process.send_after(self(), :prune, interval)

    state
  end
end
