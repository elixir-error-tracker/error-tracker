defmodule ErrorTracker.Web.Layouts do
  use ErrorTracker.Web, :html

  @css_path :code.priv_dir(:error_tracker) |> Path.join("static/app.css")
  @js_path :code.priv_dir(:error_tracker) |> Path.join("static/app.js")

  embed_templates "layouts/*"

  def get_content(:css), do: File.read!(@css_path)
  def get_content(:js), do: File.read!(@js_path)
end
