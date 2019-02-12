unit PascalCoin.RPC.Config;

interface

uses PascalCoin.RPC.Interfaces, Spring.Container;

type

TPascalCoinRPCConfig = Class(TInterfacedObject, IPascalCoinRPCConfig)
private
  FNodeName: string;
  FNodeURL: string;
  FContainer: TContainer;
  FRPCId: Integer;
  FNodeList: TArray<TStringPair>;
protected
  function GetNodeName: string;
  procedure SetNodeName(const Value: string);
  function GetNodeURL: string;
  procedure SetNodeURL(const Value: string);
  function GetContainer: TContainer;
  procedure SetContainer(Value: TContainer);
  function GetNodeList: TArray<TStringPair>;
  procedure SetNodeListItemIndex(const Value: Integer);
  function NextId: string;
public
  constructor Create;
End;

implementation

uses System.SysUtils;

{ TPascalCoinRPCConfig }

constructor TPascalCoinRPCConfig.Create;
begin
  inherited Create;
  FRPCId := 0;
  SetLength(FNodeList, 2);
  FNodeList[0].Key := 'Local Test Net';
  FNodeList[0].Value := 'http://127.0.0.1:4103';
  FNodeList[1].Key := 'Remote Test Net';
  FNodeList[1].Value := 'http://173.212.207.24:8080';

  SetNodeListItemIndex(0);
end;

function TPascalCoinRPCConfig.GetContainer: TContainer;
begin
  Result := FContainer;
end;

function TPascalCoinRPCConfig.GetNodeList: TArray<TStringPair>;
begin
  result := FNodeList;
end;

function TPascalCoinRPCConfig.GetNodeName: string;
begin
  Result := FNodeName;
end;

function TPascalCoinRPCConfig.GetNodeURL: string;
begin
  Result := FNodeURL;
end;

function TPascalCoinRPCConfig.NextId: string;
begin
   Inc(FRPCId);
   Result := FRPCId.ToString;
end;

procedure TPascalCoinRPCConfig.SetContainer(Value: TContainer);
begin
  FContainer := Value;
end;

procedure TPascalCoinRPCConfig.SetNodeListItemIndex(const Value: Integer);
begin
  FNodeName := FNodeList[Value].Key;
  FNodeURL := FNodeList[Value].Value;
end;

procedure TPascalCoinRPCConfig.SetNodeName(const Value: string);
begin
  FNodeName := Value;
end;

procedure TPascalCoinRPCConfig.SetNodeURL(const Value: string);
begin
  FNodeURL := Value;
end;

end.
