unit PascalCoin.RPC.API;

interface

uses System.JSON, PascalCoin.RPC.Interfaces, PascalCoin.Utils.Interfaces;

type

  TPascalCoinAPI = class(TInterfacedObject, IPascalCoinAPI)
  private
    FClient: IPascalCoinRPCClient;
    FLastError: string;
    FTools: IPascalCoinTools;
    FNodeStatus: IPascalCoinNodeStatus;
    FLastStatusPoll: TDateTime;
    FNodeAvailability: TNodeAvailability;
    function PublicKeyParam(const AKey: String; const AKeyStyle: TKeyStyle)
      : TParamPair;
  protected
    function GetNodeURI: String;
    procedure SetNodeURI(const Value: String);

    function URI(const Value: string): IPascalCoinAPI;
    function GetCurrentNodeStatus: IPascalCoinNodeStatus;
    function GetLastError: String;
    function GetNodeAvailability: TNodeAvailability;
    function GetIsTestNet: Boolean;

    function GetJSONResult: TJSONValue;
    function GetJSONResultStr: string;

    function getaccount(const AAccountNumber: Cardinal): IPascalCoinAccount;
    function getwalletaccounts(const APublicKey: String;
      const AKeyStyle: TKeyStyle; const AMaxCount: Integer = -1)
      : IPascalCoinAccounts;
    function getwalletaccountscount(const APublicKey: String;
      const AKeyStyle: TKeyStyle): Integer;
    function getblock(const BlockNumber: Integer): IPascalCoinBlock;
    function nodestatus: IPascalCoinNodeStatus;

    function payloadEncryptWithPublicKey(const APayload: string;
      const AKey: string; const AKeyStyle: TKeyStyle): string;

    function getaccountoperations(const AAccount: Cardinal;
      const ADepth: Integer = 100; const AStart: Integer = 0;
      const AMax: Integer = 100): IPascalCoinList<IPascalCoinOperation>;
    function executeoperation(const RawOperation: string): IPascalCoinOperation;

    property JSONResult: TJSONValue read GetJSONResult;
  public
    constructor Create(AClient: IPascalCoinRPCClient; ATools: IPascalCoinTools);
  end;

implementation

uses System.SysUtils, System.DateUtils,
  REST.JSON, PascalCoin.RPC.Account,
  PascalCoin.RPC.Node, PascalCoin.KeyTool, PascalCoin.Utils.Classes,
  PascalCoin.RPC.Operation;

{ TPascalCoinAPI }

function TPascalCoinAPI.executeoperation(const RawOperation: string)
  : IPascalCoinOperation;
begin
  if FClient.RPCCall('executeoperations', [TParamPair.Create('rawoperations', RawOperation)]) then
  begin
    result := TJSON.JsonToObject<TPascalCoinOperation>((GetJSONResult as TJSONObject));
  end
  else
  begin
    raise ERPCException.Create(FClient.ResultStr);
  end;
end;

function TPascalCoinAPI.getaccount(const AAccountNumber: Cardinal)
  : IPascalCoinAccount;
begin
  if FClient.RPCCall('getaccount',
    [TParamPair.Create('account', AAccountNumber)]) then
  begin
    result := TJSON.JsonToObject<TPascalCoinAccount>
      ((GetJSONResult as TJSONObject));
  end
  else
  begin
    raise ERPCException.Create(FClient.ResultStr);
  end;
end;

function TPascalCoinAPI.getaccountoperations(const AAccount: Cardinal;
  const ADepth: Integer = 100; const AStart: Integer = 0;
  const AMax: Integer = 100): IPascalCoinList<IPascalCoinOperation>;
var
  lVal: TJSONValue;
  lOps: TJSONArray;
  lOp: IPascalCoinOperation;
begin
  if FClient.RPCCall('getaccountoperations',
    [TParamPair.Create('account', AAccount), TParamPair.Create('depth', ADepth),
    TParamPair.Create('start', AStart), TParamPair.Create('max', AMax)]) then
  begin
    result := TPascalCoinList<IPascalCoinOperation>.Create;
    lOps := (GetJSONResult as TJSONArray);
    for lVal in lOps do
    begin
      lOp := TPascalCoinOperation.CreateFromJSON(lVal);
      result.Add(lOp);
    end;
  end
  else
  begin
    raise ERPCException.Create(FClient.ResultStr);
  end;
end;

function TPascalCoinAPI.getblock(const BlockNumber: Integer): IPascalCoinBlock;
begin
  // if True then

end;

