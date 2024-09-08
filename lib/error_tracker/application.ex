defmodule ErrorTracker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = Application.get_env(:error_tracker, :plugins, [])

    attach_handlers()

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end

  defp attach_handlers do
    ErrorTracker.Integrations.Oban.attach()
    ErrorTracker.Integrations.Phoenix.attach()
  end
end
