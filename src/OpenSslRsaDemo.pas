// SPDX-License-Identifier: MIT
unit OpenSslRsaDemo;

{$H+}

interface

uses
  SysUtils,
  Base64Url,
  libeay32;

type
  EOpenSslRsaDemo = class(Exception);

  TOpenSslRsaKey = class
  private
    FHandle: pRSA;
    FHasPrivatePart: Boolean;
    constructor Create(AHandle: pRSA; AHasPrivatePart: Boolean);
    function GetModulusBytes: Integer;
  public
    destructor Destroy; override;
    property ModulusBytes: Integer read GetModulusBytes;
    property HasPrivatePart: Boolean read FHasPrivatePart;
  end;

{ Process-global and intentionally not reference-counted. Call Finalize only
  after every key and context created by this compatibility demo is released. }
procedure LegacyOpenSslInitialize;
procedure LegacyOpenSslFinalize;
function LinkedOpenSslVersion: AnsiString;

function LoadPrivateRsaKeyPem(const FileName, Password: AnsiString):
  TOpenSslRsaKey;
function LoadPublicRsaKeyPem(const FileName: AnsiString): TOpenSslRsaKey;

function Sha256Bytes(const Data: TByteBuffer): TByteBuffer;
function RsaSha256Sign(const Data: TByteBuffer;
  Key: TOpenSslRsaKey): TByteBuffer;
function RsaSha256Verify(const Data, Signature: TByteBuffer;
  Key: TOpenSslRsaKey): Boolean;

function RsaEncryptPkcs1v15(const PlainText: TByteBuffer;
  Key: TOpenSslRsaKey): TByteBuffer;
function RsaDecryptPkcs1v15(const CipherText: TByteBuffer;
  Key: TOpenSslRsaKey): TByteBuffer;

implementation

const
  MINIMUM_RSA_BYTES = 256;

var
  GLegacyOpenSslInitialized: Boolean = False;

function BufferPointer(const Data: TByteBuffer): PCharacter;
begin
  if Length(Data) = 0 then
    Result := nil
  else
    Result := PCharacter(@Data[0]);
end;

function MutableBufferPointer(var Data: TByteBuffer): PCharacter;
begin
  if Length(Data) = 0 then
    Result := nil
  else
    Result := PCharacter(@Data[0]);
end;

function OpenSslErrors: AnsiString;
var
  ErrorCode: Cardinal;
  Buffer: array[0..255] of Char;
  MessageText: AnsiString;
begin
  Result := '';
  repeat
    ErrorCode := ERR_get_error;
    if ErrorCode = 0 then
      Break;

    FillChar(Buffer, SizeOf(Buffer), 0);
    ERR_error_string(ErrorCode, @Buffer[0]);
    MessageText := AnsiString(PChar(@Buffer[0]));
    if Result <> '' then
      Result := Result + ' | ';
    Result := Result + MessageText;
  until False;

  if Result = '' then
    Result := 'unknown OpenSSL error';
end;

procedure RaiseOpenSslError(const Operation: AnsiString);
begin
  raise EOpenSslRsaDemo.Create(string(Operation + ': ' + OpenSslErrors));
end;

procedure LegacyOpenSslInitialize;
begin
  if GLegacyOpenSslInitialized then
    Exit;

  OpenSSL_add_all_algorithms;
  ERR_load_crypto_strings;
  ERR_load_RSA_strings;
  GLegacyOpenSslInitialized := True;
end;

procedure LegacyOpenSslFinalize;
begin
  if not GLegacyOpenSslInitialized then
    Exit;

  EVP_cleanup;
  ERR_free_strings;
  GLegacyOpenSslInitialized := False;
end;

function LinkedOpenSslVersion: AnsiString;
var
  VersionText: PCharacter;
begin
  VersionText := SSLeay_version(_SSLEAY_VERSION);
  if VersionText = nil then
    Result := 'unknown'
  else
    Result := AnsiString(VersionText);
end;

constructor TOpenSslRsaKey.Create(AHandle: pRSA;
  AHasPrivatePart: Boolean);
begin
  inherited Create;
  if AHandle = nil then
    raise EOpenSslRsaDemo.Create('Cannot create an RSA key from a nil handle');
  FHandle := AHandle;
  FHasPrivatePart := AHasPrivatePart;
