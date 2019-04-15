unit PascalCoin.FMX.Wallet;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FrameStand,
  FMX.Layouts, FMX.ListBox, FMX.TabControl, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.MultiView,
  System.Actions, FMX.ActnList,
  PascalCoin.RPC.Interfaces, PascalCoin.Utils.Interfaces,
  PascalCoin.FMX.Frame.Settings, PascalCoin.FMX.Frame.Keys,
  PascalCoin.FMX.Frame.Wallet, PascalCoin.Frame.Unlock,
  PascalCoin.FMX.Frame.Receive, PascalCoin.FMX.Frame.Send;

type
  TDisplayedFrame = (dfNone, dfSettings, dfWallet, dfKeys, dfSend,
    dfReceive, dfPASA);

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
    StyleBookLive: TStyleBook;
    KeysItem: TListBoxItem;
    FrameTitle: TLabel;
    BalanceLabel: TLabel;
    StatusLabel1: TLabel;
    LockButton: TButton;
    LockToggleAction: TAction;
    NodeLayout: TLayout;
    NodeLabel: TLabel;
    StyleBookTestNet: TStyleBook;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure KeysItemClick(Sender: TObject);
    procedure LockToggleActionExecute(Sender: TObject);
    procedure NodeLabelClick(Sender: TObject);
    procedure ReceiveItemClick(Sender: TObject);
    procedure SendItemClick(Sender: TObject);
    procedure SettingsItemClick(Sender: TObject);
    procedure WalletItemClick(Sender: TObject);
  private
    FActionsLocked: Boolean;
    { Private declarations }
    FDisplayedFrame: TDisplayedFrame;
    FLastDisplayedFrame: TDisplayedFrame;

    FWalletInfoFrame: TFrameInfo<TWalletFrame>;
    FSettingsInfoFrame: TFrameInfo<TSettingsFrame>;
    FKeysInfoFrame: TFrameInfo<TKeysFrame>;
    FUnlockInfoFrame: TFrameInfo<TUnlockFrame>;
    FReceiveFrameInfo: TFrameInfo<TReceiveFrame>;
    FSendFrameInfo: TFrameInfo<TSendFrame>;
    procedure CloseDisplayedFrame(const LoadLast: Boolean);

    function GetKeysFrame: TFrameInfo<TKeysFrame>;
    function GetWalletFrame: TFrameInfo<TWalletFrame>;
    function GetSettingsFrame: TFrameInfo<TSettingsFrame>;
    function GetReceiveFrame: TFrameInfo<TReceiveFrame>;
    function GetSendFrame: TFrameInfo<TSendFrame>;

    procedure ShowKeys;
    procedure ShowWallet;
    procedure ShowSettings;
    procedure ShowReceive;
    procedure ShowSend;
    procedure WriteToStatusBar(const Value: string);

    function UnlockWallet: Boolean;

    procedure OnLockChange(const ALockState: Boolean);
    procedure OnNodeChange(NodeRec: TStringPair;
      NodeStatus: IPascalCoinNodeStatus);
    procedure OnInitComplete(Sender: TObject);
    procedure OnBalanceChange(const Value: Currency);
    procedure LockAllActions;
    procedure UnlockAllActions;

  public
    { Public declarations }

    property Wallet: TFrameInfo<TWalletFrame> read GetWalletFrame;
    property Settings: TFrameInfo<TSettingsFrame> read GetSettingsFrame;
    property Receive: TFrameInfo<TReceiveFrame> read GetReceiveFrame;
    property Send: TFrameInfo<TSendFrame> read GetSendFrame;
    property Keys: TFrameInfo<TKeysFrame> read GetKeysFrame;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses FMX.DialogService,
  PascalCoin.FMX.DataModule, PascalCoin.FMX.Frame.Base, PascalCoin.FMX.Strings;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  MainDataModule.Wallet.OnLockChange.Remove(OnLockChange);
end;

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

