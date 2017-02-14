use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or you later on).
config :catsocket, Catsocket.Endpoint,
  secret_key_base: "v6wsTFaX29v7hRpaRg4SRKz7ygE7ZorcL9S3zorwsdrJG438dW2psmztL4egaDqJ"

# Configure your database
config :catsocket, Catsocket.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "deploy",
  password: "deploy",
  database: "catsocket_phoenix_prod",
  pool_size: 20
