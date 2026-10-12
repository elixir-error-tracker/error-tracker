defmodule ErrorTracker.FilterTest do
  use ErrorTracker.Test.Case

  alias ErrorTracker.FilterTest.AuthHeaderHider
  alias ErrorTracker.FilterTest.EmailHider

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

  @tag filter: AuthHeaderHider
  test "user defined filter should be used to sanitize the context before it's saved." do
    assert %ErrorTracker.Occurrence{context: ctx} =
             report_error(fn -> raise "BOOM" end, @sensitive_ctx)

    assert ctx != @sensitive_ctx

    cleaned_header_value =
      ctx |> Map.get("request") |> Map.get("headers") |> Map.get("authorization")

    assert cleaned_header_value == "REMOVED"
  end

  @tag filter: AuthHeaderHider
  test "without sanitize_reason/1, the error message is saved as it is." do
    assert %ErrorTracker.Occurrence{reason: "BOOM jane@example.com"} =
             report_error(fn -> raise "BOOM jane@example.com" end)
  end

  @tag filter: EmailHider
  test "sanitize_reason/1 changes the error message before it's saved." do
    occurrence = report_error(fn -> raise "BOOM jane@example.com" end)

    assert %ErrorTracker.Occurrence{reason: "BOOM [email]"} =
             repo().get!(ErrorTracker.Occurrence, occurrence.id)

    assert %ErrorTracker.Error{reason: "BOOM [email]"} =
             repo().get!(ErrorTracker.Error, occurrence.error_id)
  end

  test "an error saved before sanitize_reason/1 is cleaned when it happens again." do
    report = fn -> report_error(fn -> raise "BOOM jane@example.com" end) end
    first = report.()

    previous_setting = Application.get_env(:error_tracker, :filter)
    Application.put_env(:error_tracker, :filter, EmailHider)
    on_exit(fn -> Application.put_env(:error_tracker, :filter, previous_setting) end)
    again = report.()

    assert again.error_id == first.error_id

    assert %ErrorTracker.Error{reason: "BOOM [email]"} =
             repo().get!(ErrorTracker.Error, first.error_id)
  end
end

defmodule ErrorTracker.FilterTest.EmailHider do
  @moduledoc false
  @behaviour ErrorTracker.Filter

  def sanitize(context), do: context

  def sanitize_reason(reason), do: String.replace(reason, ~r/\S+@\S+/, "[email]")
end

defmodule ErrorTracker.FilterTest.AuthHeaderHider do
  @moduledoc false
  @behaviour ErrorTracker.Filter

  def sanitize(context) do
    context
    |> Enum.map(fn
      {"authorization", _} ->
        {"authorization", "REMOVED"}

      o ->
        o
    end)
    |> Map.new(fn
      {key, val} when is_map(val) -> {key, sanitize(val)}
      o -> o
    end)
  end
end
