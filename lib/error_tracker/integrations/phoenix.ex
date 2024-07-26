defmodule ErrorTracker.Integrations.Phoenix do
  @moduledoc """
  Integration with Phoenix applications.

  ## How to use it

  It is a plug and play integration: as long as you have Phoenix installed the
  ErrorTracker will receive and store the errors as they are reported.

  It also collects the exceptions that raise on your LiveView modules.

  ### How it works

  It works using Phoenix's Telemetry events, so you don't need to modify
  anything on your application.

  ### Errors on the Endpoint

  This integration only catches errors that raise after the requests hits your
  Router. That means that an exception on a plug defined on your Endpoint will
  not be reported.

  If you want to also catch those errors, we recommend you to set up the
  `ErrorTracker.Integrations.Plug` integration too.

  ### Default context

  For errors that are reported when executing regular HTTP requests (the ones
  that go to Controllers), the context added by default is the same that you
  can find on the `ErrorTracker.Integrations.Plug` integration.

  As for exceptions generated in LiveView processes, we collect some special
  information on the context:

  * `live_view.view`: the LiveView module itself,

  * `live_view.uri`: last URI that loaded the LiveView (available when the
  `handle_params` function is invoked).

  * `live_view.params`: the params received by the LiveView (available when the
  `handle_params` function is invoked).

  * `live_view.event`: last event received by the LiveView (available when the
  `handle_event` function is invoked).

  * `live_view.event_params`: last event params received by the LiveView
  (available when the `handle_event` function is invoked).
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

  @doc """
  Attachs to Phoenix's Telemetry events if the library is detected.

  This function is usually called internally during the startup process so you
  don't have to.
  """
  def attach do
    if Application.spec(:phoenix) do
      :telemetry.attach_many(__MODULE__, @events, &__MODULE__.handle_event/4, :no_config)
    end
  end

  @doc false
  def handle_event([:phoenix, :router_dispatch, :start], _measurements, metadata, :no_config) do
    PlugIntegration.set_context(metadata.conn)
  end

  def handle_event([:phoenix, :router_dispatch, :exception], _measurements, metadata, :no_config) do
    {reason, kind, stack} =
      case metadata do
        %{reason: %Plug.Conn.WrapperError{reason: reason, kind: kind, stack: stack}} ->
          {reason, kind, stack}

        %{kind: kind, reason: reason, stacktrace: stack} ->
          {reason, kind, stack}
      end

    PlugIntegration.report_error(metadata.conn, {kind, reason}, stack)
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
    ErrorTracker.report({metadata.kind, metadata.reason}, metadata.stacktrace)
  end
end
