defmodule ErrorTracker.Integrations.PhoenixTest do
  use ErrorTracker.Test.Case

  setup do
    ErrorTracker.Integrations.Phoenix.attach()
    :ok
  end

  test "[:phoenix, :router_dispatch, :start]" do
    :telemetry.execute([:phoenix, :router_dispatch, :start], %{}, %{conn: %Plug.Conn{}})
  end
end