end;

destructor TOpenSslRsaKey.Destroy;
begin
  if FHandle <> nil then
  begin
    RSA_free(FHandle);
    FHandle := nil;
  end;
  inherited Destroy;
end;

function TOpenSslRsaKey.GetModulusBytes: Integer;
begin
  if FHandle = nil then
    raise EOpenSslRsaDemo.Create('RSA key handle has already been released');
  Result := RSA_size(FHandle);
end;

procedure ValidateKeyStrength(Rsa: pRSA);
begin
  if Rsa = nil then
    raise EOpenSslRsaDemo.Create('RSA key is missing');
  if RSA_size(Rsa) < MINIMUM_RSA_BYTES then
    raise EOpenSslRsaDemo.Create(
      'RSA moduli shorter than 256 bytes are rejected');
end;

procedure RequireKey(Key: TOpenSslRsaKey; PrivatePartRequired: Boolean);
begin
  if (Key = nil) or (Key.FHandle = nil) then
    raise EOpenSslRsaDemo.Create('An RSA key is required');
  if PrivatePartRequired and not Key.FHasPrivatePart then
    raise EOpenSslRsaDemo.Create('This operation requires an RSA private key');
end;

function PasswordCallback(Buffer: PCharacter; BufferSize: Integer;
  Verify: Integer; UserData: Pointer): Integer; cdecl;
var
  PasswordLength: Integer;
begin
  Result := 0;
  if (Buffer = nil) or (BufferSize <= 0) or (UserData = nil) then
    Exit;

  PasswordLength := StrLen(PCharacter(UserData));
  if PasswordLength > BufferSize then
    PasswordLength := BufferSize;
  if PasswordLength > 0 then
    Move(PCharacter(UserData)^, Buffer^, PasswordLength);
  Result := PasswordLength;
end;

function LoadPrivateRsaKeyPem(const FileName, Password: AnsiString):
  TOpenSslRsaKey;
var
  Bio: pBIO;
  PKey: pEVP_PKEY;
  Rsa: pRSA;
  FileNameCopy: AnsiString;
  Mode: AnsiString;
  PasswordCopy: AnsiString;
  PasswordData: Pointer;
begin
  Result := nil;
  Bio := nil;
  PKey := nil;
  Rsa := nil;
  FileNameCopy := FileName;
  Mode := 'rb';
  PasswordCopy := Password;
  UniqueString(PasswordCopy);

  try
    if not FileExists(string(FileNameCopy)) then
      raise EOpenSslRsaDemo.CreateFmt('Private-key file does not exist: %s',
        [string(FileNameCopy)]);

    LegacyOpenSslInitialize;
    ERR_clear_error;
    Bio := BIO_new_file(PCharacter(FileNameCopy), PCharacter(Mode));
    if Bio = nil then
      RaiseOpenSslError('Unable to open private-key file');

    PasswordData := Pointer(PCharacter(PasswordCopy));
    PKey := PEM_read_bio_PrivateKey(Bio, PKey, PasswordCallback,
      PasswordData);
    if PKey = nil then
      RaiseOpenSslError('Unable to parse PEM private key');

    Rsa := EVP_PKEY_get1_RSA(PKey);
    if Rsa = nil then
      RaiseOpenSslError('The private key is not an RSA key');

    ValidateKeyStrength(Rsa);
    ERR_clear_error;
    if RSA_check_key(Rsa) <> 1 then
      RaiseOpenSslError('RSA private-key validation failed');

    Result := TOpenSslRsaKey.Create(Rsa, True);
    Rsa := nil;
  finally
    if Rsa <> nil then
      RSA_free(Rsa);
    if PKey <> nil then
      EVP_PKEY_free(PKey);
    if Bio <> nil then
      BIO_free(Bio);
    if Length(PasswordCopy) > 0 then
      FillChar(PasswordCopy[1], Length(PasswordCopy), 0);
  end;
end;

function LoadPublicRsaKeyPem(const FileName: AnsiString): TOpenSslRsaKey;
var
  Bio: pBIO;
  PKey: pEVP_PKEY;
  Rsa: pRSA;
  FileNameCopy: AnsiString;
  Mode: AnsiString;
