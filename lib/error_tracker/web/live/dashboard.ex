defmodule ErrorTracker.Web.Live.Dashboard do
  @moduledoc false

  use ErrorTracker.Web, :live_view

  import Ecto.Query

  alias ErrorTracker.Error

  @per_page 10

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    {_search, search_form} = search_terms(params)

    {:ok, assign(socket, page: 1, total_pages: 1, search_form: search_form, errors: [])}
  end

  @impl Phoenix.LiveView
  def handle_params(params, uri, socket) do
    {search, search_form} = search_terms(params)

    path = struct(URI, uri |> URI.parse() |> Map.take([:path, :query]))

    {:noreply,
     socket
     |> assign(path: path, search: search, page: 1, search_form: search_form)
     |> paginate_errors()}
  end

  @impl Phoenix.LiveView
  def handle_event("search", params, socket) do
    {search, _search_form} = search_terms(params["search"] || %{})

    path_w_filters = %URI{socket.assigns.path | query: URI.encode_query(search)}

    {:noreply, push_patch(socket, to: URI.to_string(path_w_filters))}
  end

  @impl Phoenix.LiveView
  def handle_event("next-page", _params, socket) do
    {:noreply, socket |> assign(page: socket.assigns.page + 1) |> paginate_errors()}
  end

  @impl Phoenix.LiveView
  def handle_event("prev-page", _params, socket) do
    {:noreply, socket |> assign(page: socket.assigns.page - 1) |> paginate_errors()}
  end

  @impl Phoenix.LiveView
  def handle_event("resolve", %{"error_id" => id}, socket) do
    error = ErrorTracker.repo().get(Error, id, prefix: ErrorTracker.prefix())
    {:ok, _resolved} = ErrorTracker.resolve(error)

    {:noreply, paginate_errors(socket)}
  end

  @impl Phoenix.LiveView
  def handle_event("unresolve", %{"error_id" => id}, socket) do
    error = ErrorTracker.repo().get(Error, id, prefix: ErrorTracker.prefix())
    {:ok, _unresolved} = ErrorTracker.unresolve(error)

    {:noreply, paginate_errors(socket)}
  end

  defp paginate_errors(socket) do
    %{page: page, search: search} = socket.assigns
    repo = ErrorTracker.repo()
    prefix = ErrorTracker.prefix()

    query = filter(Error, search)

    total_errors = repo.aggregate(query, :count, prefix: prefix)

    errors_query =
      query
      |> order_by(desc: :last_occurrence_at)
      |> offset((^page - 1) * @per_page)
      |> limit(@per_page)

    assign(socket,
      errors: repo.all(errors_query, prefix: prefix),
      total_pages: (total_errors / @per_page) |> Float.ceil() |> trunc
    )
  end

  defp search_terms(params) do
    data = %{}
    types = %{reason: :string, source_line: :string, source_function: :string, status: :string}

    changeset = Ecto.Changeset.cast({data, types}, params, Map.keys(types))

    {Ecto.Changeset.apply_changes(changeset), to_form(changeset, as: :search)}
  end

  defp filter(query, search) do
    Enum.reduce(search, query, &do_filter/2)
  end

  defp do_filter({:status, status}, query) do
    where(query, [error], error.status == ^status)
  end

  defp do_filter({field, value}, query) do
    where(query, [error], ilike(field(error, ^field), ^"%#{value}%"))
  end
end
