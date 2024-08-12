defmodule ErrorTracker.Test.Case do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto.Query
      import ErrorTracker.Test.Case
    end
  end

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(repo())
  end

  @doc """
  Reports the error produced by the given function.
  """
  def report_error(fun) do
    occurrence =
      try do
        fun.()
      rescue
        exception ->
          ErrorTracker.report(exception, __STACKTRACE__)
      catch
        kind, reason ->
          ErrorTracker.report({kind, reason}, __STACKTRACE__)
      end

    repo().preload(occurrence, :error)
  end

  @doc """
  Sends telemetry events as messages to the current process.

  This allows test cases to check that telemetry events are fired with:

      assert_receive {:telemetry_event, event, measurements, metadata}
  """
  def attach_telemetry do
    :telemetry.attach_many(
      "telemetry-test",
      [
        [:error_tracker, :error, :new],
        [:error_tracker, :error, :resolved],
        [:error_tracker, :error, :unresolved],
        [:error_tracker, :occurrence, :new]
      ],
      &__MODULE__._send_telemetry/4,
      nil
    )
  end

  def _send_telemetry(event, measurements, metadata, _opts) do
    send(self(), {:telemetry_event, event, measurements, metadata})
  end

  def repo do
    Application.fetch_env!(:error_tracker, :repo)
  end
end
