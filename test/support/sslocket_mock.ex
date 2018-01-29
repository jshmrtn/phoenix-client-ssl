defmodule PhoenixClientSsl.Support.SslsocketMock do
  @moduledoc """
  Provide Mock for sslsocket without actually opening a socket.

  This only works for the `:ssl.peercert/1` function.
  """

  import Record, only: [defrecord: 2, extract: 2]

  defrecord :sslsocket, extract(:sslsocket, from_lib: "ssl/src/ssl_api.hrl")

  @der_cert File.read!(
              Path.join([
                Application.app_dir(:phoenix_client_ssl),
                "priv",
                "test",
                "foo.bar.baz.der"
              ])
            )

  @doc """
  Create a test socket, that answers with the `priv/test/foo.bar.baz.der` certificate.
  """
  def test_socket do
    %Task{pid: pid} =
      Task.async(fn ->
        receive do
          {:"$gen_call", {caller, reference}, :peer_certificate} ->
            send(caller, {reference, {:ok, @der_cert}})
        end
      end)

    sslsocket(pid: pid)
  end

  @doc """
  Create a broken test socket.
  """
  def undefined_test_socket do
    %Task{pid: pid} =
      Task.async(fn ->
        receive do
          {:"$gen_call", {caller, reference}, :peer_certificate} ->
            send(caller, {reference, {:ok, :undefined}})
        end
      end)

    sslsocket(pid: pid)
  end
end
