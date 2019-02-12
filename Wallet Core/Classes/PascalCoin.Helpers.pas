/// <summary>
///   TRawBytesHelper based on PascalCoin Core by Alfred Molina
/// </summary>
unit PascalCoin.Helpers;


interface

uses pascalCoin.Wallet.Interfaces;

type

TRawBytesHelper = record helper for TRawBytes
  function ToString : String; // Returns a String type
  function ToPrintable : String; // Returns a printable string with chars from #32..#126, other chars will be printed as #126 "~"
  function ToHexaString : String; // Returns an Hexastring, so each byte will be printed as an hexadecimal (double size)
  procedure FromString(const AValue : String); // Will store a RAW bytes assuming each char of the string is a byte -> ALERT: Do not use when the String contains chars encoded with multibyte character set!
  function Add(const ARawValue : TRawBytes) : TRawBytes; // Will concat a new RawBytes value to current value
  function IsEmpty : Boolean; // Will return TRUE when Length = 0
end;


implementation

uses System.SysUtils;

{ TRawBytesHelper }

function TRawBytesHelper.ToPrintable: String;
var i,inc_i : Integer;
  rbs : RawByteString; //
begin
  SetLength(rbs,Length(Self));
  inc_i := Low(rbs) - Low(Self);
  for i:=Low(Self) to High(Self) do begin
    if (Self[i] in [32..126]) then move(Self[i],rbs[i+inc_i],1)
    else rbs[i+inc_i] := Chr(126);
  end;
  Result := rbs;
end;

function TRawBytesHelper.ToString: String;
begin
  if Length(Self)>0 then begin
    Result := TEncoding.ANSI.GetString(Self);
  end else Result := '';
end;

procedure TRawBytesHelper.FromString(const AValue: String);
var i : Integer;
begin
  SetLength(Self,Length(AValue));
  for i := 0 to Length(AValue)-1 do begin
    Self[i] := Byte(AValue.Chars[i]);
  end;
end;

function TRawBytesHelper.Add(const ARawValue: TRawBytes): TRawBytes;
var iNext : Integer;
begin
  iNext := Length(Self);
  SetLength(Self,Length(Self)+Length(ARawValue));
  move(ARawValue[0],Self[iNext],Length(ARawValue));
  Result := Self;
end;

function TRawBytesHelper.IsEmpty: Boolean;
begin
  Result := Length(Self)=0;
end;

function TRawBytesHelper.ToHexaString: String;
Var i : Integer;
  rbs : RawByteString;
  raw_as_hex : TRawBytes;
begin
  SetLength(raw_as_hex,length(Self)*2);
  for i := Low(Self) to High(Self) do begin
    rbs := IntToHex(Self[i],2);
    move(rbs[Low(rbs)],raw_as_hex[i*2],1);
    move(rbs[Low(rbs)+1],raw_as_hex[(i*2)+1],1);
  end;
  Result := raw_as_hex.ToString;
end;


end.
