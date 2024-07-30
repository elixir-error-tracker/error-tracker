defmodule ErrorTracker.Web.Hooks.SetAssigns do
  @moduledoc false

  def on_mount({:set_dashboard_path, path}, _params, _session, socket) do
    {:cont, %{socket | private: Map.put(socket.private, :dashboard_path, path)}}
  end
end
