#######################################
# Development Server for ErrorTracker.
#
# Based on PhoenixLiveDashboard code.
#
# Usage:
#
# $ iex -S mix dev
#######################################
Logger.configure(level: :debug)

# Get local configuration
Code.require_file("dev.local.exs")

# Prepare the repo
defmodule ErrorTrackerDev.Repo do
  use Ecto.Repo, otp_app: :error_tracker, adapter: Ecto.Adapters.Postgres
end

_ = Ecto.Adapters.Postgres.storage_up(ErrorTrackerDev.Repo.config())

# Configures the endpoint
Application.put_env(:error_tracker, ErrorTrackerDevWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Hu4qQN3iKzTV4fJxhorPQlA/osH9fAMtbtjVS58PFgfw3ja5Z18Q/WSNR9wP4OfW",
  live_view: [signing_salt: "hMegieSe"],
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  check_origin: false,
  pubsub_server: ErrorTrackerDev.PubSub,
  watchers: [
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ],
  live_reload: [
    patterns: [
      ~r"dev.exs$",
      ~r"dist/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/error_tracker/web/(live|views)/.*(ex)$",
      ~r"lib/error_tracker/web/templates/.*(ex)$"
    ]
  ]
)

# Setup up the ErrorTracker configuration
Application.put_env(:error_tracker, :repo, ErrorTrackerDev.Repo)
Application.put_env(:error_tracker, :application, :error_tracker_dev)
Application.put_env(:error_tracker, :prefix, "private")

defmodule ErrorTrackerDevWeb.PageController do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, :index) do
    content(conn, """
    <h2>ErrorTracker Dev Server</h2>
    <div><a href="/errors">Open ErrorTracker</a></div>
    <div><a href="/plug-exception">Generate Plug exception</a></div>
    <div><a href="/404">Generate Router 404</a></div>
    <div><a href="/noroute">Raise NoRouteError from a controller</a></div>
    <div><a href="/exception">Generate Exception</a></div>
    """)
  end

  def call(conn, :noroute) do
    raise Phoenix.Router.NoRouteError, conn: conn, router: ErrorTrackerDevWeb.Router
  end

  def call(_conn, :exception) do
    raise "This is a controller exception"
  end

  defp content(conn, content) do
    conn
    |> put_resp_header("content-type", "text/html")
    |> send_resp(200, "<!doctype html><html><body>#{content}</body></html>")
  end
end

defmodule ErrorTrackerDevWeb.ErrorView do
  def render("404.html", _assigns) do
    "This is a 404"
  end

  def render("500.html", _assigns) do
    "This is a 500"
  end
end

defmodule ErrorTrackerDevWeb.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :fetch_session
    plug :protect_from_forgery
  end

  scope "/" do
    pipe_through :browser
    get "/", ErrorTrackerDevWeb.PageController, :index
    get "/noroute", ErrorTrackerDevWeb.PageController, :noroute
    get "/exception", ErrorTrackerDevWeb.PageController, :exception
  end
end

defmodule ErrorTrackerDevWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :error_tracker
  use ErrorTracker.Integrations.Plug

  @session_options [
    store: :cookie,
    key: "_error_tracker_dev",
    signing_salt: "/VEDsdfsffMnp5",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]
  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket

  plug Phoenix.LiveReloader
  plug Phoenix.CodeReloader

  plug Plug.Session, @session_options

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]
  plug :maybe_exception
  plug ErrorTrackerDevWeb.Router

  def maybe_exception(%Plug.Conn{path_info: ["plug-exception"]}, _), do: raise("Plug exception")
  def maybe_exception(conn, _), do: conn
end

defmodule Migration0 do
  use Ecto.Migration

  def up, do: ErrorTracker.Migrations.up(prefix: "private")
  def down, do: ErrorTracker.Migrations.down(prefix: "private")
end

Application.put_env(:phoenix, :serve_endpoints, true)

Task.async(fn ->
  children = [
    {Phoenix.PubSub, [name: ErrorTrackerDev.PubSub, adapter: Phoenix.PubSub.PG2]},
    ErrorTrackerDev.Repo,
    ErrorTrackerDevWeb.Endpoint
  ]

  {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)

  # Automatically run the migrations on boot
  Ecto.Migrator.run(ErrorTrackerDev.Repo, [{0, Migration0}], :up,
    all: true,
    log_migrations_sql: :debug
  )

  Process.sleep(:infinity)
end)
|> Task.await(:infinity)