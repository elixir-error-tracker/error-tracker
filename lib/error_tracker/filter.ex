defmodule ErrorTracker.Filter do
  @moduledoc """
  Behaviour for sanitizing & modifying the error context before it's saved.

      defmodule MyApp.ErrorFilter do
        @behaviour ErrorTracker.Filter

        @impl true
        def sanitize(context) do
          context # Modify the context object (add or remove fields as much as you need.)
        end
      end

  Once implemented, include it in the ErrorTracker configuration:

    config :error_tracker, filter: MyApp.Filter

  With this configuration in place, the ErrorTracker will call `MyApp.Filter.sanitize/1` to get a context before
  saving error occurrence.

  > #### A note on performance {: .warning}
  >
  > Keep in mind that the `sanitize/1` will be called in the context of the ErrorTracker itself.
  > Slow code will have a significant impact in the ErrorTracker performance. Buggy code can bring
  > the ErrorTracker process down.
  """

  @doc """
  This function will be given an error context to inspect/modify before it's saved.
  """
  @callback sanitize(context :: map()) :: map()
end
