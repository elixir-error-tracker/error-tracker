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

  @doc """
  Report a exception to be stored.

  Aside from the exception, it is expected to receive the stacktrace and,
  optionally, a context map which will be merged with the current process
  context.

  ## Exceptions

  Exceptions passed can be in three different forms:

  * An exception struct: the module of the exception is stored alongside with
  the exception message.

  * A `{kind, exception}` tuple in which the `exception` is an struct: it
  behaves the same as when passing just the exception struct.

  * A `{kind, reason}` tuple: it stores the kind and the message itself casted
  to strings, as it is useful for some errors like EXIT signals or custom error
  messages.
  """
  def report(exception, stacktrace, given_context \\ %{}) do
    {kind, reason} =
      case exception do
        %struct{} = ex when is_exception(ex) ->
          {to_string(struct), Exception.message(ex)}

        {_kind, %struct{} = ex} when is_exception(ex) ->
          {to_string(struct), Exception.message(ex)}

        {kind, ex} ->
          {to_string(kind), to_string(ex)}
      end

    {:ok, stacktrace} = ErrorTracker.Stacktrace.new(stacktrace)
    {:ok, error} = Error.new(kind, reason, stacktrace)

    context = Map.merge(get_context(), given_context)

    error =
      Repo.insert!(error,
        on_conflict: [set: [status: :unresolved, last_occurrence_at: DateTime.utc_now()]],
        conflict_target: :fingerprint
      )

    error
    |> Ecto.build_assoc(:occurrences, stacktrace: stacktrace, context: context, reason: reason)
    |> Repo.insert!()
  end

  @doc """
  Marks an error as resolved.

  If an error is marked as resolved and it happens again, it will automatically
  appear as unresolved again.
  """
  def resolve(error = %Error{status: :unresolved}) do
    changeset = Ecto.Changeset.change(error, status: :resolved)

    Repo.update(changeset)
  end

  @doc """
  Marks an error as unresolved.
  """
  def unresolve(error = %Error{status: :resolved}) do
    changeset = Ecto.Changeset.change(error, status: :unresolved)

    Repo.update(changeset)
  end

  @doc """
  Sets current process context.

  By default it will merge the current context with the new one received, taking
  preference the new context's contents over the existsing ones if any key
  matches.

  ## Depth of the context

  You can store context on more than one level of depth, but take into account
  that the merge operation is performed on the first level.

  That means that any existing data on deep levels fot he current context will
  be replaced if the first level key is received on the new contents.
  """
  @spec set_context(context()) :: context()
  def set_context(params) when is_map(params) do
    current_context = Process.get(:error_tracker_context, %{})

    Process.put(:error_tracker_context, Map.merge(current_context, params))

    params
  end

  @doc """
  Obtain the context of the current process.
  """
  @spec get_context() :: context()
  def get_context do
    Process.get(:error_tracker_context, %{})
  end
end
