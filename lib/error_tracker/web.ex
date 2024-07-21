defmodule ErrorTracker.Web do
  @moduledoc """
  ErrorTracker includes a Web UI to view and inspect errors occurred on your
  application and already stored on the database.

  In order to use it, you need to add the following to your Phoenix's `
  router.ex` file:

  ```elixir
  defmodule YourAppWeb.Router do
    use Phoenix.Router
    use ErrorTracker.Web, :router

    ...

    error_tracker_dashboard "/errors"
  end
  ```

  This will add the routes needed for the ErrorTracker LiveView UI to work.

  ## LiveView socket options

  By default the library expects you to have your LiveView socket at `/live` and
  using `websocket` transport.

  If that's not the case, you can configure it adding the following
  configuration to your app's config files:

  ```elixir
  config :error_tracker,
    socket: [
      path: "/my-custom-socket-path"
      transport: :longpoll # (accepted values are :longpoll or :websocket)
    ]
  ```
  """

  def html do
    quote do
      import Phoenix.Controller, only: [get_csrf_token: 0]

      unquote(html_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView, layout: {ErrorTracker.Web.Layouts, :live}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def router do
    quote do
      import ErrorTracker.Web.Router
    end
  end

  defp html_helpers do
    quote do
      use Phoenix.Component

      import Phoenix.HTML
      import Phoenix.LiveView.Helpers

      import ErrorTracker.Web.CoreComponents
      import ErrorTracker.Web.Helpers
      import ErrorTracker.Web.Router.Routes

      alias Phoenix.LiveView.JS
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
