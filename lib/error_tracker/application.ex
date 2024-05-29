defmodule ErrorTracker.Application do
  use Application

  def start(_type, _args) do
    children = []

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end
end
