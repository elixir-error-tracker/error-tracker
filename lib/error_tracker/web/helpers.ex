defmodule ErrorTracker.Web.Helpers do
  @moduledoc false

  @doc false
  def sanitize_module(<<"Elixir.", str::binary>>), do: str
  def sanitize_module(str), do: str

  @doc false
  def format_datetime(dt = %DateTime{}), do: Calendar.strftime(dt, "%c %Z")
end
