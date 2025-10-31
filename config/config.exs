import Config

config :logger, :console, level: :warning

config :turbo_ecto, Turbo.Ecto,
  repo: Turbo.Ecto.TestRepo,
  per_page: 10

config :turbo_ecto, ecto_repos: [Turbo.Ecto.TestRepo]

import_config "#{config_env()}.exs"
