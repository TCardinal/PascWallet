unit PascalCoin.RPC.API;

interface

uses System.JSON, PascalCoin.RPC.Interfaces, PascalCoin.Utils.Interfaces;

type

TPascalCoinAPI = class(TInterfacedObject, IPascalCoinAPI)
private
  FClient: IPascalCoinRPCClient;
  FConfig: IPascalCoinRPCConfig;
  FTools: IPascalCoinTools;
  function PublicKeyParam(const AKey: String; const AKeyStyle: TKeyStyle):
      TParamPair;
protected
  function GetJSONResult: TJSONValue;
  function GetJSONResultStr: string;
  function getaccount(const AAccountNumber: Integer): IPascalCoinAccount;
  function getwalletaccounts(const APublicKey: String; const AKeyStyle: TKeyStyle): IPascalCoinAccounts;
  function getwalletaccountscount(const APublicKey: String; const AKeyStyle: TKeyStyle): Integer;
  function getblock(const BlockNumber: Integer): IPascalCoinBlock;
  function nodestatus: IPascalCoinNodeStatus;
public
  constructor Create(AClient: IPascalCoinRPCClient; AConfig:
      IPascalCoinRPCConfig; ATools: IPascalCoinTools);
end;

implementation

uses System.SysUtils, REST.Json, PascalCoin.RPC.Account, PascalCoin.RPC.Shared,
  PascalCoin.RPC.Node, PascalCoin.KeyTool;

{ TPascalCoinAPI }

function TPascalCoinAPI.getaccount(
  const AAccountNumber: Integer): IPascalCoinAccount;
begin
  if FClient.RPCCall('getaccount', [TParamPair.Create('account', AAccountNumber)]) then
  begin
    result := TJSON.JsonToObject<TPascalCoinAccount>((GetJSONResult as TJSONObject));
  end
  else
  begin
    raise ERPCException.Create(FClient.ResultStr);
  end;
end;

function TPascalCoinAPI.getblock(const BlockNumber: Integer): IPascalCoinBlock;
begin
//  if True then

end;

function TPascalCoinAPI.GetJSONResult: TJSONValue;
begin
  result := (TJSONObject.ParseJSONValue(FClient.ResultStr) as TJSONObject).GetValue('result');
end;

function TPascalCoinAPI.GetJSONResultStr: string;
begin
   result := FClient.ResultStr;
end;

function TPascalCoinAPI.getwalletaccounts(const APublicKey: String; const
    AKeyStyle: TKeyStyle): IPascalCoinAccounts;
var lAccounts: TJSONArray;
    lAccount: TJSONValue;
begin
  if FClient.RPCCall('getwalletaccounts', [PublicKeyParam(APublicKey, AKeyStyle)]) then
  begin
    Result := TPascalCoinAccounts.Create;
    lAccounts := (GetJSONResult as TJSONArray);
    for lAccount in lAccounts do
      Result.AddAccount(TJSON.JsonToObject<TPascalCoinAccount>((lAccount as TJSONObject)));
  end
  else
    raise ERPCException.Create(FClient.ResultStr);
end;

function TPascalCoinAPI.getwalletaccountscount(const APublicKey: String; const
    AKeyStyle: TKeyStyle): Integer;
begin
  if FClient.RPCCall('getwalletaccountscount', PublicKeyParam(APublicKey, AKeyStyle)) then
     Result := GetJSONResult.ToString.ToInteger
  else
    raise ERPCException.Create(FClient.ResultStr);
end;

function TPascalCoinAPI.nodestatus: IPascalCoinNodeStatus;
begin
  if FClient.RPCCall('nodestatus', []) then
    Result := TPascalCoinNodeStatus.Create(GetJSONResult)
  else
    raise ERPCException.Create(FClient.ResultStr);

end;

function TPascalCoinAPI.PublicKeyParam(const AKey: String; const AKeyStyle: TKeyStyle): TParamPair;
const
  _KeyType: Array[Boolean] of String = ('b58_pubkey', 'enc_pubkey');
begin
  case AKeyStyle of
    ksUnkown: result := TParamPair.Create(_KeyType[FTools.IsHexaString(AKey)], AKey);
    ksEncKey: result := TParamPair.Create('enc_pubkey', AKey);
    ksB58Key: result := TParamPair.Create('b58_pubkey', AKey);
  end;
end;

constructor TPascalCoinAPI.Create(AClient: IPascalCoinRPCClient; AConfig:
    IPascalCoinRPCConfig; ATools: IPascalCoinTools);
begin
  inherited Create;
  FClient := AClient;
  FConfig := AConfig;
  FTools := ATools;
end;

end.
