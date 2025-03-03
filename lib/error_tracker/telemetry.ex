defmodule ErrorTracker.Telemetry do
  @moduledoc """
  Telemetry events of ErrorTracker.

  ErrorTracker emits some events to allow third parties to receive information
  of errors and occurrences stored.

  ### Error events

  Those occur during the life cycle of an error:

  * `[:error_tracker, :error, :new]`: is emitted when a new error is stored and
  no previous occurrences were known.

  * `[:error_tracker, :error, :resolved]`: is emitted when a new error is marked
  as resolved on the UI.

  * `[:error_tracker, :error, :unresolved]`: is emitted when a new error is
  marked as unresolved on the UI or a new occurrence is registered, moving the
  error to the unresolved state.

  ### Occurrence events

  There is only one event emitted for occurrences:

  * `[:error_tracker, :occurrence, :new]`: is emitted when a new occurrence is
  stored.

  ### Measures and metadata

  Each event is emitted with some measures and metadata, which can be used to
  receive information without having to query the database again:

  | event                                   | measures       | metadata                          |
  | --------------------------------------- | -------------- | ----------------------------------|
  | `[:error_tracker, :error, :new]`        | `:system_time` | `:error`                          |
  | `[:error_tracker, :error, :unresolved]` | `:system_time` | `:error`                          |
  | `[:error_tracker, :error, :resolved]`   | `:system_time` | `:error`                          |
  | `[:error_tracker, :occurrence, :new]`   | `:system_time` | `:occurrence`, `:error`, `:muted` |

  The metadata keys contain the following data:

  * `:error` - An `%ErrorTracker.Error{}` struct representing the error.
  * `:occurrence` - An `%ErrorTracker.Occurrence{}` struct representing the occurrence.
  * `:muted` - A boolean indicating whether the error is muted or not.
  """

  @doc false
  def new_error(error = %ErrorTracker.Error{}) do
    measurements = %{system_time: System.system_time()}
    metadata = %{error: error}
    :telemetry.execute([:error_tracker, :error, :new], measurements, metadata)
  end

  @doc false
  def unresolved_error(error = %ErrorTracker.Error{}) do
    measurements = %{system_time: System.system_time()}
    metadata = %{error: error}
    :telemetry.execute([:error_tracker, :error, :unresolved], measurements, metadata)
  end

  @doc false
  def resolved_error(error = %ErrorTracker.Error{}) do
    measurements = %{system_time: System.system_time()}
    metadata = %{error: error}
    :telemetry.execute([:error_tracker, :error, :resolved], measurements, metadata)
  end

  @doc false
  def new_occurrence(occurrence = %ErrorTracker.Occurrence{}, muted) when is_boolean(muted) do
    measurements = %{system_time: System.system_time()}
    metadata = %{error: occurrence.error, occurrence: occurrence, muted: muted}
    :telemetry.execute([:error_tracker, :occurrence, :new], measurements, metadata)
  end
end
