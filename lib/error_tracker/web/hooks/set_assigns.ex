defmodule ErrorTracker.Web.Hooks.SetAssigns do
  @moduledoc """
  Mounting hooks to set environment configuration on the socket.
  """
  import Phoenix.Component

  def on_mount({:set_dashboard_path, path}, _params, _session, socket) do
    {:cont, assign(socket, :dashboard_path, path)}
  end
end
