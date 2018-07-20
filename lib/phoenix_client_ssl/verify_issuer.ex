defmodule PhoenixClientSsl.VerifyIssuer do
  @moduledoc """
  Check separate Issuer
  """

  def verify(certificate, :valid_peer, ca_paths) do
    ca_paths
    |> Enum.map(&File.read!/1)
    |> Enum.flat_map(fn contents ->
      contents
      |> :public_key.pem_decode()
      |> Enum.map(fn {_, bin, _} -> bin end)
    end)
    |> Enum.any?(fn trusted ->
      case :public_key.pkix_path_validation(trusted, [certificate], []) do
        {:ok, _} -> true
        _ -> false
      end
    end)
    |> if do
      {:valid_peer, []}
    else
      {:fail, :invalid_issuer}
    end
  end

  def verify(_certificate, :valid, user_state) do
    {:valid, user_state}
  end

  def verify(_certificate, {:extension, _}, user_state) do
    {:unknown, user_state}
  end

  def verify(_certificate, {:bad_cert, _} = reason, _user_state) do
    {:fail, reason}
  end
end
