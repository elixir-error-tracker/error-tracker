defmodule ErrorTracker.FilterTest do
  use ErrorTracker.Test.Case

  setup context do
    if filter = context[:filter] do
      previous_setting = Application.get_env(:error_tracker, :filter)
      Application.put_env(:error_tracker, :filter, filter)
      # Ensure that the application env is restored after each test
      on_exit(fn -> Application.put_env(:error_tracker, :filter, previous_setting) end)
    end

    []
  end

  @sensitive_ctx %{
    "request" => %{
      "headers" => %{
        "accept" => "application/json, text/plain, */*",
        "authorization" => "Bearer 12341234"
      }
    }
  }

  test "without an filter, context objects are saved as they are." do
    assert %ErrorTracker.Occurrence{context: ctx} =
             report_error(fn -> raise "BOOM" end, @sensitive_ctx)

    assert ctx == @sensitive_ctx
  end

  @tag filter: ErrorTracker.FilterTest.AuthHeaderHider
  test "user defined filter should be used to sanitize the context before it's saved." do
    assert %ErrorTracker.Occurrence{context: ctx} =
             report_error(fn -> raise "BOOM" end, @sensitive_ctx)

    assert ctx != @sensitive_ctx

    cleaned_header_value =
      ctx |> Map.get("request") |> Map.get("headers") |> Map.get("authorization")

    assert cleaned_header_value == "REMOVED"
  end
end

defmodule ErrorTracker.FilterTest.AuthHeaderHider do
  @behaviour ErrorTracker.Filter

  def sanitize(context) do
    context
    |> Enum.map(fn
      {"authorization", _} ->
        {"authorization", "REMOVED"}

      o ->
        o
    end)
    |> Enum.map(fn
      {key, val} when is_map(val) -> {key, sanitize(val)}
      o -> o
    end)
    |> Map.new()
  end
end
