defmodule ErrorTracker.Integrations.Phoenix do
  @moduledoc """
  The ErrorTracker integration with Phoenix applications.

  ## How it works

  It works using your application's Telemetry events, so you don't need to
  modify anything on your application.
  """

  alias ErrorTracker.Integrations.Plug, as: PlugIntegration

  # https://hexdocs.pm/phoenix/Phoenix.Logger.html#module-instrumentation
  @events [
    [:phoenix, :router_dispatch, :start],
    [:phoenix, :router_dispatch, :exception]
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

    PlugIntegration.report_error(reason, stack)
  end
end
