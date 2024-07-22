defmodule ErrorTracker.Occurrence do
  @moduledoc """
  An Occurrence is a particular instance of an error in a given time.

  It contains all the metadata available about the moment and the environment
  in which the exception raised.
  """

  use Ecto.Schema

  schema "error_tracker_occurrences" do
    field :context, :map
    field :reason, :string

    embeds_one :stacktrace, ErrorTracker.Stacktrace
    belongs_to :error, ErrorTracker.Error

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end
end
