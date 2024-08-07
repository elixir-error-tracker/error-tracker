defmodule ErrorTracker.Integrations.Oban do
  @moduledoc """
  Integration with Oban.

  ## How to use it

  It is a plug and play integration: as long as you have Oban installed the
  ErrorTracker will receive and store the errors as they are reported.

  ### How it works

  It works using Oban's Telemetry events, so you don't need to modify anything
  on your application.

  ### Default context

  By default we store some context for you on errors generated in an Oban
  process:

  * `job.id`: the unique ID of the job.

  * `job.worker`: the name of the worker module.

  * `job.queue`: the name of the queue in which the job was inserted.

  * `job.args`: the arguments of the job being executed.

  * `job.priority`: the priority of the job.

  * `job.attempt`: the number of attempts performed for the job.
  """

  # https://hexdocs.pm/oban/Oban.Telemetry.html
  @events [
    [:oban, :job, :start],
    [:oban, :job, :exception]
  ]

  @doc false
  def attach do
    if Application.spec(:oban) do
      :telemetry.attach_many(__MODULE__, @events, &__MODULE__.handle_event/4, :no_config)
    end
  end

  @doc false
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
