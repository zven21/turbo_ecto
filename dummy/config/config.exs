# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :dummy,
  ecto_repos: [Dummy.Repo]

# Configures the endpoint
config :dummy, DummyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "b3VTDMDPRrXxGv6b2x4B1UWfBgU96UV0RoFhyKLAUlqoWJKBhJBiOAhPXzplYO0z",
  render_errors: [view: DummyWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Dummy.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :turbo_ecto, Turbo.Ecto,
  repo: Dummy.Repo,
  per_page: 2,
  entry_name: "entries"

config :turbo_html, Turbo.HTML, default_theme: :bootstrap

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
