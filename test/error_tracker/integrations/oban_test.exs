defmodule ErrorTracker.Integrations.ObanTest do
  use ErrorTracker.Test.Case

  alias ErrorTracker.Error
  alias ErrorTracker.Occurrence

  setup do
    attach_telemetry()

    :ok
  end

  test "attaches to Oban events" do
    assert attached?([:oban, :job, :exception])
  end

  test "send the exception" do
    execute_job_exception()

    assert_receive {:telemetry_event, [:error_tracker, :error, :new], _,
                    %{error: error = %Error{}}}

    assert_receive {:telemetry_event, [:error_tracker, :occurrence, :new], _,
                    %{occurrence: occurrence = %Occurrence{}}}

    assert error.kind == to_string(RuntimeError)
    assert error.reason == "Exception!"
    assert is_map(occurrence.context)
  end

  defp attached?(event, function \\ nil) do
    event
    |> :telemetry.list_handlers()
    |> Enum.any?(fn %{id: id} ->
      case function do
        nil -> true
        f -> function == f
      end && id == ErrorTracker.Integrations.Oban
    end)
  end

  defp sample_metadata do
    %{
      job: %{
        args: %{foo: "bar"},
        attempt: 1,
        id: 123,
        priority: 1,
        queue: :default,
        worker: :"Test.Worker"
      }
    }
  end

  defp execute_job_exception(additional_metadata \\ %{}) do
    raise "Exception!"
  catch
    kind, reason ->
      metadata =
        Map.merge(sample_metadata(), %{
          reason: reason,
          kind: kind,
          stacktrace: __STACKTRACE__
        })

      :telemetry.execute(
        [:oban, :job, :exception],
        %{duration: 123 * 1_000_000},
        Map.merge(metadata, additional_metadata)
      )
  end
end
