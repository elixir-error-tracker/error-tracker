# Used by "mix format"
[
  import_deps: [:ecto, :ecto_sql, :plug, :phoenix],
  inputs: ["{mix,.formatter,dev,dev.*}.exs", "{config,lib,test}/**/*.{heex,ex,exs}"],
  plugins: [Phoenix.LiveView.HTMLFormatter]
]
