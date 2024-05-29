defmodule ErrorTracker.Occurrence do
  use Ecto.Schema

  schema "error_tracker_occurrences" do
    field :context, :map

    embeds_one :stacktrace, ErrorTracker.Stacktrace
    belongs_to :error, ErrorTracker.Error

    timestamps(updated_at: false)
  end
end
