defmodule ErrorTracker.Web.Live.Dashboard do
  @moduledoc false

  use ErrorTracker.Web, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :counter, 0)}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("increment", _params, socket) do
    {:noreply, assign(socket, :counter, socket.assigns.counter + 1)}
  end
end
