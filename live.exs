Mix.install([
  {:phoenix_playground, github: "phoenix-playground/phoenix_playground", ref: "ee6da0fc3b141f78b9f967ce71a4fb015c6764a6"},
  {:error_tracker, path: ".", env: :dev}
])

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

  def handle_params(params, _uri, socket) do
    if params["crash"] == "handle_params" do
      raise "Crash on handle_params"
    end
    {:noreply, socket}
  end
end


Application.put_env(:error_tracker, :repo, ErrorTracker.DevRepo)
Application.put_env(:error_tracker, :application, :error_tracker_dev)
Application.put_env(:error_tracker, :prefix, "private")
Application.put_env(:error_tracker, ErrorTracker.DevRepo, url: "ecto://postgres:postgres@127.0.0.1/error_tracker_dev")

PhoenixPlayground.start(live: DemoLive, child_specs: [ErrorTracker.DevSupervisor])
