defmodule PhoenixClientSsl.Plug.AddClientCertificateToAbsintheContext do
  @moduledoc """
  This Plug extracts the TLS Client Certificate from eligible connections and add it to absinthe context.

  ### Installation

  The plug can be installed in any `pipeline` of the Phoenix Router. It takes no options.

      defmodule Aceme.Web.Router do
        use Acme.Web, :router

        pipeline :api do
          plug :accepts, ["json"]

          # This line enables the plug
          plug PhoenixClientSsl.Plug.AddClientCertificateToAbsintheContext
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
  def call(%Conn{private: %{absinthe: %{context: %{client_certificate: _}}}} = conn, _options), do: conn
  def call(%Conn{
    adapter: {Plug.Adapters.Cowboy.Conn, request},
    private: %{absinthe: absinthe}} = conn, _options) do
    with true = Code.ensure_loaded?(Absinthe.Plug),
         {:sslsocket, _, _} = socket <- :cowboy_req.get(:socket, request),
         {:ok, raw_certificate} <- :ssl.peercert(socket),
         {:"OTPCertificate", _, _, _} = certificate <- :public_key.pkix_decode_cert(raw_certificate, :otp)
    do
      absinthe =
      absinthe
      |> Map.put_new(:context, %{})
      |> put_in([:context, :client_certificate], certificate)

      put_private(conn, :absinthe, absinthe)
    else
      _ -> conn
    end
  end
  def call(%Conn{} = conn, options) do
    call(put_private(conn, :absinthe, %{}), options)
  end
end
