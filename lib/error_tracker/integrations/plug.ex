defmodule ErrorTracker.Integrations.Plug do
  @moduledoc """
  Integration with Plug applications.

  ## How to use it

  ### Plug applications

  The way to use this integration is by adding it to either your `Plug.Builder`
  or `Plug.Router`:

  ```elixir
  defmodule MyApp.Router do
    use Plug.Router
    use ErrorTracker.Integrations.Plug

    ...
  end
  ```

  ### Phoenix applications

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

  ### Default context

  By default we store some context for you on errors generated during a Plug
  request:

  * `request.host`: the `conn.host` value.

  * `request.ip`: the IP address that initiated the request. It includes parsing
  proxy headers

  * `request.method`: the HTTP method of the request.

  * `request.path`: the path of the request.

  * `request.query`: the query string of the request.

  * `request.params`: parsed params of the request (only available if they have
  been fetched and parsed as part of the Plug pipeline).

  * `request.headers`: headers received on the request. All headers are included
  by default except for the `Cookie` ones, as they may include large and
  sensitive content like sessions.

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
        unquote(__MODULE__).set_context(conn)
        super(conn, opts)
      rescue
        e in Plug.Conn.WrapperError ->
          unquote(__MODULE__).report_error(e.conn, e.reason, e.stack)

          Plug.Conn.WrapperError.reraise(e)

        e ->
          stack = __STACKTRACE__
          unquote(__MODULE__).report_error(conn, e, stack)

          :erlang.raise(:error, e, stack)
      catch
        kind, reason ->
          stack = __STACKTRACE__
          unquote(__MODULE__).report_error(conn, {kind, reason}, stack)

          :erlang.raise(kind, reason, stack)
      end
    end
  end

  @doc false
  def report_error(conn, reason, stack) do
    unless Process.get(:error_tracker_router_exception_reported) do
      try do
        ErrorTracker.report(reason, stack, build_context(conn))
      after
        Process.put(:error_tracker_router_exception_reported, true)
      end
    end
  end

  @doc false
  def set_context(conn = %Plug.Conn{}) do
    conn |> build_context |> ErrorTracker.set_context()
  end

  defp build_context(conn = %Plug.Conn{}) do
    %{
      "request.host" => conn.host,
      "request.path" => conn.request_path,
      "request.query" => conn.query_string,
      "request.method" => conn.method,
      "request.ip" => remote_ip(conn),
      "request.headers" => conn.req_headers |> Map.new() |> Map.drop(["cookie"]),
      # Depending on the error source, the request params may have not been fetched yet
      "request.params" => unless(is_struct(conn.params, Plug.Conn.Unfetched), do: conn.params)
    }
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
