defmodule Catsocket.Mixfile do
  use Mix.Project

  def project do
    [app: :catsocket,
     version: "0.1.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     dialyzer: [plt_add_deps: :transitive],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Catsocket, []},
      applications: [
        :phoenix,
        :phoenix_pubsub,
        :phoenix_html,
        :cowboy,
        :logger,
        :gettext,
        :phoenix_ecto,
        :postgrex,
        :comeonin,
        :ex_machina,

        :timex,
        :phoenix_slime,
        :httpotion,

        :runtime_tools,
        # :wobserver,

        # TODO: do we need these?
        :dbg,
        # :folsom,
        # :meck,
        :elixir_make,
        :edeliver
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.1"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:phoenix_slime, "~> 0.8.0"},
     {:comeonin, "~> 3.0"},
     {:ex_machina, "~> 1.0"},
     {:httpotion, "~> 3.0.2"},

     {:exprof, "~> 0.2.0"},
     {:timex, "~> 3.0"},

     {:dialyxir, "~> 0.4", only: [:dev, :test], runtime: false},

     # TODO: do we still need these?
     {:dbg, "~> 1.0.0"},
     # {:wobserver, "~> 0.1"},

     # {:folsom, github: "boundary/folsom"},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:edeliver, "~> 1.4.0"},
     {:distillery, ">= 0.8.0", warn_missing: false},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
