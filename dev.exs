# This is the development server for Errortracker built on the PhoenixLiveDashboard project.
# To start the development server run:
#     $ iex dev.exs
#
Mix.install([
  {:ecto_sqlite3, ">= 0.0.0"},
  {:error_tracker, path: ".", force: true},
  {:phoenix_playground, "~> 0.1.7"}
])

otp_app = :error_tracker_dev

Application.put_all_env(
  error_tracker_dev: [
    {ErrorTrackerDev.Repo, [database: "priv/repo/dev.db"]}
  ],
  error_tracker: [
    {:application, otp_app},
    {:otp_app, otp_app},
    {:repo, ErrorTrackerDev.Repo}
  ]
)

defmodule ErrorTrackerDev.Repo do
  require Logger
  use Ecto.Repo, otp_app: otp_app, adapter: Ecto.Adapters.SQLite3

  defmodule Migration do
    use Ecto.Migration

    def up, do: ErrorTracker.Migration.up()
    def down, do: ErrorTracker.Migration.down()
  end

  def migrate do
    Ecto.Migrator.run(__MODULE__, [{0, __MODULE__.Migration}], :up, all: true)
  end
end

defmodule ErrorTrackerDev.Controller do
  use Phoenix.Controller, formats: [:html]
  use Phoenix.Component

  plug :put_layout, false
  plug :put_view, __MODULE__

  def index(conn, _params) do
    render(conn)
  end

  def index(assigns) do
    ~H"""
    <h2>ErrorTracker Dev server</h2>

    <ul>
      <li></li>
    </ul>
    """
  end

  def noroute(conn, _params) do
    ErrorTracker.add_breadcrumb("ErrorTrackerDev.Controller.noroute/2")

    raise Phoenix.Router.NoRouteError, conn: conn, router: ErrorTrackerDev.Router
  end

  def exception(_conn, _params) do
    ErrorTracker.add_breadcrumb("ErrorTrackerDev.Controller.exception/2")

    raise ErrorTrackerDev.Exception,
      message: "This is a controller exception",
      bread_crumbs: ["First", "Second"]
  end

  def exit(_conn, _params) do
    ErrorTracker.add_breadcrumb("ErrorTrackerDev.Controller.exit/2")

    exit(:timeout)
  end
end

defmodule ErrorTrackerDev.Live do
  use Phoenix.LiveView

  def mount(params, _session, socket) do
    if params["crash_on_mount"] do
      raise("Crashed on mount/3")
    end

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    if params["crash_on_handle_params"] do
      raise "Crashed on handle_params/3"
    end

    {:noreply, socket}
  end

  def handle_event("crash_on_handle_event", _params, _socket) do
    raise "Crashed on handle_event/3"
  end

  def handle_event("crash_on_render", _params, socket) do
    {:noreply, assign(socket, crash_on_render: true)}
  end

  def handle_event("genserver-timeout", _params, socket) do
    GenServer.call(ErrorTrackerDev.GenServer, :timeout, 2000)
    {:noreply, socket}
  end

  def render(assigns) do
    if Map.has_key?(assigns, :crash_on_render) do
      raise "Crashed on render/1"
    end

    ~H"""
    <h1>ErrorTracker Dev server</h1>

    <.link href="/dev/errors" target="_blank">Open the ErrorTracker dashboard</.link>

    <p>
      Errors are stored in the <code>priv/repo/dev.db</code>
      database, which is automatically created by this script.<br />
      If you want to clear the state stop the script, run the following command and start it again. <pre>rm priv/repo/dev.db priv/repo/dev.db-shm priv/repo/dev.db-wal</pre>
    </p>

    <h2>LiveView examples</h2>

    <ul>
      <li>
        <.link href="/?crash_on_mount">Crash on mount/3</.link>
      </li>
      <li>
        <.link patch="/?crash_on_handle_params">Crash on handle_params/3</.link>
      </li>
      <li>
        <.link phx-click="crash_on_render">Crash on render/1</.link>
      </li>
      <li>
        <.link phx-click="crash_on_handle_event">Crash on handle_event/3</.link>
      </li>
      <li>
        <.link phx-click="genserver-timeout">Crash with a GenServer timeout</.link>
      </li>
    </ul>

    <h2>Controller examples</h2>

    <ul>
      <li>
        <.link href="/noroute">Generate a 404 error from the controller</.link>
      </li>
      <li>
        <.link href="/exception">Generate an exception from the controller</.link>
      </li>
      <li>
        <.link href="/plug_exception">Generate an exception from the router</.link>
      </li>
      <li>
        <.link href="/exit">Generate an exit from the controller</.link>
      </li>
    </ul>
    """
  end
