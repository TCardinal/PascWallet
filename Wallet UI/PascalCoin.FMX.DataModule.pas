unit PascalCoin.FMX.DataModule;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, FMX.ImgList,
  PascalCoin.Wallet.Interfaces, PascalCoin.FMX.Wallet.Shared;

type

  TBooleanEvent = Function: Boolean of object;

  TMainDataModule = class(TDataModule)
    ImageList: TImageList;
    procedure DataModuleCreate(Sender: TObject);
  private
    FWallet: IWallet;
    FSettingsName: string;
    FOnTryUnlock: TBooleanEvent;
    FOnLockChanged: TProc<Boolean>;
    function GetWallet: IWallet;
    procedure LoadSettings;
  public
    { Public declarations }
    Settings: TWalletAppSettings;
    procedure SaveSettings;
    function TryUnlock: boolean;
    property Wallet: IWallet read GetWallet;
    property OnTryUnlock: TBooleanEvent write FOnTryUnlock;
  end;

var
  MainDataModule: TMainDataModule;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses PascalCoin.RPC.Shared, System.IOUtils, Rest.JSON;

{$R *.dfm}

procedure TMainDataModule.DataModuleCreate(Sender: TObject);
begin
  FWallet := Nil;
  FWallet := RPCConfig.Container.Resolve<IWallet>;

  FSettingsName := TPath.Combine(TPath.GetDirectoryName(FWallet.GetWalletFileName),
    'PascalConFMX.json');

  LoadSettings;

end;

function TMainDataModule.GetWallet: IWallet;
begin
  result := FWallet;
end;

procedure TMainDataModule.LoadSettings;
var
  lJson: string;
begin
  if TFile.Exists(FSettingsName) then
  begin
    lJson := TFile.ReadAllText(FSettingsName);
    Settings := TJson.JsonToObject<TWalletAppSettings>(lJson);
  end
  else
     Settings := TWalletAppSettings.Create;
end;

procedure TMainDataModule.SaveSettings;
var lJson: string;
begin
  lJson := TJson.ObjectToJsonString(Settings);
  TFile.WriteAllText(FSettingsName, lJson);
end;

function TMainDataModule.TryUnlock: boolean;
begin
   Result := Not FWallet.Locked;
   if Result then
      Exit;

   if Wallet.State = esPlainText then
      Exit(Wallet.Unlock(''));

   if Assigned(FOnTryUnlock) then
      Result := FOnTryUnlock
   else
      Result := False;
end;

end.
