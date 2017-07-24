defmodule PhoenixClientSsl.Plug.ExtractCommonName do
  @moduledoc """
  This Plug extracts the Common Name of a certificate in eligible connections.

  Best used together with `PhoenixClientSsl.Plug.ExtractClientCertificate`.

  ### Installation

  The plug can be installed in any `pipeline` of the Phoenix Router. It takes no options.

      defmodule Aceme.Web.Router do
        use Acme.Web, :router

        pipeline :api do
          plug :accepts, ["json"]

          # This line enables the plug
          plug PhoenixClientSsl.Plug.ExtractCommonName
        end

        scope "/", Acme.Web do
          pipe_through :api

          get "/", SomeController, :index
        end
      end

  """

  import Plug.Conn
  alias Plug.Conn

  @doc """
  No configuration needed.
  """
  def init([]), do: %{}

  @doc """
  Extract the COmmon Name of a certificate in eligible connections.

  Skipping if either the common name is already set or the connection has no client certificate.
  """
  def call(%Conn{assigns: %{client_certificate_common_name: _}} = conn, _options), do: conn
  def call(%Conn{assigns: %{client_certificate: certificate}} = conn, _options) do
    assign(conn, :client_certificate_common_name, PublicKeySubject.common_name(certificate))
  end
  def call(conn, _options), do: conn
end
