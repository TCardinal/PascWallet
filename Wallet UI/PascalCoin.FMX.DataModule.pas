Unit PascalCoin.FMX.DataModule;

Interface

Uses
  System.SysUtils, System.Classes, System.ImageList, FMX.ImgList,
  PascalCoin.Wallet.Interfaces, PascalCoin.FMX.Wallet.Shared, Data.DB,
  Datasnap.DBClient, Spring, PascalCoin.Update.Interfaces,
  PascalCoin.RPC.Interfaces, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  PascalCoin.Utils.Interfaces, FMX.Types;

Type

  TPascalCoinNodeChange = Procedure(NodeRec: TStringPair;
    NodeStatus: IPascalCoinNodeStatus) Of Object;

  TMainDataModule = Class(TDataModule)
    ImageList: TImageList;
    AccountsData: TFDMemTable;
    AccountsDataAccountNumber: TIntegerField;
    AccountsDataCheckSum: TIntegerField;
    AccountsDataAccountName: TStringField;
    AccountsDataBalance: TCurrencyField;
    AccountsDataAccountNumChkSum: TStringField;
    AccountsDataNOps: TIntegerField;
    AccountsDataAccountState: TStringField;
    LockTimer: TTimer;
    Procedure AccountsDataCalcFields(DataSet: TDataSet);
    Procedure DataModuleCreate(Sender: TObject);
  private
    FInitialising: boolean;
    FConfig: IPascalCoinWalletConfig;
    FAPI: IPascalCoinAPI;
    FUtils: IPascalCoinTools;
    FWallet: IWallet;
    FSettingsName: String;
    FAccountUpdate: IFetchAccountData;
    FPascBalance: Currency;
    FStoredAccount: Integer;

    FOnBalanceChangeEvent: Event<TPascalCoinCurrencyEvent>;
    FNodeChangeEvent: Event<TPascalCoinNodeChange>;
    FInitComplete: Event<TNotifyEvent>;
    FOnAccountsUpdated: Event<TNotifyEvent>;

    FSelectedNodeURI: String;
    FSelectedNodeName: String;
    FKeyTools: IKeyTools;

    Function GetWallet: IWallet;
    Procedure LoadSettings;
    Function GetPascBalance: Currency;
    Function GetBalanceChangeEvent: IEvent<TPascalCoinCurrencyEvent>;
    Procedure SetPascBalance(Const Value: Currency);
    procedure AccountsUpdated(Value: IUpdatedAccounts);
    Procedure SetNodeURI(Const Value: String);
    Function GetNodeChangeEvent: IEvent<TPascalCoinNodeChange>;
    Function GetInitCompleteEvent: IEvent<TNotifyEvent>;
    Function GetHasAccounts: boolean;
    Function GetAPI: IPascalCoinAPI;
    Function GetOnAccountsUpdated: IEvent<TNotifyEvent>;
    Procedure UnlockTimeChanged(Const Value: Integer);
    function CalcBalance: Currency;
  public
    { Public declarations }
    Settings: TWalletAppSettings;

    Procedure SaveSettings;
    Function TryUnlock: boolean;
    Procedure DisableAccountData;
    Procedure EnableAccountData;
    Procedure ResetLockTimer;

    Procedure StartAccountUpdates;

    function NewAPI(const AURI: String = ''): IPascalCoinAPI;
    procedure UpdatesPause;
    procedure UpdatesRestart;

    Property Config: IPascalCoinWalletConfig read FConfig;
    Property Wallet: IWallet read GetWallet;
    Property PascBalance: Currency read FPascBalance write SetPascBalance;
    Property NodeURI: String write SetNodeURI;
    Property SelectedNodeName: String read FSelectedNodeName;
    Property SelectedNodeURI: String read FSelectedNodeURI;
    Property HasAccounts: boolean read GetHasAccounts;
    Property Utils: IPascalCoinTools read FUtils;
    Property KeyTools: IKeyTools read FKeyTools;
    Property API: IPascalCoinAPI read GetAPI;

    Property OnBalanceChangeEvent: IEvent<TPascalCoinCurrencyEvent>
      read GetBalanceChangeEvent;
    Property OnNodeChange: IEvent<TPascalCoinNodeChange>
      read GetNodeChangeEvent;
    Property OnInitComplete: IEvent<TNotifyEvent> read GetInitCompleteEvent;
    Property OnAccountsUpdated: IEvent<TNotifyEvent> read GetOnAccountsUpdated;
  End;

Var
  MainDataModule: TMainDataModule;

Implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

Uses System.IOUtils, System.StrUtils, Rest.JSON;

{$R *.dfm}

