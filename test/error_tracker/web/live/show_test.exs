defmodule ErrorTracker.Web.Live.ShowTest do
  use ExUnit.Case, async: true

  alias ErrorTracker.Error
  alias ErrorTracker.Occurrence
  alias ErrorTracker.Stacktrace
  alias ErrorTracker.Web.Live.Show

  test "copy_error_text/3 includes LLM-friendly error details" do
    error = %Error{
      id: 123,
      kind: "Elixir.RuntimeError",
      source_function: "Demo.run/1",
      source_line: "lib/demo.ex:10"
    }

    occurrence = %Occurrence{
      id: 456,
      reason: "Something broke",
      breadcrumbs: ["opened dashboard", "clicked button"],
      context: %{"request_id" => "req-1"},
      stacktrace: %Stacktrace{
        lines: [
          %Stacktrace.Line{
            application: "demo",
            module: "Demo",
            function: "run",
            arity: 1,
            file: "lib/demo.ex",
            line: 10
          },
          %Stacktrace.Line{
            application: nil,
            module: "Kernel",
            function: "apply",
            arity: 2,
            file: "nofile",
            line: nil
          }
        ]
      }
    }

    text = Show.copy_error_text(error, occurrence, :fallback_app)

    assert text =~ "Error #123"
    assert text =~ "Occurrence #456"
    assert text =~ "Kind: Elixir.RuntimeError"
    assert text =~ "Message:\nSomething broke"
    assert text =~ "Source:\nDemo.run/1\nlib/demo.ex:10"
    assert text =~ "Breadcrumbs:\n1. clicked button\n2. opened dashboard"
    assert text =~ "(demo) Demo.run/1\n    lib/demo.ex:10"
    assert text =~ "(fallback_app) Kernel.apply/2\n    (nofile)"
    assert text =~ ~s("request_id":"req-1")
  end
end
