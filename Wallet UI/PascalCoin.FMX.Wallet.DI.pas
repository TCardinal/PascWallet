unit PascalCoin.FMX.Wallet.DI;

interface

uses Spring.Container,  PascalCoin.Wallet.Interfaces;

function RegisterStuff(AContainer: TContainer): IPascalCoinWalletConfig;

implementation

uses PascalCoin.RPC.Interfaces,
  PascalCoin.FMX.Wallet.Config,
  PascalCoin.HTTPClient.Delphi, PascalCoin.RPC.Client, PascalCoin.RPC.Account,
  PascalCoin.RPC.API,
  PascalCoin.KeyTool, PascalCoin.StreamOp,
 PascalCoin.Wallet.Classes,
  PascalCoin.URI,
  PascalCoin.Utils.Interfaces, PascalCoin.Utils.Classes,
  PascalCoin.Update.Interfaces, PascalCoin.Update.Classes,
  PascalCoin.RawOp.Interfaces, PascalCoin.RawOp.Classes;

function RegisterStuff(AContainer: TContainer): IPascalCoinWalletConfig;
var
  lConfig: IPascalCoinWalletConfig;
begin
  lConfig := TPascalCoinWalletConfig.Create;
  AContainer.RegisterInstance<IPascalCoinWalletConfig>(lConfig).AsSingleton;

  AContainer.RegisterType<IKeyTools, TPascalCoinKeyTools>;
  AContainer.RegisterType<IStreamOp, TStreamOp>;
  AContainer.RegisterType<IRPCHTTPRequest, TDelphiHTTP>;
  AContainer.RegisterType<IPascalCoinRPCClient, TPascalCoinRPCClient>;
  AContainer.RegisterType<IPascalCoinAccount, TPascalCoinAccount>;
  AContainer.RegisterType<IPascalCoinAPI, TPascalCoinAPI>;
  AContainer.RegisterType<IPascalCoinAccounts, TPascalCoinAccounts>;
  AContainer.RegisterType<IPascalCoinTools, TPascalCoinTools>;
  AContainer.RegisterType<IWallet, TWallet>;
  AContainer.RegisterType<IWalletKey, TWalletKey>;
  AContainer.RegisterType<IRawOperations, TRawOperations>;
  AContainer.RegisterType<IRawTransactionOp, TRawTransactionOp>;

  AContainer.RegisterType<IFetchAccountData, TFetchAccountData>;

  AContainer.RegisterType<IPascalCoinURI, TPascalCoinURI>;

  AContainer.Build;
  (lConfig as IPascalCoinWalletConfig).Container := AContainer;
  result := lConfig;
end;

end.
