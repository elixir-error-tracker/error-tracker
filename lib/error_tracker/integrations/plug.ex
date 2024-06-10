defmodule ErrorTracker.Integrations.Plug do
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_) do
    quote do
      defoverridable call: 2

      def call(conn, opts) do
        try do
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
  end

  def report_error(_conn, reason, stack) do
    unless Process.get(:error_tracker_router_exception_reported) do
      # TODO: Add metadata from conn when implemented
      try do
        ErrorTracker.report(reason, stack)
      after
        Process.put(:error_tracker_router_exception_reported, true)
      end
    end
  end
end
