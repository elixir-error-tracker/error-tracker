defmodule ErrorTracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :error_tracker,
      version: "0.5.2",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      source_url: "https://github.com/elixir-error-tracker/error-tracker",
      aliases: aliases(),
      name: "ErrorTracker",
      docs: [
        main: "ErrorTracker",
        formatters: ["html"],
        groups_for_modules: groups_for_modules(),
        extra_section: "GUIDES",
        extras: [
          "guides/Getting Started.md"
        ],
        api_reference: false,
        main: "getting-started"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ErrorTracker.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  def package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/elixir-error-tracker/error-tracker"
      },
      maintainers: [
        "Óscar de Arriba González",
        "Cristian Álvarez Belaustegui",
        "Víctor Ortiz Heredia"
      ],
      files: ~w(lib priv/static LICENSE mix.exs README.md .formatter.exs)
    ]
  end

  def description do
    "An Elixir-based built-in error tracking solution"
  end

  defp groups_for_modules do
    [
      Integrations: [
        ErrorTracker.Integrations.Oban,
        ErrorTracker.Integrations.Phoenix,
        ErrorTracker.Integrations.Plug
      ],
      Plugins: [
        ErrorTracker.Plugins.Pruner
      ],
      Schemas: [
        ErrorTracker.Error,
        ErrorTracker.Occurrence,
        ErrorTracker.Stacktrace,
        ErrorTracker.Stacktrace.Line
      ],
      "Web UI": [
        ErrorTracker.Web,
        ErrorTracker.Web.Router
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:ecto, "~> 3.11"},
      {:phoenix_live_view, "~> 0.19 or ~> 1.0"},
      {:phoenix_ecto, "~> 4.6"},
      {:plug, "~> 1.10"},
      {:jason, "~> 1.1", optional: true},
      {:postgrex, ">= 0.0.0", optional: true},
      {:myxql, ">= 0.0.0", optional: true},
      {:ecto_sqlite3, ">= 0.0.0", optional: true},
      # Dev dependencies
      {:bun, "~> 1.3", only: :dev},
      {:credo, "~> 1.7", only: [:dev, :test]},
      {:ex_doc, "~> 0.33", only: :dev},
      {:phoenix_live_reload, ">= 0.0.0", only: :dev},
      {:plug_cowboy, ">= 0.0.0", only: :dev},
      {:tailwind, "~> 0.2", only: :dev}
    ]
  end

  defp aliases do
    [
      dev: "run --no-halt dev.exs",
      "assets.install": ["bun.install", "cmd _build/bun install --cwd assets/"],
      "assets.watch": ["tailwind default --watch"],
      "assets.build": ["bun default", "tailwind default"]
    ]
  end
end
