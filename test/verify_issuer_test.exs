defmodule PhoenixClientSsl.VerifyIssuerTest do
  @moduledoc false

  use ExUnit.Case

  alias PhoenixClientSsl.VerifyIssuer

  @single_ca Application.app_dir(:phoenix_client_ssl, "priv/test/single/ca.pem")
  @single_cert Application.app_dir(:phoenix_client_ssl, "priv/test/single/client.der")

  @multiple_ca Application.app_dir(:phoenix_client_ssl, "priv/test/multiple/ca.pem")
  @multiple_cert Application.app_dir(:phoenix_client_ssl, "priv/test/multiple/client.der")

  describe "verify/3" do
    test "small cert chain" do
      certificate = File.read!(@single_cert)
      assert {:valid_peer, []} = VerifyIssuer.verify(certificate, :valid_peer, [@single_ca])
    end

    test "large cert chain" do
      certificate = File.read!(@multiple_cert)
      assert {:valid_peer, []} = VerifyIssuer.verify(certificate, :valid_peer, [@multiple_ca])
    end
  end
end
