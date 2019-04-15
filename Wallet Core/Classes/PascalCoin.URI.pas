unit PascalCoin.URI;

interface

uses PascalCoin.Utils.Interfaces;

type

  TPascalCoinURI = class(TInterfacedObject, IPascalCoinURI)
  private
    FAccountNumber: String;
    FAmount: Currency;
    FPayload: string;
    FPayloadEncode: TPayloadEncode;
    FPayloadEncrypt: TPayloadEncryption;
    FPassword: string;
  protected
    function GetAccountNumber: string;
    procedure SetAccountNumber(const Value: string);
    function GetAmount: Currency;
    procedure SetAmount(const Value: Currency);
    function GetPayload: string;
    procedure SetPayload(const Value: string);
    function GetPayLoadEncode: TPayloadEncode;
    procedure SetPayloadEncode(const Value: TPayloadEncode);
    function GetPayloadEncrypt: TPayloadEncryption;
    procedure SetPayloadEncrypt(const Value: TPayloadEncryption);
    function GetPassword: string;
    procedure SetPassword(const Value: string);
    function GetURI: string;
    procedure SetURI(const Value: string);
  end;

implementation

uses System.SysUtils;

{ TPascalCoinURI }

function TPascalCoinURI.GetAccountNumber: string;
begin
  result := FAccountNumber;
end;

function TPascalCoinURI.GetAmount: Currency;
begin
  result := FAmount;
end;

function TPascalCoinURI.GetPassword: string;
begin
  result := FPassword;
end;

function TPascalCoinURI.GetPayload: string;
begin
  result := FPayload;
end;

function TPascalCoinURI.GetPayLoadEncode: TPayloadEncode;
begin
  result := FPayloadEncode;
end;

function TPascalCoinURI.GetPayloadEncrypt: TPayloadEncryption;
begin
  result := FPayloadEncrypt;
end;

function TPascalCoinURI.GetURI: string;
begin
  result := 'pasc://pay?account' + FAccountNumber;

  if FAmount > 0 then
    result := result + '&amount=' + CurrToStrF(FAmount, ffCurrency, 4);

  if FPayload = '' then
    Exit;

  result := result + '&payload=' + FPayload + '&payloadencode=' +
    PayloadEncodeCode[FPayloadEncode] + '&payloadencryption=' +
    PayloadEncryptionCode[FPayloadEncrypt];

  if FPayloadEncrypt = TPayloadEncryption.Password then
    result := result + '&password=' + FPassword;

end;

procedure TPascalCoinURI.SetAccountNumber(const Value: string);
begin
  FAccountNumber := Value;
end;

procedure TPascalCoinURI.SetAmount(const Value: Currency);
begin
  FAmount := Value;
end;

procedure TPascalCoinURI.SetPassword(const Value: string);
begin
  FPassword := Value;
end;

procedure TPascalCoinURI.SetPayload(const Value: string);
begin
  FPayload := Value;
end;

procedure TPascalCoinURI.SetPayloadEncode(const Value: TPayloadEncode);
begin
  FPayloadEncode := Value;
end;

procedure TPascalCoinURI.SetPayloadEncrypt(const Value: TPayloadEncryption);
begin
  FPayloadEncrypt := Value;
end;

procedure TPascalCoinURI.SetURI(const Value: string);
begin

end;

end.
