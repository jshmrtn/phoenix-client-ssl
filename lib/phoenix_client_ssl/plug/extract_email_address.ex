defmodule PhoenixClientSsl.Plug.ExtractEmailAddress do
  @moduledoc """
  This Plug extracts the `emailAddress` of a certificate in eligible connections.

  Best used together with `PhoenixClientSsl.Plug.ExtractClientCertificate`.

  ### Installation

  The plug can be installed in any `pipeline` of the Phoenix Router. It takes no options.

      defmodule Aceme.Web.Router do
        use Acme.Web, :router

        pipeline :api do
          plug :accepts, ["json"]

          # This line enables the plug
          plug PhoenixClientSsl.Plug.EmailAdress
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
  Extract the emailAddress of a certificate in eligible connections.

  Skipping if either the email address is already set or the connection has no client certificate.
  """
  def call(%Conn{private: %{client_certificate_email_address: _}} = conn, _options), do: conn

  def call(%Conn{private: %{client_certificate: certificate}} = conn, _options) do
    put_private(conn, :client_certificate_email_address, PublicKeySubject.email_address(certificate))
  end

  def call(conn, _options), do: conn
end
