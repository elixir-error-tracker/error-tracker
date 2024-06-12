defmodule ErrorTracker.Integrations.Plug do
  @moduledoc """
  The ErrorTracker integration with Plug applications.

  ## How it works

  The way to use this integration is by adding it to either your `Plug.Builder``
  or `Plug.Router`:

  ```elixir
  defmodule MyApp.Router do
    use Plug.Router
    use ErrorTracker.Integrations.Plug

    ...
  end
  ```

  ## Using it with Phoenix

  There is a particular use case which can be useful when running a Phoenix
  web application.

  If you want to record exceptions that may occur in your application's endpoint
  before reaching your router (for example, in any plug like the ones decoding
  cookies of body contents) you may want to add this integration too:

  ```elixir
  defmodule MyApp.Endpoint do
    use Phoenix.Endpoint
    use ErrorTracker.Integrations.Plug

    ...
  end
  ```
  """

  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_) do
    quote do
      defoverridable call: 2

      def call(conn, opts) do
        super(conn, opts)
      rescue
        e in Plug.Conn.WrapperError ->
          unquote(__MODULE__).report_error(conn, e, e.stack)

          Plug.Conn.WrapperError.reraise(e)

        e ->
          stack = __STACKTRACE__
          unquote(__MODULE__).report_error(conn, e, stack)

          :erlang.raise(:error, e, stack)
      catch
        kind, reason ->
          stack = __STACKTRACE__
          unquote(__MODULE__).report_error(conn, reason, stack)

          :erlang.raise(kind, reason, stack)
      end
    end
  end

  def report_error(_conn, reason, stack) do
    unless Process.get(:error_tracker_router_exception_reported) do
      try do
        ErrorTracker.report(reason, stack)
      after
        Process.put(:error_tracker_router_exception_reported, true)
      end
    end
  end
end
