program RPCTest;

uses
  System.StartUpCopy,
  FMX.Forms,
  Spring.Container,
  PascalCoin.RPC.Test.Main in 'PascalCoin.RPC.Test.Main.pas' {Form1},
  PascalCoin.RPC.Test.DI in 'PascalCoin.RPC.Test.DI.pas',
  PascalCoin.RPC.Test.Account in 'PascalCoin.RPC.Test.Account.pas' {AccountFrame: TFrame},
  PascalCoin.RPC.Test.AccountList in 'PascalCoin.RPC.Test.AccountList.pas' {AccountsList: TFrame},
  PascalCoin.RPC.Test.Node in 'PascalCoin.RPC.Test.Node.pas' {NodeStatusFrame: TFrame},
  PascalCoin.Test.Wallet in 'PascalCoin.Test.Wallet.pas' {WalletFrame: TFrame},
  PascalCoin.HTTPClient.Delphi in '..\RPC Core\PascalCoin.HTTPClient.Delphi.pas',
  PascalCoin.RPC.Account in '..\RPC Core\PascalCoin.RPC.Account.pas',
  PascalCoin.RPC.API in '..\RPC Core\PascalCoin.RPC.API.pas',
  PascalCoin.RPC.Block in '..\RPC Core\PascalCoin.RPC.Block.pas',
  PascalCoin.RPC.Client in '..\RPC Core\PascalCoin.RPC.Client.pas',
  PascalCoin.RPC.Interfaces in '..\RPC Core\PascalCoin.RPC.Interfaces.pas',
  PascalCoin.RPC.Node in '..\RPC Core\PascalCoin.RPC.Node.pas',
  PascalCoin.StreamOp in '..\Wallet Core\Classes\PascalCoin.StreamOp.pas',
  PascalCoin.Wallet.Classes in '..\Wallet Core\Classes\PascalCoin.Wallet.Classes.pas',
  PascalCoin.Wallet.Interfaces in '..\Wallet Core\Interfaces\PascalCoin.Wallet.Interfaces.pas',
  PascalCoin.ResourceStrings in '..\Wallet Core\Classes\PascalCoin.ResourceStrings.pas',
  PascalCoin.FMX.Strings in '..\Wallet UI\PascalCoin.FMX.Strings.pas',
  PascalCoin.Utils.Interfaces in '..\Utils Core\PascalCoin.Utils.Interfaces.pas',
  PascalCoin.Utils.Classes in '..\Utils Core\PascalCoin.Utils.Classes.pas',
  PascalCoin.Helpers in '..\Utils Core\PascalCoin.Helpers.pas',
  PascalCoin.KeyTool in '..\Utils Core\PascalCoin.KeyTool.pas',
  PascalCoin.RPC.Test.Operations in 'PascalCoin.RPC.Test.Operations.pas' {OperationsFrame: TFrame},
  PascalCoin.RPC.Operation in '..\RPC Core\PascalCoin.RPC.Operation.pas',
  PascalCoin.RPC.Test.RawOp in 'PascalCoin.RPC.Test.RawOp.pas' {RawOpFrame: TFrame},
  ClpFixedSecureRandom in '..\Libraries\ClpFixedSecureRandom.pas',
  ClpIFixedSecureRandom in '..\Libraries\ClpIFixedSecureRandom.pas',
  PascalCoin.RPC.Test.Payload in 'PascalCoin.RPC.Test.Payload.pas' {PayloadTest: TFrame},
  PascalCoin.RPC.Test.DM in 'PascalCoin.RPC.Test.DM.pas' {DM: TDataModule},
  PascalCoin.RawOp.Classes in '..\Utils Core\PascalCoin.RawOp.Classes.pas',
  PascalCoin.RawOp.Interfaces in '..\Utils Core\PascalCoin.RawOp.Interfaces.pas';

{$R *.res}

begin
  RegisterStuff(GlobalContainer);
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
