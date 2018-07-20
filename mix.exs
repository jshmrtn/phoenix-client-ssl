defmodule PhoenixClientSsl.Mixfile do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :phoenix_client_ssl,
      version: "0.3.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      compilers: Mix.compilers() ++ [:erlang, :app],
      test_coverage: [tool: ExCoveralls],
      erlc_paths: ["lib"],
      deps: deps()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [extra_applications: [:logger, :public_key]]
  end

  defp description do
    """
    Set of Plugs / Lib to help with SSL Client Auth.
    """
  end

  defp package do
    [
      name: :phoenix_client_ssl,
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["airatel Inc.", "Jonatan Männchen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jshmrtn/phoenix-client-ssl"}
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:cowboy, "~> 1.0"},
      {:glob, "~> 0.0.9"},
      {:absinthe_plug, "~> 1.4", optional: true},
      {:inch_ex, only: :docs, runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 0.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.4", only: [:dev, :test], runtime: false}
    ]
  end
end
