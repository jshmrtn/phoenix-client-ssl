%%
%% Utility to extract the subject / its CN from Certificates
%%
%% The reason for this module to be written in Erlang is, that it is impossible
%% without hacks, to use Erlang Macros like `?'id-at-commonName'` in Elixir.
%%
%% Also all Erlang Records would have to be pulicated in Elixir and there's no
%% pattern matching in Elixir for Records.
%%

-module(public_key_subject).

-include_lib("public_key/include/public_key.hrl").

-export ([common_name/1,
          email_address/1,
          pkix_subject_id/1]).

%%--------------------------------------------------------------------
-spec pkix_subject_id(Cert::binary()| #'OTPCertificate'{}) -> {rdnSequence, [#'AttributeTypeAndValue'{}]}.
%
%% Description: Returns the subject id.
%%--------------------------------------------------------------------
pkix_subject_id(#'OTPCertificate'{} = OtpCert) ->
    TBSCert = OtpCert#'OTPCertificate'.tbsCertificate,
    Subject = TBSCert#'OTPTBSCertificate'.subject,
    pubkey_cert:normalize_general_name(Subject);
pkix_subject_id(Cert) when is_binary(Cert) ->
    OtpCert = public_key:pkix_decode_cert(Cert, otp),
    pkix_subject_id(OtpCert).

%%--------------------------------------------------------------------
-spec common_name(Cert::{rdnSequence, [#'AttributeTypeAndValue'{}]} | binary() | #'OTPCertificate'{}) -> binary().

%
%% Description: Returns the common name.
%%--------------------------------------------------------------------

common_name({rdnSequence, Sequence}) ->
  case rdn_part(Sequence, ?'id-at-commonName') of
    error ->
      error;
    Other ->
      rdn_to_ex_string(Other)
  end;
common_name(Cert) ->
  common_name(pkix_subject_id(Cert)).

%%--------------------------------------------------------------------
-spec email_address(Cert::{rdnSequence, [#'AttributeTypeAndValue'{}]} | binary() | #'OTPCertificate'{}) -> binary().

%
%% Description: Returns the email address.
%%--------------------------------------------------------------------

email_address({rdnSequence, Sequence}) ->
  case rdn_part(Sequence, ?'id-emailAddress') of
    error ->
      error;
    Other ->
      Other
  end;
email_address(Cert) ->
  email_address(pkix_subject_id(Cert)).

%%--------------------------------------------------------------------
-spec rdn_part([#'AttributeTypeAndValue'{}], any()) -> any().

%
%% Description: Returns the attribute value matching Type.
%%--------------------------------------------------------------------

rdn_part([[#'AttributeTypeAndValue'{type=Type, value=Value} | _] | _], Type) ->
    Value;
rdn_part([_ | Tail], Type) ->
    rdn_part(Tail, Type);
rdn_part([], _) ->
    error.

%%--------------------------------------------------------------------
-spec rdn_to_ex_string(any()) -> binary().

%
%% Description: Returns the rdn value as Elixir Binary.
%%--------------------------------------------------------------------

rdn_to_ex_string({utf8String, Binary}) ->
    Binary;
rdn_to_ex_string({printableString, String}) ->
    String.
