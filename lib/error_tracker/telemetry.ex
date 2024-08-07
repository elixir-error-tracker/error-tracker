defmodule ErrorTracker.Telemetry do
  @moduledoc """
  TODO
  """

  @doc false
  def new_error(error) do
    measurements = %{system_time: System.system_time()}
    metadata = %{error: error}
    :telemetry.execute([:error_tracker, :error, :new], measurements, metadata)
  end

  @doc false
  def unresolved_error(error) do
    measurements = %{system_time: System.system_time()}
    metadata = %{error: error}
    :telemetry.execute([:error_tracker, :error, :unresolved], measurements, metadata)
  end

  @doc false
  def resolved_error(error) do
    measurements = %{system_time: System.system_time()}
    metadata = %{error: error}
    :telemetry.execute([:error_tracker, :error, :resolved], measurements, metadata)
  end

  @doc false
  def new_occurrence(occurrence) do
    measurements = %{system_time: System.system_time()}
    metadata = %{occurrence: occurrence}
    :telemetry.execute([:error_tracker, :occurrence, :new], measurements, metadata)
  end
end
