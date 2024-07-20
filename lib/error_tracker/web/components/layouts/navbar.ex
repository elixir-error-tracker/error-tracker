defmodule ErrorTracker.Web.Layouts.Navbar do
  @moduledoc false
  use ErrorTracker.Web, :live_component

  def render(assigns) do
    ~H"""
    <nav class="border-gray-200 bg-gray-800" phx-click-away={JS.hide(to: "#navbar-main")}>
      <div class="max-w-screen-xl flex flex-wrap items-center justify-between mx-auto p-4">
        <span class="self-center text-2xl font-semibold whitespace-nowrap text-white">
          ErrorTracker
        </span>
        <button
          type="button"
          class="inline-flex items-center p-2 w-10 h-10 justify-center text-sm rounded -lg md:hidden focus:outline-none focus:ring-2 text-gray-400 hover:bg-gray-600 focus:ring-gray-500"
          aria-controls="navbar-main"
          aria-expanded="false"
          phx-click={JS.toggle(to: "#navbar-main")}
        >
          <span class="sr-only">Open main menu</span>
          <svg
            class="w-5 h-5"
            aria-hidden="true"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 17 14"
          >
            <path
              stroke="currentColor"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M1 1h15M1 7h15M1 13h15"
            />
          </svg>
        </button>
        <div class="hidden w-full md:block md:w-auto" id="navbar-main">
          <ul class="font-medium flex flex-col p-4 md:p-0 mt-4 border border-gray-600 rounded-lg bg-gray-700 md:flex-row md:space-x-8 rtl:space-x-reverse md:mt-0 md:border-0 md:bg-gray-800">
            <.navbar_item to="https://github.com" target="_blank">GitHub</.navbar_item>
          </ul>
        </div>
      </div>
    </nav>
    """
  end

  attr :to, :string, required: true
  attr :rest, :global

  slot :inner_block, required: true

  def navbar_item(assigns) do
    ~H"""
    <li>
      <a
        href={@to}
        class="block py-2 px-3 text-gray-900 rounded text-white hover:text-white hover:bg-gray-700 md:hover:bg-transparent md:border-0 md:hover:text-blue-500 md:p-0"
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </a>
    </li>
    """
  end
end
