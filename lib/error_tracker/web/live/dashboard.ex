defmodule ErrorTracker.Web.Live.Dashboard do
  @moduledoc false

  use ErrorTracker.Web, :live_view

  import Ecto.Query

  alias ErrorTracker.Error
  alias ErrorTracker.Repo

  @per_page 10

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
    error = Repo.get(Error, id)
    {:ok, _resolved} = ErrorTracker.resolve(error)

    {:noreply, paginate_errors(socket)}
  end

  @impl Phoenix.LiveView
  def handle_event("unresolve", %{"error_id" => id}, socket) do
    error = Repo.get(Error, id)
    {:ok, _unresolved} = ErrorTracker.unresolve(error)

    {:noreply, paginate_errors(socket)}
  end

  @impl Phoenix.LiveView
  def handle_event("mute", %{"error_id" => id}, socket) do
    error = Repo.get(Error, id)
    {:ok, _muted} = ErrorTracker.mute(error)

    {:noreply, paginate_errors(socket)}
  end

  @impl Phoenix.LiveView
  def handle_event("unmute", %{"error_id" => id}, socket) do
    error = Repo.get(Error, id)
    {:ok, _unmuted} = ErrorTracker.unmute(error)

    {:noreply, paginate_errors(socket)}
  end

  defp paginate_errors(socket) do
    %{page: page, search: search} = socket.assigns
    offset = (page - 1) * @per_page
    query = filter(Error, search)

    total_errors = Repo.aggregate(query, :count)

    errors =
      Repo.all(
        from query,
          order_by: [desc: :last_occurrence_at],
          offset: ^offset,
          limit: @per_page
      )

    error_ids = Enum.map(errors, & &1.id)

    occurrences =
      if errors != [] do
        errors
        |> Ecto.assoc(:occurrences)
        |> where([o], o.error_id in ^error_ids)
        |> group_by([o], o.error_id)
        |> select([o], {o.error_id, count(o.id)})
        |> Repo.all()
      else
        []
      end

    assign(socket,
      errors: errors,
      occurrences: Map.new(occurrences),
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
    # Postgres provides the ILIKE operator which produces a case-insensitive match between two
    # strings. SQLite3 only supports LIKE, which is case-insensitive for ASCII characters.
    Repo.with_adapter(fn
      :postgres -> where(query, [error], ilike(field(error, ^field), ^"%#{value}%"))
      :mysql -> where(query, [error], like(field(error, ^field), ^"%#{value}%"))
      :sqlite -> where(query, [error], like(field(error, ^field), ^"%#{value}%"))
    end)
  end
end
