defmodule ErrorTracker.Telemetry do
  @moduledoc """
  TODO
  """

  @doc false
  def new_error(error) do
    measurements = %{system_time: System.system_time()}
    :telemetry.execute([:error_tracker, :new_error], measurements, %{error: error})
  end

  @doc false
  def unresolved_error(error) do
    measurements = %{system_time: System.system_time()}
    :telemetry.execute([:error_tracker, :unresolved_error], measurements, %{error: error})
  end

  @doc false
  def resolved_error(error) do
    measurements = %{system_time: System.system_time()}
    :telemetry.execute([:error_tracker, :unresolved_error], measurements, %{error: error})
  end

  @doc false
  def new_occurrence(occurrence) do
    measurements = %{system_time: System.system_time()}
    :telemetry.execute([:error_tracker, :new_occurrence], measurements, %{occurrence: occurrence})
  end
end
