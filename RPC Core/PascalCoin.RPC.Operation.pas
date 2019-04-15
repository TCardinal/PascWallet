unit PascalCoin.RPC.Operation;

interface

uses PascalCoin.Utils.Interfaces, PascalCoin.RPC.Interfaces, System.JSON;

type
  TPascalCoinOperation = class(TInterfacedObject, IPascalCoinOperation)
  private
    FValid: Boolean;
    FErrors: string;
    FBlock: UInt64;
    FTime: Integer;
    FOpBlock: UInt64;
    FMaturation: Integer;
    FOpType: Integer;
    FOpTxt: string;
    FAccount: Cardinal;
    FAmount: Currency;
    FFee: Currency;
    FBalance: Currency;
    FSender_Account: Cardinal;
    FDest_Account: Cardinal;
    FEnc_Pubkey: HexStr;
    FOpHash: HexStr;
    FOld_Ophash: HexStr;
    FSubType: string;
    FSigner_account: Cardinal;
    FN_Operation: Integer;
    FPayload: HexStr;
    FSenders: IPascalCoinList<IPascalCoinSender>;
    FReceivers: IPascalCoinList<IPascalCoinReceiver>;
    FChangers: IPascalCoinList<IPascalCoinChanger>;
  protected
    function GetValid: Boolean;
    procedure SetValid(const Value: Boolean);
    function GetErrors: string;
    procedure SetErrors(const Value: string);
    function GetBlock: UInt64;
    procedure SetBlock(const Value: UInt64);
    function GetTime: Integer;
    procedure SetTime(const Value: Integer);
    function GetOpblock: Integer;
    procedure SetOpblock(const Value: Integer);
    function GetMaturation: Integer;
    procedure SetMaturation(const Value: Integer);
    function GetOptype: Integer;
    procedure SetOptype(const Value: Integer);
    function GetOperationType: TOperationType;
    procedure SetOperationType(const Value: TOperationType);
    function GetOptxt: string;
    procedure SetOptxt(const Value: string);
    function GetAccount: Cardinal;
    procedure SetAccount(const Value: Cardinal);
    function GetAmount: Currency;
    procedure SetAmount(const Value: Currency);
    function GetFee: Currency;
    procedure SetFee(const Value: Currency);
    function GetBalance: Currency;
    procedure SetBalance(const Value: Currency);
    function GetSender_account: Cardinal;
    procedure SetSender_Account(const Value: Cardinal);
    function GetDest_account: Cardinal;
    procedure SetDest_Account(const Value: Cardinal);
    function GetEnc_pubkey: HexStr;
    procedure SetEnc_pubkey(const Value: HexStr);
    function GetOphash: HexStr;
    procedure SetOphash(const Value: HexStr);
    function GetOld_ophash: HexStr;
    procedure SetOld_ophash(const Value: HexStr);
    function GetSubtype: string;
    procedure SetSubtype(const Value: string);
    function GetSigner_account: Cardinal;
    procedure SetSigner_account(const Value: Cardinal);
    function GetN_operation: Integer;
    procedure SetN_operation(const Value: Integer);
    function GetPayload: HexStr;
    procedure SetPayload(const Value: HexStr);

    function GetSenders: IPascalCoinList<IPascalCoinSender>;
    procedure SetSenders(Value: IPascalCoinList<IPascalCoinSender>);
    function GetReceivers: IPascalCoinList<IPascalCoinReceiver>;
    procedure SetReceivers(Value: IPascalCoinList<IPascalCoinReceiver>);
    function GetChangers: IPascalCoinList<IPascalCoinChanger>;
    procedure SetChangers(Value: IPascalCoinList<IPascalCoinChanger>);

  public
    constructor Create;
    class function CreateFromJSON(Value: TJSONValue): TPascalCoinOperation;
  end;

  TPascalCoinSender = class(TInterfacedObject, IPascalCoinSender)
  private
    FAccount: Cardinal;
    FN_Operation: Integer;
    FAmount: Currency;
    FPayload: HexStr;
  protected
    function GetAccount: Cardinal;
    procedure SetAccount(const Value: Cardinal);
    function GetN_operation: Integer;
    procedure SetN_operation(const Value: Integer);
    function GetAmount: Currency;
    procedure SetAmount(const Value: Currency);
    function GetPayload: HexStr;
    procedure SetPayload(const Value: HexStr);
  public
  end;

  TPascalCoinReceiver = class(TInterfacedObject, IPascalCoinReceiver)
  private
    FAccount: Cardinal;
    FAmount: Currency;
    FPayload: HexStr;
  protected
    function GetAccount: Cardinal;
    procedure SetAccount(const Value: Cardinal);
    function GetAmount: Currency;
    procedure SetAmount(const Value: Currency);
    function GetPayload: HexStr;
    procedure SetPayload(const Value: HexStr);
  public
  end;

  TPascalCoinChanger = Class(TInterfacedObject, IPascalCoinChanger)
  private
    FAccount: Cardinal;
    FN_Operation: Integer;
    FNew_enc_pubkey: String;
    FNew_Type: string;
    FAmount: Currency;
    FSeller_account: Cardinal;
    FAccount_price: Currency;
    FLocked_until_block: UInt64;
    FFee: Currency;
  protected
    function GetAccount: Cardinal;
    procedure SetAccount(const Value: Cardinal);
    function GetN_operation: Integer;
    procedure SetN_operation(const Value: Integer);
    function GetNew_enc_pubkey: string;
    procedure SetNew_enc_pubkey(const Value: string);
    function GetNew_Type: string;
    procedure SetNew_Type(const Value: string);
    function GetSeller_account: Cardinal;
    procedure SetSeller_account(const Value: Cardinal);
    function GetAccount_price: Currency;
    procedure SetAccount_price(const Value: Currency);
    function GetLocked_until_block: UInt64;
    procedure SetLocked_until_block(const Value: UInt64);
    function GetFee: Currency;
    procedure SetFee(const Value: Currency);
  public
  end;

