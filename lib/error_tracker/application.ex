defmodule ErrorTracker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = []

    if Application.spec(:phoenix), do: ErrorTracker.Integrations.Phoenix.attach()
    if Application.spec(:oban), do: ErrorTracker.Integrations.Oban.attach()

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end
end
