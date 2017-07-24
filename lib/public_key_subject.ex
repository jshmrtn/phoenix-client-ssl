defmodule PublicKeySubject do
  @moduledoc """
  Utility to extract the subject / its CN from Certificates.
  """

  @doc """
  Returns the common name.

  ### Examples

      iex> PublicKeySubject.common_name({:rdnSequence,
      ...>                               [[{:AttributeTypeAndValue, {2, 5, 4, 3}, {:printableString, "foo.bar.baz"}}],
      ...>                                [{:AttributeTypeAndValue, {2, 5, 4, 6}, 'CH'}]]})
      "foo.bar.baz"

      iex> der_path = Path.join([Application.app_dir(:phoenix_client_ssl), "priv", "test", "foo.bar.baz.der"])
      iex> PublicKeySubject.common_name(File.read!(der_path))
      "foo.bar.baz"

  """
  defdelegate common_name(cert_or_rdn_sequence), to: :public_key_subject

  @doc """
  Returns the certificates subject.

  ### Examples

      iex> der_path = Path.join([Application.app_dir(:phoenix_client_ssl), "priv", "test", "foo.bar.baz.der"])
      iex> PublicKeySubject.pkix_subject_id(File.read!(der_path))
      {:rdnSequence,
       [[{:AttributeTypeAndValue, {2, 5, 4, 3},
          {:utf8String, "foo.bar.baz"}}],
        [{:AttributeTypeAndValue, {2, 5, 4, 6}, 'CH'}],
        [{:AttributeTypeAndValue, {1, 2, 840, 113549, 1, 9, 1},
          'jonatan@maennchen.ch'}]]}

  """
  defdelegate pkix_subject_id(cert), to: :public_key_subject
end