implementation

{ TPascalCoinOperation }

uses PascalCoin.Utils.Classes, REST.JSON;

constructor TPascalCoinOperation.Create;
begin
  inherited Create;
  FSenders := TPascalCoinList<IPascalCoinSender>.Create;
  FReceivers := TPascalCoinList<IPascalCoinReceiver>.Create;
  FChangers := TPascalCoinList<IPascalCoinChanger>.Create;
end;

class function TPascalCoinOperation.CreateFromJSON(Value: TJSONValue)
  : TPascalCoinOperation;
var
  lObj: TJSONObject;
  lArr: TJSONArray;
  lVal: TJSONValue;
  lSender: IPascalCoinSender;
  lReceiver: IPascalCoinReceiver;
  lChanger: IPascalCoinChanger;
  S: string;
begin
  lObj := Value as TJSONObject;
  result := TPascalCoinOperation.Create;

  if lObj.TryGetValue<string>('valid', S) then
    result.FValid := (S <> 'false')
  else
    result.FValid := True;

  result.FBlock := lObj.Values['block'].AsType<UInt64>; // 279915
  result.FTime := lObj.Values['time'].AsType<Integer>; // 0,
  result.FOpBlock := lObj.Values['opblock'].AsType<UInt64>; // 1,

  lObj.Values['maturation'].TryGetValue<Integer>(result.FMaturation); // null,
  result.FOpType := lObj.Values['optype'].AsType<Integer>; // 1,
  { TODO : should be Int? }
  result.FSubType := lObj.Values['subtype'].AsType<string>; // 12,
  result.FAccount := lObj.Values['account'].AsType<Cardinal>; // 865822,
  result.FSigner_account := lObj.Values['signer_account'].AsType<Cardinal>;
  // 865851,
  result.FN_Operation := lObj.Values['n_operation'].AsType<Integer>;
  result.FOpTxt := lObj.Values['optxt'].AsType<String>;
  // "Tx-In 16.0000 PASC from 865851-95 to 865822-14",
  result.FFee := lObj.Values['fee'].AsType<Currency>; // 0.0000,
  result.FAmount := lObj.Values['amount'].AsType<Currency>; // 16.0000,
  result.FPayload := lObj.Values['payload'].AsType<HexStr>;
  // "7A6962626564656520646F6F646168",
  result.FBalance := lObj.Values['balance'].AsType<Currency>; // 19.1528,
  result.FSender_Account := lObj.Values['sender_account'].AsType<Cardinal>;
  // 865851,
  result.FDest_Account := lObj.Values['dest_account'].AsType<Cardinal>;
  // 865822,
  result.FOpHash := lObj.Values['ophash'].AsType<HexStr>;

  lArr := lObj.Values['senders'] as TJSONArray;
  for lVal in lArr do
  begin
    result.FSenders.Add(TJSON.JsonToObject<TPascalCoinSender>
      (lVal as TJSONObject));
  end;

  lArr := lObj.Values['receivers'] as TJSONArray;
  for lVal in lArr do
  begin
    result.FReceivers.Add(TJSON.JsonToObject<TPascalCoinReceiver>
      (lVal as TJSONObject));
  end;

  lArr := lObj.Values['changers'] as TJSONArray;
  for lVal in lArr do
  begin
    result.FChangers.Add(TJSON.JsonToObject<TPascalCoinChanger>
      (lVal as TJSONObject));
  end;

