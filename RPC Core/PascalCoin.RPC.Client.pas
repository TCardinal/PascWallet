unit PascalCoin.RPC.Client;

interface

uses System.JSON, PascalCoin.RPC.Interfaces;

type

TPascalCoinRPCClient = Class(TInterfacedObject, IPascalCoinRPCClient)
private
  FConfig: IPascalCoinRPCConfig;
  FHTTPClient: IRPCHTTPRequest;
  FResultStr: String;
  FError: boolean;
  FErrorData: String;
  FCallId: string;
protected
  function GetResult: TJSONObject;
  function GetResultStr: string;
  function RPCCall(const AMethod: String; const AParams: Array of TParamPair): Boolean;
public
  constructor Create(AConfig: IPascalCoinRPCConfig; AHTTPClient: IRPCHTTPRequest);
End;

implementation

uses System.SysUtils;

{ TPascalCoinRPCClient }

constructor TPascalCoinRPCClient.Create(AConfig: IPascalCoinRPCConfig;
  AHTTPClient: IRPCHTTPRequest);
begin
  inherited Create;
  FConfig := AConfig;
  FHTTPClient := AHTTPClient;
  FError := True;
end;

function TPascalCoinRPCClient.GetResult: TJSONObject;
begin
  if Not FError then
     Result := TJSONObject.ParseJSONValue(FResultStr) As TJSONObject
  else
     Result := TJSONObject.ParseJSONValue(FErrorData) As TJSONObject;
end;

function TPascalCoinRPCClient.GetResultStr: string;
begin
  if Not FError then
    Result := FResultStr
  else
    Result := FErrorData;
end;

//{"jsonrpc": "2.0", "method": "XXX", "id": YYY, "params":{"p1":" ","p2":" "}}
function TPascalCoinRPCClient.RPCCall(const AMethod: String; const AParams:
    Array of TParamPair): Boolean;
var lObj, lParams, lErr: TJSONObject;
    lParam: TParamPair;
begin
  FCallId := FConfig.NextId;
  lObj := TJSONObject.Create;
  try
    lObj.AddPair('jsonrpc', '2.0');
    lObj.AddPair('id', FCallId);
    lObj.AddPair('method', AMethod);

    lParams := TJSONObject.Create;
    for lParam in AParams do
    begin
      lParams.AddPair(lParam.Key, lParam.Value);
    end;

    lObj.AddPair('params', lParams);

    Result := FHTTPClient.Post(FConfig.NodeURL, lObj.ToJSON);
    FError := not Result;

    if FError then
    begin
      lObj.Free;
      lObj := TJSONObject.Create;
      lObj.AddPair('StatusCode', FHTTPClient.StatusCode.ToString);
      lObj.AddPair('StatusMessage', FHTTPClient.StatusText);
      lObj.AddPair('ErrorSource', 'HTTPClient');
      FErrorData := lObj.ToJSON;
      lObj.Free;
    end
    { TODO : Test that return Id matches call id }
    else
    begin
      FResultStr := FHTTPClient.ResponseStr;
      if FResultStr.IndexOf('{"error') = 0 then
      begin
        lObj := (TJSONObject.ParseJSONValue(FResultStr) as TJSONObject);
        lErr := TJSONObject.Create;
        lErr.AddPair('StatusCode', lObj.Values['code']);
        lErr.AddPair('StatusMessage', lObj.Values['message']);
        lErr.AddPair('ErrorSource', 'RemoteRPC');

        FErrorData := lErr.ToJSON;
        FResultStr := '';
        Result := False;
        FError := False;
      end;
    end;

  finally
    lObj.Free;
    if lParams <> nil then
       lParams.Free;
    if lErr <> nil then
       lErr.Free;
  end;
end;

end.