begin
  Result := nil;
  Bio := nil;
  PKey := nil;
  Rsa := nil;
  FileNameCopy := FileName;
  Mode := 'rb';

  if not FileExists(string(FileNameCopy)) then
    raise EOpenSslRsaDemo.CreateFmt('Public-key file does not exist: %s',
      [string(FileNameCopy)]);

  LegacyOpenSslInitialize;
  ERR_clear_error;
  try
    Bio := BIO_new_file(PCharacter(FileNameCopy), PCharacter(Mode));
    if Bio = nil then
      RaiseOpenSslError('Unable to open public-key file');

    PKey := PEM_read_bio_PUBKEY(Bio, PKey, nil, nil);
    if PKey <> nil then
    begin
      Rsa := EVP_PKEY_get1_RSA(PKey);
      if Rsa = nil then
        RaiseOpenSslError('The public key is not an RSA key');
    end
    else
    begin
      BIO_free(Bio);
      Bio := nil;
      ERR_clear_error;

      Bio := BIO_new_file(PCharacter(FileNameCopy), PCharacter(Mode));
      if Bio = nil then
        RaiseOpenSslError('Unable to reopen public-key file');
      Rsa := PEM_read_bio_RSAPublicKey(Bio, Rsa, nil, nil);
      if Rsa = nil then
        RaiseOpenSslError('Unable to parse PEM RSA public key');
    end;

    ValidateKeyStrength(Rsa);
    Result := TOpenSslRsaKey.Create(Rsa, False);
    Rsa := nil;
  finally
    if Rsa <> nil then
      RSA_free(Rsa);
    if PKey <> nil then
      EVP_PKEY_free(PKey);
    if Bio <> nil then
      BIO_free(Bio);
  end;
end;

function Sha256Bytes(const Data: TByteBuffer): TByteBuffer;
var
  Context: EVP_MD_CTX;
  DigestLength: Cardinal;
begin
  LegacyOpenSslInitialize;
  FillChar(Context, SizeOf(Context), 0);
  SetLength(Result, 32);
  DigestLength := 0;

  EVP_MD_CTX_init(@Context);
  try
    EVP_DigestInit(@Context, EVP_sha256());
    if Length(Data) > 0 then
      EVP_DigestUpdate(@Context, BufferPointer(Data), Length(Data));
    EVP_DigestFinal(@Context, MutableBufferPointer(Result), DigestLength);
  finally
    EVP_MD_CTX_cleanup(@Context);
  end;

  if DigestLength <> 32 then
    raise EOpenSslRsaDemo.CreateFmt(
      'OpenSSL returned an unexpected SHA-256 length: %d', [DigestLength]);
end;

function RsaSha256Sign(const Data: TByteBuffer;
  Key: TOpenSslRsaKey): TByteBuffer;
var
  Context: EVP_MD_CTX;
  PKey: pEVP_PKEY;
  MaximumSignatureLength: Integer;
  SignatureLength: Cardinal;
begin
  RequireKey(Key, True);
  LegacyOpenSslInitialize;
  ERR_clear_error;
  PKey := EVP_PKEY_new;
  if PKey = nil then
    RaiseOpenSslError('Unable to allocate an EVP key');

  FillChar(Context, SizeOf(Context), 0);
  EVP_MD_CTX_init(@Context);
  try
    if EVP_PKEY_set1_RSA(PKey, Key.FHandle) <> 1 then
      RaiseOpenSslError('Unable to attach the RSA private key');

    EVP_SignInit(@Context, EVP_sha256());
    if Length(Data) > 0 then
      EVP_SignUpdate(@Context, BufferPointer(Data), Length(Data));

    MaximumSignatureLength := EVP_PKEY_size(PKey);
    if MaximumSignatureLength <= 0 then
      RaiseOpenSslError('OpenSSL returned an invalid signature capacity');
    SetLength(Result, MaximumSignatureLength);
    SignatureLength := Length(Result);
    if EVP_SignFinal(@Context, MutableBufferPointer(Result), SignatureLength,
      PKey) <> 1 then
      RaiseOpenSslError('RSA-SHA256 signing failed');
    if SignatureLength > Cardinal(Length(Result)) then
      raise EOpenSslRsaDemo.Create('OpenSSL returned an invalid signature length');
    SetLength(Result, Integer(SignatureLength));
  finally
    EVP_MD_CTX_cleanup(@Context);
    EVP_PKEY_free(PKey);
  end;
