defmodule PhoenixClientSsl.VerifyIssuer do
  @moduledoc """
  Check separate Issuer
  """

  def verify(certificate, :valid_peer, [ca_path]) do
    ca_path
    |> File.read!()
    |> :public_key.pem_decode()
    |> Enum.map(fn {_, bin, _} -> bin end)
    |> List.first()
    |> :public_key.pkix_path_validation([certificate], [])
    |> case do
      {:ok, _} ->
        {:valid_peer, []}

      _ ->
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
