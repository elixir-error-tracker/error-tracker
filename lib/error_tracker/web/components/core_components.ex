defmodule ErrorTracker.Web.CoreComponents do
  @moduledoc false
  use Phoenix.Component

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value href patch navigate)

  slot :inner_block, required: true

  def button(%{type: "link"} = assigns) do
    ~H"""
    <.link
      class={[
        "phx-submit-loading:opacity-75 py-[11.5px]",
        "text-sm font-semibold text-sky-500 light:text-sky-600 hover:text-white/80 light:hover:text-gray-900/80",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-sky-500 hover:bg-sky-700 py-2 px-4",
        "text-sm text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Renders a badge.

  ## Examples

      <.badge>Info</.badge>
      <.badge color={:red}>Error</.badge>
  """
  attr :color, :atom, default: :blue
  attr :rest, :global

  slot :inner_block, required: true

  def badge(assigns) do
    color_class =
      case assigns.color do
        :blue ->
          "bg-blue-900 light:bg-blue-100 text-blue-300 light:text-blue-800"

        :gray ->
          "bg-gray-700 light:bg-gray-200 text-gray-300 light:text-gray-700"

        :red ->
          "bg-red-400/10 light:bg-red-100 text-red-300 light:text-red-800 ring-red-400/20 light:ring-red-400/30"

        :green ->
          "bg-emerald-400/10 light:bg-emerald-100 text-emerald-300 light:text-emerald-800 ring-emerald-400/20 light:ring-emerald-400/30"

        :yellow ->
          "bg-yellow-900 light:bg-yellow-100 text-yellow-300 light:text-yellow-800"

        :indigo ->
          "bg-indigo-900 light:bg-indigo-100 text-indigo-300 light:text-indigo-800"

        :purple ->
          "bg-purple-900 light:bg-purple-100 text-purple-300 light:text-purple-800"

        :pink ->
          "bg-pink-900 light:bg-pink-100 text-pink-300 light:text-pink-800"
      end

    assigns = Map.put(assigns, :color_class, color_class)

    ~H"""
    <span
      class={["text-sm font-medium me-2 py-1 px-2 rounded-lg ring-1 ring-inset", @color_class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  attr :page, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :event_previous, :string, default: "prev-page"
  attr :event_next, :string, default: "next-page"

  def pagination(assigns) do
    ~H"""
    <div class="mt-10 w-full flex">
      <button
        :if={@page > 1}
        class="flex items-center justify-center px-4 h-10 text-base font-medium text-gray-400 light:text-gray-500 bg-gray-900 light:bg-gray-100 border border-gray-400 light:border-gray-300 rounded-lg hover:bg-gray-800 light:hover:bg-gray-200 hover:text-white light:hover:text-gray-900"
        phx-click={@event_previous}
      >
        Previous page
      </button>
      <button
        :if={@page < @total_pages}
        class="flex items-center justify-center px-4 h-10 text-base font-medium text-gray-400 light:text-gray-500 bg-gray-900 light:bg-gray-100 border border-gray-400 light:border-gray-300 rounded-lg hover:bg-gray-800 light:hover:bg-gray-200 hover:text-white light:hover:text-gray-900"
        phx-click={@event_next}
      >
        Next page
      </button>
    </div>
    """
  end

  attr :title, :string
  attr :title_class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def section(assigns) do
    ~H"""
    <div>
      <h2
        :if={assigns[:title]}
        class={[
          "text-sm font-semibold mb-2 uppercase text-gray-400 light:text-gray-500",
          @title_class
        ]}
      >
        {@title}
      </h2>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :name, :string, values: ~w[bell bell-slash arrow-left arrow-right]

  def icon(%{name: "bell"} = assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 16 16"
      fill="currentColor"
      class="!h-4 !w-4 inline-block"
    >
      <path
        fill-rule="evenodd"
        d="M12 5a4 4 0 0 0-8 0v2.379a1.5 1.5 0 0 1-.44 1.06L2.294 9.707a1 1 0 0 0-.293.707V11a1 1 0 0 0 1 1h2a3 3 0 1 0 6 0h2a1 1 0 0 0 1-1v-.586a1 1 0 0 0-.293-.707L12.44 8.44A1.5 1.5 0 0 1 12 7.38V5Zm-5.5 7a1.5 1.5 0 0 0 3 0h-3Z"
        clip-rule="evenodd"
      />
    </svg>
    """
  end

  def icon(%{name: "bell-slash"} = assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 16 16"
      fill="currentColor"
      class="!h-4 !w-4 inline-block"
    >
      <path
        fill-rule="evenodd"
        d="M4 7.379v-.904l6.743 6.742A3 3 0 0 1 5 12H3a1 1 0 0 1-1-1v-.586a1 1 0 0 1 .293-.707L3.56 8.44A1.5 1.5 0 0 0 4 7.38ZM6.5 12a1.5 1.5 0 0 0 3 0h-3Z"
        clip-rule="evenodd"
      />
      <path d="M14 11a.997.997 0 0 1-.096.429L4.92 2.446A4 4 0 0 1 12 5v2.379c0 .398.158.779.44 1.06l1.267 1.268a1 1 0 0 1 .293.707V11ZM2.22 2.22a.75.75 0 0 1 1.06 0l10.5 10.5a.75.75 0 1 1-1.06 1.06L2.22 3.28a.75.75 0 0 1 0-1.06Z" />
    </svg>
    """
  end

  def icon(%{name: "arrow-left"} = assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 16 16"
      fill="currentColor"
      class="!h-4 !w-4 inline-block"
    >
      <path
        fill-rule="evenodd"
        d="M14 8a.75.75 0 0 1-.75.75H4.56l3.22 3.22a.75.75 0 1 1-1.06 1.06l-4.5-4.5a.75.75 0 0 1 0-1.06l4.5-4.5a.75.75 0 0 1 1.06 1.06L4.56 7.25h8.69A.75.75 0 0 1 14 8Z"
        clip-rule="evenodd"
      />
    </svg>
    """
  end

  def icon(%{name: "arrow-right"} = assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 16 16"
      fill="currentColor"
      class="!h-4 !w-4 inline-block"
    >
      <path
        fill-rule="evenodd"
        d="M2 8a.75.75 0 0 1 .75-.75h8.69L8.22 4.03a.75.75 0 0 1 1.06-1.06l4.5 4.5a.75.75 0 0 1 0 1.06l-4.5 4.5a.75.75 0 0 1-1.06-1.06l3.22-3.22H2.75A.75.75 0 0 1 2 8Z"
        clip-rule="evenodd"
      />
    </svg>
    """
  end
end