end;

function TPascalCoinOperation.GetAccount: Cardinal;
begin
  result := FAccount;
end;

function TPascalCoinOperation.GetAmount: Currency;
begin
  result := FAmount;
end;

function TPascalCoinOperation.GetBalance: Currency;
begin
  result := FBalance;
end;

function TPascalCoinOperation.GetBlock: UInt64;
begin
  result := FBlock;
end;

function TPascalCoinOperation.GetChangers: IPascalCoinList<IPascalCoinChanger>;
begin
  result := FChangers;
end;

function TPascalCoinOperation.GetDest_account: Cardinal;
begin
  result := FDest_Account;
end;

function TPascalCoinOperation.GetEnc_pubkey: HexStr;
begin
  result := FEnc_Pubkey;
end;

function TPascalCoinOperation.GetErrors: string;
begin
  result := FErrors;
end;

function TPascalCoinOperation.GetFee: Currency;
begin
  result := FFee;
end;

function TPascalCoinOperation.GetMaturation: Integer;
begin
  result := FMaturation;
end;

function TPascalCoinOperation.GetN_operation: Integer;
begin
  result := FN_Operation;
end;

function TPascalCoinOperation.GetOld_ophash: HexStr;
begin
  result := FOld_Ophash;
end;

function TPascalCoinOperation.GetOpblock: Integer;
begin
  result := FOpBlock;
end;

function TPascalCoinOperation.GetOperationType: TOperationType;
begin
  result := TOperationType(FOpType);
end;

function TPascalCoinOperation.GetOphash: HexStr;
begin
  result := FOpHash;
end;

function TPascalCoinOperation.GetOptxt: string;
begin
  result := FOpTxt;
end;

function TPascalCoinOperation.GetOptype: Integer;
begin
  result := FOpType;
end;

function TPascalCoinOperation.GetPayload: HexStr;
begin
  result := FPayload;
end;

function TPascalCoinOperation.GetReceivers
  : IPascalCoinList<IPascalCoinReceiver>;
begin
  result := FReceivers;
end;

function TPascalCoinOperation.GetSenders: IPascalCoinList<IPascalCoinSender>;
begin
  result := FSenders;
end;

function TPascalCoinOperation.GetSender_account: Cardinal;
begin
  result := FSender_Account;
end;

function TPascalCoinOperation.GetSigner_account: Cardinal;
begin
  result := FSigner_account;
end;

function TPascalCoinOperation.GetSubtype: string;
begin
  result := FSubType;
end;

function TPascalCoinOperation.GetTime: Integer;
begin
  result := FTime;
end;

function TPascalCoinOperation.GetValid: Boolean;
begin
  result := FValid;
end;

procedure TPascalCoinOperation.SetAccount(const Value: Cardinal);
begin
  FAccount := Value;
end;

procedure TPascalCoinOperation.SetAmount(const Value: Currency);
begin
  FAmount := Value;
end;

procedure TPascalCoinOperation.SetBalance(const Value: Currency);
begin
  FBalance := Value;
end;

procedure TPascalCoinOperation.SetBlock(const Value: UInt64);
begin
  FBlock := Value;
end;

procedure TPascalCoinOperation.SetChangers
  (Value: IPascalCoinList<IPascalCoinChanger>);
begin
  FChangers := Value;
end;

procedure TPascalCoinOperation.SetDest_Account(const Value: Cardinal);
begin
  FDest_Account := Value;
end;

procedure TPascalCoinOperation.SetEnc_pubkey(const Value: HexStr);
begin
  FEnc_Pubkey := Value;
end;

procedure TPascalCoinOperation.SetErrors(const Value: string);
begin
  FErrors := Value;
end;

procedure TPascalCoinOperation.SetFee(const Value: Currency);
begin
  FFee := Value;
end;

procedure TPascalCoinOperation.SetMaturation(const Value: Integer);
begin
  FMaturation := Value;
end;

procedure TPascalCoinOperation.SetN_operation(const Value: Integer);
begin
  FN_Operation := Value;