end

defmodule ErrorTrackerDev.Router do
  use Phoenix.Router
  use ErrorTracker.Web, :router

  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, [:html]
    plug :put_root_layout, html: {PhoenixPlayground.Layout, :root}
    plug :put_secure_browser_headers
  end

  scope "/" do
    pipe_through :browser

    live "/", ErrorTrackerDev.Live
    get "/noroute", ErrorTrackerDev.Controller, :noroute
    get "/exception", ErrorTrackerDev.Controller, :exception
    get "/exit", ErrorTrackerDev.Controller, :exit

    scope "/dev" do
      error_tracker_dashboard "/errors", csp_nonce_assign_key: :custom_csp_nonce
    end
  end
end

defmodule ErrorTrackerDev.Endpoint do
  use Phoenix.Endpoint, otp_app: :phoenix_playground
  use ErrorTracker.Integrations.Plug

  # Default PhoenixPlayground.Endpoint
  plug Plug.Logger
  socket "/live", Phoenix.LiveView.Socket
  plug Plug.Static, from: {:phoenix, "priv/static"}, at: "/assets/phoenix"
  plug Plug.Static, from: {:phoenix_live_view, "priv/static"}, at: "/assets/phoenix_live_view"
  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
  plug Phoenix.LiveReloader
  plug Phoenix.CodeReloader, reloader: &PhoenixPlayground.CodeReloader.reload/2

  # Use a custom Content Security Policy
  plug :set_csp
  # Raise an exception in the /plug_exception path
  plug :plug_exception
  # Our custom router which allows us to have regular controllers and live views
  plug ErrorTrackerDev.Router

  defp set_csp(conn, _opts) do
    nonce = 10 |> :crypto.strong_rand_bytes() |> Base.encode64()

    policies = [
      "script-src 'self' 'nonce-#{nonce}';",
      "style-src 'self' 'nonce-#{nonce}';"
    ]

    conn
    |> Plug.Conn.assign(:custom_csp_nonce, "#{nonce}")
    |> Plug.Conn.put_resp_header("content-security-policy", Enum.join(policies, " "))
  end

  defp plug_exception(conn = %Plug.Conn{path_info: path_info}, _opts) when is_list(path_info) do
    if "plug_exception" in path_info,
      do: raise("Crashed in Endpoint"),
      else: conn
  end
end

defmodule ErrorTrackerDev.ErrorView do
  def render("404.html", _assigns) do
    "This is a 404"
  end

  def render("500.html", _assigns) do
    "This is a 500"
  end
end

defmodule ErrorTrackerDev.GenServer do
  use GenServer

  # Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  # Server (callbacks)

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:timeout, _from, state) do
    :timer.sleep(5000)
    {:reply, state, state}
  end
end

defmodule ErrorTrackerDev.Exception do
  defexception [:message, :bread_crumbs]
end

defmodule ErrorTrackerDev.Telemetry do
  def handle_event(event, measure, metadata, _opts) do
    dbg([event, measure, metadata])
  end
end

PhoenixPlayground.start(
  endpoint: ErrorTrackerDev.Endpoint,
  child_specs: [
    {ErrorTrackerDev.Repo, []},
    {ErrorTrackerDev.GenServer, [name: ErrorTrackerDev.GenServer]}
  ],
  open_browser: false,
  debug_errors: false
)

ErrorTrackerDev.Repo.migrate()

:telemetry.attach_many(
  "error-tracker-events",
  [
    [:error_tracker, :error, :new],
    [:error_tracker, :error, :resolved],
    [:error_tracker, :error, :unresolved],
    [:error_tracker, :occurrence, :new]
  ],
  &ErrorTrackerDev.Telemetry.handle_event/4,
  []
)
