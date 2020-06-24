defmodule PhoenixClientSsl.Plug.ExtractClientCertificateTest do
  @moduledoc false

  use ExUnit.Case

  alias PhoenixClientSsl.Plug.ExtractClientCertificate
  alias PhoenixClientSsl.Support.SslsocketMock
  alias Plug.Conn

  @der_cert File.read!(
              Path.join([
                Application.app_dir(:phoenix_client_ssl),
                "priv",
                "test",
                "foo.bar.baz.der"
              ])
            )

  doctest ExtractClientCertificate

  describe "init/1" do
    test "empty config passes" do
      assert ExtractClientCertificate.init([]) == %{}
    end

    test "fails with given configuration" do
      assert_raise(FunctionClauseError, fn ->
        ExtractClientCertificate.init(foo: :bar)
      end)
    end
  end

  describe "call/2" do
    @tag :cowboy_1
    test "cowboy1 skipps with already configure certificate" do
      socket = SslsocketMock.test_socket()
      request = :cowboy_req.new(socket, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, false, 13, 14)

      conn = %Conn{
        adapter: {Plug.Adapters.Cowboy.Conn, request},
        private: %{client_certificate: :foo}
      }

      assert %Conn{private: %{client_certificate: :foo}} =
               ExtractClientCertificate.call(conn, %{})
    end

    @tag :cowboy_1
    test "cowboy1 extracts certificate" do
      socket = SslsocketMock.test_socket()
      request = :cowboy_req.new(socket, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, false, 13, 14)
      conn = %Conn{adapter: {Plug.Adapters.Cowboy.Conn, request}}

      assert %Conn{private: %{client_certificate: certificate}} =
               ExtractClientCertificate.call(conn, %{})

      assert {:OTPCertificate, _, _, _} = certificate
    end

    @tag :cowboy_1
    test "cowboy1 does nothing with incorrect socket" do
      socket = SslsocketMock.undefined_test_socket()
      request = :cowboy_req.new(socket, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, false, 13, 14)
      conn = %Conn{adapter: {Plug.Adapters.Cowboy.Conn, request}}

      assert %Conn{private: private} = ExtractClientCertificate.call(conn, %{})
      refute private[:client_certificate]
    end

    @tag :cowboy_2
    test "cowboy2 skipps with already configure certificate" do
      conn = %Conn{
        adapter: {Plug.Adapters.Cowboy2.Conn, %{cert: @der_cert}},
        private: %{client_certificate: :foo}
      }

      assert %Conn{private: %{client_certificate: :foo}} =
               ExtractClientCertificate.call(conn, %{})
    end

    @tag :cowboy_2
    test "cowboy2 extracts certificate" do
      conn = %Conn{adapter: {Plug.Adapters.Cowboy2.Conn, %{cert: @der_cert}}}

      assert %Conn{private: %{client_certificate: certificate}} =
               ExtractClientCertificate.call(conn, %{})

      assert {:OTPCertificate, _, _, _} = certificate
    end

    test "skips with wrong adapter" do
      conn = %Conn{adapter: {Some.Other.Adapter, :something}}

      assert %Conn{private: private} = ExtractClientCertificate.call(conn, %{})
      refute private[:client_certificate]
    end
  end
end
