# Used by "mix format"
locals_without_parens = [error_tracker_dashboard: 1, error_tracker_dashboard: 2]

# Parse SemVer minor elixir version from project configuration
# eg `"~> 1.15"` version requirement will yield `"1.15"`
[elixir_minor_version | _] = Regex.run(~r/([\d\.]+)/, Mix.Project.config()[:elixir])

[
  import_deps: [:ecto, :ecto_sql, :plug, :phoenix],
  inputs: ["{mix,.formatter,dev,dev.*}.exs", "{config,lib,test}/**/*.{heex,ex,exs}"],
  plugins: [Phoenix.LiveView.HTMLFormatter, Styler],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens],
  styler: [
    minimum_supported_elixir_version: "#{elixir_minor_version}.0"
  ]
]
