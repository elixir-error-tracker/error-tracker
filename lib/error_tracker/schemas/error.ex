defmodule ErrorTracker.Error do
  @moduledoc """
  An Error is a type of exception recorded by the ErrorTracker.

  It stores a kind, reason and source code location to generate a unique
  fingerprint that can be used to avoid duplicates.
  """

  use Ecto.Schema

  schema "error_tracker_errors" do
    field :kind, :string
    field :reason, :string
    field :source_line, :string
    field :source_function, :string
    field :status, Ecto.Enum, values: [:resolved, :unresolved], default: :unresolved
    field :fingerprint, :binary

    has_many :occurrences, ErrorTracker.Occurrence

    timestamps(type: :utc_datetime_usec)
  end

  def new(exception, stacktrace = %ErrorTracker.Stacktrace{}) do
    source = ErrorTracker.Stacktrace.source(stacktrace)

    params = [
      kind: "error",
      reason: Exception.message(exception),
      source_line: "#{source.file}:#{source.line}",
      source_function: "#{source.module}.#{source.function}/#{source.arity}"
    ]

    fingerprint = :crypto.hash(:sha256, params |> Keyword.values() |> Enum.join())

    %__MODULE__{}
    |> Ecto.Changeset.change(params)
    |> Ecto.Changeset.put_change(:fingerprint, Base.encode16(fingerprint))
    |> Ecto.Changeset.apply_action(:new)
  end
end
