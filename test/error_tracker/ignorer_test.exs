defmodule ErrorTracker.IgnorerTest do
  use ErrorTracker.Test.Case

  setup_all do
    Application.put_env(:error_tracker, :ignorer, ErrorTracker.EveryErrorIgnorer)
  end

  test "ignores errors" do
    refute report_error(fn -> raise "[IGNORE] Sample error" end)
    assert report_error(fn -> raise "Sample error" end)
  end
end

defmodule ErrorTracker.EveryErrorIgnorer do
  @behaviour ErrorTracker.Ignorer

  @impl true
  def ignore?(error, _context) do
    String.contains?(error.reason, "[IGNORE]")
  end
end