function TMainForm.GetReceiveFrame: TFrameInfo<TReceiveFrame>;
begin
  if FReceiveFrameInfo = nil then
  begin
    FReceiveFrameInfo := FrameStand1.New<TReceiveFrame>(ContentLayout);
    FReceiveFrameInfo.Frame.OnStatusBarWrite := WriteToStatusBar;
    FReceiveFrameInfo.Frame.InitialiseFrame;
  end;
  result := FReceiveFrameInfo;
end;

function TMainForm.GetSendFrame: TFrameInfo<TSendFrame>;
begin
  if not Assigned(FSendFrameInfo) then
  begin
    FSendFrameInfo := FrameStand1.New<TSendFrame>(ContentLayout);
    FSendFrameInfo.Frame.OnStatusBarWrite := WriteToStatusBar;
    FSendFrameInfo.Frame.InitialiseFrame;
  end;
  result := FSendFrameInfo;
end;

function TMainForm.GetSettingsFrame: TFrameInfo<TSettingsFrame>;
begin
  if not Assigned(FSettingsInfoFrame) then
  begin
    FSettingsInfoFrame := FrameStand1.New<TSettingsFrame>(ContentLayout);
    FSettingsInfoFrame.Frame.OnStatusBarWrite := WriteToStatusBar;
    FSettingsInfoFrame.Frame.InitialiseFrame;
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

  LockAllActions;
  NodeLabel.Text := 'connecting...';
  FDisplayedFrame := dfNone;
  FLastDisplayedFrame := dfNone;
  MainDataModule.Wallet.OnLockChange.Add(OnLockChange);
  MainDataModule.OnNodeChange.Add(OnNodeChange);
  MainDataModule.OnInitComplete.Add(OnInitComplete);
  MainDataModule.OnBalanceChangeEvent.Add(OnBalanceChange);
  ShowWallet;
end;

{ TMainForm }

procedure TMainForm.CloseDisplayedFrame(const LoadLast: Boolean);
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
      dfNone:
        ;
      dfSettings:
        ;
      dfWallet:
        ShowWallet;
      dfKeys:
        ShowKeys;
    end;
  end;

  // FLastDisplayedFrame := lDisplayed;

end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  MainDataModule.StartAccountUpdates;
end;

procedure TMainForm.KeysItemClick(Sender: TObject);
begin
  if FActionsLocked then
    Exit;
  ShowKeys;
end;

procedure TMainForm.LockAllActions;
begin
  LockToggleAction.Enabled := False;
  FActionsLocked := True;
end;

procedure TMainForm.LockToggleActionExecute(Sender: TObject);
begin

  if MainDataModule.Wallet.Locked then
  begin
    FUnlockInfoFrame := FrameStand1.New<TUnlockFrame>(self);
    FUnlockInfoFrame.Frame.OnCancel := procedure
      begin
        FUnlockInfoFrame.Hide(100,
          procedure
          begin
            FUnlockInfoFrame.Close;
            FUnlockInfoFrame := nil;
          end);
      end;

    FUnlockInfoFrame.Frame.OnOk := procedure
      var
        lPassword: string;
        lRetval: Boolean;
      begin
        lPassword := FUnlockInfoFrame.Frame.Password;

        lRetval := MainDataModule.Wallet.Unlock(lPassword);
        FUnlockInfoFrame.Hide(100,
          procedure
          begin
            FUnlockInfoFrame.Close;
            FUnlockInfoFrame := nil;
            if not lRetval then
              ShowMessage(SFailedToUnlockYourWallet);
          end);
      end;

    FUnlockInfoFrame.Show;

  end
  else
  begin
    MainDataModule.Wallet.Lock;
  end;
end;

procedure TMainForm.NodeLabelClick(Sender: TObject);
begin
  //
end;

procedure TMainForm.OnBalanceChange(const Value: Currency);
begin
  BalanceLabel.Text := CurrToStrF(Value, ffCurrency, 4);
end;

