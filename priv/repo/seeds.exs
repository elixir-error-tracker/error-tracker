adapter =
  case Application.get_env(:error_tracker, :ecto_adapter) do
    :postgres -> Ecto.Adapters.Postgres
    :sqlite3 -> Ecto.Adapters.SQLite3
  end

defmodule ErrorTrackerDev.Repo do
  use Ecto.Repo, otp_app: :error_tracker, adapter: adapter
end

ErrorTrackerDev.Repo.start_link()

ErrorTrackerDev.Repo.delete_all(ErrorTracker.Error)

errors =
  for i <- 1..100 do
    %{
      kind: "Error #{i}",
      reason: "Reason #{i}",
      source_line: "line",
      source_function: "function",
      status: :unresolved,
      fingerprint: "#{i}",
      last_occurrence_at: DateTime.utc_now(),
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }
  end

{_, errors} = dbg(ErrorTrackerDev.Repo.insert_all(ErrorTracker.Error, errors, returning: [:id]))

for error <- errors do
  occurrences =
    for _i <- 1..200 do
      %{
        context: %{},
        reason: "REASON",
        stacktrace: %ErrorTracker.Stacktrace{},
        error_id: error.id,
        inserted_at: DateTime.utc_now()
      }
    end

  ErrorTrackerDev.Repo.insert_all(ErrorTracker.Occurrence, occurrences)
end
