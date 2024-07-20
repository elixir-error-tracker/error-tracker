defmodule ErrorTracker.Web.Live.Show do
  @moduledoc false
  use ErrorTracker.Web, :live_view

  import Ecto.Query

  alias ErrorTracker.Error
  alias ErrorTracker.Repo

  @occurreneces_to_navigate 50

  def mount(%{"id" => id}, _session, socket) do
    error = Repo.get!(Error, id)
    {:ok, assign(socket, error: error)}
  end

  def handle_params(%{"occurence_id" => occurrence_id}, _uri, socket) do
    base_query = Ecto.assoc(socket.assigns.error, :occurrences)
    occurrence = Repo.get!(base_query, occurrence_id)

    previous_occurrences =
      base_query
      |> where([o], o.id < ^occurrence.id)
      |> related_occurrences(@occurreneces_to_navigate / 2)

    limit_next_occurrences = @occurreneces_to_navigate - length(previous_occurrences) - 1

    next_occurrences =
      base_query
      |> where([o], o.id > ^occurrence.id)
      |> related_occurrences(limit_next_occurrences)

    socket =
      socket
      |> assign(:occurrences, previous_occurrences ++ occurrence ++ next_occurrences)
      |> assign(:occurrence, occurrence)

    {:noreply, socket}
  end

  def handle_params(_, _uri, socket) do
    base_query = Ecto.assoc(socket.assigns.error, :occurrences)

    occurrences = related_occurrences(base_query)
    occurrence = Repo.get!(base_query, hd(occurrences).id)

    socket =
      socket
      |> assign(:occurrences, occurrences)
      |> assign(:occurrence, occurrence)

    {:noreply, socket}
  end

  defp related_occurrences(query, num_results \\ @occurreneces_to_navigate) do
    query
    |> order_by([o], desc: o.id)
    |> select([:id, :inserted_at])
    |> limit(^num_results)
    |> Repo.all()
  end
end
