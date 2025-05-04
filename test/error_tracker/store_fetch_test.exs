defmodule ErrorTracker.StoreFetchTest do
  @moduledoc """
  Test if simple store-retrieve operations are successful.

  This is necessary, because some Ecto adapters like `Ecto.Adapters.MyXQL` may successfully store a field, but crash on retrieval.
  """
  use ErrorTracker.Test.Case

  test "after reporting an error its occurrence should be retrievable from DB" do
    assert %ErrorTracker.Occurrence{id: occurrence_id} =
             report_error(fn -> raise "BOOM" end)

    assert %ErrorTracker.Occurrence{} = repo().get!(ErrorTracker.Occurrence, occurrence_id)
  end
end
