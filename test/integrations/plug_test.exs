defmodule ErrorTracker.Integrations.PlugTest do
  use ErrorTracker.Test.Case

  alias ErrorTracker.Integrations.Plug, as: IntegrationPlug

  @fake_callstack []

  test "it reports errors, including the request headers" do
    conn = Phoenix.ConnTest.build_conn() |> Plug.Conn.put_req_header("accept", "application/json")

    IntegrationPlug.report_error(
      conn,
      {"an error from Phoenix", "something bad happened"},
      @fake_callstack
    )

    [error] = repo().all(ErrorTracker.Error)

    assert error.kind == "an error from Phoenix"
    assert error.reason == "something bad happened"

    [occurrence] = repo().all(ErrorTracker.Occurrence)
    assert occurrence.error_id == error.id

    %{"request.headers" => request_headers} = occurrence.context
    assert request_headers == %{"accept" => "application/json"}
  end
end
