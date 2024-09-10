defmodule ErrorTracker.Web.Router do
  @moduledoc """
  ErrorTracker UI integration into your application's router.
  """

  alias ErrorTracker.Web.Hooks.SetAssigns

  @doc """
  Creates the routes needed to use the `ErrorTracker` web interface.

  It requires a path in which you are going to serve the web interface.

  ## Security considerations

  The dashboard inlines both the JS and CSS assets. This means that, if your
  application has a Content Security Policy, you need to specify the
  `csp_nonce_assign_key` option, which is explained below.

  ## Options

  * `on_mount`: a list of mount hooks to use before invoking the dashboard
  LiveView views.

  * `as`: a session name to use for the dashboard LiveView session. By default
  it uses `:error_tracker_dashboard`.

  * `csp_nonce_assign_key`: an assign key to find the CSP nonce value used for assets.
  Supports either `atom()` or a map of type
  `%{optional(:img) => atom(), optional(:script) => atom(), optional(:style) => atom()}`
  """
  defmacro error_tracker_dashboard(path, opts \\ []) do
    quote bind_quoted: [path: path, opts: opts] do
      # Ensure that the given path includes previous scopes so we can generate proper
      # paths for navigating through the dashboard.
      scoped_path = Phoenix.Router.scoped_path(__MODULE__, path)
      # Generate the session name and session hooks.
      {session_name, session_opts} = __parse_options__(opts, scoped_path)

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
  def __parse_options__(opts, path) do
    custom_on_mount = Keyword.get(opts, :on_mount, [])
    session_name = Keyword.get(opts, :as, :error_tracker_dashboard)

    csp_nonce_assign_key =
      case opts[:csp_nonce_assign_key] do
        nil -> nil
        key when is_atom(key) -> %{img: key, style: key, script: key}
        keys when is_map(keys) -> Map.take(keys, [:img, :style, :script])
      end

    session_opts = [
      session: {__MODULE__, :__session__, [csp_nonce_assign_key]},
      on_mount: [{SetAssigns, {:set_dashboard_path, path}}] ++ custom_on_mount,
      root_layout: {ErrorTracker.Web.Layouts, :root}
    ]

    {session_name, session_opts}
  end

  @doc false
  def __session__(conn, csp_nonce_assign_key) do
    %{
      "csp_nonces" => %{
        img: conn.assigns[csp_nonce_assign_key[:img]],
        style: conn.assigns[csp_nonce_assign_key[:style]],
        script: conn.assigns[csp_nonce_assign_key[:script]]
      }
    }
  end
end
