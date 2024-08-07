import Config

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

config :bun,
  version: "1.1.18",
  default: [
    args: ~w(build app.js --outdir=../../priv/static),
    cd: Path.expand("../assets/js", __DIR__),
    env: %{}
  ]
