defmodule ErrorTracker do
  @moduledoc """
  En Elixir based built-in error tracking solution.

  The main objectives behind this project are:

  * Provide a basic free error tracking solution: because tracking errors on
  your application should be a requirement to almost any project, and helps to
  provide quality and maintenance to your project.

  * Easy to use: by providing plug and play integrations, documentation and a
  simple UI to manage your errors.

  * Be as minimalistic as possible: you just need a database to store errors and
  an Phoenix application if you want to inspect them via web. That's all.

  ## How to report an error

  You can report an exception as easy as:

  ```elixir
  try do
    # your code
  catch
    e ->
      ErrorTracker.report(e, __STACKTRACE__)
  end
  ```

  ## Integrations

  We currently include integrations for what we consider the basic stack of
  an application: Phoenix, Plug and Oban.

  However, we may continue working in adding support for more systems and
  libraries in the future if there is enough interest by the community.

  ## Context

  Aside from the information abot each exception (kind, message, stacktrace...)
  we also store contexts.

  Contexts are arbitrary maps that allow you to store extra information of an
  exception to be able to reproduce it later.

  Each integration includes a default context with the useful information they
  can gather, but aside from that you can also add your own information:

  ```elixir
  ErrorTracker.set_context(%{user_id: conn.assigns.current_user.id})
  ```

  ## Migrations

  As we store information in a database, there are migrations to create the
  required database objects (tables, indices...) for you to stay up to date with
  the project.

  Please, check the documentation of the `ErrorTracker.Migration` module for
  more details.

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
