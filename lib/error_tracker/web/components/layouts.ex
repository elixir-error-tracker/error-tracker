defmodule ErrorTracker.Web.Layouts do
  @moduledoc false
  use ErrorTracker.Web, :html

  alias ErrorTracker.Web.Layouts.Navbar

  @default_socket_config %{path: "/live", transport: :websocket}

  @css :code.priv_dir(:error_tracker) |> Path.join("static/app.css") |> File.read!()
  @js :code.priv_dir(:error_tracker) |> Path.join("static/app.js") |> File.read!()

  embed_templates "layouts/*"

  def get_content(:css), do: @css
  def get_content(:js), do: @js

  def get_socket_config(key) do
    default = Map.get(@default_socket_config, key)
    config = Application.get_env(:error_tracker, :live_view_socket, [])
    Keyword.get(config, key, default)
  end
end
