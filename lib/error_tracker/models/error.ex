defmodule ErrorTracker.Error do
  use Ecto.Schema

  schema "error_tracker_errors" do
    field :kind, :string
    field :reason, :string
    field :source, :string
    field :status, Ecto.Enum, values: [:resolved, :unresolved], default: :unresolved
    field :fingerprint, :binary

    has_many :occurrences, ErrorTracker.Occurrence

    timestamps()
  end

  def new(exception, stacktrace = %ErrorTracker.Stacktrace{}) do
    source = ErrorTracker.Stacktrace.source(stacktrace)

    params = [
      kind: "error",
      reason: Exception.message(exception),
      source: to_string(source)
    ]

    fingerprint = :crypto.hash(:sha256, params |> Keyword.values() |> Enum.join())

    %__MODULE__{}
    |> Ecto.Changeset.change(params)
    |> Ecto.Changeset.put_change(:fingerprint, Base.encode16(fingerprint))
    |> Ecto.Changeset.apply_action(:new)
  end
end