function TPascalCoinAPI.GetCurrentNodeStatus: IPascalCoinNodeStatus;
begin
  if (not Assigned(FNodeStatus)) or (MinutesBetween(Now, FLastStatusPoll) > 5) then
  begin
    try
      FNodeStatus := Self.nodestatus;
      FNodeAvailability := TNodeAvailability.Avaialable;
      FLastStatusPoll := Now;
    except
      on E: Exception do
      begin
        FNodeAvailability := TNodeAvailability.NotAvailable;
        FLastError := E.Message;
        Result := Nil;
      end;
    end;
  end;

  result := FNodeStatus;
end;

function TPascalCoinAPI.GetIsTestNet: Boolean;
begin
  Result := FNodeStatus.version.Contains('TESTNET');
end;

function TPascalCoinAPI.GetJSONResult: TJSONValue;
begin
  result := (TJSONObject.ParseJSONValue(FClient.ResultStr) as TJSONObject)
    .GetValue('result');
end;

function TPascalCoinAPI.GetJSONResultStr: string;
begin
  result := FClient.ResultStr;
end;

function TPascalCoinAPI.GetLastError: String;
begin
  result := FLastError;
end;

function TPascalCoinAPI.GetNodeAvailability: TNodeAvailability;
begin
  result := FNodeAvailability;
end;

function TPascalCoinAPI.GetNodeURI: String;
begin
  result := FClient.NodeURI;
end;

function TPascalCoinAPI.getwalletaccounts(const APublicKey: String;
  const AKeyStyle: TKeyStyle; const AMaxCount: Integer): IPascalCoinAccounts;
var
  lAccounts: TJSONArray;
  lAccount: TJSONValue;
  lMax: Integer;
begin
  if AMaxCount = -1 then
    lMax := MaxInt
  else
    lMax := AMaxCount;
  if FClient.RPCCall('getwalletaccounts',
    [PublicKeyParam(APublicKey, AKeyStyle), TParamPair.Create('max', lMax)])
  then
  begin
    result := TPascalCoinAccounts.Create;
    lAccounts := (GetJSONResult as TJSONArray);
    for lAccount in lAccounts do
      result.AddAccount(TJSON.JsonToObject<TPascalCoinAccount>
        ((lAccount as TJSONObject)));
  end
  else
    raise ERPCException.Create(FClient.ResultStr);
end;

function TPascalCoinAPI.getwalletaccountscount(const APublicKey: String;
  const AKeyStyle: TKeyStyle): Integer;
begin
  if FClient.RPCCall('getwalletaccountscount', PublicKeyParam(APublicKey,
    AKeyStyle)) then
    result := GetJSONResult.AsType<Integer>
  else
    raise ERPCException.Create(FClient.ResultStr);
end;

function TPascalCoinAPI.nodestatus: IPascalCoinNodeStatus;
begin
  result := nil;
  if FClient.RPCCall('nodestatus', []) then
  begin
    result := TPascalCoinNodeStatus.Create(GetJSONResult);
  end
  else
    raise ERPCException.Create(FClient.ResultStr);

end;

function TPascalCoinAPI.payloadEncryptWithPublicKey(const APayload,
  AKey: string; const AKeyStyle: TKeyStyle): string;
begin
  if FClient.RPCCall('payloadencrypt', [TParamPair.Create('payload', APayload),
    TParamPair.Create('payload_method', 'pubkey'), PublicKeyParam(AKey,
    AKeyStyle)]) then
    result := GetJSONResult.AsType<string>
  else
    raise ERPCException.Create(FClient.ResultStr);
end;

function TPascalCoinAPI.PublicKeyParam(const AKey: String;
  const AKeyStyle: TKeyStyle): TParamPair;
const
  _KeyType: Array [Boolean] of String = ('b58_pubkey', 'enc_pubkey');
begin
  case AKeyStyle of
    ksUnkown:
      result := TParamPair.Create(_KeyType[FTools.IsHexaString(AKey)], AKey);
    ksEncKey:
      result := TParamPair.Create('enc_pubkey', AKey);
    ksB58Key:
      result := TParamPair.Create('b58_pubkey', AKey);
  end;
end;

procedure TPascalCoinAPI.SetNodeURI(const Value: String);
begin
  FClient.NodeURI := Value;
  GetCurrentNodeStatus;
end;

function TPascalCoinAPI.URI(const Value: string): IPascalCoinAPI;
begin
  SetNodeURI(Value);
  result := Self;
end;

constructor TPascalCoinAPI.Create(AClient: IPascalCoinRPCClient;
  ATools: IPascalCoinTools);
begin
  inherited Create;
  FClient := AClient;
  // FConfig := AConfig;
  FTools := ATools;
end;

end.