end;

function RsaSha256Verify(const Data, Signature: TByteBuffer;
  Key: TOpenSslRsaKey): Boolean;
var
  Context: EVP_MD_CTX;
  PKey: pEVP_PKEY;
  VerifyResult: Integer;
begin
  Result := False;
  RequireKey(Key, False);
  if Length(Signature) <> Key.ModulusBytes then
    Exit;

  LegacyOpenSslInitialize;
  ERR_clear_error;
  PKey := EVP_PKEY_new;
  if PKey = nil then
    RaiseOpenSslError('Unable to allocate an EVP key');

  FillChar(Context, SizeOf(Context), 0);
  EVP_MD_CTX_init(@Context);
  try
    if EVP_PKEY_set1_RSA(PKey, Key.FHandle) <> 1 then
      RaiseOpenSslError('Unable to attach the RSA public key');

    EVP_VerifyInit(@Context, EVP_sha256());
    if Length(Data) > 0 then
      EVP_VerifyUpdate(@Context, BufferPointer(Data), Length(Data));
    VerifyResult := EVP_VerifyFinal(@Context, BufferPointer(Signature),
      Length(Signature), PKey);

    if VerifyResult = 1 then
      Result := True
    else if VerifyResult = 0 then
    begin
      ERR_clear_error;
      Result := False;
    end
    else
      RaiseOpenSslError('RSA-SHA256 verification failed');
  finally
    EVP_MD_CTX_cleanup(@Context);
    EVP_PKEY_free(PKey);
  end;
end;

function RsaEncryptPkcs1v15(const PlainText: TByteBuffer;
  Key: TOpenSslRsaKey): TByteBuffer;
var
  OutputLength: Integer;
  ModulusBytes: Integer;
begin
  RequireKey(Key, False);
  ModulusBytes := Key.ModulusBytes;
  if Length(PlainText) = 0 then
    raise EOpenSslRsaDemo.Create(
      'PKCS#1 v1.5 encryption requires non-empty plaintext');
  if Length(PlainText) > (ModulusBytes - 11) then
    raise EOpenSslRsaDemo.CreateFmt(
      'PKCS#1 v1.5 plaintext is too long; maximum is %d bytes',
      [ModulusBytes - 11]);

  LegacyOpenSslInitialize;
  if RAND_status <> 1 then
    RAND_screen;
  if RAND_status <> 1 then
    raise EOpenSslRsaDemo.Create('OpenSSL random-number generator is not ready');

  ERR_clear_error;
  SetLength(Result, ModulusBytes);
  OutputLength := RSA_public_encrypt(Length(PlainText),
    BufferPointer(PlainText), MutableBufferPointer(Result), Key.FHandle,
    RSA_PKCS1_PADDING);
  if OutputLength < 0 then
    RaiseOpenSslError('RSA PKCS#1 v1.5 encryption failed');
  SetLength(Result, OutputLength);
end;

function RsaDecryptPkcs1v15(const CipherText: TByteBuffer;
  Key: TOpenSslRsaKey): TByteBuffer;
var
  OutputLength: Integer;
  ModulusBytes: Integer;
begin
  RequireKey(Key, True);
  ModulusBytes := Key.ModulusBytes;
  if Length(CipherText) <> ModulusBytes then
    raise EOpenSslRsaDemo.CreateFmt(
      'RSA ciphertext must be exactly %d bytes', [ModulusBytes]);

  LegacyOpenSslInitialize;
  ERR_clear_error;
  SetLength(Result, ModulusBytes);
  OutputLength := RSA_private_decrypt(Length(CipherText),
    BufferPointer(CipherText), MutableBufferPointer(Result), Key.FHandle,
    RSA_PKCS1_PADDING);
  if OutputLength < 0 then
    RaiseOpenSslError('RSA PKCS#1 v1.5 decryption failed');
  SetLength(Result, OutputLength);
end;

end.
