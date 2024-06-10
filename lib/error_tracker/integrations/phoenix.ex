defmodule ErrorTracker.Integrations.Phoenix do
  @moduledoc """
  The ErrorTracker integration with Phoenix applications.

  ## How it works

  It works using your application's Telemetry events, so you don't need to
  modify anything on your application.
  """

  alias ErrorTracker.Integrations.Plug, as: PlugIntegration

  def attach do
    if Application.spec(:phoenix) do
      :telemetry.attach(
        __MODULE__,
        [:phoenix, :router_dispatch, :exception],
        &__MODULE__.handle_exception/4,
        []
      )
    end
  end

  def handle_exception(
        [:phoenix, :router_dispatch, :exception],
        _measurements,
        %{reason: %Plug.Conn.WrapperError{conn: conn, reason: reason, stack: stack}},
        _opts
      ) do
    PlugIntegration.report_error(conn, reason, stack)
  end

  def handle_exception(
        [:phoenix, :router_dispatch, :exception],
        _measurements,
        %{reason: reason, stacktrace: stack, conn: conn},
        _opts
      ) do
    PlugIntegration.report_error(conn, reason, stack)
  end
end
