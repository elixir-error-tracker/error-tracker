defmodule ErrorTracker.Web.Layouts do
  @moduledoc false
  use ErrorTracker.Web, :html

  alias ErrorTracker.Web.Layouts.Navbar

  @css_path :code.priv_dir(:error_tracker) |> Path.join("static/app.css")
  @js_path :code.priv_dir(:error_tracker) |> Path.join("static/app.js")

  @default_docket_config %{path: "/live", transport: :websocket}

  embed_templates "layouts/*"

  def get_content(:css), do: File.read!(@css_path)
  def get_content(:js), do: File.read!(@js_path)

  def get_socket_config(key) do
    default = Map.get(@default_docket_config, key)
    config = Application.get_env(:error_tracker, :live_view_socket, [])
    Keyword.get(config, key, default)
  end
end
