defmodule ErrorTracker.Web.Live.Dashboard do
  @moduledoc false

  use ErrorTracker.Web, :live_view

  import Ecto.Query

  alias ErrorTracker.Error

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page: 1, per_page: 5)
     |> paginate_errors(1)}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("next-page", _params, socket) do
    {:noreply, paginate_errors(socket, socket.assigns.page + 1)}
  end

  @impl Phoenix.LiveView
  def handle_event("prev-page", %{"_overran" => true}, socket) do
    {:noreply, paginate_errors(socket, 1)}
  end

  @impl Phoenix.LiveView
  def handle_event("prev-page", _params, socket) do
    if socket.assigns.page > 1 do
      {:noreply, paginate_errors(socket, socket.assigns.page - 1)}
    else
      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("resolve", %{"error_id" => id}, socket) do
    error = ErrorTracker.repo().get(Error, id, prefix: ErrorTracker.prefix())
    {:ok, resolved} = ErrorTracker.resolve(error)

    {:noreply, stream_insert(socket, :errors, resolved)}
  end

  @impl Phoenix.LiveView
  def handle_event("unresolve", %{"error_id" => id}, socket) do
    error = ErrorTracker.repo().get(Error, id, prefix: ErrorTracker.prefix())
    {:ok, unresolved} = ErrorTracker.unresolve(error)

    {:noreply, stream_insert(socket, :errors, unresolved)}
  end

  defp paginate_errors(socket, new_page) when new_page >= 1 do
    %{per_page: per_page, page: cur_page} = socket.assigns

    errors =
      ErrorTracker.repo().all(
        from(Error,
          order_by: [desc: :last_occurrence_at],
          offset: (^new_page - 1) * ^per_page,
          limit: ^per_page
        ),
        prefix: ErrorTracker.prefix()
      )

    {errors, at, limit} =
      if new_page >= cur_page do
        {errors, -1, per_page * 3 * -1}
      else
        {Enum.reverse(errors), 0, per_page * 3}
      end

    case errors do
      [] ->
        assign(socket, end_of_errors?: at == -1)

      [_ | _] ->
        socket
        |> assign(end_of_errors?: false, page: new_page)
        |> stream(:errors, errors, at: at, limit: limit)
    end
  end
end
