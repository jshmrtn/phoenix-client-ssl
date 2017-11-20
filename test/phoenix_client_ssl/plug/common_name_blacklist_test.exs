defmodule PhoenixClientSsl.Plug.CommonNameBlacklistTest do
  @moduledoc false

  use ExUnit.Case

  alias PhoenixClientSsl.Plug.CommonNameBlacklist
  alias Plug.Conn

  doctest CommonNameBlacklist

  defp send_and_return(conn, reason) do
    send self(), reason
    conn
  end

  describe "init/1" do
    test "config with patterns passes" do
      options = [patterns: ["foo"], handler: &send_and_return/2]
      assert %{patterns: ["foo"], handler: _} = CommonNameBlacklist.init(options)
    end
  end

  describe "call/2" do
    test "passes with valid pattern blacklist" do
      conn = %Conn{private: %{client_certificate_common_name: "foo"}}
      options = %{patterns: ["bar"], handler: &send_and_return/2}

      assert %Conn{} = CommonNameBlacklist.call(conn, options)

      refute_received(:forbidden)
      refute_received(:unauthorized)
    end

    test "stops with invalid pattern blacklist" do
      conn = %Conn{private: %{client_certificate_common_name: "foo"}}
      options = %{patterns: ["foo"], handler: &send_and_return/2}

      assert %Conn{} = CommonNameBlacklist.call(conn, options)

      assert_received(:forbidden)
      refute_received(:unauthorized)
    end

    test "passes with empty pattern whitelist" do
      conn = %Conn{private: %{client_certificate_common_name: "foo"}}
      options = %{patterns: [], handler: &send_and_return/2}

      assert %Conn{} = CommonNameBlacklist.call(conn, options)

      refute_received(:forbidden)
      refute_received(:unauthorized)
    end

    test "stops with missing common name" do
      options = %{patterns: ["foo"], handler: &send_and_return/2}

      assert %Conn{} = CommonNameBlacklist.call(%Conn{}, options)

      assert_received(:unauthorized)
      refute_received(:forbidden)
    end
  end
end
