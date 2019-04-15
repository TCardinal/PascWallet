/// <summary>
/// TStreamOp is based on TStreamOp form PascalCoin Core by Alfred Molina
/// </summary>
unit PascalCoin.StreamOp;

interface

uses PascalCoin.Wallet.Interfaces, PascalCoin.Utils.Interfaces, System.Classes,
  System.SysUtils;

type

  TStreamOp = Class(TInterfacedObject, IStreamOp)
  public
    function ReadRawBytes(Stream: TStream; var Value: TRawBytes): Integer;
    function WriteRawBytes(Stream: TStream; const Value: TRawBytes)
      : Integer; overload;
    function ReadString(Stream: TStream; var Value: String): Integer;
    function WriteAccountKey(Stream: TStream; const Value: IPublicKey): Integer;
    function ReadAccountKey(Stream: TStream; var Value: IPublicKey): Integer;
    function SaveStreamToRawBytes(Stream: TStream): TRawBytes;
    procedure LoadStreamFromRawBytes(Stream: TStream; const raw: TRawBytes);
  End;

implementation

{ TStreamOp }

uses PascalCoin.Helpers;

procedure TStreamOp.LoadStreamFromRawBytes(Stream: TStream;
  const raw: TRawBytes);
begin
  Stream.WriteBuffer(raw[Low(raw)], Length(raw));
end;

function TStreamOp.ReadAccountKey(Stream: TStream;
  var Value: IPublicKey): Integer;
begin

end;

function TStreamOp.ReadRawBytes(Stream: TStream; var Value: TRawBytes): Integer;
Var
  w: Word;
begin
  if Stream.Size - Stream.Position < 2 then
  begin
    SetLength(Value, 0);
    Result := -1;
    Exit;
  end;
  Stream.Read(w, 2);
  if Stream.Size - Stream.Position < w then
  begin
    Stream.Position := Stream.Position - 2; // Go back!
    SetLength(Value, 0);
    Result := -1;
    Exit;
  end;
  SetLength(Value, w);
  if (w > 0) then
  begin
    Stream.ReadBuffer(Value[Low(Value)], w);
  end;
  Result := w + 2;
end;

function TStreamOp.ReadString(Stream: TStream; var Value: String): Integer;
var
  raw: TRawBytes;
begin
  Result := ReadRawBytes(Stream, raw);
  Value := raw.ToString;
end;

function TStreamOp.SaveStreamToRawBytes(Stream: TStream): TRawBytes;
begin
  SetLength(Result, Stream.Size);
  Stream.Position := 0;
  Stream.ReadBuffer(Result[Low(Result)], Stream.Size);
end;

function TStreamOp.WriteAccountKey(Stream: TStream;
  const Value: IPublicKey): Integer;
begin

end;

function TStreamOp.WriteRawBytes(Stream: TStream;
  const Value: TRawBytes): Integer;
Var
  w: Word;
begin
  if (Length(Value) > (256 * 256)) then
  begin
    raise Exception.Create('Invalid stream size! ' + Inttostr(Length(Value)));
  end;

  w := Length(Value);
  Stream.Write(w, 2);
  if (w > 0) then
    Stream.WriteBuffer(Value[Low(Value)], Length(Value));
  Result := w + 2;
end;

end.
