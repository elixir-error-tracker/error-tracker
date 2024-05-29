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
      source_url: "https://github.com/elixir-error-tracker/error-tracker"
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
      {:ex_doc, "~> 0.33", only: :dev, runtime: false},
      {:jason, "~> 1.1"},
      {:postgrex, ">= 0.0.0"}
    ]
  end
end
