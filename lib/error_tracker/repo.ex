defmodule ErrorTracker.Repo do
  def insert!(struct_or_changeset, opts \\ []) do
    repo = Application.get_env(:error_tracker, :repo)

    repo.insert!(struct_or_changeset, opts)
  end
end
