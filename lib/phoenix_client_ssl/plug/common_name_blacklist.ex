defmodule PhoenixClientSsl.Plug.CommonNameBlacklist do
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
          plug PhoenixClientSsl.Plug.CommonNameBlacklist, Application.get_env(:acme, :common_name_blacklist, [])
        end

        scope "/", Acme.Web do
          pipe_through :api

          get "/", SomeController, :index
        end
      end

  Config:

      config :acme, :common_name_blacklist,
        patterns: ["*.example.com"],
        handler: &Acme.ErrorHandler.handle_blacklist_error/2

  """

  alias Plug.Conn

  @doc """
  Configuration for Plug.

  ### Options

  * `patterns` - List of blacklisted patterns
  * `handler` - Handler function of failures

  """
  def init(options) when is_list(options) do
    %{
      patterns: Keyword.get(options, :patterns, []),
      handler: Keyword.fetch!(options, :handler),
    }
  end

  @doc """
  Check if the common name matches against a given blacklist of patterns.
  """
  def call(%Conn{assigns: %{client_certificate_common_name: _}} = conn, %{patterns: []}) do
    conn
  end
  def call(%Conn{assigns: %{client_certificate_common_name: name}} = conn, %{patterns: patterns, handler: handler}) do
    if GlobMatcher.matches?(patterns, name) do
      apply(handler, [conn, :forbidden])
    else
      conn
    end
  end
  def call(conn, %{handler: handler}) do
    apply(handler, [conn, :unauthorized])
  end
end
