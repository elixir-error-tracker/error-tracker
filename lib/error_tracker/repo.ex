defmodule ErrorTracker.Repo do
  @moduledoc false

  def insert!(struct_or_changeset, opts \\ []) do
    dispatch(:insert!, [struct_or_changeset], opts)
  end

  def update(changeset, opts \\ []) do
    dispatch(:update, [changeset], opts)
  end

  def get(queryable, id, opts \\ []) do
    dispatch(:get, [queryable, id], opts)
  end

  def get!(queryable, id, opts \\ []) do
    dispatch(:get!, [queryable, id], opts)
  end

  def one(queryable, opts \\ []) do
    dispatch(:one, [queryable], opts)
  end

  def all(queryable, opts \\ []) do
    dispatch(:all, [queryable], opts)
  end

  def aggregate(queryable, aggregate, opts \\ []) do
    dispatch(:aggregate, [queryable, aggregate], opts)
  end

  def transaction(fun_or_multi, opts \\ []) do
    dispatch(:transaction, [fun_or_multi], opts)
  end

  def with_adapter(fun) do
    adapter =
      case repo().__adapter__() do
        Ecto.Adapters.Postgres -> :postgres
        Ecto.Adapters.SQLite3 -> :sqlite
      end

    fun.(adapter)
  end

  defp dispatch(action, args, opts) do
    repo = repo()

    defaults =
      with_adapter(fn
        :postgres -> [prefix: Application.get_env(:error_tracker, :prefix, "public")]
        _ -> []
      end)

    opts_w_defaults = Keyword.merge(defaults, opts)

    apply(repo, action, args ++ [opts_w_defaults])
  end

  defp repo do
    Application.fetch_env!(:error_tracker, :repo)
  end
end
