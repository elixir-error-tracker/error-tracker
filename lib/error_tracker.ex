defmodule ErrorTracker do
  @moduledoc """
  En Elixir based built-in error tracking solution.
  """

  @typedoc """
  A map containing the relevant context for a particular error.
  """
  @type context :: %{String.t() => any()}

  alias ErrorTracker.Error
  alias ErrorTracker.Repo

  def report(exception, stacktrace, given_context \\ %{}) do
    {:ok, stacktrace} = ErrorTracker.Stacktrace.new(stacktrace)
    {:ok, error} = Error.new(exception, stacktrace)

    context = Map.merge(get_context(), given_context)

    error =
      Repo.insert!(error,
        on_conflict: [set: [status: :unresolved, last_occurrence_at: DateTime.utc_now()]],
        conflict_target: :fingerprint
      )

    error
    |> Ecto.build_assoc(:occurrences, stacktrace: stacktrace, context: context)
    |> Repo.insert!()
  end

  def resolve(error = %Error{status: :unresolved}) do
    changeset = Ecto.Changeset.change(error, status: :resolved)

    Repo.update(changeset)
  end

  def unresolve(error = %Error{status: :resolved}) do
    changeset = Ecto.Changeset.change(error, status: :unresolved)

    Repo.update(changeset)
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
