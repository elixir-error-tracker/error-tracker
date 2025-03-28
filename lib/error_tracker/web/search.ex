defmodule ErrorTracker.Web.Search do
  @moduledoc false

  @types %{
    reason: :string,
    source_line: :string,
    source_function: :string,
    status: :string
  }

  defp changeset(params) do
    Ecto.Changeset.cast({%{}, @types}, params, Map.keys(@types))
  end

  @spec from_params(map()) :: %{atom() => String.t()}
  def from_params(params) do
    params |> changeset() |> Ecto.Changeset.apply_changes()
  end

  @spec to_form(map()) :: Phoenix.HTML.Form.t()
  def to_form(params) do
    params |> changeset() |> Phoenix.Component.to_form(as: :search)
  end
end
