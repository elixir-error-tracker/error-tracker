defmodule ErrorTracker.Web.CoreComponents do
  use Phoenix.Component

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-zinc-600 hover:bg-zinc-400 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
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
        :red -> "bg-red-900 text-red-300"
        :green -> "bg-green-900 text-green-300"
        :yellow -> "bg-yellow-900 text-yellow-300"
        :indigo -> "bg-indigo-900 text-indigo-300"
        :purple -> "bg-purple-900 text-purple-300"
        :pink -> "bg-pink-900 text-pink-300"
        :gray -> "bg-gray-700 text-gray-300"
        :gray -> "bg-gray-700 text-gray-300"
      end

    assigns = Map.put(assigns, :color_class, color_class)

    ~H"""
    <span class={["text-sm font-medium me-2 px-2.5 py-1.5 rounded", @color_class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end
end
