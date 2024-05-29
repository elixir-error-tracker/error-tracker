defmodule ErrorTracker do
  alias ErrorTracker.Repo

  def report(exception, stacktrace, context \\ %{}) do
    {:ok, stacktrace} = ErrorTracker.Stacktrace.new(stacktrace)
    {:ok, error} = ErrorTracker.Error.new(exception, stacktrace)

    error =
      Repo.insert!(error,
        on_conflict: [set: [status: :unresolved]],
        conflict_target: :fingerprint
      )

    error
    |> Ecto.build_assoc(:occurrences, stacktrace: stacktrace, context: context)
    |> Repo.insert!()
  end

  def raise do
    raise "PROBANDO PROBANDO"
  rescue
    e -> report(e, __STACKTRACE__)
  end
end
