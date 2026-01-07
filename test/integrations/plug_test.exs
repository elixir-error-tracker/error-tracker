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
      |> Plug.Conn.put_req_header("authentication-helper", "hunter42")
      |> Plug.Conn.put_req_header("important-token", "abcxyz")
      |> Plug.Conn.put_req_header("private-name", "Some call me... Tim")
      |> Plug.Conn.put_req_header("special-credential", "drink-your-ovaltine")
      |> Plug.Conn.put_req_header("special-key", "Begin Private Key; dontleakmeplz")
      |> Plug.Conn.put_req_header("special-secret", "Shh, it's a secret")
      |> Plug.Conn.put_req_header("special-password", "correct-horse-battery-staple")
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
    assert "authentication-helper" not in header_names
    assert "important-token" not in header_names
    assert "private-name" not in header_names
    assert "special-credential" not in header_names
    assert "special-key" not in header_names
    assert "special-password" not in header_names
    assert "special-secret" not in header_names

    assert "safe" in header_names
    assert length(header_names) == 1
  end
end
