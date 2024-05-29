defmodule ErrorTracker.Plug do
  defmacro __using__(_opts) do
    quote do
      use Plug.ErrorHandler

      @impl Plug.ErrorHandler
      def handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do


        dbg kind
        dbg reason
        dbg stack

        :ok
      end
    end
  end
end
