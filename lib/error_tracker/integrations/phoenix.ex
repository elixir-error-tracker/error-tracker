defmodule ErrorTracker.Integrations.Phoenix do
  @moduledoc """
  The ErrorTracker integration with Phoenix applications.

  ## How it works

  It works using your application's Telemetry events, so you don't need to
  modify anything on your application.
  """

  alias ErrorTracker.Integrations.Plug, as: PlugIntegration

  @events [
    # https://hexdocs.pm/phoenix/Phoenix.Logger.html#module-instrumentation
    [:phoenix, :router_dispatch, :start],
    [:phoenix, :router_dispatch, :exception],
    # https://hexdocs.pm/phoenix_live_view/telemetry.html
    [:phoenix, :live_view, :mount, :start],
    [:phoenix, :live_view, :mount, :exception],
    [:phoenix, :live_view, :handle_params, :start],
    [:phoenix, :live_view, :handle_params, :exception],
    [:phoenix, :live_view, :handle_event, :start],
    [:phoenix, :live_view, :handle_event, :exception],
    [:phoenix, :live_view, :render, :exception]
  ]

  def attach do
    if Application.spec(:phoenix) do
      :telemetry.attach_many(__MODULE__, @events, &__MODULE__.handle_event/4, :no_config)
    end
  end

  def handle_event([:phoenix, :router_dispatch, :start], _measurements, metadata, :no_config) do
    PlugIntegration.set_context(metadata.conn)
  end

  def handle_event([:phoenix, :router_dispatch, :exception], _measurements, metadata, :no_config) do
    {reason, stack} =
      case metadata do
        %{reason: %Plug.Conn.WrapperError{reason: reason, stack: stack}} ->
          {reason, stack}

        %{reason: reason, stacktrace: stack} ->
          {reason, stack}
      end

    PlugIntegration.report_error(metadata.conn, reason, stack)
  end

  def handle_event([:phoenix, :live_view, :mount, :start], _, metadata, :no_config) do
    ErrorTracker.set_context(%{
      "live_view.view" => metadata.socket.view
    })
  end

  def handle_event([:phoenix, :live_view, :handle_params, :start], _, metadata, :no_config) do
    ErrorTracker.set_context(%{
      "live_view.uri" => metadata.uri,
      "live_view.params" => metadata.params
    })
  end

  def handle_event([:phoenix, :live_view, :handle_event, :start], _, metadata, :no_config) do
    ErrorTracker.set_context(%{
      "live_view.event" => metadata.event,
      "live_view.event_params" => metadata.params
    })
  end

  def handle_event([:phoenix, :live_view, _action, :exception], _, metadata, :no_config) do
    ErrorTracker.report(metadata.reason, metadata.stacktrace)
  end
end
