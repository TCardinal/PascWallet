unit PascalCoin.FMX.Wallet.DI;

interface
uses Spring.Container;

procedure RegisterStuff(AContainer: TContainer);

implementation

uses PascalCoin.RPC.Interfaces,
  PascalCoin.RPC.Shared, PascalCoin.RPC.Config,
  PascalCoin.HTTPClient.Delphi, PascalCoin.RPC.Client, PascalCoin.RPC.Account,
  PascalCoin.RPC.API,
  PascalCoin.KeyTool, PascalCoin.StreamOp,
  PascalCoin.Wallet.Interfaces, PascalCoin.Wallet.Classes,
  PascalCoin.Utils.Interfaces, PascalCoin.Utils.Classes;

procedure RegisterStuff(AContainer: TContainer);
var lConfig: TPascalCoinRPCConfig;
begin
  lConfig := TPascalCoinRPCConfig.Create;
  AContainer.RegisterInstance<IPascalCoinRPCConfig>(lConfig).AsSingleton;

  AContainer.RegisterType<IKeyTools, TPascalCoinKeyTools>;
  AContainer.RegisterType<IStreamOp, TStreamOp>;
  AContainer.RegisterType<IRPCHTTPRequest, TDelphiHTTP>;
  AContainer.RegisterType<IPascalCoinRPCClient, TPascalCoinRPCClient>;
  AContainer.RegisterType<IPascalCoinAccount, TPascalCoinAccount>;
  AContainer.RegisterType<IPascalCoinAPI, TPascalCoinAPI>;
  AContainer.RegisterType<IPascalCoinTools, TPascalCoinTools>;
  AContainer.RegisterType<IWallet, TWallet>;
  AContainer.RegisterType<IWalletKey, TWalletKey>;


  AContainer.Build;
  (lConfig as IPascalCoinRPCConfig).Container := AContainer;
  SetRPCConfig(lConfig);
end;

end.
