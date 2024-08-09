defmodule ErrorTracker.Web.Layouts.Navbar do
  @moduledoc false
  use ErrorTracker.Web, :live_component

  def render(assigns) do
    ~H"""
    <nav class="border-gray-400 bg-gray-900">
      <div class="container flex flex-wrap items-center justify-between mx-auto p-4">
        <.link
          href={dashboard_path(@socket)}
          class="self-center text-2xl font-semibold whitespace-nowrap text-white"
        >
          ErrorTracker
        </.link>
        <button
          type="button"
          class="inline-flex items-center p-2 w-10 h-10 justify-center text-sm rounded -lg md:hidden focus:outline-none focus:ring-2 text-gray-400 hover:bg-gray-700 focus:ring-gray-500"
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
          <ul class="font-medium flex flex-col p-4 md:p-0 mt-4 border border-gray-400 bg-gray-900 rounded-lg md:flex-row md:space-x-8 rtl:space-x-reverse md:mt-0 md:border-0 md:bg-gray-800">
            <.navbar_item to="https://github.com" target="_blank">
              <svg width="18" height="18" aria-hidden="true" viewBox="0 0 24 24" version="1.1" class="inline-block mr-1 align-text-top">
                <path fill="currentColor" d="M12.5.75C6.146.75 1 5.896 1 12.25c0 5.089 3.292 9.387 7.863 10.91.575.101.79-.244.79-.546 0-.273-.014-1.178-.014-2.142-2.889.532-3.636-.704-3.866-1.35-.13-.331-.69-1.352-1.18-1.625-.402-.216-.977-.748-.014-.762.906-.014 1.553.834 1.769 1.179 1.035 1.74 2.688 1.25 3.349.948.1-.747.402-1.25.733-1.538-2.559-.287-5.232-1.279-5.232-5.678 0-1.25.445-2.285 1.178-3.09-.115-.288-.517-1.467.115-3.048 0 0 .963-.302 3.163 1.179.92-.259 1.897-.388 2.875-.388.977 0 1.955.13 2.875.388 2.2-1.495 3.162-1.179 3.162-1.179.633 1.581.23 2.76.115 3.048.733.805 1.179 1.825 1.179 3.09 0 4.413-2.688 5.39-5.247 5.678.417.36.776 1.05.776 2.128 0 1.538-.014 2.774-.014 3.162 0 .302.216.662.79.547C20.709 21.637 24 17.324 24 12.25 24 5.896 18.854.75 12.5.75Z"></path>
              </svg>
              GitHub
            </.navbar_item>
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
        class="whitespace-nowrap flex-0 block py-2 px-3 rounded-lg text-white hover:text-white hover:bg-gray-700 md:hover:bg-transparent md:border-0 md:hover:text-sky-500"
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </a>
    </li>
    """
  end
end
