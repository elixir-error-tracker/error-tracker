defmodule ErrorTracker.Web.Router.Routes do
  @moduledoc false

  alias ErrorTracker.Error
  alias ErrorTracker.Occurrence
  alias Phoenix.LiveView.Socket

  @doc """
  Returns the dashboard path
  """
  def dashboard_path(%Socket{} = socket, params \\ %{}) do
    socket
    |> dashboard_uri(params)
    |> URI.to_string()
  end

  @doc """
  Returns the path to see the details of an error
  """
  def error_path(%Socket{} = socket, %Error{id: id}, params \\ %{}) do
    socket
    |> dashboard_uri(params)
    |> URI.append_path("/#{id}")
    |> URI.to_string()
  end

  @doc """
  Returns the path to see the details of an occurrence
  """
  def occurrence_path(%Socket{} = socket, %Occurrence{id: id, error_id: error_id}, params \\ %{}) do
    socket
    |> dashboard_uri(params)
    |> URI.append_path("/#{error_id}/#{id}")
    |> URI.to_string()
  end

  defp dashboard_uri(%Socket{} = socket, params) do
    %URI{
      path: socket.private[:dashboard_path],
      query: if(Enum.any?(params), do: URI.encode_query(params))
    }
  end
end
