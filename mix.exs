defmodule PhoenixClientSsl.Mixfile do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :phoenix_client_ssl,
      version: "0.4.1",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      compilers: Mix.compilers() ++ [:erlang, :app],
      test_coverage: [tool: ExCoveralls],
      erlc_paths: ["lib"],
      deps: deps(),
      build_embedded: (System.get_env("BUILD_EMBEDDED") || "false") in ["1", "true"],
      dialyzer:
        [
          ignore_warnings: ".dialyzer_ignore.exs"
        ] ++
          if (System.get_env("DIALYZER_PLT_PRIV") || "false") in ["1", "true"] do
            [
              plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
            ]
          else
            []
          end
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
      {:phoenix, "~> 1.3"},
      {:cowboy, "~> 1.0 or ~> 2.0"},
      {:glob, "~> 1.0"},
      {:absinthe_plug, "~> 1.4", optional: true},
      {:ex_doc, "~> 0.19", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.4", only: [:test], runtime: false},
      {:credo, "~> 1.4", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end
