defmodule ErrorTrackerTest do
  use ErrorTracker.Test.Case

  alias ErrorTracker.{Error, Occurrence, Stacktrace}
  alias ErrorTracker.Test.Repo

  describe inspect(&ErrorTracker.report/3) do
    test "reports exceptions" do
      %Occurrence{error: error = %Error{}, stacktrace: stack = %Stacktrace{}} = report_error()

      # The exception kind and reason have been recorded
      assert error.kind == to_string(RuntimeError)
      assert error.reason == "This is a test exception"
      # Reported errors are unresolved
      assert error.status == :unresolved
      # The stack trace points to the current file, which raised the exception
      assert Path.absname(List.first(stack.lines).file, File.cwd!()) == __ENV__.file
    end
  end

  describe inspect(&ErrorTracker.resolve/1) do
    test "marks the error as resolved" do
      %Occurrence{error: error} = report_error()

      assert {:ok, %Error{status: :resolved}} = ErrorTracker.resolve(error)
    end
  end

  describe inspect(&ErrorTracker.unresolve/1) do
    test "marks the error as unresolved" do
      %Occurrence{error: error} = report_error()
      # Manually mark the error as resolved
      {:ok, resolved} = ErrorTracker.resolve(error)

      assert {:ok, %Error{status: :unresolved}} = ErrorTracker.unresolve(resolved)
    end
  end

  defp report_error do
    expected_error = RuntimeError
    expected_reason = "This is a test exception"

    occurrence =
      try do
        raise expected_error, expected_reason
      rescue
        exception ->
          ErrorTracker.report(exception, __STACKTRACE__)
      end

    Repo.preload(occurrence, :error)
  end
end
