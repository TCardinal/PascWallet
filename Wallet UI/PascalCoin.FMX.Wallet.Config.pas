unit PascalCoin.FMX.Wallet.Config;

interface

uses PascalCoin.Wallet.Interfaces, Spring.Container;

type

TPascalCoinWalletConfig = class(TInterfacedObject, IPascalCoinWalletConfig)
private
  FContainer: TContainer;
protected
  function GetContainer: TContainer;
  procedure SetContainer(Value: TContainer);
end;

implementation

{ TPascalCoinWalletConfig }

function TPascalCoinWalletConfig.GetContainer: TContainer;
begin
  result := FContainer;
end;

procedure TPascalCoinWalletConfig.SetContainer(Value: TContainer);
begin
  FContainer := Value;
end;

end.
