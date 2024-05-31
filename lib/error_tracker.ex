defmodule ErrorTracker do
  def report(exception, stacktrace, context \\ %{}) do
    {:ok, stacktrace} = ErrorTracker.Stacktrace.new(stacktrace)
    {:ok, error} = ErrorTracker.Error.new(exception, stacktrace)

    error =
      repo().insert!(error,
        on_conflict: [set: [status: :unresolved]],
        conflict_target: :fingerprint
      )

    error
    |> Ecto.build_assoc(:occurrences, stacktrace: stacktrace, context: context)
    |> repo().insert!()
  end

  def repo do
    Application.fetch_env!(:error_tracker, :repo)
  end
end
