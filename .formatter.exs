# Used by "mix format"
locals_without_parens = [error_tracker_dashboard: 1, error_tracker_dashboard: 2]

[
  import_deps: [:ecto, :ecto_sql, :plug, :phoenix],
  inputs: ["{mix,.formatter,dev,dev.*}.exs", "{config,lib,test}/**/*.{heex,ex,exs}"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens]
]
