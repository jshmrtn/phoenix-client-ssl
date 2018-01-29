if Code.ensure_loaded?(Absinthe.Plug) do
  defmodule PhoenixClientSsl.Plug.AddClientCertificateToAbsintheContext do
    @moduledoc """
    This Plug extracts the TLS Client Certificate CN from eligible connections and adds it to the absinthe context.

    Best used together with `PhoenixClientSsl.Plug.ExtractClientCertificate` and `PhoenixClientSsl.Plug.ExtractCommonName`.

    ### Installation

    The plug can be installed in any `pipeline` of the Phoenix Router. It takes no options.

        defmodule Acme.Web.Router do
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
    Add common name of a certificate to Absinthe context.
    """
    def call(
          %Conn{private: %{absinthe: absinthe, client_certificate_common_name: common_name}} =
            conn,
          _options
        ) do
      absinthe =
        absinthe
        |> Map.put_new(:context, %{})
        |> put_in([:context, :client_certificate_common_name], common_name)

      put_private(conn, :absinthe, absinthe)
    end

    def call(%Conn{private: %{client_certificate_common_name: _}} = conn, options) do
      call(put_private(conn, :absinthe, %{}), options)
    end

    def call(%Conn{} = conn, _options), do: conn
  end
end
