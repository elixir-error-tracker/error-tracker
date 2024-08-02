defmodule ErrorTracker.Test.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto.Query
      import ErrorTracker.Test.Case

      alias ErrorTracker.Test.Repo
    end
  end

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(ErrorTracker.Test.Repo)
  end
end
