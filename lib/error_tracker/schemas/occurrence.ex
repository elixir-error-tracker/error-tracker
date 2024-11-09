defmodule ErrorTracker.Occurrence do
  @moduledoc """
  Schema to store a particular instance of an error in a given time.

  It contains all the metadata available about the moment and the environment
  in which the exception raised.
  """

  import Ecto.Changeset

  use Ecto.Schema

  require Logger

  @type t :: %__MODULE__{}

  schema "error_tracker_occurrences" do
    field :reason, :string

    field :context, :map
    field :bread_crumbs, {:array, :string}

    embeds_one :stacktrace, ErrorTracker.Stacktrace
    belongs_to :error, ErrorTracker.Error

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  @doc false
  def changeset(occurrence, attrs) do
    occurrence
    |> cast(attrs, [:context, :reason, :bread_crumbs])
    |> maybe_put_stacktrace()
    |> validate_required([:reason, :stacktrace])
    |> validate_context()
    |> foreign_key_constraint(:error)
  end

  # This function validates if the context can be serialized to JSON before
  # storing it to the DB.
  #
  # If it cannot be serialized a warning log message is emitted and an error
  # is stored in the context.
  #
  defp validate_context(changeset) do
    if changeset.valid? do
      context = get_field(changeset, :context, %{})

      json_encoder =
        ErrorTracker.Repo.with_adapter(fn
          :postgres -> Application.get_env(:postgrex, :json_library, Jason)
          :mysql -> Application.get_env(:myxql, :json_library, Jason)
          :sqlite -> Application.get_env(:ecto_sqlite3, :json_library, Jason)
        end)

      case json_encoder.encode_to_iodata(context) do
        {:ok, _} ->
          put_change(changeset, :context, context)

        {:error, _} ->
          Logger.warning(
            "[ErrorTracker] Context has been ignored: it is not serializable to JSON."
          )

          put_change(changeset, :context, %{
            error: "Context not stored because it contains information not serializable to JSON."
          })
      end
    else
      changeset
    end
  end

  defp maybe_put_stacktrace(changeset) do
    if stacktrace = Map.get(changeset.params, "stacktrace"),
      do: put_embed(changeset, :stacktrace, stacktrace),
      else: changeset
  end
end
