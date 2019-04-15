unit PascalCoin.RPC.Test.DI;

interface

uses Spring.Container;

procedure RegisterStuff(AContainer: TContainer);

implementation

uses PascalCoin.RPC.Interfaces,
  PascalCoin.HTTPClient.Delphi, PascalCoin.RPC.Client, PascalCoin.RPC.Account,
  PascalCoin.RPC.API,
  PascalCoin.KeyTool, PascalCoin.StreamOp,
  PascalCoin.Wallet.Interfaces, PascalCoin.Wallet.Classes,
  PascalCoin.Utils.Interfaces, PascalCoin.Utils.Classes;

procedure RegisterStuff(AContainer: TContainer);
begin

  AContainer.RegisterType<IKeyTools, TPascalCoinKeyTools>;
  AContainer.RegisterType<IStreamOp, TStreamOp>;
  Acontainer.RegisterType<IPascalCoinTools, TPascalCoinTools>;
  AContainer.RegisterType<IRPCHTTPRequest, TDelphiHTTP>;
  AContainer.RegisterType<IPascalCoinRPCClient, TPascalCoinRPCClient>;
  AContainer.RegisterType<IPascalCoinAccount, TPascalCoinAccount>;
  AContainer.RegisterType<IPascalCoinAPI, TPascalCoinAPI>;

  AContainer.RegisterType<IWallet, TWallet>;
  AContainer.RegisterType<IWalletKey, TWalletKey>;

  AContainer.Build;
end;

end.
