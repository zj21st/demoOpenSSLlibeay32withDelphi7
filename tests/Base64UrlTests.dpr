// SPDX-License-Identifier: MIT
program Base64UrlTests;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}
{$H+}

uses
  SysUtils,
  Base64Url;

procedure Fail(const MessageText: string);
begin
  Writeln('FAIL: ', MessageText);
  Halt(1);
end;

procedure AssertEqual(const Expected, Actual, TestName: AnsiString);
begin
  if Expected <> Actual then
    Fail(string(TestName + ': expected "' + Expected + '", got "' +
      Actual + '"'));
end;

procedure AssertBufferEqual(const Expected, Actual: TByteBuffer;
  const TestName: AnsiString);
var
  I: Integer;
begin
  if Length(Expected) <> Length(Actual) then
    Fail(string(TestName + ': buffer lengths differ'));
  for I := 0 to Length(Expected) - 1 do
    if Expected[I] <> Actual[I] then
      Fail(string(TestName + ': buffer contents differ'));
end;

procedure ExpectDecodeError(const Encoded, TestName: AnsiString);
begin
  try
    Base64UrlDecode(Encoded);
    Fail(string(TestName + ': invalid input was accepted'));
  except
    on E: EBase64Url do
      Exit;
  end;
end;

procedure RunTests;
var
  BinaryData: TByteBuffer;
  RoundTripData: TByteBuffer;
begin
  AssertEqual('', Base64UrlEncode(BytesFromAnsi('')), 'empty');
  AssertEqual('Zg', Base64UrlEncode(BytesFromAnsi('f')), 'f');
  AssertEqual('Zm8', Base64UrlEncode(BytesFromAnsi('fo')), 'fo');
  AssertEqual('Zm9v', Base64UrlEncode(BytesFromAnsi('foo')), 'foo');

  SetLength(BinaryData, 3);
  BinaryData[0] := $FB;
  BinaryData[1] := $EF;
  BinaryData[2] := $FF;
  AssertEqual('--__', Base64UrlEncode(BinaryData), 'URL-safe alphabet');

  RoundTripData := Base64UrlDecode(Base64UrlEncode(BinaryData));
  AssertBufferEqual(BinaryData, RoundTripData, 'binary round trip');
  AssertEqual('', AnsiFromBytes(Base64UrlDecode('')), 'decode empty');
  AssertEqual('f', AnsiFromBytes(Base64UrlDecode('Zg')), 'decode f');
  AssertEqual('fo', AnsiFromBytes(Base64UrlDecode('Zm8')), 'decode fo');
  AssertEqual('foo', AnsiFromBytes(Base64UrlDecode('Zm9v')),
    'decode foo');

  ExpectDecodeError('A', 'length modulo four');
  ExpectDecodeError('Zg=', 'padding rejection');
  ExpectDecodeError('Z g', 'whitespace rejection');
  ExpectDecodeError('AB', 'non-canonical trailing bits');
  ExpectDecodeError('Zm9', 'non-canonical three-character trailing bits');
end;

begin
  RunTests;
  Writeln('All Base64URL tests passed.');
end.
