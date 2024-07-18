defmodule ErrorTracker.Web.Live.Show do
  @moduledoc false

  use ErrorTracker.Web, :live_view

  alias ErrorTracker.Error

  def mount(params, _session, socket) do
    error = ErrorTracker.repo().get!(Error, params["id"], prefix: ErrorTracker.prefix())
    error = ErrorTracker.repo().preload(error, [:occurrences], prefix: ErrorTracker.prefix())

    dbg(error)

    {:ok, assign(socket, error: error)}
  end
end
