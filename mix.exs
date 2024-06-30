defmodule ErrorTracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :error_tracker,
      version: "0.0.1",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      source_url: "https://github.com/elixir-error-tracker/error-tracker",
      aliases: aliases()
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
      }
    ]
  end

  def description do
    "An Elixir based built-in error tracking solution"
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:ecto, "~> 3.11"},
      {:jason, "~> 1.1"},
      {:phoenix_live_view, "~> 0.19 or ~> 1.0"},
      {:plug, "~> 1.10"},
      {:postgrex, ">= 0.0.0"},
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
      setup: ["deps.get", "cmd --cd assets npm install"],
      dev: "run --no-halt dev.exs",
      "assets.watch": ["tailwind default --watch"],
      "assets.build": ["bun default --minify", "tailwind default --minify"]
    ]
  end
end
