unit PascalCoin.RPC.Shared;

interface

uses PascalCoin.RPC.Interfaces;

function RPCConfig: IPascalCoinRPCConfig;


procedure SetRPCConfig(Value: IPascalCoinRPCConfig);

implementation

var
_RPCConfig: IPascalCoinRPCConfig;

function RPCConfig: IPascalCoinRPCConfig;
begin
  result := _RPCConfig;
end;

procedure SetRPCConfig(Value: IPascalCoinRPCConfig);
begin
  _RPCConfig := nil;
  _RPCConfig := Value;
end;

end.
