defmodule ErrorTracker.Plugins.Pruner do
  @moduledoc """
  Periodically delete resolved errors based on their age.

  Pruning allows you to keep your database size under control by removing old errors that are not
  needed anymore.

  ## Using the pruner

  To enable the pruner you must register the plugin in the ErrorTracker configuration. This will use
  the default options, which is to prune errors resolved after 24 hours.

      config :error_tracker,
        plugins: [ErrorTracker.Plugins.Pruner]

  You can override the default options by passing them as an argument when registering the plugin.

      config :error_tracker,
        plugins: [{ErrorTracker.Plugins.Pruner, max_age: :timer.minutes(30)}]

  ## Options

  - `:limit`  - the maximum number of errors to prune on each execution. Occurrences are removed
    along the errors. The default is 200 to prevent timeouts and unnecesary database load.

  - `:max_age` - the number of milliseconds after a resolved error may be pruned. The default is 24
    hours.

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
        use Oban.Worker

        def perform(%Job{}) do
          ErrorTracker.Plugins.Pruner.prune_errors(limit: 10_000, max_age: :timer.minutes(60))
        end
      end
  """
  use GenServer

  import Ecto.Query

  alias ErrorTracker.Error
  alias ErrorTracker.Occurrence
  alias ErrorTracker.Repo

  @doc """
  Prunes resolved errors.

  You do not need to use this function if you activate the Pruner plugin. This function is exposed
  only for advanced use cases and Oban integration.

  ## Options

  - `:limit`  - the maximum number of errors to prune on each execution. Occurrences are removed
    along the errors. The default is 200 to prevent timeouts and unnecesary database load.

  - `:max_age` - the number of milliseconds after a resolved error may be pruned. The default is 24
    hours. You may find the `:timer` module functions useful to pass readable values to this option.
  """
  @spec prune_errors(keyword()) :: {:ok, list(Error.t())}
  def prune_errors(opts \\ []) do
    limit = opts[:limit] || raise ":limit option is required"
    max_age = opts[:max_age] || raise ":max_age option is required"
    time = DateTime.add(DateTime.utc_now(), -max_age, :millisecond)

    errors =
      Repo.all(
        from error in Error,
          select: [:id, :kind, :source_line, :source_function],
          where: error.status == :resolved,
          where: error.last_occurrence_at < ^time,
          limit: ^limit
      )

    if Enum.any?(errors) do
      _pruned_occurrences_count =
        errors
        |> Ecto.assoc(:occurrences)
        |> prune_occurrences()
        |> Enum.sum()

      Repo.delete_all(from error in Error, where: error.id in ^Enum.map(errors, & &1.id))
    end

    {:ok, errors}
  end

  defp prune_occurrences(occurrences_query) do
    Stream.unfold(occurrences_query, fn occurrences_query ->
      occurrences_ids =
        Repo.all(from occurrence in occurrences_query, select: occurrence.id, limit: 1000)

      case Repo.delete_all(from o in Occurrence, where: o.id in ^occurrences_ids) do
        {0, _} -> nil
        {deleted, _} -> {deleted, occurrences_query}
      end
    end)
  end

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl GenServer
  @doc false
  def init(state \\ []) do
    state = %{
      limit: state[:limit] || 200,
      max_age: state[:max_age] || :timer.hours(24),
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
