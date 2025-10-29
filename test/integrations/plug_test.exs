defmodule ErrorTracker.Integrations.PlugTest do
  use ErrorTracker.Test.Case

  alias ErrorTracker.Integrations.Plug

  @fake_callstack []

  test "it reports errors" do
    conn = Phoenix.ConnTest.build_conn()

    Plug.report_error(conn, {"an error from Phoenix", "something bad happened"}, @fake_callstack)

    [error] = repo().all(ErrorTracker.Error)

    assert error.kind == "an error from Phoenix"
    assert error.reason == "something bad happened"
  end
end
