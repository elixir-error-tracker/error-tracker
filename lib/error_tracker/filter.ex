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

  The error message (the exception's `reason`) is saved as well, and it can carry
  user data such as an email address or a query value. Implement the optional
  `sanitize_reason/1` callback to change it before it is saved:

      defmodule MyApp.ErrorFilter do
        @behaviour ErrorTracker.Filter

        @impl true
        def sanitize(context), do: context

        @impl true
        def sanitize_reason(reason), do: String.slice(reason, 0, 300)
      end

  The ignorer still receives the original message, since nothing it sees is saved.

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

  @doc """
  This function will be given the error message to inspect/modify before it's saved,
  on both the error and the occurrence.
  """
  @callback sanitize_reason(reason :: String.t()) :: String.t()

  @optional_callbacks sanitize_reason: 1
end
