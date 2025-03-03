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

  def button(assigns = %{type: "link"}) do
    ~H"""
    <.link
      class={[
        "phx-submit-loading:opacity-75 py-[11.5px]",
        "text-sm font-semibold text-sky-500 hover:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
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
      <%= render_slot(@inner_block) %>
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
        :blue -> "bg-blue-900 text-blue-300"
        :gray -> "bg-gray-700 text-gray-300"
        :red -> "bg-red-400/10 text-red-300 ring-red-400/20"
        :green -> "bg-emerald-400/10 text-emerald-300 ring-emerald-400/20"
        :yellow -> "bg-yellow-900 text-yellow-300"
        :indigo -> "bg-indigo-900 text-indigo-300"
        :purple -> "bg-purple-900 text-purple-300"
        :pink -> "bg-pink-900 text-pink-300"
      end

    assigns = Map.put(assigns, :color_class, color_class)

    ~H"""
    <span
      class={["text-sm font-medium me-2 py-1 px-2 rounded-lg ring-1 ring-inset", @color_class]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
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
        class="flex items-center justify-center px-4 h-10 text-base font-medium text-gray-400  bg-gray-900 border border-gray-400 rounded-lg hover:bg-gray-800 hover:text-white"
        phx-click={@event_previous}
      >
        Previous page
      </button>
      <button
        :if={@page < @total_pages}
        class="flex items-center justify-center px-4 h-10 text-base font-medium text-gray-400 bg-gray-900 border border-gray-400 rounded-lg hover:bg-gray-800 hover:text-white"
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
        class={["text-sm font-semibold mb-2 uppercase text-gray-400", @title_class]}
      >
        <%= @title %>
      </h2>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :name, :string, values: ~w[bell bell-slash]

  def icon(assigns = %{name: "bell"}) do
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

  def icon(assigns = %{name: "bell-slash"}) do
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
end
