/// <summary>
///   TStreamOp is based on TStreamOp form PascalCoin Core by Alfred Molina
/// </summary>
unit PascalCoin.StreamOp;

interface

uses PascalCoin.Wallet.Interfaces, System.Classes, System.SysUtils;

type

TStreamOp = Class(TInterfacedObject, IStreamOp)
public
  function ReadRawBytes(Stream: TStream; var Value: TRawBytes): Integer;
  function WriteRawBytes(Stream: TStream; const value: TRawBytes): Integer; overload;
  function ReadString(Stream: TStream; var value: String): Integer;
  function WriteAccountKey(Stream: TStream; const value: IPublicKey): Integer;
  function ReadAccountKey(Stream: TStream; var value : IPublicKey): Integer;
  function SaveStreamToRawBytes(Stream: TStream) : TRawBytes;
  procedure LoadStreamFromRawBytes(Stream: TStream; const raw : TRawBytes);
End;


implementation

{ TStreamOp }

uses PascalCoin.Helpers;

procedure TStreamOp.LoadStreamFromRawBytes(Stream: TStream;
  const raw: TRawBytes);
begin
   Stream.WriteBuffer(raw[Low(raw)],Length(raw));
end;

function TStreamOp.ReadAccountKey(Stream: TStream;
  var value: IPublicKey): Integer;
begin

end;

function TStreamOp.ReadRawBytes(Stream: TStream; var Value: TRawBytes): Integer;
Var
  w: Word;
begin
  if Stream.Size - Stream.Position < 2 then begin
    SetLength(value,0);
    Result := -1;
    Exit;
  end;
  Stream.Read(w, 2);
  if Stream.Size - Stream.Position < w then begin
    Stream.Position := Stream.Position - 2; // Go back!
    SetLength(value,0);
    Result := -1;
    Exit;
  end;
  SetLength(value, w);
  if (w>0) then begin
    Stream.ReadBuffer(value[Low(value)], w);
  end;
  Result := w+2;
end;

function TStreamOp.ReadString(Stream: TStream; var value: String): Integer;
var raw : TRawBytes;
begin
  Result := ReadRawBytes(Stream,raw);
  value := raw.ToString;
end;

function TStreamOp.SaveStreamToRawBytes(Stream: TStream): TRawBytes;
begin
  SetLength(Result,Stream.Size);
  Stream.Position:=0;
  Stream.ReadBuffer(Result[Low(Result)],Stream.Size);
end;

function TStreamOp.WriteAccountKey(Stream: TStream;
  const value: IPublicKey): Integer;
begin

end;

function TStreamOp.WriteRawBytes(Stream: TStream;
  const value: TRawBytes): Integer;
Var
  w: Word;
begin
  if (Length(value)>(256*256)) then begin
    raise Exception.Create('Invalid stream size! '+Inttostr(Length(value)));
  end;

  w := Length(value);
  Stream.Write(w, 2);
  if (w > 0) then
    Stream.WriteBuffer(value[Low(value)], Length(value));
  Result := w+2;
end;

end.
