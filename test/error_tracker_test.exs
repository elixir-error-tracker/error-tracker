defmodule ErrorTrackerTest do
  use ErrorTracker.Test.Case

  alias ErrorTracker.Error
  alias ErrorTracker.Occurrence

  # We use this file path because for some reason the test scripts are not
  # handled as part of the application, so the last line of the app executed is
  # on the case module.
  @relative_file_path "test/support/case.ex"

  describe inspect(&ErrorTracker.report/3) do
    setup context do
      if Map.has_key?(context, :enabled) do
        Application.put_env(:error_tracker, :enabled, context[:enabled])
        # Ensure that the application env is restored after each test
        on_exit(fn -> Application.delete_env(:error_tracker, :enabled) end)
      end

      []
    end

    test "reports exceptions" do
      %Occurrence{error: error = %Error{}} =
        report_error(fn -> raise "This is a test" end)

      assert error.kind == to_string(RuntimeError)
      assert error.reason == "This is a test"
      assert error.source_line =~ @relative_file_path
    end

    test "reports badarith errors" do
      string_var = to_string(1)

      %Occurrence{error: error = %Error{}, stacktrace: %{lines: [last_line | _]}} =
        report_error(fn -> 1 + string_var end)

      assert error.kind == to_string(ArithmeticError)
      assert error.reason == "bad argument in arithmetic expression"

      # Elixir 1.17.0 reports these errors differently than previous versions
      if Version.compare(System.version(), "1.17.0") == :lt do
        dbg(last_line)
        assert last_line.module == "Elixir.ErrorTrackerTest"
        assert last_line.function == "report_error/2"
        assert last_line.arity == 1
        assert last_line.file == @relative_file_path
        assert last_line.line == 11
      else
        assert last_line.module == "erlang"
        assert last_line.function == "+"
        assert last_line.arity == 2
        refute last_line.file
        refute last_line.line
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
      assert error.source_line == "(nofile)"
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

    @tag capture_log: true
    test "reports errors with invalid context" do
      # It's invalid because cannot be serialized to JSON
      invalid_context = %{foo: %ErrorTracker.Error{}}

      assert %Occurrence{} = report_error(fn -> raise "test" end, invalid_context)
    end

    test "without enabled flag it works as expected" do
      # Ensure no value is set
      Application.delete_env(:error_tracker, :enabled)

      assert %Occurrence{} = report_error(fn -> raise "Sample error" end)
    end

    @tag enabled: true
    test "with enabled flag to true it works as expected" do
      assert %Occurrence{} = report_error(fn -> raise "Sample error" end)
    end

    @tag enabled: false
    test "with enabled flag to false it does not store the exception" do
      assert report_error(fn -> raise "Sample error" end) == :noop
    end

    test "includes breadcrumbs if present" do
      breadcrumbs = ["breadcrumb 1", "breadcrumb 2"]

      occurrence =
        report_error(fn ->
          raise ErrorWithBreadcrumbs, message: "test", bread_crumbs: breadcrumbs
        end)

      assert occurrence.breadcrumbs == breadcrumbs
    end

    test "includes breadcrumbs if stored by the user" do
      ErrorTracker.add_breadcrumb("breadcrumb 1")
      ErrorTracker.add_breadcrumb("breadcrumb 2")

      occurrence = report_error(fn -> raise "Sample error" end)

      assert occurrence.breadcrumbs == ["breadcrumb 1", "breadcrumb 2"]
    end

    test "merges breadcrumbs stored by the user and contained on the exception" do
      ErrorTracker.add_breadcrumb("breadcrumb 1")
      ErrorTracker.add_breadcrumb("breadcrumb 2")

      occurrence =
        report_error(fn ->
          raise ErrorWithBreadcrumbs, message: "test", bread_crumbs: ["breadcrumb 3"]
        end)

      assert occurrence.breadcrumbs == ["breadcrumb 1", "breadcrumb 2", "breadcrumb 3"]
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

  describe inspect(&ErrorTracker.add_breadcrumb/1) do
    test "adds an entry to the breadcrumbs list" do
      ErrorTracker.add_breadcrumb("breadcrumb 1")
      ErrorTracker.add_breadcrumb("breadcrumb 2")

      assert ["breadcrumb 1", "breadcrumb 2"] = ErrorTracker.get_breadcrumbs()
    end
  end
end

defmodule ErrorWithBreadcrumbs do
  defexception [:message, :bread_crumbs]
end
