defmodule PhoenixClientSsl.Plug.ExtractClientCertificate do
  @moduledoc """
  This Plug extracts the TLS Client Certificate from eligible connections.

  ### Installation

  The plug can be installed in any `pipeline` of the Phoenix Router. It takes no options.

      defmodule Aceme.Web.Router do
        use Acme.Web, :router

        pipeline :api do
          plug :accepts, ["json"]

          # This line enables the plug
          plug PhoenixClientSsl.Plug.ExtractClientCertificate
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
  Extract TLS Client Certificate from Connection.

  Skipping if either the certificate is already set, the socket is non-ssl,
  or if the connection adapter is not `Plug.Adapters.Cowboy.Conn`.
  """
  def call(%Conn{private: %{client_certificate: _}} = conn, _options), do: conn

  def call(%Conn{adapter: {Plug.Adapters.Cowboy.Conn, request}} = conn, _options) do
    with {:sslsocket, _, _} = socket <- :cowboy_req.get(:socket, request),
         {:ok, raw_certificate} <- :ssl.peercert(socket),
         {:OTPCertificate, _, _, _} = certificate <-
           :public_key.pkix_decode_cert(raw_certificate, :otp) do
      put_private(conn, :client_certificate, certificate)
    else
      _ -> conn
    end
  end

  def call(
        %Conn{adapter: {Plug.Adapters.Cowboy2.Conn, %{cert: raw_certificate}}} = conn,
        _options
      )
      when is_binary(raw_certificate) do
    case :public_key.pkix_decode_cert(raw_certificate, :otp) do
      {:OTPCertificate, _, _, _} = certificate ->
        put_private(conn, :client_certificate, certificate)

      _ ->
        conn
    end
  end

  def call(conn, _options), do: conn
end
