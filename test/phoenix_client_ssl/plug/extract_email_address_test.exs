defmodule PhoenixClientSsl.Plug.ExtractEmailAddressTest do
  @moduledoc false

  use ExUnit.Case

  alias PhoenixClientSsl.Plug.ExtractEmailAddress
  alias Plug.Conn

  doctest ExtractEmailAddress

  @otp_cert [Application.app_dir(:phoenix_client_ssl), "priv", "test", "foo.bar.baz.der"]
            |> Path.join()
            |> File.read!()
            |> :public_key.pkix_decode_cert(:otp)

  describe "init/1" do
    test "empty config passes" do
      assert ExtractEmailAddress.init([]) == %{}
    end

    test "fails with given configuration" do
      assert_raise(FunctionClauseError, fn ->
        ExtractEmailAddress.init(foo: :bar)
      end)
    end
  end

  describe "call/2" do
    test "skipps with already configure email address" do
      conn = %Conn{
        private: %{client_certificate: @otp_cert, client_certificate_email_address: :foo}
      }

      assert %Conn{private: %{client_certificate_email_address: :foo}} =
               ExtractEmailAddress.call(conn, %{})
    end

    test "extracts email address" do
      conn = %Conn{private: %{client_certificate: @otp_cert}}

      assert %Conn{private: %{client_certificate_email_address: "jonatan@maennchen.ch"}} =
               ExtractEmailAddress.call(conn, %{})
    end

    test "skips with missing certificate" do
      conn = %Conn{}

      assert %Conn{private: private} = ExtractEmailAddress.call(conn, %{})
      refute private[:client_certificate_email_address]
    end
  end
end
