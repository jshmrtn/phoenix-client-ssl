defmodule PhoenixClientSsl.Mixfile do
  @moduledoc false

  use Mix.Project

  def project do
    [app: :phoenix_client_ssl,
     version: "0.1.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: Mix.compilers ++ [:erlang, :app],
     test_coverage: [tool: ExCoveralls],
     erlc_paths: ["lib"],
     deps: deps()]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  def application do
    [extra_applications: [:logger, :public_key]]
  end

  defp deps do
    [{:phoenix, "~> 1.3.0-rc"},
     {:cowboy, "~> 1.0"},
     {:ex_doc, ">= 0.0.0", only: [:dev, :test], runtime: false},
     {:excoveralls, "~> 0.4", only: [:dev, :test], runtime: false},
     {:credo, "~> 0.5", only: [:dev, :test], runtime: false},
     {:dialyxir, "~> 0.4", only: [:dev, :test], runtime: false}]
  end
end
