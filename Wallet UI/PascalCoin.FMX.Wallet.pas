unit PascalCoin.FMX.Wallet;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FrameStand,
  FMX.Layouts, FMX.ListBox, FMX.TabControl, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.MultiView,
  System.Actions, FMX.ActnList,
  PascalCoin.FMX.Frame.Settings, PascalCoin.FMX.Frame.Keys,
  PascalCoin.FMX.Frame.Wallet, PascalCoin.Frame.Unlock;

type
  TDisplayedFrame = (dfNone, dfSettings, dfWallet, dfKeys, dfSend, dfReceive, dfPASA);

  TMainForm = class(TForm)
    MultiView1: TMultiView;
    MasterLayout: TLayout;
    ToolBar1: TToolBar;
    MenuLabel: TLabel;
    Hamburger: TSpeedButton;
    TabControl1: TTabControl;
    MenuTab: TTabItem;
    MainMenu: TListBox;
    VersionLabel: TLabel;
    FrameStand1: TFrameStand;
    SettingsItem: TListBoxItem;
    ActionList1: TActionList;
    StatusBar1: TStatusBar;
    ContentLayout: TLayout;
    ReceiveItem: TListBoxItem;
    SendItem: TListBoxItem;
    WalletItem: TListBoxItem;
    ToolBar2: TToolBar;
    StyleBook1: TStyleBook;
    KeysItem: TListBoxItem;
    FrameTitle: TLabel;
    BalanceLabel: TLabel;
    StatusLabel1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure KeysItemClick(Sender: TObject);
    procedure SettingsItemClick(Sender: TObject);
    procedure WalletItemClick(Sender: TObject);
  private
    { Private declarations }
    FDisplayedFrame: TDisplayedFrame;
    FLastDisplayedFrame: TDisplayedFrame;

    FWalletInfoFrame: TFrameInfo<TWalletFrame>;
    FSettingsInfoFrame: TFrameInfo<TSettingsFrame>;
    FKeysInfoFrame: TFrameInfo<TKeysFrame>;
    FUnlockInfoFrame: TFrameInfo<TUnlockFrame>;
    procedure CloseDisplayedFrame(const LoadLast: boolean);
    function GetKeysFrame: TFrameInfo<TKeysFrame>;
    function GetWalletFrame: TFrameInfo<TWalletFrame>;
    procedure ShowKeys;
    procedure ShowWallet;
    procedure ShowSettings;
    procedure WriteToStatusBar(const Value: string);
    function GetSettingsFrame: TFrameInfo<TSettingsFrame>;

    function UnlockWallet: boolean;
  public
    { Public declarations }
    property Wallet: TFrameInfo<TWalletFrame> read GetWalletFrame;
    property Settings: TFrameInfo<TSettingsFrame> read GetSettingsFrame;
    property Keys: TFrameInfo<TKeysFrame> read GetKeysFrame;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses PascalCoin.FMX.DataModule, PascalCoin.FMX.Frame.Base;

function TMainForm.GetKeysFrame: TFrameInfo<TKeysFrame>;
begin
  if not Assigned(FKeysInfoFrame) then
  begin
     FKeysInfoFrame := FrameStand1.New<TKeysFrame>(ContentLayout);
     FKeysInfoFrame.Frame.OnStatusBarWrite := WriteToStatusBar;
     FKeysInfoFrame.Frame.InitialiseFrame;
  end;
  result := FKeysInfoFrame;
end;

function TMainForm.GetSettingsFrame: TFrameInfo<TSettingsFrame>;
begin
  if not Assigned(FSettingsInfoFrame) then
  begin
    FSettingsInfoFrame := FrameStand1.New<TSettingsFrame>(ContentLayout);
    FSettingsInfoFrame.Frame.InitialiseFrame;
    FSettingsInfoFrame.Frame.OnStatusBarWrite := WriteToStatusBar;
  end;
  result := FSettingsInfoFrame;
end;

function TMainForm.GetWalletFrame: TFrameInfo<TWalletFrame>;
begin
  if not Assigned(FWalletInfoFrame) then
  begin
     FWalletInfoFrame := FrameStand1.New<TWalletFrame>(ContentLayout);
     FWalletInfoFrame.Frame.OnStatusBarWrite := WriteToStatusBar;
     FWalletInfoFrame.Frame.InitialiseFrame;
  end;
  result := FWalletInfoFrame;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FDisplayedFrame := dfNone;
  FLastDisplayedFrame := dfNone;
  MainDataModule.OnTryUnlock := UnlockWallet;
  ShowWallet;
end;

{ TMainForm }

procedure TMainForm.CloseDisplayedFrame(const LoadLast: boolean);
var lDisplayed: TDisplayedFrame;
begin
  if FrameStand1.LastShownFrame <> nil then
  begin
    if (FrameStand1.LastShownFrame is TBaseFrame) then
       TBaseFrame(FrameStand1.LastShownFrame).Hiding;
    FrameStand1.FrameInfo(FrameStand1.LastShownFrame).Hide();
  end;
  if LoadLast then
  begin
    case FLastDisplayedFrame of
      dfNone: ;
      dfSettings: ;
      dfWallet: ShowWallet;
      dfKeys: ShowKeys;
    end;
  end;

//  FLastDisplayedFrame := lDisplayed;

end;

procedure TMainForm.KeysItemClick(Sender: TObject);
begin
  ShowKeys;
end;

procedure TMainForm.SettingsItemClick(Sender: TObject);
begin
  ShowSettings;
end;

procedure TMainForm.ShowKeys;
begin
  CloseDisplayedFrame(False);
  FrameTitle.Text := 'My Keys';
  Keys.Frame.Showing;
  Keys.Show();
  FDisplayedFrame := dfKeys;
end;

procedure TMainForm.ShowSettings;
begin
  if FDisplayedFrame = dfSettings then
     Exit;
  CloseDisplayedFrame(False);
  FrameTitle.Text := 'Settings';
  Settings.Frame.Showing;
  Settings.Show();
  FDisplayedFrame := dfSettings;
end;

procedure TMainForm.ShowWallet;
begin
  CloseDisplayedFrame(False);
  FrameTitle.Text := 'My Wallet';
  StatusLabel1.Text := '';
  Wallet.Show();
  FDisplayedFrame := dfWallet;
end;

function TMainForm.UnlockWallet: boolean;
var lRetval: boolean;
begin
  FUnlockInfoFrame := FrameStand1.New<TUnlockFrame>(self);
  FUnlockInfoFrame.Frame.OnCancel :=
    procedure
    begin
      lRetval := False;
      FUnlockInfoFrame.Hide(100,
      procedure
      begin
        FUnlockInfoFrame.Close;
        FUnlockInfoFrame := nil;
      end);
    end;

  FUnlockInfoFrame.Frame.OnOk :=
    procedure
    var lPassword: string;
    begin
      lPassword := FUnlockInfoFrame.Frame.Password;

      lRetval := MainDataModule.Wallet.Unlock(lPassword);

      FUnlockInfoFrame.Hide(100,
      procedure
      begin
        FUnlockInfoFrame.Close;
        FUnlockInfoFrame := nil;
      end);
    end;

  FUnlockInfoFrame.Show;

  result := lRetval;
end;

procedure TMainForm.WalletItemClick(Sender: TObject);
begin
  ShowWallet;
end;

procedure TMainForm.WriteToStatusBar(const Value: string);
begin
  StatusLabel1.Text := Value;
end;

end.
