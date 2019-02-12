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
  PascalCoin.RPC.Config in '..\RPC Core\PascalCoin.RPC.Config.pas',
  PascalCoin.RPC.Interfaces in '..\RPC Core\PascalCoin.RPC.Interfaces.pas',
  PascalCoin.RPC.Node in '..\RPC Core\PascalCoin.RPC.Node.pas',
  PascalCoin.RPC.Shared in '..\RPC Core\PascalCoin.RPC.Shared.pas',
  PascalCoin.Helpers in '..\Wallet Core\Classes\PascalCoin.Helpers.pas',
  PascalCoin.KeyTool in '..\Wallet Core\Classes\PascalCoin.KeyTool.pas',
  PascalCoin.StreamOp in '..\Wallet Core\Classes\PascalCoin.StreamOp.pas',
  PascalCoin.Wallet.Classes in '..\Wallet Core\Classes\PascalCoin.Wallet.Classes.pas',
  PascalCoin.Wallet.Interfaces in '..\Wallet Core\Interfaces\PascalCoin.Wallet.Interfaces.pas',
  PascalCoin.ResourceStrings in '..\Wallet Core\Classes\PascalCoin.ResourceStrings.pas',
  PascalCoin.FMX.Strings in '..\Wallet UI\PascalCoin.FMX.Strings.pas',
  PascalCoin.Utils.Interfaces in '..\Utils Core\PascalCoin.Utils.Interfaces.pas',
  PascalCoin.Utils.Classes in '..\Utils Core\PascalCoin.Utils.Classes.pas';

{$R *.res}

begin
  RegisterStuff(TContainer.Create);
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
