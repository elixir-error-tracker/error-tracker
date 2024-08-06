defmodule ErrorTracker.Telemetry do
  @moduledoc """
  TODO
  """

  def execute_new_occurrence(occurrence) do
    measurements = %{system_time: System.system_time()}
    metadata = %{occurrence: occurrence}
    :telemetry.execute([:error_tracker, :new_occurrence], measurements, metadata)
  end
end
