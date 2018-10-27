use Mix.Config

config :turbo_ecto, Turbo.Ecto.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "turbo_ecto_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
