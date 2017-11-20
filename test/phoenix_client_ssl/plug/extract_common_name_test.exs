defmodule PhoenixClientSsl.Plug.ExtractCommonNameTest do
  @moduledoc false

  use ExUnit.Case

  alias PhoenixClientSsl.Plug.ExtractCommonName
  alias Plug.Conn

  doctest ExtractCommonName

  @otp_cert [Application.app_dir(:phoenix_client_ssl), "priv", "test", "foo.bar.baz.der"]
  |> Path.join
  |> File.read!
  |> :public_key.pkix_decode_cert(:otp)

  describe "init/1" do
    test "empty config passes" do
      assert ExtractCommonName.init([]) == %{}
    end

    test "fails with given configuration" do
      assert_raise(FunctionClauseError, fn ->
        ExtractCommonName.init([foo: :bar])
      end)
    end
  end

  describe "call/2" do
    test "skipps with already configure common name" do
      conn = %Conn{private: %{client_certificate: @otp_cert, client_certificate_common_name: :foo}}

      assert %Conn{private: %{client_certificate_common_name: :foo}} = ExtractCommonName.call(conn, %{})
    end

    test "extracts common name" do
      conn = %Conn{private: %{client_certificate: @otp_cert}}

      assert %Conn{private: %{client_certificate_common_name: "foo.bar.baz"}} = ExtractCommonName.call(conn, %{})
    end

    test "skips with missing certificate" do
      conn = %Conn{}

      assert %Conn{private: private} = ExtractCommonName.call(conn, %{})
      refute private[:client_certificate_common_name]
    end
  end
end
