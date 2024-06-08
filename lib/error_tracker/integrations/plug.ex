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

  def report_error(conn, reason, stack) do
    unless Process.get(:error_tracker_router_exception_reported) do
      try do
        ErrorTracker.report(reason, stack, set_context(conn))
      after
        Process.put(:error_tracker_router_exception_reported, true)
      end
    end
  end

  def set_context(conn = %Plug.Conn{}) do
    ErrorTracker.set_context(%{
      "request.host" => conn.host,
      "request.path" => conn.request_path,
      "request.query" => conn.query_string,
      "request.method" => conn.method,
      "request.ip" => remote_ip(conn),
      "request.headers" => Map.new(conn.req_headers),
      "response.headers" => Map.new(conn.resp_headers),
      # TODO most likey this will be a %Plug.Conn.Unfetched{}
      # Should we fetch it here?
      "request.params" => %{},
      "request.session" => %{}
    })

    conn
  end

  defp remote_ip(conn = %Plug.Conn{}) do
    remote_ip =
      case Plug.Conn.get_req_header(conn, "x-forwarded-for") do
        [x_forwarded_for | _] ->
          x_forwarded_for |> String.split(",", parts: 2) |> List.first()

        [] ->
          case :inet.ntoa(conn.remote_ip) do
            {:error, _} -> ""
            address -> to_string(address)
          end
      end

    String.trim(remote_ip)
  end
end
