defmodule ErrorTracker do
  @moduledoc """
  En Elixir based built-in error tracking solution.
  """

  @typedoc """
  A map containing the relvant context for a particular error.
  """
  @type context :: %{String.t() => any()}

  def report(exception, stacktrace, given_context \\ %{}) do
    {:ok, stacktrace} = ErrorTracker.Stacktrace.new(stacktrace)
    {:ok, error} = ErrorTracker.Error.new(exception, stacktrace)

    context = Map.merge(get_context(), given_context)

    error =
      repo().insert!(error,
        on_conflict: [set: [status: :unresolved]],
        conflict_target: :fingerprint,
        prefix: prefix()
      )

    error
    |> Ecto.build_assoc(:occurrences, stacktrace: stacktrace, context: context)
    |> repo().insert!(prefix: prefix())
  end

  def repo do
    Application.fetch_env!(:error_tracker, :repo)
  end

  def prefix do
    Application.get_env(:error_tracker, :prefix, "public")
  end

  @spec set_context(context()) :: context()
  def set_context(params) when is_map(params) do
    current_context = Process.get(:error_tracker_context, %{})

    Process.put(:error_tracker_context, Map.merge(current_context, params))

    params
  end

  @spec get_context() :: context()
  def get_context do
    Process.get(:error_tracker_context, %{})
  end
end
