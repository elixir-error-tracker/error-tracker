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

defmodule ErrorTrackerDevWeb.PageController do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, :index) do
    content(conn, """
    <h2>ErrorTracker Dev Server</h2>
    <div><a href="/errors">Open ErrorTracker</a></div>
    <div><a href="/404">Generate 404 Error</a></div>
    <div><a href="/exception">Generate Exception</a></div>
    """)
  end

  def call(_conn, :exception) do
    raise "This is an error"
  end

  defp content(conn, content) do
    conn
    |> put_resp_header("content-type", "text/html")
    |> send_resp(200, "<!doctype html><html><body>#{content}</body></html>")
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
    get "/exception", ErrorTrackerDevWeb.PageController, :exception
  end
end

defmodule ErrorTrackerDevWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :error_tracker

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
  plug ErrorTrackerDevWeb.Router
end

Application.put_env(:phoenix, :serve_endpoints, true)

Task.async(fn ->
  children = [
    {Phoenix.PubSub, [name: ErrorTrackerDev.PubSub, adapter: Phoenix.PubSub.PG2]},
    ErrorTrackerDev.Repo,
    ErrorTrackerDevWeb.Endpoint
  ]

  {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  Process.sleep(:infinity)
end)
|> Task.await(:infinity)
