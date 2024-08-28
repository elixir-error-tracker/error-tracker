defmodule ErrorTracker.OccurrenceTest do
  use ErrorTracker.Test.Case

  import Ecto.Changeset

  alias ErrorTracker.Occurrence
  alias ErrorTracker.Stacktrace

  describe inspect(&Occurrence.changeset/2) do
    test "works as expected with valid data" do
      attrs = %{context: %{foo: :bar}, reason: "Test reason", stacktrace: %Stacktrace{}}
      changeset = Occurrence.changeset(%Occurrence{}, attrs)

      assert changeset.valid?
    end

    test "validates required fields" do
      changeset = Occurrence.changeset(%Occurrence{}, %{})

      refute changeset.valid?
      assert {_, [validation: :required]} = changeset.errors[:reason]
      assert {_, [validation: :required]} = changeset.errors[:stacktrace]
    end

    @tag capture_log: true
    test "if context is not serializable, an error messgae is stored" do
      attrs = %{
        context: %{foo: %ErrorTracker.Error{}},
        reason: "Test reason",
        stacktrace: %Stacktrace{}
      }

      changeset = Occurrence.changeset(%Occurrence{}, attrs)

      assert %{error: err} = get_field(changeset, :context)
      assert err =~ "not serializable to JSON"
    end
  end
end
