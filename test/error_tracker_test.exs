defmodule ErrorTrackerTest do
  use ErrorTracker.Test.Case

  alias ErrorTracker.Error
  alias ErrorTracker.Occurrence

  @relative_file_path Path.relative_to(__ENV__.file, File.cwd!())

  describe inspect(&ErrorTracker.report/3) do
    test "reports exceptions" do
      %Occurrence{error: error = %Error{}} =
        report_error(fn -> raise "This is a test" end)

      assert error.kind == to_string(RuntimeError)
      assert error.reason == "This is a test"
      assert error.source_line =~ @relative_file_path
    end

    test "reports badarith errors" do
      string_var = to_string(1)

      %Occurrence{error: error = %Error{}} =
        report_error(fn -> 1 + string_var end)

      assert error.kind == to_string(ArithmeticError)
      assert error.reason == "bad argument in arithmetic expression"

      # Elixir 1.17.0 reports these errors differently than previous versions
      if Version.compare(System.version(), "1.17.0") == :lt do
        assert error.source_line =~ @relative_file_path
      else
        assert error.source_function == "erlang.+/2"
        assert error.source_line == "nofile"
      end
    end

    test "reports undefined function errors" do
      # This function does not exist and will raise when called
      {m, f, a} = {ErrorTracker, :invalid_fun, []}

      %Occurrence{error: error = %Error{}} =
        report_error(fn -> apply(m, f, a) end)

      assert error.kind == to_string(UndefinedFunctionError)
      assert error.reason =~ "is undefined or private"
      assert error.source_function == Exception.format_mfa(m, f, Enum.count(a))
      assert error.source_line == "nofile"
    end

    test "reports throws" do
      %Occurrence{error: error = %Error{}} =
        report_error(fn -> throw("This is a test") end)

      assert error.kind == "throw"
      assert error.reason == "This is a test"
      assert error.source_line =~ @relative_file_path
    end

    test "reports exits" do
      %Occurrence{error: error = %Error{}} =
        report_error(fn -> exit("This is a test") end)

      assert error.kind == "exit"
      assert error.reason == "This is a test"
      assert error.source_line =~ @relative_file_path
    end
  end

  describe inspect(&ErrorTracker.resolve/1) do
    test "marks the error as resolved" do
      %Occurrence{error: error} = report_error(fn -> raise "This is a test" end)

      assert {:ok, %Error{status: :resolved}} = ErrorTracker.resolve(error)
    end
  end

  describe inspect(&ErrorTracker.unresolve/1) do
    test "marks the error as unresolved" do
      %Occurrence{error: error} = report_error(fn -> raise "This is a test" end)
      # Manually mark the error as resolved
      {:ok, resolved} = ErrorTracker.resolve(error)

      assert {:ok, %Error{status: :unresolved}} = ErrorTracker.unresolve(resolved)
    end
  end
end
