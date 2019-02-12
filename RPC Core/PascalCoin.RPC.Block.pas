unit PascalCoin.RPC.Block;

interface

uses PascalCoin.RPC.Interfaces;

type

TPascalCoinBlock = class(TInterfacedObject, IPascalCoinBlock)
private
  Fblock: Integer;
  Fenc_pubkey: String;
  Freward: Currency;
  Ffee: Currency;
  Fver: Integer;
  Fver_a: Integer;
  Ftimestamp: Integer;
  Ftarget: Integer;
  Fnonce: Integer;
  Fpayload: String;
  Fsbh: String;
  Foph: String;
  Fpow: String;
  Foperations: Integer;
  Fhashratekhs: Integer;
  Fmaturation: Integer;
protected
    function GetBlock: Integer;
    function GetEnc_PubKey: String;
    function GetFee: Currency;
    function GetHashRateKHS: Integer;
    function GetMaturation: Integer;
    function GetNonce: Integer;
    function GetOperations: Integer;
    function GetOPH: String;
    function GetPayload: String;
    function GetPOW: String;
    function GetReward: Currency;
    function GetSBH: String;
    function GetTarget: Integer;
    function GetTimeStamp: Integer;
    function GetVer: Integer;
    function GetVer_a: Integer;
    procedure SetBlock(const Value: Integer);
    procedure SetEnc_PubKey(const Value: String);
    procedure SetFee(const Value: Currency);
    procedure SetHashRateKHS(const Value: Integer);
    procedure SetMaturation(const Value: Integer);
    procedure SetNonce(const Value: Integer);
    procedure SetOperations(const Value: Integer);
    procedure SetOPH(const Value: String);
    procedure SetPayload(const Value: String);
    procedure SetPOW(const Value: String);
    procedure SetReward(const Value: Currency);
    procedure SetSBH(const Value: String);
    procedure SetTarget(const Value: Integer);
    procedure SetTimeStamp(const Value: Integer);
    procedure SetVer(const Value: Integer);
    procedure SetVer_a(const Value: Integer);

    function GetDelphiTimeStamp: TDateTime;
    procedure SetDelphiTimeStamp(const Value: TDateTime);
public
end;

implementation

uses System.DateUtils;

{ TPascalCoinBlock }

function TPascalCoinBlock.GetBlock: Integer;
begin
  result := Fblock;
end;

function TPascalCoinBlock.GetDelphiTimeStamp: TDateTime;
begin
  result := UnixToDateTime(Ftimestamp);
end;

function TPascalCoinBlock.GetEnc_PubKey: String;
begin
  result := Fenc_pubkey;
end;

function TPascalCoinBlock.GetFee: Currency;
begin
  result := Ffee;
end;

function TPascalCoinBlock.GetHashRateKHS: Integer;
begin
  result := Fhashratekhs;
end;

function TPascalCoinBlock.GetMaturation: Integer;
begin
  result := Fmaturation;
end;

function TPascalCoinBlock.GetNonce: Integer;
begin
  result := Fnonce;
end;

function TPascalCoinBlock.GetOperations: Integer;
begin
  result := Foperations;
end;

function TPascalCoinBlock.GetOPH: String;
begin
  result := Foph;
end;

function TPascalCoinBlock.GetPayload: String;
begin
  result := Fpayload;
end;

function TPascalCoinBlock.GetPOW: String;
begin
  result := Fpow;
end;

function TPascalCoinBlock.GetReward: Currency;
begin
  result := Freward;
end;

function TPascalCoinBlock.GetSBH: String;
begin
  result := Fsbh;
end;

function TPascalCoinBlock.GetTarget: Integer;
begin
  result := Ftarget;
end;

function TPascalCoinBlock.GetTimeStamp: Integer;
begin
  result := Ftimestamp;
end;

function TPascalCoinBlock.GetVer: Integer;
begin
  result := Fver;
end;

function TPascalCoinBlock.GetVer_a: Integer;
begin
  result := Fver_a;
end;

procedure TPascalCoinBlock.SetBlock(const Value: Integer);
begin
  Fblock := Value;
end;

procedure TPascalCoinBlock.SetDelphiTimeStamp(const Value: TDateTime);
begin
  Ftimestamp := DateTimeToUnix(Value);
end;

procedure TPascalCoinBlock.SetEnc_PubKey(const Value: String);
begin
   Fenc_pubkey := Value;
end;

procedure TPascalCoinBlock.SetFee(const Value: Currency);
begin
  Ffee := Value;
end;

procedure TPascalCoinBlock.SetHashRateKHS(const Value: Integer);
begin
  Fhashratekhs := Value;
end;

procedure TPascalCoinBlock.SetMaturation(const Value: Integer);
begin
  Fmaturation := Value;
end;

procedure TPascalCoinBlock.SetNonce(const Value: Integer);
begin
  Fnonce := Value;
end;

procedure TPascalCoinBlock.SetOperations(const Value: Integer);
begin
  Foperations := Value;
end;

procedure TPascalCoinBlock.SetOPH(const Value: String);
begin
  Foph := Value;
end;

procedure TPascalCoinBlock.SetPayload(const Value: String);
begin
  Fpayload := Value;
end;

procedure TPascalCoinBlock.SetPOW(const Value: String);
begin
  Fpow := Value;
end;

procedure TPascalCoinBlock.SetReward(const Value: Currency);
begin
  Freward := Value;
end;

procedure TPascalCoinBlock.SetSBH(const Value: String);
begin
  Fsbh := Value;
end;

procedure TPascalCoinBlock.SetTarget(const Value: Integer);
begin
  Ftarget := Value;
end;

procedure TPascalCoinBlock.SetTimeStamp(const Value: Integer);
begin
  Ftimestamp := Value;
end;

procedure TPascalCoinBlock.SetVer(const Value: Integer);
begin
  Fver := Value;
end;

procedure TPascalCoinBlock.SetVer_a(const Value: Integer);
begin
  Fver_a := Value;
end;

end.
