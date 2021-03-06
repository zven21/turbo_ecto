defmodule Turbo.Ecto.MixProject do
  use Mix.Project

  @version "1.0.1"
  @github "https://github.com/zven21/turbo_ecto"

  def project do
    [
      app: :turbo_ecto,
      description: "A elixir lib for search, sort, paginate.",
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0", only: :test},
      {:ex_machina, "~> 2.4", only: :test},
      {:excoveralls, "~> 0.13.3", only: :test},
      {:credo, "~> 1.5.2", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["zven21"],
      licenses: ["MIT"],
      links: %{"GitHub" => @github}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "priv", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      test: [
        "ecto.drop -r Turbo.Ecto.TestRepo --quiet",
        "ecto.create -r Turbo.Ecto.TestRepo --quiet",
        "ecto.migrate -r Turbo.Ecto.TestRepo --quiet",
        "test"
      ]
    ]
  end
end
