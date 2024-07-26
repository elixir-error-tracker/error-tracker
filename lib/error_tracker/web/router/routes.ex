defmodule ErrorTracker.Web.Router.Routes do
  @moduledoc false

  alias ErrorTracker.Error
  alias ErrorTracker.Occurrence

  @doc """
  Returns the dashboard path
  """
  def dashboard_path(%{dashboard_path: dashboard_path}), do: dashboard_path

  @doc """
  Returns the path to see the details of an error
  """
  def error_path(assigns, %Error{id: id}), do: dashboard_path(assigns) <> "/#{id}"

  @doc """
  Returns the path to see the details of an occurrence
  """
  def occurrence_path(assigns, %Occurrence{id: id, error_id: error_id}),
    do: dashboard_path(assigns) <> "/#{error_id}/#{id}"
end