end;

procedure TPascalCoinOperation.SetOld_ophash(const Value: HexStr);
begin
  FOld_Ophash := Value;
end;

procedure TPascalCoinOperation.SetOpblock(const Value: Integer);
begin
  FOpBlock := Value;
end;

procedure TPascalCoinOperation.SetOperationType(const Value: TOperationType);
begin
  FOpType := Integer(Value);
end;

procedure TPascalCoinOperation.SetOphash(const Value: HexStr);
begin
  FOpHash := Value;
end;

procedure TPascalCoinOperation.SetOptxt(const Value: string);
begin
  FOpTxt := Value;
end;

procedure TPascalCoinOperation.SetOptype(const Value: Integer);
begin
  FOpType := Value;
end;

procedure TPascalCoinOperation.SetPayload(const Value: HexStr);
begin
  FPayload := Value;
end;

procedure TPascalCoinOperation.SetReceivers
  (Value: IPascalCoinList<IPascalCoinReceiver>);
begin
  FReceivers := Value;
end;

procedure TPascalCoinOperation.SetSenders
  (Value: IPascalCoinList<IPascalCoinSender>);
begin
  FSenders := Value;
end;

procedure TPascalCoinOperation.SetSender_Account(const Value: Cardinal);
begin
  FSender_Account := Value;
end;

procedure TPascalCoinOperation.SetSigner_account(const Value: Cardinal);
begin
  FSigner_account := Value;
end;

procedure TPascalCoinOperation.SetSubtype(const Value: string);
begin
  FSubType := Value;
end;

procedure TPascalCoinOperation.SetTime(const Value: Integer);
begin
  FTime := Value;
end;

procedure TPascalCoinOperation.SetValid(const Value: Boolean);
begin
  FValid := Value;
end;

{ TPascalCoinSender }

function TPascalCoinSender.GetAccount: Cardinal;
begin

end;

function TPascalCoinSender.GetAmount: Currency;
begin

end;

function TPascalCoinSender.GetN_operation: Integer;
begin

end;

function TPascalCoinSender.GetPayload: HexStr;
begin

end;

procedure TPascalCoinSender.SetAccount(const Value: Cardinal);
begin

end;

procedure TPascalCoinSender.SetAmount(const Value: Currency);
begin

end;

procedure TPascalCoinSender.SetN_operation(const Value: Integer);
begin

end;

procedure TPascalCoinSender.SetPayload(const Value: HexStr);
begin

end;

{ TPascalCoinReceiver }

function TPascalCoinReceiver.GetAccount: Cardinal;
begin

end;

function TPascalCoinReceiver.GetAmount: Currency;
begin

end;

function TPascalCoinReceiver.GetPayload: HexStr;
begin

end;

procedure TPascalCoinReceiver.SetAccount(const Value: Cardinal);
begin

end;

procedure TPascalCoinReceiver.SetAmount(const Value: Currency);
begin

end;

procedure TPascalCoinReceiver.SetPayload(const Value: HexStr);
begin

end;

{ TPascalCoinChanger }

function TPascalCoinChanger.GetAccount: Cardinal;
begin

end;

function TPascalCoinChanger.GetAccount_price: Currency;
begin

end;

function TPascalCoinChanger.GetFee: Currency;
begin

end;

function TPascalCoinChanger.GetLocked_until_block: UInt64;
begin

end;

function TPascalCoinChanger.GetNew_enc_pubkey: string;
begin

end;

function TPascalCoinChanger.GetNew_Type: string;
begin

end;

function TPascalCoinChanger.GetN_operation: Integer;
begin

end;

function TPascalCoinChanger.GetSeller_account: Cardinal;
begin

end;

procedure TPascalCoinChanger.SetAccount(const Value: Cardinal);
begin

end;

procedure TPascalCoinChanger.SetAccount_price(const Value: Currency);
begin

end;

procedure TPascalCoinChanger.SetFee(const Value: Currency);
begin

end;

procedure TPascalCoinChanger.SetLocked_until_block(const Value: UInt64);
begin

end;

procedure TPascalCoinChanger.SetNew_enc_pubkey(const Value: string);
begin

end;

procedure TPascalCoinChanger.SetNew_Type(const Value: string);
begin

end;

procedure TPascalCoinChanger.SetN_operation(const Value: Integer);
begin

end;

procedure TPascalCoinChanger.SetSeller_account(const Value: Cardinal);
begin

end;

end.
