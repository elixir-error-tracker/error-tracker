defmodule ErrorTracker.IgnorerTest do
  use ErrorTracker.Test.Case

  setup context do
    if ignorer = context[:ignorer] do
      previous_setting = Application.get_env(:error_tracker, :ignorer)
      Application.put_env(:error_tracker, :ignorer, ignorer)
      # Ensure that the application env is restored after each test
      on_exit(fn -> Application.put_env(:error_tracker, :ignorer, previous_setting) end)
    end

    []
  end

  @tag ignorer: ErrorTracker.EveryErrorIgnorer
  test "with an ignorer ignores errors" do
    assert :noop = report_error(fn -> raise "[IGNORE] Sample error" end)
    assert %ErrorTracker.Occurrence{} = report_error(fn -> raise "Sample error" end)
  end

  @tag ignorer: false
  test "without an ignorer does not ignore errors" do
    assert %ErrorTracker.Occurrence{} = report_error(fn -> raise "[IGNORE] Sample error" end)
    assert %ErrorTracker.Occurrence{} = report_error(fn -> raise "Sample error" end)
  end
end

defmodule ErrorTracker.EveryErrorIgnorer do
  @behaviour ErrorTracker.Ignorer

  @impl true
  def ignore?(error, _context) do
    String.contains?(error.reason, "[IGNORE]")
  end
end
