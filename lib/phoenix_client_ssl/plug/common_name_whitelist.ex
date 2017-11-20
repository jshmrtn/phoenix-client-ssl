defmodule PhoenixClientSsl.Plug.CommonNameWhitelist do
  @moduledoc """
  This Plug checks a given common name against patterns.

  Best used together with `PhoenixClientSsl.Plug.ExtractCommonName`.

  ### Installation

  The plug can be installed in any `pipeline` of the Phoenix Router. It takes the option `patterns`.

  Router:

      defmodule Aceme.Web.Router do
        use Acme.Web, :router

        pipeline :api do
          plug :accepts, ["json"]

          # This line enables the plug
          plug PhoenixClientSsl.Plug.CommonNameWhitelist, Application.get_env(:acme, :common_name_whitelist, [])
        end

        scope "/", Acme.Web do
          pipe_through :api

          get "/", SomeController, :index
        end
      end

  Config:

      config :acme, :common_name_whitelist,
        patterns: ["*.example.com"],
        handler: &Acme.ErrorHandler.handle_whitelist_error/2

  """

  alias Plug.Conn

  @doc """
  Configuration for Plug.

  ### Options

  * `patterns` - List of whitelisted patterns
  * `handler` - Handler function of failures

  """
  def init(options) when is_list(options) do
    %{
      patterns: Keyword.get(options, :patterns, []),
      handler: Keyword.fetch!(options, :handler),
    }
  end

  @doc """
  Check if the common name matches against a given whitelist of patterns.
  """
  def call(%Conn{private: %{client_certificate_common_name: _}} = conn, %{patterns: [], handler: handler}) do
    apply(handler, [conn, :forbidden])
  end
  def call(%Conn{private: %{client_certificate_common_name: name}} = conn, %{patterns: patterns, handler: handler}) do
    if GlobMatcher.matches?(patterns, name) do
      conn
    else
      apply(handler, [conn, :forbidden])
    end
  end
  def call(conn, %{handler: handler}) do
    apply(handler, [conn, :unauthorized])
  end
end
