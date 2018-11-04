use Mix.Config

config :logger, :console, level: :error

config :turbo_ecto, Turbo.Ecto,
  repo: Turbo.Ecto.Repo,
  per_page: 10

config :turbo_ecto, ecto_repos: [Turbo.Ecto.Repo]

import_config "#{Mix.env()}.exs"