Procedure TMainDataModule.AccountsDataCalcFields(DataSet: TDataSet);
Begin
  If DataSet.State In [dsCalcFields, dsInternalCalc] Then
  Begin
    AccountsDataAccountNumChkSum.Value := AccountsDataAccountNumber.AsString +
      '-' + AccountsDataCheckSum.AsString;
  End;
End;

Procedure TMainDataModule.DataModuleCreate(Sender: TObject);
Var
  TS: TStringList;
Begin
  FInitialising := True;

  FormatSettings.CurrencyString := 'Ƿ'; // U+01F7 &#503;
  FormatSettings.CurrencyFormat := 0;
  FormatSettings.CurrencyDecimals := 4;

  FWallet := Nil;

  AccountsData.CreateDataSet;

  FConfig := UConfig;

  FUtils := FConfig.Container.Resolve<IPascalCoinTools>;
  FKeyTools := FConfig.Container.Resolve<IKeyTools>;
  FWallet := FConfig.Container.Resolve<IWallet>;

  FSettingsName := TPath.Combine
    (TPath.GetDirectoryName(FWallet.GetWalletFileName), 'PascalCoinFMX.json');

  LoadSettings;

  FAccountUpdate := FConfig.Container.Resolve<IFetchAccountData>;
  FAccountUpdate.NodeURI := FSelectedNodeURI;
  FAccountUpdate.OnSync.Add(AccountsUpdated);
  TS := TStringList.Create;
  Try
    FWallet.PublicKeysToStrings(TS, TKeyEncoding.Base58);
    FAccountUpdate.KeyStyle := TKeyStyle.ksB58Key;
    FAccountUpdate.AddPublicKeys(TS);
  Finally
    TS.Free;
  End;


End;

Procedure TMainDataModule.DisableAccountData;
Begin
  AccountsData.DisableControls;
  FStoredAccount := AccountsDataAccountNumber.Value;
End;

Procedure TMainDataModule.EnableAccountData;
Begin
  AccountsData.Locate('AccountNumber', FStoredAccount, []);
  FStoredAccount := 0;
  AccountsData.EnableControls;
End;

Function TMainDataModule.GetAPI: IPascalCoinAPI;
Begin
  if not Assigned(FAPI)  then
  begin
     FAPI := NewAPI;
  end;
  result := FAPI;
End;

Function TMainDataModule.GetBalanceChangeEvent
  : IEvent<TPascalCoinCurrencyEvent>;
Begin
  result := FOnBalanceChangeEvent;
End;

Function TMainDataModule.GetHasAccounts: boolean;
Begin
  result := AccountsData.RecordCount > 0;
End;

Function TMainDataModule.GetInitCompleteEvent: IEvent<TNotifyEvent>;
Begin
  result := FInitComplete;
End;

Function TMainDataModule.GetNodeChangeEvent: IEvent<TPascalCoinNodeChange>;
Begin
  result := FNodeChangeEvent;
End;

Function TMainDataModule.GetOnAccountsUpdated: IEvent<TNotifyEvent>;
Begin
  result := FOnAccountsUpdated;
End;

Function TMainDataModule.GetPascBalance: Currency;
Begin
  result := FPascBalance;
End;

Function TMainDataModule.GetWallet: IWallet;
Begin
  result := FWallet;
End;

Procedure TMainDataModule.LoadSettings;
Var
  lNode: TNodeRecord;
Begin
  Settings := TWalletAppSettings.Create;
  If TFile.Exists(FSettingsName) Then
  Begin
    Settings.AsJSON := TFile.ReadAllText(FSettingsName);
  End;

  Settings.OnUnlockTimeChange.Add(UnlockTimeChanged);
  LockTimer.Interval := Settings.UnlockTime * 1000;

  If Settings.Nodes.Count = 0 Then
  Begin
{$IFDEF TESTNET}
    Settings.Nodes.Add(TNodeRecord.Create('LocalHost TestNet',
      'http://127.0.0.1:4103', 'ntTestNet'));
    Settings.SelectedNodeURI := 'http://127.0.0.1:4103';
{$ELSE}
    Settings.Nodes.Add(TNodeRecord.Create('LocalHost Live',
      'http://127.0.0.1:4003', 'ntLive'));
    Settings.SelectedNodeURI := 'http://127.0.0.1:4003';
{$ENDIF}
  End;

  NodeURI := Settings.SelectedNodeURI;

End;

function TMainDataModule.NewAPI(const AURI: String): IPascalCoinAPI;
begin
  Result := FConfig.Container.Resolve<IPascalCoinAPI>.URI(IfThen(AURI <> '', AURI, FSelectedNodeURI));
end;

