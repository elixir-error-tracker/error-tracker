defmodule ErrorTracker.Web do
  @moduledoc """
  ErrorTracker includes a dashboard to view and inspect errors that occurred
  on your application and are already stored in the database.

  In order to use it, you need to add the following to your Phoenix's
  `router.ex` file:

  ```elixir
  defmodule YourAppWeb.Router do
    use Phoenix.Router
    use ErrorTracker.Web, :router

    ...

    scope "/" do
      ...

      error_tracker_dashboard "/errors"
    end
  end
  ```

  This will add the routes needed for ErrorTracker's dashboard to work.

  **Note:** when adding the dashboard routes, make sure you do it in an scope that
  has CSRF protection (usually the `:browser` pipeline in most projects), as
  otherwise you may experience LiveView issues like crashes and redirections.

  ## Security considerations

  Errors may contain sensitive information, like IP addresses, users information
  or even passwords sent on forms!

  Securing your dashboard is an important part of integrating ErrorTracker on
  your project.

  In order to do so, we recommend implementing your own security mechanisms in
  the form of a mount hook and pass it to the `error_tracker_dashboard` macro
  using the `on_mount` option.

  You can find more details on
  `ErrorTracker.Web.Router.error_tracker_dashboard/2`.

  ### Static assets

  Static assets (CSS and JS) are inlined during the compilation. If you have
  a [Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
  be sure to allow inline styles and scripts.

  To do this, ensure that your `style-src` and `script-src` policies include the
  `unsafe-inline` value.

  ## LiveView socket options

  By default the library expects you to have your LiveView socket at `/live` and
  using `websocket` transport.

  If that's not the case, you can configure it adding the following
  configuration to your app's config files:

  ```elixir
  config :error_tracker,
    socket: [
      path: "/my-custom-live-path"
      transport: :longpoll # (accepted values are :longpoll or :websocket)
    ]
  ```
  """

  @doc false
  def html do
    quote do
      import Phoenix.Controller, only: [get_csrf_token: 0]

      unquote(html_helpers())
    end
  end

  @doc false
  def live_view do
    quote do
      use Phoenix.LiveView, layout: {ErrorTracker.Web.Layouts, :live}

      unquote(html_helpers())
    end
  end

  @doc false
  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  @doc false
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
