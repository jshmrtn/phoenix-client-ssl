defmodule PublicKeySubjectTest do
  @moduledoc false

  use ExUnit.Case

  doctest PublicKeySubject

  @test_sequences [
    {"foo.bar.baz",
     {:rdnSequence,
      [
        [{:AttributeTypeAndValue, {2, 5, 4, 3}, {:printableString, "foo.bar.baz"}}],
        [{:AttributeTypeAndValue, {2, 5, 4, 6}, 'CH'}],
        [{:AttributeTypeAndValue, {1, 2, 840, 113_549, 1, 9, 1}, 'jonatan@maennchen.ch'}]
      ]}},
    {"something",
     {:rdnSequence,
      [
        [{:AttributeTypeAndValue, {2, 5, 4, 6}, 'CH'}],
        [{:AttributeTypeAndValue, {2, 5, 4, 3}, {:printableString, "something"}}],
        [{:AttributeTypeAndValue, {1, 2, 840, 113_549, 1, 9, 1}, 'jonatan@maennchen.ch'}]
      ]}},
    {"äöü",
     {:rdnSequence,
      [
        [{:AttributeTypeAndValue, {2, 5, 4, 3}, {:utf8String, "äöü"}}],
        [{:AttributeTypeAndValue, {2, 5, 4, 6}, 'CH'}],
        [{:AttributeTypeAndValue, {1, 2, 840, 113_549, 1, 9, 1}, 'jonatan@maennchen.ch'}]
      ]}}
  ]

  @der_cert [Application.app_dir(:phoenix_client_ssl), "priv", "test", "foo.bar.baz.der"]
            |> Path.join()
            |> File.read!()

  describe "common_name/1" do
    for {expected, data} <- @test_sequences do
      @data data
      test "correct output for #{expected}" do
        assert PublicKeySubject.common_name(@data) == unquote(expected)
      end
    end

    test "sequence without common name" do
      assert PublicKeySubject.common_name({:rdnSequence, []}) == :error
    end

    test "with cert string" do
      assert PublicKeySubject.common_name(@der_cert) == "foo.bar.baz"
    end

    test "with otp cert" do
      cert = :public_key.pkix_decode_cert(@der_cert, :otp)

      assert PublicKeySubject.common_name(cert) == "foo.bar.baz"
    end
  end

  describe "email_address/1" do
    for {expected, data} <- @test_sequences do
      @data data
      test "correct output for #{expected}" do
        assert PublicKeySubject.email_address(@data) === "jonatan@maennchen.ch"
      end
    end

    test "sequence without email address" do
      assert PublicKeySubject.email_address({:rdnSequence, []}) == :error
    end

    test "with cert string" do
      assert PublicKeySubject.email_address(@der_cert) == "jonatan@maennchen.ch"
    end

    test "with otp cert" do
      cert = :public_key.pkix_decode_cert(@der_cert, :otp)

      assert PublicKeySubject.email_address(cert) == "jonatan@maennchen.ch"
    end
  end

  describe "pkix_subject_id/1" do
    test "with cert string" do
      assert PublicKeySubject.pkix_subject_id(@der_cert) ==
               {:rdnSequence,
                [
                  [{:AttributeTypeAndValue, {2, 5, 4, 3}, {:utf8String, "foo.bar.baz"}}],
                  [{:AttributeTypeAndValue, {2, 5, 4, 6}, 'CH'}],
                  [
                    {:AttributeTypeAndValue, {1, 2, 840, 113_549, 1, 9, 1},
                     'jonatan@maennchen.ch'}
                  ]
                ]}
    end

    test "with otp cert" do
      cert = :public_key.pkix_decode_cert(@der_cert, :otp)

      assert PublicKeySubject.pkix_subject_id(cert) ==
               {:rdnSequence,
                [
                  [{:AttributeTypeAndValue, {2, 5, 4, 3}, {:utf8String, "foo.bar.baz"}}],
                  [{:AttributeTypeAndValue, {2, 5, 4, 6}, 'CH'}],
                  [
                    {:AttributeTypeAndValue, {1, 2, 840, 113_549, 1, 9, 1},
                     'jonatan@maennchen.ch'}
                  ]
                ]}
    end
  end
end
