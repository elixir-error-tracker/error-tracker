defmodule ErrorTracker.Stacktrace do
  @moduledoc """
  An Stacktrace contains the information about the execution stack for a given
  occurrence of an exception.
  """

  use Ecto.Schema

  @primary_key false
  embedded_schema do
    embeds_many :lines, Line, primary_key: false do
      field :application, :string
      field :module, :string
      field :function, :string
      field :arity, :integer
      field :file, :string
      field :line, :integer
    end
  end

  def new(stack) do
    lines_params =
      for {module, function, arity, opts} <- stack do
        application = Application.get_application(module)

        %{
          application: to_string(application),
          module: module |> to_string() |> String.replace_prefix("Elixir.", ""),
          function: to_string(function),
          arity: normalize_arity(arity),
          file: to_string(opts[:file]),
          line: opts[:line]
        }
      end

    %__MODULE__{}
    |> Ecto.Changeset.cast(%{lines: lines_params}, [])
    |> Ecto.Changeset.cast_embed(:lines, with: &line_changeset/2)
    |> Ecto.Changeset.apply_action(:new)
  end

  defp normalize_arity(a) when is_integer(a), do: a
  defp normalize_arity(a) when is_list(a), do: length(a)

  defp line_changeset(line = %__MODULE__.Line{}, params) do
    Ecto.Changeset.cast(line, params, ~w[application module function arity file line]a)
  end

  @doc """
  Source of the error stack trace.

  The first line matching the client application. If no line belongs to the current
  application, just the first line.
  """
  def source(stack = %__MODULE__{}) do
    client_app = Application.fetch_env!(:error_tracker, :otp_app)

    Enum.find(stack.lines, &(&1.application == client_app)) || List.first(stack.lines)
  end
end

defimpl String.Chars, for: ErrorTracker.Stacktrace do
  def to_string(stack = %ErrorTracker.Stacktrace{}) do
    Enum.join(stack.lines, "\n")
  end
end

defimpl String.Chars, for: ErrorTracker.Stacktrace.Line do
  def to_string(stack_line = %ErrorTracker.Stacktrace.Line{}) do
    "#{stack_line.module}.#{stack_line.function}/#{stack_line.arity} in #{stack_line.file}:#{stack_line.line}"
  end
end
