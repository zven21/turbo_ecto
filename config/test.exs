use Mix.Config

config :turbo_ecto, Turbo.Ecto.TestRepo,
  username: "postgres",
  password: "postgres",
  database: "turbo_ecto_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :warn
