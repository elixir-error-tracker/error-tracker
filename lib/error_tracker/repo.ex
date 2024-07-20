defmodule ErrorTracker.Repo do
  @moduledoc """
  Wraps Ecto.Repo calls and applies default options.
  """
  def insert!(struct_or_changeset, opts \\ []) do
    dispatch(:insert, [struct_or_changeset], opts)
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

  def all(queryable, opts \\ []) do
    dispatch(:all, [queryable], opts)
  end

  def aggregate(queryable, aggregate, opts \\ []) do
    dispatch(:aggregate, [queryable, aggregate], opts)
  end

  def __adapter__, do: repo().__adapter__()

  defp dispatch(action, args, opts) do
    defaults = [prefix: Application.get_env(:error_tracker, :prefix, "public")]
    opts_w_defaults = Keyword.merge(defaults, opts)

    apply(repo(), action, args ++ [opts_w_defaults])
  end

  defp repo do
    Application.fetch_env!(:error_tracker, :repo)
  end
end
