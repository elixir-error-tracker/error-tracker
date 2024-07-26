defmodule ErrorTracker.Web.Hooks.SetAssigns do
  @moduledoc false
  import Phoenix.Component

  def on_mount({:set_dashboard_path, path}, _params, _session, socket) do
    {:cont, assign(socket, :dashboard_path, path)}
  end
end