Procedure TMainDataModule.ResetLockTimer;
Begin
  If Not LockTimer.Enabled Then
    Exit;
  LockTimer.Enabled := False;
  LockTimer.Enabled := True;
End;

Procedure TMainDataModule.AccountsUpdated(Value: IUpdatedAccounts);
Var
  I, lAccounts, lAccount: Integer;
  lBalance: Currency;
Begin
  lBalance := 0;

  If Value = Nil Then
  Begin
    If FInitialising Then
    Begin
      // NOT initialised so
      // FInitialising := False;
      FInitComplete.Invoke(Self);
    End;

    Exit;
  End;

  if not AccountsData.IsEmpty then
     FStoredAccount := AccountsDataAccountNumber.Value
  else
     FStoredAccount := -1;

  lAccounts := Value.Count;
  AccountsData.DisableControls;
  Try
    For I := 0 To Value.Count - 1 Do
    Begin
      lAccount := Value[I].account.account;

      If AccountsData.Locate('AccountNumber', lAccount, []) Then
      Begin
        case Value[I].Status of
         TAccountUpdateStatus.NoChange: begin
           Continue;
         end;
         TAccountUpdateStatus.Changed: AccountsData.Edit;
         TAccountUpdateStatus.Added:Continue;//?? need to trap this
         TAccountUpdateStatus.Deleted:begin
           AccountsData.Delete;
         end;
        end;

      End
      Else if Value[I].Status = TAccountUpdateStatus.Added then
      Begin
        AccountsData.Insert;
        AccountsDataAccountNumber.Value := Value[I].Account.account;
        AccountsDataCheckSum.Value := FUtils.AccountNumberCheckSum
          (Value[I].Account.account);
      End
      Else
        Continue;

      AccountsDataBalance.Value := Value[I].Account.balance;
      AccountsDataNOps.Value := Value[I].Account.n_operation;
      AccountsDataAccountState.Value := Value[I].Account.State;
      AccountsDataAccountName.Value := Value[I].Account.name;

      AccountsData.Post;
    End;

    If FInitialising Then
    Begin
      FInitialising := False;
      FInitComplete.Invoke(Self);
    End;

    FOnAccountsUpdated.Invoke(Self);

    PascBalance := CalcBalance;

    if (FStoredAccount = -1) or (Not AccountsData.Locate('AccountNumber', FStoredAccount, [])) then
       AccountsData.First;

     FStoredAccount := 0;

  Finally
    AccountsData.EnableControls;
  End;
End;

function TMainDataModule.CalcBalance: Currency;
begin
//  Result := AccountsData.Aggregates.Items[0].Value;
//  Exit;
  Result := 0;
  AccountsData.First;
  while not AccountsData.Eof do
  begin
    Result := Result + AccountsDataBalance.Value;
    AccountsData.Next;
  end;
end;

Procedure TMainDataModule.SaveSettings;
Begin
//  interfaces not supported so, we'll do it the hard way
  TFile.WriteAllText(FSettingsName, Settings.AsJSON);
End;

Procedure TMainDataModule.SetNodeURI(Const Value: String);
Var
  lNode: TNodeRecord;
Begin
  For lNode In Settings.Nodes Do
  Begin
    If SameText(lNode.URI, Value) Then
    Begin
      Settings.SelectedNodeURI := lNode.URI;
      FSelectedNodeURI := lNode.URI;
      FSelectedNodeName := lNode.name;
      FNodeChangeEvent.Invoke(TStringPair.Create(lNode.name, lNode.URI),
        API.URI(lNode.URI).CurrenNodeStatus);
    End;
  End;
End;

Procedure TMainDataModule.SetPascBalance(Const Value: Currency);
Begin
  FPascBalance := Value;
  FOnBalanceChangeEvent.Invoke(FPascBalance);
End;

Procedure TMainDataModule.StartAccountUpdates;
Begin
  If FAccountUpdate.IsRunning Then
    Exit;
  FAccountUpdate.Execute;
End;

Function TMainDataModule.TryUnlock: boolean;
Begin
  result := Not FWallet.Locked;
  If result Then
    Exit;

  If Wallet.State = esPlainText Then
    Exit(Wallet.Unlock(''));

  result := False;
End;

Procedure TMainDataModule.UnlockTimeChanged(Const Value: Integer);
Begin
  If Value = 0 Then
    LockTimer.Enabled := False;
  LockTimer.Interval := Value * 1000;
End;

procedure TMainDataModule.UpdatesPause;
begin
  FAccountUpdate.Pause := True;
end;

procedure TMainDataModule.UpdatesRestart;
begin
  FAccountUpdate.Pause := False;
end;

End.
