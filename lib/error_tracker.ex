defmodule ErrorTracker do
  @moduledoc """
  En Elixir-based built-in error tracking solution.

  The main objectives behind this project are:

  * Provide a basic free error tracking solution: because tracking errors in
  your application should be a requirement for almost any project, and helps to
  provide quality and maintenance to your project.

  * Be easy to use: by providing plug-and-play integrations, documentation and a
  simple UI to manage your errors.

  * Be as minimalistic as possible: you just need a database to store errors and
  a Phoenix application if you want to inspect them via web. That's all.

  ## Requirements

  ErrorTracker requires Elixir 1.15+, Ecto 3.11+, Phoenix LiveView 0.19+, and
  PostgreSQL or SQLite3 as database.

  ## Integrations

  We currently include integrations for what we consider the basic stack of
  an application: Phoenix, Plug, and Oban.

  However, we may continue working in adding support for more systems and
  libraries in the future if there is enough interest from the community.

  If you want to manually report an error, you can use the `ErrorTracker.report/3` function.

  ## Context

  Aside from the information about each exception (kind, message, stack trace...)
  we also store contexts.

  Contexts are arbitrary maps that allow you to store extra information about an
  exception to be able to reproduce it later.

  Each integration includes a default context with useful information they
  can gather, but aside from that, you can also add your own information. You can
  do this in a per-process basis or in a per-call basis (or both).

  **Per process**

  This allows you to set a general context for the current process such as a Phoenix
  request or an Oban job. For example, you could include the following code in your
  authentication Plug to automatically include the user ID in any error that is
  tracked during the Phoenix request handling.

  ```elixir
  ErrorTracker.set_context(%{user_id: conn.assigns.current_user.id})
  ```

  **Per call**

  As we had seen before, you can use `ErrorTracker.report/3` to manually report an
  error. The third parameter of this function is optional and allows you to include
  extra context that will be tracked along with the error.
  """

  @typedoc """
  A map containing the relevant context for a particular error.
  """
  @type context :: %{String.t() => any()}

  alias ErrorTracker.Error
  alias ErrorTracker.Repo

  @doc """
  Report an exception to be stored.

  Aside from the exception, it is expected to receive the stack trace and,
  optionally, a context map which will be merged with the current process
  context.

  Keep in mind that errors that occur in Phoenix controllers, Phoenix LiveViews
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

  Exceptions can be passed in three different forms:

  * An exception struct: the module of the exception is stored along with
  the exception message.

  * A `{kind, exception}` tuple in which case the information is converted to
  an Elixir exception (if possible) and stored.
  """
  def report(exception, stacktrace, given_context \\ %{}) do
    {kind, reason} = normalize_exception(exception, stacktrace)
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
  Sets the current process context.

  The given context will be merged into the current process context. The given context
  may override existing keys from the current process context.

  ## Context depth

  You can store context on more than one level of depth, but take into account
  that the merge operation is performed on the first level.

  That means that any existing data on deep levels for he current context will
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

  defp normalize_exception(%struct{} = ex, _stacktrace) when is_exception(ex) do
    {to_string(struct), Exception.message(ex)}
  end

  defp normalize_exception({kind, ex}, stacktrace) do
    case Exception.normalize(kind, ex, stacktrace) do
      %struct{} ->
        {to_string(struct), Exception.message(ex)}

      other ->
        {to_string(kind), to_string(other)}
    end
  end
end
