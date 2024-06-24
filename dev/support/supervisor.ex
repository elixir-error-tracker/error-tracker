defmodule ErrorTracker.DevSupervisor do
  use Supervisor

  @impl Supervisor
  def init(_init_arg) do
    Supervisor.init(children(), strategy: :one_for_one)
  end

  def start_link(_init_arg) do
    Supervisor.start_link(children(), strategy: :one_for_one, name: __MODULE__)

    ErrorTracker.DevRepo.setup_database()
  end

  defp children do
    [ErrorTracker.DevRepo]
  end
end
