defmodule ErrorTracker.Web.Router do
  @moduledoc """
  Integration of the ErrorTracker UI into your application's router.
  """

  @doc """
  Creates the routes needed to use the `ErrorTracker` web interface.

  It requires a path in which you are going to serve the web interface.

  ## Security considerations

  Errors may contain sensitive information so it is recommended to use the `on_mount`
  option to provide a custom hook that implements authentication and authorization
  for access control.

  ## Options

  * `on_mount`: a list of mount hooks to use before invoking the dashboard
  LiveView views.

  * `as`: a session name to use for the dashboard LiveView session. By default
  it uses `:error_tracker_dashboard`.
  """
  defmacro error_tracker_dashboard(path, opts \\ []) do
    quote bind_quoted: [path: path, opts: opts] do
      # Ensure that the given path includes previous scopes so we can generate proper
      # paths for navigating through the dashboard.
      scoped_path = Phoenix.Router.scoped_path(__MODULE__, path)
      # Generate the session name and session hooks.
      {session_name, session_opts} = parse_options(opts, scoped_path)

      scope path, alias: false, as: false do
        import Phoenix.LiveView.Router, only: [live: 4, live_session: 3]

        live_session session_name, session_opts do
          live "/", ErrorTracker.Web.Live.Dashboard, :index, as: session_name
          live "/:id", ErrorTracker.Web.Live.Show, :show, as: session_name
          live "/:id/:occurrence_id", ErrorTracker.Web.Live.Show, :show, as: session_name
        end
      end
    end
  end

  @doc false
  def parse_options(opts, path) do
    custom_on_mount = Keyword.get(opts, :on_mount, [])

    on_mount =
      [{ErrorTracker.Web.Hooks.SetAssigns, {:set_dashboard_path, path}}] ++ custom_on_mount

    session_name = Keyword.get(opts, :as, :error_tracker_dashboard)

    session_opts = [
      on_mount: on_mount,
      root_layout: {ErrorTracker.Web.Layouts, :root}
    ]

    {session_name, session_opts}
  end
end
