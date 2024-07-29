defmodule ErrorTracker do
  @moduledoc """
  En Elixir based built-in error tracking solution.

  The main objectives behind this project are:

  * Provide a basic free error tracking solution: because tracking errors on
  your application should be a requirement to almost any project, and helps to
  provide quality and maintenance to your project.

  * Be easy to use: by providing plug and play integrations, documentation and a
  simple UI to manage your errors.

  * Be as minimalistic as possible: you just need a database to store errors and
  an Phoenix application if you want to inspect them via web. That's all.

  ## Requirements

  ErrorTracker requires Elixir 1.15+, Ecto 3.11+, Phoenix LiveView 0.19+ and PostgreSQL

  ## Integrations

  We currently include integrations for what we consider the basic stack of
  an application: Phoenix, Plug and Oban.

  However, we may continue working in adding support for more systems and
  libraries in the future if there is enough interest by the community.

  If you want to manually report an error you can use the `ErrorTracker.report/3` function.

  ## Context

  Aside from the information abot each exception (kind, message, stacktrace...)
  we also store contexts.

  Contexts are arbitrary maps that allow you to store extra information of an
  exception to be able to reproduce it later.

  Each integration includes a default context with the useful information they
  can gather, but aside from that you can also add your own information. You can
  do this in a per-process way or in a per-call way (or both).

  **Per process**

  This allows you to set general context for the current process such as a Phoenix
  request or an Oban job. For example you could include the following code in your
  authentication Plug to automatically include the user ID on any error that is
  tracked during the Phoenix request handling.

  ```elixir
  ErrorTracker.set_context(%{user_id: conn.assigns.current_user.id})
  ```

  **Per call**

  As we had seen before you can use `ErrorTracker.report/3` to manually report an
  error. The third parameter of this function is optional and allows you to include
  extra context that will be tracked along with that error.
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

  Keep in mind that errors that happen in Phoenix controllers, Phoenix live views
  and Oban jobs are automatically reported. You will need this function only if you
  want to report custom errors.

  ```elixir
  try do
    # your code
  catch
    e ->
      ErrorTracker.report(e, __STACKTRACE__)
  end
  ```

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
