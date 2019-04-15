unit PascalCoin.FMX.Frame.Keys;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation,
  PascalCoin.Wallet.Interfaces,
  FMX.ScrollBox, FMX.Memo, PascalCoin.FMX.Frame.Base, System.ImageList,
  FMX.ImgList, FrameStand, PascalCoin.Frame.NewKey;

type
  TKeysFrame = class(TBaseFrame)
    Layout1: TLayout;
    StateLabel: TLabel;
    KeyListBox: TListBox;
    KeyListLayout: TLayout;
    KeyNameLabel: TLabel;
    KeyTypeLabel: TLabel;
    PublicKeyLabel: TLabel;
    KeyNameValue: TLabel;
    KeyTypeValue: TLabel;
    PublicKeyValue: TMemo;
    NameLayout: TLayout;
    KeyTypeLayout: TLayout;
    PublicKeyLayout: TLayout;
    ButtonsLayout: TLayout;
    KeyImages: TImageList;
    PasswordButton: TButton;
    NewKeyButton: TButton;
    ImportWalletButton: TButton;
    BackupWalletButton: TButton;
    KeyDeleteButton: TButton;
    ChangeKeyNameButton: TButton;
    CopyPublicKeyBtn: TButton;
    FrameStandKeys: TFrameStand;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure ChangeKeyNameButtonClick(Sender: TObject);
    procedure CopyPublicKeyBtnClick(Sender: TObject);
    procedure KeyListBoxItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure NewKeyButtonClick(Sender: TObject);
    procedure PasswordButtonClick(Sender: TObject);
  private
    FCanCopy: Boolean;
    FSelectedIndex: Integer;
    FSelectedKey: IWalletKey;
    FNewKeyInfo: TFrameInfo<TNewKeyFrame>;
    procedure CheckCopyFunction;
    procedure ChangeKeyName(const NewName: string);
    procedure SetPasswordButtonText;
    procedure SetSelectedIndex(const Value: Integer);
    procedure SetSelectedKey(const Value: IWalletKey);
    procedure UpdateSelectKeyDisplay;
    procedure OnLockChange(const ALockState: Boolean);
  protected
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex;
    property SelectedKey: IWalletKey read FSelectedKey write SetSelectedKey;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InitialiseFrame; override;
  end;

implementation

{$R *.fmx}

uses FMX.Platform, PascalCoin.FMX.DataModule, PascalCoin.ResourceStrings,
  PascalCoin.FMX.Wallet.Shared, PascalCoin.FMX.Strings, FMX.DialogService;

procedure TKeysFrame.ChangeKeyName(const NewName: string);
begin
  if NewName = '' then
  begin
    TDialogService.ShowMessage(SYouHavenTEneteredAName);
    Exit;
  end;
  if NewName = FSelectedKey.Name then
  begin
    TDialogService.ShowMessage(SThisIsTheSameAsTheExistingName);
    Exit;
  end;

  SelectedKey.Name := NewName;
  MainDataModule.Wallet.SaveToStream;
  UpdateSelectKeyDisplay;

  KeyListBox.BeginUpdate;
  KeyListBox.ListItems[FSelectedIndex].Text := FSelectedKey.Name + ' (' +
    cStateText[FSelectedKey.State] + ')';
  KeyListBox.EndUpdate;

end;

procedure TKeysFrame.ChangeKeyNameButtonClick(Sender: TObject);
var
  lNewName: string;
begin
  TDialogService.InputQuery('Rename Key', ['New Name'], [lNewName],
    procedure(const AResult: TModalResult; const AValues: array of string)
    var
      aName: string;
    begin
      if (AResult <> mrOK) or (Length(AValues) = 0) then
        Exit;
      aName := AValues[0].Trim;
      ChangeKeyName(aName);
    end);
end;

procedure TKeysFrame.CheckCopyFunction;
var
  Svc: IFMXClipboardService;
begin
  FCanCopy := TPlatformServices.Current.SupportsPlatformService
    (IFMXClipboardService, Svc);
end;

procedure TKeysFrame.CopyPublicKeyBtnClick(Sender: TObject);
var
  Svc: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, Svc)
  then
  begin
    Svc.SetClipboard(PublicKeyValue.Text);
    WriteToStatusBar(SPublicKeyCopiedToClipboard);
  end;
end;

constructor TKeysFrame.Create(AOwner: TComponent);
begin
  inherited;
  MainDataModule.Wallet.OnLockChange.Add(OnLockChange);
  CheckCopyFunction;
  ChangeKeyNameButton.Enabled := False;
  SetPasswordButtonText;
end;

destructor TKeysFrame.Destroy;
begin
  MainDataModule.Wallet.OnLockChange.Remove(OnLockChange);
  inherited;
end;

procedure TKeysFrame.Button1Click(Sender: TObject);
begin
  ShowMessage(SelectedKey.PublicKey.AsHexStr);
end;

{ TFrame1 }

procedure TKeysFrame.InitialiseFrame;
var
  I: Integer;
