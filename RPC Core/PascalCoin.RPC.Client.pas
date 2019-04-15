unit PascalCoin.RPC.Client;

interface

uses System.JSON, PascalCoin.RPC.Interfaces, PascalCoin.Utils.Interfaces;

type

  TPascalCoinRPCClient = Class(TInterfacedObject, IPascalCoinRPCClient)
  private
    FNodeURI: string;

    FHTTPClient: IRPCHTTPRequest;
    FResultStr: String;
    FResultObj: TJSONObject;
    FError: boolean;
    FErrorData: String;
    FCallId: string;
    FNextId: Integer;
    function NextId: String;
  protected
    function GetResult: TJSONObject;
    function GetResultStr: string;
    function RPCCall(const AMethod: String;
      const AParams: Array of TParamPair): boolean;
    function GetNodeURI: String;
    procedure SetNodeURI(const Value: string);

  public
    constructor Create(AHTTPClient: IRPCHTTPRequest);
  End;

implementation

uses System.SysUtils, System.IOUtils;

{ TPascalCoinRPCClient }

constructor TPascalCoinRPCClient.Create(AHTTPClient: IRPCHTTPRequest);
begin
  inherited Create;
  FHTTPClient := AHTTPClient;
  FError := True;
end;

function TPascalCoinRPCClient.GetNodeURI: String;
begin
  result := FNodeURI;
end;

function TPascalCoinRPCClient.GetResult: TJSONObject;
begin
  if Not FError then
    result := TJSONObject.ParseJSONValue(FResultStr) As TJSONObject
  else
    result := TJSONObject.ParseJSONValue(FErrorData) As TJSONObject;
end;

function TPascalCoinRPCClient.GetResultStr: string;
begin
  if Not FError then
    result := FResultStr
  else
    result := FErrorData;
end;

function TPascalCoinRPCClient.NextId: String;
begin
  Inc(FNextId);
  result := FNextId.ToString;
end;

// {"jsonrpc": "2.0", "method": "XXX", "id": YYY, "params":{"p1":" ","p2":" "}}
function TPascalCoinRPCClient.RPCCall(const AMethod: String;
  const AParams: Array of TParamPair): boolean;
var
  lObj, lErrObj, lParams, lErr, lAObj: TJSONObject;
  lArr: TJSONArray;
  lParam: TParamPair;
  lValue, lElem, lErrElem: TJSONValue;
  FAErrors: String;
begin
  lErr := nil;
  lParams := nil;

  FCallId := NextId;
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

    result := FHTTPClient.Post(FNodeURI, lObj.ToJSON);
    FError := not result;

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
      FResultObj := (TJSONObject.ParseJSONValue(FResultStr) as TJSONObject);
      lValue := FResultObj.FindValue('error');


      if lValue <> nil then
      begin
        lErrObj := lValue as TJSONObject;
        lErr := TJSONObject.Create;
        lErr.AddPair('StatusCode', lErrObj.Values['code'].AsType<string>);
        lErr.AddPair('StatusMessage', lErrObj.Values['message'].AsType<string>);
        lErr.AddPair('ErrorSource', 'RemoteRPC');

        FErrorData := lErr.ToJSON;
        lErr.Free;
        FResultStr := '';
        result := False;
        FError := True;
        Exit;
      end;

      lValue := FResultObj.FindValue('result');
      if lValue is TJSONArray then
      begin
        FAErrors := '';
        lArr := lValue as TJSONArray;
        for lElem in lArr do
        begin
          lAObj := lElem as TJSONObject;
          lErrElem := lAObj.FindValue('errors');
          if lErrElem <> nil then
          begin
            FAErrors := FAErrors + lErrElem.AsType<String> + ';';
          end;
        end;

        if FAErrors <> '' then
        begin
          lErr := TJSONObject.Create;
          lErr.AddPair('StatusCode', '-1');
          lErr.AddPair('StatusMessage', FAErrors);
          lErr.AddPair('ErrorSource', 'RemoteRPC');

          FErrorData := lErr.ToJSON;
          lErr.Free;
          FResultStr := '';
          Result := False;
          FError := True;
        end
        else
        begin
          Result := True;
          FError := False;
        end;

      end
      else if lValue is TJSONObject then
      begin
          Result := True;
          FError := False;
      end;

    end;

  finally
    lObj.Free;
  end;
end;

procedure TPascalCoinRPCClient.SetNodeURI(const Value: string);
begin
  FNodeURI := Value;

end;

end.
