defmodule PhoenixClientSsl.Plug.AddClientCertificateToAbsintheContextTest do
  @moduledoc false

  use ExUnit.Case

  alias PhoenixClientSsl.Plug.ExtractClientCertificate
  alias PhoenixClientSsl.Plug.ExtractCommonName
  alias PhoenixClientSsl.Plug.AddClientCertificateToAbsintheContext
  alias Plug.Conn
  alias PhoenixClientSsl.Support.SslsocketMock

  doctest AddClientCertificateToAbsintheContext

  describe "init/1" do
    test "empty config passes" do
      assert AddClientCertificateToAbsintheContext.init([]) == %{}
    end

    test "fails with given configuration" do
      assert_raise(FunctionClauseError, fn ->
        AddClientCertificateToAbsintheContext.init([foo: :bar])
      end)
    end
  end

  describe "call/2" do
    test "skipps with no common name added" do
      conn = %Conn{}
      assert conn = AddClientCertificateToAbsintheContext.call(conn, %{})
    end

    test "skipps with already configured certificate" do
      conn = %Conn{private: %{absinthe: %{context: %{client_certificate_common_name: :foo}}}}

      assert conn = AddClientCertificateToAbsintheContext.call(conn, %{})
    end

    test "extracts certificate and adds it to existing absinthe map" do
      socket = SslsocketMock.test_socket()
      request = :cowboy_req.new(socket, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, false, 13, 14)
      conn = %Conn{
        adapter: {Plug.Adapters.Cowboy.Conn, request},
        private: %{absinthe: %{random_value: "value"}}}
        |> ExtractClientCertificate.call(%{})
        |> ExtractCommonName.call(%{})

      assert %Conn{private: %{absinthe: %{context: %{client_certificate_common_name: common_name}, random_value: "value"}}}
        = AddClientCertificateToAbsintheContext.call(conn, %{})

      assert "foo.bar.baz" = common_name
    end

    test "extracts certificate" do
      socket = SslsocketMock.test_socket()
      request = :cowboy_req.new(socket, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, false, 13, 14)
      conn = %Conn{adapter: {Plug.Adapters.Cowboy.Conn, request}}
      |> ExtractClientCertificate.call(%{})
      |> ExtractCommonName.call(%{})

      assert %Conn{private: %{absinthe: %{context: %{client_certificate_common_name: common_name}}}}
        = AddClientCertificateToAbsintheContext.call(conn, %{})
      assert "foo.bar.baz" = common_name
    end
  end
end
