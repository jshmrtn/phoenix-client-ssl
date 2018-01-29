defmodule PhoenixClientSsl.Plug.AddClientCertificateToAbsintheContextTest do
  @moduledoc false

  use ExUnit.Case

  alias PhoenixClientSsl.Plug.AddClientCertificateToAbsintheContext
  alias Plug.Conn

  doctest AddClientCertificateToAbsintheContext

  describe "init/1" do
    test "empty config passes" do
      assert AddClientCertificateToAbsintheContext.init([]) == %{}
    end

    test "fails with given configuration" do
      assert_raise(FunctionClauseError, fn ->
        AddClientCertificateToAbsintheContext.init(foo: :bar)
      end)
    end
  end

  describe "call/2" do
    test "skipps with no common name added" do
      assert %Conn{} = AddClientCertificateToAbsintheContext.call(%Conn{}, %{})
    end

    test "skipps with already configured certificate" do
      conn = %Conn{private: %{absinthe: %{context: %{client_certificate_common_name: :foo}}}}
      assert conn = AddClientCertificateToAbsintheContext.call(conn, %{})
    end

    test "extracts certificate and adds it to existing absinthe map" do
      conn = %Conn{
        private: %{
          absinthe: %{random_value: "value"},
          client_certificate_common_name: "foo.bar.baz"
        }
      }

      assert %Conn{
               private: %{
                 absinthe: %{
                   context: %{client_certificate_common_name: common_name},
                   random_value: "value"
                 }
               }
             } = AddClientCertificateToAbsintheContext.call(conn, %{})

      assert "foo.bar.baz" = common_name
    end

    test "extracts certificate" do
      conn = %Conn{private: %{client_certificate_common_name: "foo.bar.baz"}}

      assert %Conn{
               private: %{absinthe: %{context: %{client_certificate_common_name: common_name}}}
             } = AddClientCertificateToAbsintheContext.call(conn, %{})

      assert "foo.bar.baz" = common_name
    end
  end
end
