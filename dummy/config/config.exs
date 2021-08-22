# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :dummy,
  ecto_repos: [Dummy.Repo]

config :turbo_ecto, Turbo.Ecto,
  repo: Dummy.Repo,
  per_page: 10,
  entry_name: "entries"

# Configures the endpoint
config :dummy, DummyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "BuDdd474ra2KhjAu8LzSplS8Bm79HO5QWE53oL3rfvowoxkZOBLv5Rp1jG/SKMJe",
  render_errors: [view: DummyWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Dummy.PubSub,
  live_view: [signing_salt: "LOD7E3Yl"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
