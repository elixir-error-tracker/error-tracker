defmodule ErrorTracker.Integrations.Plug do
  defmacro __using__(_opts) do
    quote do
      use Plug.ErrorHandler

      @impl Plug.ErrorHandler
      def handle_errors(conn, %{kind: :error, reason: exception, stack: stack}) do
        ErrorTracker.report(exception, stack)

        :ok
      end

      def handle_errors(conn, _throw_or_exit) do
        :ok
      end
    end
  end
end
