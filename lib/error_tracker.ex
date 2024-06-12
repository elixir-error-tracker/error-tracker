defmodule ErrorTracker do
  @moduledoc """
  En Elixir based built-in error tracking solution.
  """

  def report(exception, stacktrace, context \\ %{}) do
    {:ok, stacktrace} = ErrorTracker.Stacktrace.new(stacktrace)
    {:ok, error} = ErrorTracker.Error.new(exception, stacktrace)

    error =
      repo().insert!(error,
        on_conflict: [set: [status: :unresolved]],
        conflict_target: :fingerprint,
        prefix: prefix()
      )

    error
    |> Ecto.build_assoc(:occurrences, stacktrace: stacktrace, context: context)
    |> repo().insert!(prefix: prefix())
  end

  def repo do
    Application.fetch_env!(:error_tracker, :repo)
  end

  def prefix do
    Application.get_env(:error_tracker, :prefix, "public")
  end
end
