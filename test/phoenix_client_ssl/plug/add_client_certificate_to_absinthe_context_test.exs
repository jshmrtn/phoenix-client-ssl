defmodule PhoenixClientSsl.Plug.AddClientCertificateToAbsintheContextTest do
  @moduledoc false

  use ExUnit.Case

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
    test "skipps with already configure certificate" do
      socket = SslsocketMock.test_socket()
      request = :cowboy_req.new(socket, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, false, 13, 14)
      conn = %Conn{adapter: {Plug.Adapters.Cowboy.Conn, request}, private: %{client_certificate: :foo}}

      assert %Conn{private: %{client_certificate: :foo}} = AddClientCertificateToAbsintheContext.call(conn, %{})
    end

    test "extracts certificate and add it to existing absinthe map" do
      socket = SslsocketMock.test_socket()
      request = :cowboy_req.new(socket, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, false, 13, 14)
      conn = %Conn{
        adapter: {Plug.Adapters.Cowboy.Conn, request}}

      assert %Conn{private: %{absinthe: %{context: %{client_certificate: certificate}}}}
        = AddClientCertificateToAbsintheContext.call(conn, %{})
      assert {:"OTPCertificate", _, _, _} = certificate
    end

    test "extracts certificate" do
      socket = SslsocketMock.test_socket()
      request = :cowboy_req.new(socket, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, false, 13, 14)
      conn = %Conn{adapter: {Plug.Adapters.Cowboy.Conn, request}}

      assert %Conn{private: %{absinthe: %{context: %{client_certificate: certificate}}}}
        = AddClientCertificateToAbsintheContext.call(conn, %{})
      assert {:"OTPCertificate", _, _, _} = certificate
    end

    test "does nothing with incorrect socket" do
      socket = SslsocketMock.undefined_test_socket()
      request = :cowboy_req.new(socket, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, false, 13, 14)
      conn = %Conn{adapter: {Plug.Adapters.Cowboy.Conn, request}}

      assert %Conn{private: private} = AddClientCertificateToAbsintheContext.call(conn, %{})
      refute private[:client_certificate]
    end
  end
end
