defmodule ErrorTracker.Integrations.UtilsBehaviour do
  @moduledoc false
  @callback application_spec(atom) :: [{atom, term}] | nil
end

defmodule ErrorTracker.Integrations.UtilsImpl do
  @moduledoc false
  @behaviour ErrorTracker.Integrations.UtilsBehaviour

  @impl true
  def application_spec(app) do
    Application.spec(app)
  end
end

defmodule ErrorTracker.Integrations.Utils do
  @moduledoc false
  def application_spec(app), do: impl().application_spec(app)

  defp impl, do: Application.get_env(:error_tracker, :utils, ErrorTracker.Integrations.UtilsImpl)
end
