defmodule ErrorTracker.Filter do
  @moduledoc """
  Behaviour for sanitizing & modifying the saved error context
  """
  @callback sanitize(context :: map()) :: map()
end
