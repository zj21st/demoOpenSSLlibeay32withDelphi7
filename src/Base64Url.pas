// SPDX-License-Identifier: MIT
unit Base64Url;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}
{$H+}

interface

uses
  SysUtils;

type
  TByteBuffer = array of Byte;
  EBase64Url = class(Exception);

function Base64UrlEncode(const Data: TByteBuffer): AnsiString;
function Base64UrlDecode(const Text: AnsiString): TByteBuffer;
function BytesFromAnsi(const Text: AnsiString): TByteBuffer;
function AnsiFromBytes(const Data: TByteBuffer): AnsiString;
function HexEncode(const Data: TByteBuffer): AnsiString;

implementation

const
  BASE64URL_ALPHABET: AnsiString =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
  HEX_ALPHABET: AnsiString = '0123456789abcdef';

function Base64Value(C: AnsiChar): Integer;
begin
  case C of
    'A'..'Z': Result := Ord(C) - Ord('A');
    'a'..'z': Result := Ord(C) - Ord('a') + 26;
    '0'..'9': Result := Ord(C) - Ord('0') + 52;
    '-': Result := 62;
    '_': Result := 63;
  else
    Result := -1;
  end;
end;

function CheckedBase64Value(C: AnsiChar): Integer;
begin
  Result := Base64Value(C);
  if Result < 0 then
    raise EBase64Url.CreateFmt('Invalid Base64URL character: 0x%.2x',
      [Ord(C)]);
end;

function Base64UrlEncode(const Data: TByteBuffer): AnsiString;
var
  DataLength: Integer;
  InputIndex: Integer;
  OutputIndex: Integer;
  OutputLength: Integer;
  Remaining: Integer;
  B0: Byte;
  B1: Byte;
  B2: Byte;
begin
  DataLength := Length(Data);
  OutputLength := (DataLength div 3) * 4;
  case DataLength mod 3 of
    1: Inc(OutputLength, 2);
    2: Inc(OutputLength, 3);
  end;

  SetLength(Result, OutputLength);
  InputIndex := 0;
  OutputIndex := 1;

  while (DataLength - InputIndex) >= 3 do
  begin
    B0 := Data[InputIndex];
    B1 := Data[InputIndex + 1];
    B2 := Data[InputIndex + 2];

    Result[OutputIndex] := BASE64URL_ALPHABET[(B0 shr 2) + 1];
    Result[OutputIndex + 1] := BASE64URL_ALPHABET[
      (((B0 and $03) shl 4) or (B1 shr 4)) + 1];
    Result[OutputIndex + 2] := BASE64URL_ALPHABET[
      (((B1 and $0F) shl 2) or (B2 shr 6)) + 1];
    Result[OutputIndex + 3] := BASE64URL_ALPHABET[(B2 and $3F) + 1];

    Inc(InputIndex, 3);
    Inc(OutputIndex, 4);
  end;

  Remaining := DataLength - InputIndex;
  if Remaining = 1 then
  begin
    B0 := Data[InputIndex];
    Result[OutputIndex] := BASE64URL_ALPHABET[(B0 shr 2) + 1];
    Result[OutputIndex + 1] := BASE64URL_ALPHABET[((B0 and $03) shl 4) + 1];
  end
  else if Remaining = 2 then
  begin
    B0 := Data[InputIndex];
    B1 := Data[InputIndex + 1];
    Result[OutputIndex] := BASE64URL_ALPHABET[(B0 shr 2) + 1];
    Result[OutputIndex + 1] := BASE64URL_ALPHABET[
      (((B0 and $03) shl 4) or (B1 shr 4)) + 1];
    Result[OutputIndex + 2] := BASE64URL_ALPHABET[((B1 and $0F) shl 2) + 1];
  end;
end;

function Base64UrlDecode(const Text: AnsiString): TByteBuffer;
var
  TextLength: Integer;
  InputIndex: Integer;
  OutputIndex: Integer;
  OutputLength: Integer;
  Remaining: Integer;
  V0: Integer;
  V1: Integer;
  V2: Integer;
  V3: Integer;
begin
  TextLength := Length(Text);
  if (TextLength mod 4) = 1 then
    raise EBase64Url.Create('Invalid Base64URL length');

  OutputLength := (TextLength div 4) * 3;
  case TextLength mod 4 of
    2: Inc(OutputLength, 1);
    3: Inc(OutputLength, 2);
  end;
  SetLength(Result, OutputLength);

  InputIndex := 1;
  OutputIndex := 0;
  while (TextLength - InputIndex + 1) >= 4 do
  begin
    V0 := CheckedBase64Value(Text[InputIndex]);
    V1 := CheckedBase64Value(Text[InputIndex + 1]);
    V2 := CheckedBase64Value(Text[InputIndex + 2]);
    V3 := CheckedBase64Value(Text[InputIndex + 3]);

    Result[OutputIndex] := Byte((V0 shl 2) or (V1 shr 4));
    Result[OutputIndex + 1] := Byte(((V1 and $0F) shl 4) or (V2 shr 2));
    Result[OutputIndex + 2] := Byte(((V2 and $03) shl 6) or V3);

    Inc(InputIndex, 4);
    Inc(OutputIndex, 3);
  end;

  Remaining := TextLength - InputIndex + 1;
  if Remaining = 2 then
  begin
    V0 := CheckedBase64Value(Text[InputIndex]);
    V1 := CheckedBase64Value(Text[InputIndex + 1]);
    if (V1 and $0F) <> 0 then
      raise EBase64Url.Create('Non-canonical Base64URL trailing bits');
    Result[OutputIndex] := Byte((V0 shl 2) or (V1 shr 4));
  end
  else if Remaining = 3 then
  begin
    V0 := CheckedBase64Value(Text[InputIndex]);
    V1 := CheckedBase64Value(Text[InputIndex + 1]);
    V2 := CheckedBase64Value(Text[InputIndex + 2]);
    if (V2 and $03) <> 0 then
      raise EBase64Url.Create('Non-canonical Base64URL trailing bits');
    Result[OutputIndex] := Byte((V0 shl 2) or (V1 shr 4));
    Result[OutputIndex + 1] := Byte(((V1 and $0F) shl 4) or (V2 shr 2));
  end;
end;

function BytesFromAnsi(const Text: AnsiString): TByteBuffer;
begin
  SetLength(Result, Length(Text));
  if Length(Text) > 0 then
    Move(Text[1], Result[0], Length(Text));
end;

function AnsiFromBytes(const Data: TByteBuffer): AnsiString;
begin
  SetLength(Result, Length(Data));
  if Length(Data) > 0 then
    Move(Data[0], Result[1], Length(Data));
end;

function HexEncode(const Data: TByteBuffer): AnsiString;
var
  I: Integer;
begin
  SetLength(Result, Length(Data) * 2);
  for I := 0 to Length(Data) - 1 do
  begin
    Result[(I * 2) + 1] := HEX_ALPHABET[(Data[I] shr 4) + 1];
    Result[(I * 2) + 2] := HEX_ALPHABET[(Data[I] and $0F) + 1];
  end;
end;

end.
