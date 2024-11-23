Mix.install([
  {:phoenix_playground, "~> 0.1.7"},
  {:postgrex, "~> 0.19.3"},
  {:error_tracker, path: "."}
])

# Set up the repository for the Error Tracker
defmodule ErrorTrackerDev.Repo do
  use Ecto.Repo, otp_app: :error_tracker, adapter: Ecto.Adapters.Postgres
end

Application.put_env(:error_tracker, :repo, ErrorTrackerDev.Repo)
Application.put_env(:error_tracker, :application, :error_tracker_dev)
Application.put_env(:error_tracker, :prefix, "private")
Application.put_env(:error_tracker, :otp_app, :error_tracker_dev)

Application.put_env(:error_tracker, ErrorTrackerDev.Repo,
  url: "ecto://postgres:postgres@127.0.0.1/error_tracker_dev"
)

# This migration will set up the database structure
defmodule Migration0 do
  use Ecto.Migration

  def up, do: ErrorTracker.Migration.up(prefix: "private")
  def down, do: ErrorTracker.Migration.down(prefix: "private")
end

defmodule ErrorTrackerDev.TimeoutGenServer do
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

defmodule DemoLive do
  use Phoenix.LiveView

  def mount(params, _session, socket) do
    if params["crash"] == "mount" do
      raise "Crashing on mount"
    end

    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    if assigns.count == 5 do
      raise "Crash on render"
    end

    ~H"""
    <span><%= @count %></span>
    <button phx-click="inc">+</button>
    <button phx-click="dec">-</button>
    <button phx-click="error">Crash on handle_event</button>
    <button phx-click="genserver-timeout">GenServer timeout</button>

    <.link href="/?crash=mount">Crash on mount</.link>
    <.link patch="/?crash=handle_params">Crash on handle_params</.link>

    <style type="text/css">
      body { padding: 1em; }
    </style>
    """
  end

  def handle_event("inc", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end

  def handle_event("dec", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count - 1)}
  end

  def handle_event("error", _params, _socket) do
    raise "Crash on handle_event"
  end

  def handle_event("genserver-timeout", _params, socket) do
    GenServer.call(TimeoutGenServer, :timeout, 2000)
    {:noreply, socket}
  end

  def handle_params(params, _uri, socket) do
    if params["crash"] == "handle_params" do
      raise "Crash on handle_params"
    end

    {:noreply, socket}
  end
end

defmodule DemoRouter do
  use Phoenix.Router
  use ErrorTracker.Web, :router

  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :put_root_layout, html: {PhoenixPlayground.Layout, :root}
  end

  scope "/" do
    pipe_through :browser
    live "/", DemoLive
    error_tracker_dashboard "/errors"
  end
end

defmodule DemoEndpoint do
  use Phoenix.Endpoint, otp_app: :phoenix_playground
  plug Plug.Logger
  socket "/live", Phoenix.LiveView.Socket
  plug Plug.Static, from: {:phoenix, "priv/static"}, at: "/assets/phoenix"
  plug Plug.Static, from: {:phoenix_live_view, "priv/static"}, at: "/assets/phoenix_live_view"
  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
  plug Phoenix.LiveReloader
  plug Phoenix.CodeReloader, reloader: &PhoenixPlayground.CodeReloader.reload/2
  plug DemoRouter
end

PhoenixPlayground.start(
  endpoint: DemoEndpoint,
  child_specs: [
    {ErrorTrackerDev.Repo, []},
    {ErrorTrackerDev.TimeoutGenServer, [name: TimeoutGenServer]}
  ]
)

# Create the database if it does not exist and run migrations if needed
_ = Ecto.Adapters.Postgres.storage_up(ErrorTrackerDev.Repo.config())

Ecto.Migrator.run(ErrorTrackerDev.Repo, [{0, Migration0}], :up,
  all: true,
  log_migrations_sql: :debug
)
