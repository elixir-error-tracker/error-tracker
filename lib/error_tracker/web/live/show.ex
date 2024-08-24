defmodule ErrorTracker.Web.Live.Show do
  @moduledoc false
  use ErrorTracker.Web, :live_view

  import Ecto.Query

  alias ErrorTracker.Error
  alias ErrorTracker.Occurrence
  alias ErrorTracker.Repo

  @occurrences_to_navigate 50

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    error = Repo.get!(Error, id)
    {:ok, assign(socket, error: error, app: Application.fetch_env!(:error_tracker, :otp_app))}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"occurrence_id" => occurrence_id}, _uri, socket) do
    occurrence =
      socket.assigns.error
      |> Ecto.assoc(:occurrences)
      |> Repo.get!(occurrence_id)

    socket =
      socket
      |> assign(:occurrence, occurrence)
      |> load_related_occurrences()

    {:noreply, socket}
  end

  def handle_params(_, _uri, socket) do
    [occurrence] =
      socket.assigns.error
      |> Ecto.assoc(:occurrences)
      |> order_by([o], desc: o.id)
      |> limit(1)
      |> Repo.all()

    socket =
      socket
      |> assign(:occurrence, occurrence)
      |> load_related_occurrences()

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("occurrence_navigation", %{"occurrence_id" => id}, socket) do
    {:noreply,
     push_patch(socket,
       to: occurrence_path(socket, %Occurrence{error_id: socket.assigns.error.id, id: id})
     )}
  end

  @impl Phoenix.LiveView
  def handle_event("resolve", _params, socket) do
    {:ok, updated_error} = ErrorTracker.resolve(socket.assigns.error)

    {:noreply, assign(socket, :error, updated_error)}
  end

  @impl Phoenix.LiveView
  def handle_event("unresolve", _params, socket) do
    {:ok, updated_error} = ErrorTracker.unresolve(socket.assigns.error)

    {:noreply, assign(socket, :error, updated_error)}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", _params, socket) do
    error = Repo.get!(Error, socket.assigns.error.id)
    {:ok, _} = Repo.delete(error)
    {:noreply, redirect(socket, to: dashboard_path(socket))}
  end

  defp load_related_occurrences(socket) do
    current_occurrence = socket.assigns.occurrence
    base_query = Ecto.assoc(socket.assigns.error, :occurrences)

    half_limit = floor(@occurrences_to_navigate / 2)

    previous_occurrences_query = where(base_query, [o], o.id < ^current_occurrence.id)
    next_occurrences_query = where(base_query, [o], o.id > ^current_occurrence.id)
    previous_count = Repo.aggregate(previous_occurrences_query, :count)
    next_count = Repo.aggregate(next_occurrences_query, :count)

    {previous_limit, next_limit} =
      cond do
        previous_count < half_limit and next_count < half_limit ->
          {previous_count, next_count}

        previous_count < half_limit ->
          {previous_count, @occurrences_to_navigate - previous_count - 1}

        next_count < half_limit ->
          {@occurrences_to_navigate - next_count - 1, next_count}

        true ->
          {half_limit, half_limit}
      end

    occurrences =
      [
        related_occurrences(next_occurrences_query, next_limit),
        current_occurrence,
        related_occurrences(previous_occurrences_query, previous_limit)
      ]
      |> List.flatten()
      |> Enum.reverse()

    total_occurrences =
      socket.assigns.error
      |> Ecto.assoc(:occurrences)
      |> Repo.aggregate(:count)

    socket
    |> assign(:occurrences, occurrences)
    |> assign(:total_occurrences, total_occurrences)
  end

  defp related_occurrences(query, num_results) do
    query
    |> order_by([o], desc: o.id)
    |> select([:id, :error_id, :inserted_at])
    |> limit(^num_results)
    |> Repo.all()
  end
end