procedure TMainForm.OnInitComplete(Sender: TObject);
begin
  if MainDataModule.API.NodeAvailability = TNodeAvailability.Avaialable then
  begin
    if MainDataModule.API.IsTestNet then
      self.StyleBook := StyleBookTestNet;
    NodeLabel.Text := 'connected to ' + MainDataModule.SelectedNodeName + ' ' +
      MainDataModule.API.NodeStatus.version + ' [' +
      MainDataModule.API.CurrenNodeStatus.status_s + ']';
    NodeLabel.Hint := MainDataModule.SelectedNodeURI;
    NodeLabel.Cursor := crDefault;
    NodeLabel.TextSettings.Font.Style := [];
    NodeLabel.OnClick := nil;
    UnlockAllActions;
  end
  else
  begin
    NodeLabel.Text := 'UNABLE to connect to ' + MainDataModule.SelectedNodeName
      + ' - Click to retry';

    NodeLabel.Hint := MainDataModule.SelectedNodeURI;
    NodeLabel.Cursor := crHandPoint;
    NodeLabel.OnClick := NodeLabelClick;
    NodeLabel.TextSettings.Font.Style := [TFontStyle.fsUnderline];
    LockAllActions;
  end;

end;

procedure TMainForm.OnLockChange(const ALockState: Boolean);
begin
  if ALockState then
    LockToggleAction.Text := SUnlockWallet
  else
    LockToggleAction.Text := SLockWallet;
end;

procedure TMainForm.OnNodeChange(NodeRec: TStringPair;
NodeStatus: IPascalCoinNodeStatus);
begin
  if NodeStatus <> nil then
  begin
    NodeLabel.Text := 'Connected to ' + NodeRec.Key + ' ' + NodeStatus.status_s;
    NodeLabel.Hint := NodeRec.Value;
    if MainDataModule.API.IsTestNet then
      self.StyleBook := StyleBookTestNet;
  end
  else
  begin
    NodeLabel.Text := 'Not connected to ' + NodeRec.Key;
    NodeLabel.Hint := NodeRec.Value;
  end;
end;

procedure TMainForm.ReceiveItemClick(Sender: TObject);
begin
  if FActionsLocked then
    Exit;
  ShowReceive;
end;

procedure TMainForm.SendItemClick(Sender: TObject);
begin
  if FActionsLocked then
    Exit;
  ShowSend;
end;

procedure TMainForm.SettingsItemClick(Sender: TObject);
begin
  if FActionsLocked then
    Exit;
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

procedure TMainForm.ShowReceive;
begin
  if not MainDataModule.HasAccounts then
  begin
    ShowMessage
      ('You must have an account (PASA) before you can receive payments');
    Exit;
  end;

  if FDisplayedFrame = dfReceive then
    Exit;
  CloseDisplayedFrame(False);
  FrameTitle.Text := 'Receive PascalCoin (PASC)';
  Receive.Frame.Showing;
  Receive.Show();
  FDisplayedFrame := dfReceive;
end;

procedure TMainForm.ShowSend;
begin

  if not MainDataModule.HasAccounts then
  begin
    ShowMessage('You must have an account (PASA) before you can send payments');
    Exit;
  end;

  if FDisplayedFrame = dfSend then
    Exit;
  CloseDisplayedFrame(False);
  FrameTitle.Text := 'Send PascalCoin (PASC)';
  Send.Frame.Showing;
  Send.Show();
  FDisplayedFrame := dfSend;

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

procedure TMainForm.UnlockAllActions;
begin
  LockToggleAction.Enabled := True;
  FActionsLocked := False;
end;

function TMainForm.UnlockWallet: Boolean;
var
  lRetval: Boolean;
begin

  FUnlockInfoFrame := FrameStand1.New<TUnlockFrame>(self);
  FUnlockInfoFrame.Frame.OnCancel := procedure
    begin
      lRetval := False;
      FUnlockInfoFrame.Hide(100,
        procedure
        begin
          FUnlockInfoFrame.Close;
          FUnlockInfoFrame := nil;
        end);
    end;

  FUnlockInfoFrame.Frame.OnOk := procedure
    var
      lPassword: string;
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
  if FActionsLocked then
    Exit;
  ShowWallet;
end;

procedure TMainForm.WriteToStatusBar(const Value: string);
begin
  StatusLabel1.Text := Value;
end;

end.
