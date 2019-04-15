unit PascalCoin.Utils.Classes;

interface

uses System.Generics.Collections, System.Classes, System.SysUtils,
  PascalCoin.Utils.Interfaces;

Type

  TPascalCoinList<T> = class(TInterfacedObject, IPascalCoinList<T>)
  private
    FItems: TList<T>;
  protected
    function GetItem(const Index: Integer): T;
    function Count: Integer;
    function Add(Item: T): Integer;
    procedure Delete(const Index: Integer);
    procedure Clear;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TPascalCoinTools = class(TInterfacedObject, IPascalCoinTools)
  private
  protected
    function IsHexaString(const Value: string): Boolean;
    function AccountNumberCheckSum(const Value: Cardinal): Integer;
    function ValidAccountNumber(const Value: string): Boolean;
    function SplitAccount(const Value: string; out AccountNumber: Cardinal;
      out CheckSum: Integer): Boolean;
    function ValidateAccountName(const Value: string): Boolean;
    function UnixToLocalDate(const Value: Integer): TDateTime;
    function StrToHex(const Value: string): string;
  end;

implementation

uses System.DateUtils, clpConverters, clpEncoders;

{ TPascalCoinList<T> }

function TPascalCoinList<T>.Add(Item: T): Integer;
begin
  result := FItems.Add(Item);
end;

procedure TPascalCoinList<T>.Clear;
begin
  FItems.Clear;
end;

function TPascalCoinList<T>.Count: Integer;
begin
  result := FItems.Count;
end;

constructor TPascalCoinList<T>.Create;
begin
  inherited Create;
  FItems := TList<T>.Create;
end;

procedure TPascalCoinList<T>.Delete(const Index: Integer);
begin
  FItems.Delete(index);
end;

destructor TPascalCoinList<T>.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TPascalCoinList<T>.GetItem(const Index: Integer): T;
begin
  result := FItems[Index];
end;

{ TPascalCoinTools }

function TPascalCoinTools.AccountNumberCheckSum(const Value: Cardinal): Integer;
var
  lVal: Int64;
begin
  lVal := Value;
  result := ((lVal * 101) MOD 89) + 10;
end;

function TPascalCoinTools.IsHexaString(const Value: string): Boolean;
var
  i: Integer;
begin
  result := true;
  for i := Low(Value) to High(Value) do
    if (NOT CharInSet(Value[i], ['0' .. '9'])) AND
      (NOT CharInSet(Value[i], ['a' .. 'f'])) AND
      (NOT CharInSet(Value[i], ['A' .. 'F'])) then
    begin
      result := false;
      exit;
    end;
end;

function TPascalCoinTools.SplitAccount(const Value: string;
  out AccountNumber: Cardinal; out CheckSum: Integer): Boolean;
var
  lVal: TArray<string>;
begin
  if Value.IndexOf('-') > 0 then
  begin
    lVal := Value.Trim.Split(['-']);
    AccountNumber := lVal[0].ToInt64;
    CheckSum := lVal[1].ToInteger;
  end
  else
  begin
    AccountNumber := Value.ToInt64;
    CheckSum := -1;
  end;
end;

function TPascalCoinTools.StrToHex(const Value: string): string;
begin
  result := THex.Encode(TConverters.ConvertStringToBytes(Value,
    TEncoding.ANSI));
end;

function TPascalCoinTools.UnixToLocalDate(const Value: Integer): TDateTime;
begin
  TTimeZone.Local.ToLocalTime(UnixToDateTime(Value));
end;

function TPascalCoinTools.ValidAccountNumber(const Value: string): Boolean;
var
  lVal: TArray<string>;
  lChk: Integer;
  lAcct: Int64;
begin
  result := false;
  lVal := Value.Trim.Split(['-']);
  if length(lVal) = 1 then
  begin
    if TryStrToInt64(lVal[0], lAcct) then
      result := true;
  end
  else
  begin
    if TryStrToInt64(lVal[0], lAcct) then
    begin
      lChk := AccountNumberCheckSum(lVal[0].Trim.ToInt64);
      result := lChk = lVal[1].Trim.ToInteger;
    end;
  end;
end;

function TPascalCoinTools.ValidateAccountName(const Value: string): Boolean;
var
  i: Integer;
begin
  result := true;
  if Value = '' then
    exit;
  if Not CharInSet(Value.Chars[0], PascalCoinNameStart) then
    exit(false);
  if Value.length < 3 then
    exit(false);
  if Value.length > 64 then
    exit(false);
  for i := 0 to Value.length - 1 do
  begin
    if Not CharInSet(Value.Chars[i], PascalCoinEncoding) then
      exit(false);
  end;
end;

end.
