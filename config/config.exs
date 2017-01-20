# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :catsocket,
  ecto_repos: [Catsocket.Repo]

# Configures the endpoint
config :catsocket, Catsocket.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "R1XWSEs8Y/XSLKPJhGXUYQB8OYkum7BCrX1P1eUw6t1savkDfdiQG15A1RwteXqU",
  render_errors: [view: Catsocket.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Catsocket.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
