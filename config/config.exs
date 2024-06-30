import Config

if config_env() == :dev do
  config :tailwind,
    version: "3.4.3",
    default: [
      args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/app.css
    ),
      cd: Path.expand("../assets", __DIR__)
    ]

  config :esbuild,
    version: "0.21.5",
    default: [
      args: ~w(app.js --bundle --target=es2016 --outdir=../../priv/static),
      cd: Path.expand("../assets/js", __DIR__),
      env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
    ]
end
