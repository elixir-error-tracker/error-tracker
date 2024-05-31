# Prepare the Repo URL
Application.put_env(
  :error_tracker,
  ErrorTrackerDev.Repo,
  url: "ecto://postgres:postgres@127.0.0.1/error_tracker_dev"
)
