import Config

if config_env() == :dev do
  config :tailwind,
    version: "3.4.3",
    default: [
      args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
      cd: Path.expand("../assets", __DIR__)
    ]
end
