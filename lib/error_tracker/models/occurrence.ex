defmodule ErrorTracker.Occurrence do
  use Ecto.Schema

  schema "error_tracker_occurrences" do
    field :context, :map

    embeds_one :stacktrace, ErrorTracker.Stacktrace
    belongs_to :error, ErrorTracker.Error

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end
end