begin
  inherited;
  KeyListBox.Clear;
  StateLabel.Text := yourWalletIs + ' ' + cStateText
    [MainDataModule.Wallet.State];

  for I := 0 to MainDataModule.Wallet.Count - 1 do
  begin
    KeyListBox.Items.Add(MainDataModule.Wallet[I].Name + ' (' + cStateText
      [MainDataModule.Wallet[1].State] + ')');
  end;

  SelectedKey := nil;
end;

procedure TKeysFrame.KeyListBoxItemClick(const Sender: TCustomListBox;
const Item: TListBoxItem);
begin
  SelectedIndex := Item.Index;
end;

procedure TKeysFrame.NewKeyButtonClick(Sender: TObject);
begin

  FNewKeyInfo := FrameStandKeys.New<TNewKeyFrame>(KeyListLayout);
  FNewKeyInfo.Frame.OnCancel := procedure
    begin
      FNewKeyInfo.Hide(250,
        procedure
        begin
          FNewKeyInfo.Close;
          FNewKeyInfo := nil;
        end);
    end;
  FNewKeyInfo.Frame.OnCreateKey := procedure(Value: Integer)
    var
      lKey: IWalletKey;
      I: Integer;
    begin
      lKey := MainDataModule.Wallet[Value];
      I := KeyListBox.Items.Add(lKey.Name + ' (' + cStateText
        [lKey.State] + ')');
      Assert(I = Value, 'Key index doesn''t match');

      KeyListBox.ItemIndex := I;

      FNewKeyInfo.Hide(250,
        procedure
        begin
          FNewKeyInfo.Close;
          FNewKeyInfo := nil;
        end);

    end;

  FNewKeyInfo.Show();
end;

procedure TKeysFrame.OnLockChange(const ALockState: Boolean);
begin

end;

procedure TKeysFrame.PasswordButtonClick(Sender: TObject);
var
  lOk, lExit: Boolean;
  Password1, Password2: string;
  lInitialState: TEncryptionState;
begin
  if not MainDataModule.TryUnlock then
  begin
    ShowMessage(SPleaseUnlockYourWalletFirst);
    Exit;
  end;

  lOk := False;
  lExit := False;
  repeat
    TDialogService.InputQuery('New Password', ['Password', 'Repeat Password'],
      [Password1, Password2],
      procedure(const AResult: TModalResult; const AValues: array of string)
      begin
        if AResult = mrOK then
        begin
          Password1 := AValues[0];
          Password2 := AValues[1];
          if Password1 <> Password2 then
            ShowMessage('Passwords do not match')
          else if Password1.StartsWith(' ') then
            ShowMessage('Passwords cannot start with a space')
          else if Password1.EndsWith(' ') then
            ShowMessage('Passwords cannot end with a space')
          else
            lOk := True;
        end
        else
          lExit := True;
      end);
    if lExit then
      Exit;
  until lOk;

  lInitialState := MainDataModule.Wallet.State;

  if MainDataModule.Wallet.ChangePassword(Password1) then
  begin
    if lInitialState = esPlainText then
      ShowMessage(SYourWalletHasBeenEncrypted)
    else
      ShowMessage(SYourPasswordHasBeenChanged)
  end
  else
  begin
    if lInitialState = esPlainText then
      ShowMessage(SItHasBeenNotPossibleToEncryptYou)
    else
      ShowMessage(SItHasNotBeenPossibleToChangeYour)
  end;

end;

procedure TKeysFrame.SetPasswordButtonText;
begin
  case MainDataModule.Wallet.State of
    esPlainText:
      PasswordButton.Text := SSetAPassword;
    esEncrypted, esDecrypted:
      PasswordButton.Text := SChangeYourPassword;
  end;
end;

procedure TKeysFrame.SetSelectedIndex(const Value: Integer);
begin
  FSelectedIndex := Value;
  if FSelectedIndex > -1 then
    SelectedKey := MainDataModule.Wallet[FSelectedIndex]
  else
    SelectedKey := nil;
end;

procedure TKeysFrame.SetSelectedKey(const Value: IWalletKey);
begin
  FSelectedKey := Value;
  if FSelectedKey <> nil then
  begin
    UpdateSelectKeyDisplay;
    CopyPublicKeyBtn.Enabled := FCanCopy;
    ChangeKeyNameButton.Enabled := True;
    KeyDeleteButton.Enabled := True;
  end
  else
  begin
    KeyNameValue.Text := '';
    KeyTypeValue.Text := '';
    PublicKeyValue.ClearContent;
    CopyPublicKeyBtn.Enabled := False;
    ChangeKeyNameButton.Enabled := False;
    KeyDeleteButton.Enabled := False;
  end;
end;

procedure TKeysFrame.UpdateSelectKeyDisplay;
begin
  KeyNameValue.Text := SelectedKey.Name;
  KeyTypeValue.Text := SelectedKey.PublicKey.KeyTypeAsStr;
  PublicKeyValue.ClearContent;
  PublicKeyValue.Text := SelectedKey.PublicKey.AsBase58;
end;

end.
