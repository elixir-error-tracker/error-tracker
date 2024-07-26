defmodule ErrorTracker.Integrations.Oban do
  @moduledoc """
  Integration with Oban.

  ## How it works

  It works using your application's Telemetry events, so you don't need to
  modify anything on your application.
  """

  # https://hexdocs.pm/oban/Oban.Telemetry.html
  @events [
    [:oban, :job, :start],
    [:oban, :job, :exception]
  ]

  def attach do
    if Application.spec(:oban) do
      :telemetry.attach_many(__MODULE__, @events, &__MODULE__.handle_event/4, :no_config)
    end
  end

  def handle_event([:oban, :job, :start], _measurements, metadata, :no_config) do
    %{job: job} = metadata

    ErrorTracker.set_context(%{
      "job.args" => job.args,
      "job.attempt" => job.attempt,
      "job.id" => job.id,
      "job.priority" => job.priority,
      "job.queue" => job.queue,
      "job.worker" => job.worker
    })
  end

  def handle_event([:oban, :job, :exception], _measurements, metadata, :no_config) do
    %{reason: exception, stacktrace: stacktrace} = metadata

    ErrorTracker.report(exception, stacktrace)
  end
end
