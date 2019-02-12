unit PascalCoin.RPC.Account;

interface

uses System.Generics.Collections, PascalCoin.RPC.Interfaces;

type

TPascalCoinAccount = Class(TInterfacedObject, IPascalCoinAccount)
private
  FAccount: Integer;
  Fenc_pubkey: String;
  FBalance: Currency;
  FN_Operation: Integer;
  FUpdated_b: Integer;
  FState: string;
  FLocked_Until_Block: Integer;
  FPrice: Currency;
  FSeller_Account: Integer;
  FPrivate_Sale: Boolean;
  FNew_Enc_PubKey: String;
  FName: String;
  FAccountType: Integer;
protected
  function GetAccount: Integer;
  procedure SetAccount(const Value: Integer);
  function GetPubKey: String;
  procedure SetPubKey(const Value: String);
  function GetBalance: Currency;
  procedure SetBalance(const Value: Currency);
  function GetN_Operation: Integer;
  procedure SetN_Operation(const Value: Integer);
  function GetUpdated_b: Integer;
  procedure SetUpdated_b(const Value: Integer);
  function GetState: String;
  procedure SetState(const Value: String);
  function GetLocked_Until_Block: Integer;
  procedure SetLocked_Until_Block(const Value: Integer);
  function GetPrice: Currency;
  procedure SetPrice(const Value: Currency);
  function GetSeller_Account: Integer;
  procedure SetSeller_Account(const Value: Integer);
  function GetPrivate_Sale: Boolean;
  procedure SetPrivate_Sale(const Value: Boolean);
  function GetNew_Enc_PubKey: String;
  procedure SetNew_Enc_PubKey(const Value: String);
  function GetName: String;
  procedure SetName(const Value: String);
  function GetAccount_Type: Integer;
  procedure SetAccount_Type(const Value: Integer);
public
End;

TPascalCoinAccounts = class(TInterfacedObject, IPascalCoinAccounts)
private
  FAccounts: TList<IPascalCoinAccount>;
protected
  function GetAccount(const Index: Integer): IPascalCoinAccount;
  function Count: Integer;
  function AddAccount(Value: IPascalCoinAccount): Integer;
public
  constructor Create;
  destructor Destroy; override;
end;

implementation

{ TPascalCoinAccount }

function TPascalCoinAccount.GetAccount: Integer;
begin
  result := FAccount;
end;

function TPascalCoinAccount.GetAccount_Type: Integer;
begin
  result := FAccountType;
end;

function TPascalCoinAccount.GetBalance: Currency;
begin
  result := FBalance;
end;

function TPascalCoinAccount.GetLocked_Until_Block: Integer;
begin
  result := FLocked_Until_Block;
end;

function TPascalCoinAccount.GetName: String;
begin
  result := FName;
end;

function TPascalCoinAccount.GetNew_Enc_PubKey: String;
begin
  result := FNew_Enc_PubKey;
end;

function TPascalCoinAccount.GetN_Operation: Integer;
begin
  result := FN_Operation;
end;

function TPascalCoinAccount.GetPrice: Currency;
begin
  result := FPrice;
end;

function TPascalCoinAccount.GetPrivate_Sale: Boolean;
begin
  result := FPrivate_Sale;
end;

function TPascalCoinAccount.GetPubKey: String;
begin
  result := Fenc_pubkey;
end;

function TPascalCoinAccount.GetSeller_Account: Integer;
begin
  result := FSeller_Account;
end;

function TPascalCoinAccount.GetState: String;
begin
  result := FState;
end;

function TPascalCoinAccount.GetUpdated_b: Integer;
begin
  result := FUpdated_b;
end;

procedure TPascalCoinAccount.SetAccount(const Value: Integer);
begin
  FAccount := Value;
end;

procedure TPascalCoinAccount.SetAccount_Type(const Value: Integer);
begin
  FAccountType := Value;
end;

procedure TPascalCoinAccount.SetBalance(const Value: Currency);
begin
  FBalance := Value;
end;

procedure TPascalCoinAccount.SetLocked_Until_Block(const Value: Integer);
begin
  FLocked_Until_Block := Value;
end;

procedure TPascalCoinAccount.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TPascalCoinAccount.SetNew_Enc_PubKey(const Value: String);
begin
  FNew_Enc_PubKey := Value;
end;

procedure TPascalCoinAccount.SetN_Operation(const Value: Integer);
begin
  FN_Operation := Value;
end;

procedure TPascalCoinAccount.SetPrice(const Value: Currency);
begin
  FPrice := Value;
end;

procedure TPascalCoinAccount.SetPrivate_Sale(const Value: Boolean);
begin
  FPrivate_Sale := Value;
end;

procedure TPascalCoinAccount.SetPubKey(const Value: String);
begin
  Fenc_pubkey := Value;
end;

procedure TPascalCoinAccount.SetSeller_Account(const Value: Integer);
begin
  FSeller_Account := Value;
end;

procedure TPascalCoinAccount.SetState(const Value: String);
begin
  FState := Value;
end;

procedure TPascalCoinAccount.SetUpdated_b(const Value: Integer);
begin
  FUpdated_b := Value;
end;

{ TPascalCoinAccounts }

function TPascalCoinAccounts.AddAccount(Value: IPascalCoinAccount): Integer;
begin
  result := FAccounts.Add(Value);
end;

function TPascalCoinAccounts.Count: Integer;
begin
  result := FAccounts.Count;
end;

constructor TPascalCoinAccounts.Create;
begin
  inherited Create;
  FAccounts := TList<IPascalCoinAccount>.Create;
end;

destructor TPascalCoinAccounts.Destroy;
begin
  FAccounts.Free;
  inherited;
end;

function TPascalCoinAccounts.GetAccount(
  const Index: Integer): IPascalCoinAccount;
begin
  result := FAccounts[Index];
end;

end.
