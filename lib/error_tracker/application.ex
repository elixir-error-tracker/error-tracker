defmodule ErrorTracker.Application do
  use Application

  def start(_type, _args) do
    children = []

    attach_handlers()

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end

  defp attach_handlers do
    ErrorTracker.Integrations.Oban.attach()
  end
end
