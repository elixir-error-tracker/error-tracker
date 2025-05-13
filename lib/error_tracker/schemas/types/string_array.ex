defmodule ErrorTracker.Types.StringArray do
  @moduledoc """
  Custom Ecto type for lists.

  The built-in `:array` type is not properly implemented for the Ecto adapter `Ecto.Adapters.MyXQL`.
  Therefore we can not use it and have to impelement our own.
  """
  use Ecto.Type

  def type, do: {:array, :string}

  def cast(list) when is_list(list) do
    {:ok, list}
  end

  def cast(_), do: :error

  def load(list) when is_binary(list) do
    Jason.decode(list)
  end

  def load(list) when is_nil(list) do
    []
  end

  def load(list), do: {:ok, list}

  def dump(list) when is_list(list) do
    ErrorTracker.Repo.with_adapter(fn
      :mysql -> Jason.encode(list)
      _ -> {:ok, list}
    end)
  end

  def dump(_), do: :error
end
