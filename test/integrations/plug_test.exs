defmodule ErrorTracker.Integrations.PlugTest do
  use ErrorTracker.Test.Case

  alias ErrorTracker.Integrations.Plug, as: IntegrationPlug

  @fake_callstack []

  setup do
    [conn: Phoenix.ConnTest.build_conn()]
  end

  test "it reports errors, including the request headers", %{conn: conn} do
    conn = conn |> Plug.Conn.put_req_header("accept", "application/json")

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

  test "it does not save sensitive request headers, to avoid storing them in cleartext", %{
    conn: conn
  } do
    conn =
      conn
      |> Plug.Conn.put_req_header("cookie", "who stole the cookie from the cookie jar ?")
      |> Plug.Conn.put_req_header("authorization", "Bearer plz-dont-leak-my-secrets")
      |> Plug.Conn.put_req_header("safe", "this can be safely stored in cleartext")

    IntegrationPlug.report_error(
      conn,
      {"an error from Phoenix", "something bad happened"},
      @fake_callstack
    )

    [occurrence] = repo().all(ErrorTracker.Occurrence)

    header_names = occurrence.context |> Map.get("request.headers") |> Map.keys()

    assert "cookie" not in header_names
    assert "authorization" not in header_names

    assert "safe" in header_names
  end
end
