defmodule PhoenixClientSsl.Plug.ExtractClientCertificateTest do
  @moduledoc false

  use ExUnit.Case

  alias PhoenixClientSsl.Plug.ExtractClientCertificate
  alias Plug.Conn
  alias PhoenixClientSsl.Support.SslsocketMock

  doctest ExtractClientCertificate

  describe "init/1" do
    test "empty config passes" do
      assert ExtractClientCertificate.init([]) == %{}
    end

    test "fails with given configuration" do
      assert_raise(FunctionClauseError, fn ->
        ExtractClientCertificate.init([foo: :bar])
      end)
    end
  end

  describe "call/2" do
    test "skipps with already configure certificate" do
      socket = SslsocketMock.test_socket()
      request = :cowboy_req.new(socket, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, false, 13, 14)
      conn = %Conn{adapter: {Plug.Adapters.Cowboy.Conn, request}, assigns: %{client_certificate: :foo}}

      assert %Conn{assigns: %{client_certificate: :foo}} = ExtractClientCertificate.call(conn, %{})
    end

    test "extracts certificate" do
      socket = SslsocketMock.test_socket()
      request = :cowboy_req.new(socket, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, false, 13, 14)
      conn = %Conn{adapter: {Plug.Adapters.Cowboy.Conn, request}}

      assert %Conn{assigns: %{client_certificate: certificate}} = ExtractClientCertificate.call(conn, %{})
      assert {:"OTPCertificate", _, _, _} = certificate
    end

    test "does nothing with incorrect socket" do
      socket = SslsocketMock.undefined_test_socket()
      request = :cowboy_req.new(socket, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, false, 13, 14)
      conn = %Conn{adapter: {Plug.Adapters.Cowboy.Conn, request}}

      assert %Conn{assigns: assigns} = ExtractClientCertificate.call(conn, %{})
      refute assigns[:client_certificate]
    end

    test "skips with wrong adapter" do
      conn = %Conn{adapter: {Some.Other.Adapter, :something}}

      assert %Conn{assigns: assigns} = ExtractClientCertificate.call(conn, %{})
      refute assigns[:client_certificate]
    end
  end
end
