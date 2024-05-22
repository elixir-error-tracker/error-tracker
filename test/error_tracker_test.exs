defmodule ErrorTrackerTest do
  use ExUnit.Case
  doctest ErrorTracker

  test "greets the world" do
    assert ErrorTracker.hello() == :world
  end
end
