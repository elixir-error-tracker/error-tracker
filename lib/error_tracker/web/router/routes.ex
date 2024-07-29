defmodule ErrorTracker.Web.Router.Routes do
  @moduledoc false

  alias ErrorTracker.Error
  alias ErrorTracker.Occurrence
  alias Phoenix.LiveView.Socket

  @doc """
  Returns the dashboard path
  """
  def dashboard_path(socket = %Socket{}) do
    socket.private[:dashboard_path]
  end

  @doc """
  Returns the path to see the details of an error
  """
  def error_path(socket = %Socket{}, %Error{id: id}) do
    dashboard_path(socket) <> "/#{id}"
  end

  @doc """
  Returns the path to see the details of an occurrence
  """
  def occurrence_path(socket = %Socket{}, %Occurrence{id: id, error_id: error_id}) do
    dashboard_path(socket) <> "/#{error_id}/#{id}"
  end
end
