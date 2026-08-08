// SPDX-License-Identifier: MIT
program Demo;

{$APPTYPE CONSOLE}
{$H+}

uses
  SysUtils,
  Base64Url in '..\..\src\Base64Url.pas',
  OpenSslRsaDemo in '..\..\src\OpenSslRsaDemo.pas',
  libeay32 in '..\..\src\legacy\libeay32.pas';

const
  EXPECTED_SHA256_ABC =
    'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad';

function BuffersEqual(const Left, Right: TByteBuffer): Boolean;
var
  I: Integer;
  Difference: Byte;
begin
  if Length(Left) <> Length(Right) then
  begin
    Result := False;
    Exit;
  end;

  Difference := 0;
  for I := 0 to Length(Left) - 1 do
    Difference := Byte(Difference or (Left[I] xor Right[I]));
  Result := Difference = 0;
end;

function CloneBuffer(const Source: TByteBuffer): TByteBuffer;
begin
  SetLength(Result, Length(Source));
  if Length(Source) > 0 then
    Move(Source[0], Result[0], Length(Source));
end;

procedure RunSelfTest(const PrivateKeyFile, PublicKeyFile: AnsiString);
var
  PrivateKey: TOpenSslRsaKey;
  PublicKey: TOpenSslRsaKey;
  MessageData: TByteBuffer;
  ModifiedMessage: TByteBuffer;
  Digest: TByteBuffer;
  Signature: TByteBuffer;
  ModifiedSignature: TByteBuffer;
  EncodedSignature: AnsiString;
  DecodedSignature: TByteBuffer;
  CipherText: TByteBuffer;
  PlainText: TByteBuffer;
begin
  PrivateKey := nil;
  PublicKey := nil;
  try
    PrivateKey := LoadPrivateRsaKeyPem(PrivateKeyFile, '');
    PublicKey := LoadPublicRsaKeyPem(PublicKeyFile);

    Writeln('Linked library: ', string(LinkedOpenSslVersion));
    Writeln('RSA modulus storage: ', PublicKey.ModulusBytes, ' bytes');

    Digest := Sha256Bytes(BytesFromAnsi('abc'));
    if HexEncode(Digest) <> EXPECTED_SHA256_ABC then
      raise Exception.Create('SHA-256 reference vector failed');
    Writeln('[ok] SHA-256 reference vector');

    MessageData := BytesFromAnsi('Delphi 7 legacy OpenSSL compatibility demo');
    Signature := RsaSha256Sign(MessageData, PrivateKey);
    if not RsaSha256Verify(MessageData, Signature, PublicKey) then
      raise Exception.Create('RSA-SHA256 signature verification failed');

    ModifiedMessage := BytesFromAnsi(
      'Delphi 7 legacy OpenSSL compatibility demo!');
    if RsaSha256Verify(ModifiedMessage, Signature, PublicKey) then
      raise Exception.Create('A modified message passed signature verification');

    ModifiedSignature := CloneBuffer(Signature);
    ModifiedSignature[0] := ModifiedSignature[0] xor $01;
    if RsaSha256Verify(MessageData, ModifiedSignature, PublicKey) then
      raise Exception.Create('A modified signature passed verification');
    Writeln('[ok] RSA-SHA256 sign, verify, and tamper rejection');

    EncodedSignature := Base64UrlEncode(Signature);
    DecodedSignature := Base64UrlDecode(EncodedSignature);
    if not BuffersEqual(Signature, DecodedSignature) then
      raise Exception.Create('Base64URL round trip failed');
    Writeln('[ok] unpadded Base64URL round trip');

    CipherText := RsaEncryptPkcs1v15(MessageData, PublicKey);
    PlainText := RsaDecryptPkcs1v15(CipherText, PrivateKey);
    if not BuffersEqual(MessageData, PlainText) then
      raise Exception.Create('RSA PKCS#1 v1.5 round trip failed');
    Writeln('[ok] legacy RSA PKCS#1 v1.5 encryption round trip');

    Writeln('Signature (Base64URL): ', string(EncodedSignature));
    Writeln('All compatibility self-tests passed.');
  finally
    PublicKey.Free;
    PrivateKey.Free;
  end;
end;

var
  ProgramExitCode: Integer;
begin
  ProgramExitCode := 0;
  try
    if ParamCount <> 2 then
    begin
      Writeln('Usage: Demo.exe <private-key.pem> <public-key.pem>');
      ProgramExitCode := 2;
    end
    else
    begin
      Writeln('WARNING: legacy interoperability demo; not for production use.');
      LegacyOpenSslInitialize;
      RunSelfTest(AnsiString(ParamStr(1)), AnsiString(ParamStr(2)));
    end;
  except
    on E: Exception do
    begin
      Writeln('ERROR: ', E.Message);
      ProgramExitCode := 1;
    end;
  end;

  LegacyOpenSslFinalize;
  Halt(ProgramExitCode);
end.
