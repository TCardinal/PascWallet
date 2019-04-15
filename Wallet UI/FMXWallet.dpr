program FMXWallet;

uses
  System.StartUpCopy,
  FMX.Forms,
  Spring.Container,
  PascalCoin.FMX.Wallet in 'PascalCoin.FMX.Wallet.pas' {MainForm},
  PascalCoin.FMX.DataModule in 'PascalCoin.FMX.DataModule.pas' {MainDataModule: TDataModule},
  PascalCoin.FMX.Frame.Settings in 'PascalCoin.FMX.Frame.Settings.pas' {SettingsFrame: TFrame},
  PascalCoin.FMX.Frame.Wallet in 'PascalCoin.FMX.Frame.Wallet.pas' {WalletFrame: TFrame},
  PascalCoin.FMX.Wallet.DI in 'PascalCoin.FMX.Wallet.DI.pas',
  PascalCoin.Wallet.Interfaces in '..\Wallet Core\Interfaces\PascalCoin.Wallet.Interfaces.pas',
  PascalCoin.ResourceStrings in '..\Wallet Core\Classes\PascalCoin.ResourceStrings.pas',
  PascalCoin.Wallet.Classes in '..\Wallet Core\Classes\PascalCoin.Wallet.Classes.pas',
  PascalCoin.HTTPClient.Delphi in '..\RPC Core\PascalCoin.HTTPClient.Delphi.pas',
  PascalCoin.RPC.Account in '..\RPC Core\PascalCoin.RPC.Account.pas',
  PascalCoin.RPC.API in '..\RPC Core\PascalCoin.RPC.API.pas',
  PascalCoin.RPC.Block in '..\RPC Core\PascalCoin.RPC.Block.pas',
  PascalCoin.RPC.Client in '..\RPC Core\PascalCoin.RPC.Client.pas',
  PascalCoin.RPC.Interfaces in '..\RPC Core\PascalCoin.RPC.Interfaces.pas',
  PascalCoin.RPC.Node in '..\RPC Core\PascalCoin.RPC.Node.pas',
  PascalCoin.FMX.Frame.Keys in 'PascalCoin.FMX.Frame.Keys.pas' {KeysFrame: TFrame},
  PascalCoin.FMX.Wallet.Shared in 'PascalCoin.FMX.Wallet.Shared.pas',
  PascalCoin.FMX.Frame.Base in 'PascalCoin.FMX.Frame.Base.pas' {BaseFrame: TFrame},
  PascalCoin.FMX.Strings in 'PascalCoin.FMX.Strings.pas',
  PascalCoin.Frame.NewKey in 'PascalCoin.Frame.NewKey.pas' {NewKeyFrame: TFrame},
  PascalCoin.Frame.Unlock in 'PascalCoin.Frame.Unlock.pas' {UnlockFrame: TFrame},
  PascalCoin.Frame.Password in 'PascalCoin.Frame.Password.pas' {Frame1: TFrame},
  PascalCoin.Utils.Classes in '..\Utils Core\PascalCoin.Utils.Classes.pas',
  PascalCoin.Utils.Interfaces in '..\Utils Core\PascalCoin.Utils.Interfaces.pas',
  PascalCoin.Update.Interfaces in '..\Wallet Core\Interfaces\PascalCoin.Update.Interfaces.pas',
  PascalCoin.Update.Classes in '..\Wallet Core\Classes\PascalCoin.Update.Classes.pas',
  PascalCoin.FMX.Frame.Receive in 'PascalCoin.FMX.Frame.Receive.pas' {ReceiveFrame: TFrame},
  DelphiZXIngQRCode in '..\Libraries\DelphiZXIngQRCode.pas',
  PascalCoin.URI in '..\Wallet Core\Classes\PascalCoin.URI.pas',
  PascalCoin.FMX.Frame.Send in 'PascalCoin.FMX.Frame.Send.pas' {SendFrame: TFrame},
  PascalCoin.KeyTool in '..\Utils Core\PascalCoin.KeyTool.pas',
  PascalCoin.Helpers in '..\Utils Core\PascalCoin.Helpers.pas',
  PascalCoin.StreamOp in '..\Wallet Core\Classes\PascalCoin.StreamOp.pas',
  PascalCoin.RPC.Operation in '..\RPC Core\PascalCoin.RPC.Operation.pas',
  ClpFixedSecureRandom in '..\Libraries\ClpFixedSecureRandom.pas',
  ClpIFixedSecureRandom in '..\Libraries\ClpIFixedSecureRandom.pas',
  PascalCoin.RawOp.Interfaces in '..\Utils Core\PascalCoin.RawOp.Interfaces.pas',
  PascalCoin.RawOp.Classes in '..\Utils Core\PascalCoin.RawOp.Classes.pas',
  PascalCoin.FMX.Frame.Settings.Node in 'PascalCoin.FMX.Frame.Settings.Node.pas' {EditNodeFrame: TFrame},
  PascalCoin.FMX.Wallet.Config in 'PascalCoin.FMX.Wallet.Config.pas';

{$R *.res}

begin
  UConfig := RegisterStuff(TContainer.Create);
  Application.Initialize;
  Application.CreateForm(TMainDataModule, MainDataModule);
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;

end.
