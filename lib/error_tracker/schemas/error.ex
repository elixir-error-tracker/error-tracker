defmodule ErrorTracker.Error do
  @moduledoc """
  Schema to store an error or exception recorded by ErrorTracker.

  It stores a kind, reason and source code location to generate a unique
  fingerprint that can be used to avoid duplicates.

  The fingerprint currently does not include the reason itself because it can
  contain specific details that can change on the same error depending on
  runtime conditions.
  """

  use Ecto.Schema

  schema "error_tracker_errors" do
    field :kind, :string
    field :reason, :string
    field :source_line, :string
    field :source_function, :string
    field :status, Ecto.Enum, values: [:resolved, :unresolved], default: :unresolved
    field :fingerprint, :binary
    field :last_occurrence_at, :utc_datetime_usec

    has_many :occurrences, ErrorTracker.Occurrence

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def new(kind, reason, stacktrace = %ErrorTracker.Stacktrace{}) do
    source = ErrorTracker.Stacktrace.source(stacktrace)

    params = [
      kind: to_string(kind),
      source_line: "#{source.file}:#{source.line}",
      source_function: "#{source.module}.#{source.function}/#{source.arity}"
    ]

    fingerprint = :crypto.hash(:sha256, params |> Keyword.values() |> Enum.join())

    %__MODULE__{}
    |> Ecto.Changeset.change(params)
    |> Ecto.Changeset.put_change(:reason, reason)
    |> Ecto.Changeset.put_change(:fingerprint, Base.encode16(fingerprint))
    |> Ecto.Changeset.put_change(:last_occurrence_at, DateTime.utc_now())
    |> Ecto.Changeset.apply_action(:new)
  end
end
