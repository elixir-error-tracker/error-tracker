defmodule ErrorTracker.Ignorer do
  @moduledoc """
  Behaviour for ignoring errors.

  The ErrorTracker tracks every error that happens in your application. In certain cases you may
  want to ignore some errors and don't track them. To do so you can implement this behaviour.

      defmodule MyApp.ErrorIgnorer do
        @behaviour ErrorTracker.Ignorer

        @impl true
        def ignore?(error = %ErrorTracker.Error{}, context) do
          # return true if the error should be ignored
        end
      end

  Once implemented, include it in the ErrorTracker configuration:

      config :error_tracker, ignorer: MyApp.ErrorIgnorer

  With this configuration in place, the ErrorTracker will call `MyApp.ErrorIgnorer.ignore?/2` before
  tracking errors. If the function returns `true` the error will be ignored and won't be tracked.

  > #### A note on performance {: .warning}
  >
  > Keep in mind that the `ignore?/2` will be called in the context of the ErrorTracker itself.
  > Slow code will have a significant impact in the ErrorTracker performance. Buggy code can bring
  > the ErrorTracker process down.
  """

  @doc """
  Decide wether the given error should be ignored or not.

  This function receives both the current Error and context and should return a boolean indicating
  if it should be ignored or not. If the function returns true the error will be ignored, otherwise
  it will be tracked.
  """
  @callback ignore?(error :: ErrorTracker.Error.t(), context :: map()) :: boolean
end
