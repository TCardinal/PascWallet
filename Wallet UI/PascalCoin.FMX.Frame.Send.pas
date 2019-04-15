unit PascalCoin.FMX.Frame.Send;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  PascalCoin.FMX.Frame.Base, FMX.EditBox, FMX.NumberBox, FMX.Edit, FMX.ListBox,
  FMX.Controls.Presentation, FMX.Layouts, PascalCoin.RPC.Interfaces,
  PascalCoin.Wallet.Interfaces;

type
  TSendFrame = class(TBaseFrame)
    MainLayout: TLayout;
    AccountLayout: TLayout;
    AccountLabel: TLabel;
    AccountNumber: TComboBox;
    PayloadLayout: TLayout;
    PayloadLabel: TLabel;
    Payload: TEdit;
    AmountLayout: TLayout;
    AmountLabel: TLabel;
    Amount: TNumberBox;
    PascLabel: TLabel;
    PayloadAdvanced: TLayout;
    PayloadEncodeLayout: TLayout;
    PayloadEncodeLabel: TLabel;
    PayloadEncode: TComboBox;
    PayloadEncryptLayout: TLayout;
    PayloadEncryptLabel: TLabel;
    PayloadEncrypt: TComboBox;
    PayloadPasswordLayout: TLayout;
    PasswordLabel: TLabel;
    PayloadPassword: TEdit;
    SendTolayout: TLayout;
    SendToLabel: TLabel;
    SendTo: TEdit;
    FooterLayout: TLayout;
    SendButton: TButton;
    FeeLayout: TLayout;
    FeeLabel: TLabel;
    Fee: TNumberBox;
    Label2: TLabel;
    procedure AccountNumberChange(Sender: TObject);
    procedure AmountChange(Sender: TObject);
    procedure SendButtonClick(Sender: TObject);
    procedure SendToChange(Sender: TObject);
  private
    { Private declarations }
    FSendFromValid: Boolean;
    FSendToValid: Boolean;
    FAmountValid: Boolean;
    FSenderAccount: Cardinal;
    FSenderCheckSum: Integer;
    FRecipientAccountNumber: Cardinal;
    FRecipientCheckSum: Integer;
    FRecipientAccount: IPascalCoinAccount;
    FAvaliableBalance: Currency;
    procedure DataChanged;
    function CheckEnoughPasc: Boolean;
    function CheckSendToValid: Boolean;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

var
  SendFrame: TSendFrame;

implementation

{$R *.fmx}

uses System.Rtti, PascalCoin.FMX.DataModule, PascalCoin.FMX.Wallet.Shared,
  PascalCoin.Utils.Interfaces, PascalCoin.FMX.Strings,
  PascalCoin.RawOp.Interfaces;

{ TSendFrame }

function TSendFrame.CheckEnoughPasc: Boolean;
begin

  if (Amount.Value > 0) and (Amount.Value > FAvaliableBalance) then
  begin
    ShowMessage
      ('The selected account doesn''t have enough PASC for this transaction');
    result := False;
  end
  else
    result := True;

end;

function TSendFrame.CheckSendToValid: Boolean;
var
  lAccount: Cardinal;
  lChkSum: Integer;
begin
  FRecipientAccountNumber := 0;
  FRecipientCheckSum := 0;

  result := MainDataModule.Utils.ValidAccountNumber(SendTo.Text);
  if not result then
  begin
    ShowMessage(STheAccountNumberIsInvalid);
    Exit;
  end;

  MainDataModule.Utils.SplitAccount(SendTo.Text, lAccount, lChkSum);

  try
    FRecipientAccount := MainDataModule.API.getaccount(lAccount);
    result := True;
    FRecipientAccountNumber := lAccount;
    FRecipientCheckSum := lChkSum;
  except
    ShowMessage('Cannot find this account in the SafeBox');
  end;
end;

constructor TSendFrame.Create(AOwner: TComponent);
var
  lPE: TPayloadEncryption;
  lPT: TPayloadEncode;
  lAccount, tAccount: string;
  sAccount: Integer;
begin
  inherited;

  PascLabel.Text := FormatSettings.CurrencyString;
  // FURI := MainDataModule.Config.Container.Resolve<IPascalCoinURI>;

  for lPE := Low(TPayloadEncryption) to High(TPayloadEncryption) do
    PayloadEncrypt.Items.Add(_PayloadEncryptText[lPE]);
  PayloadEncrypt.ItemIndex := 2;

  for lPT := Low(TPayloadEncode) to High(TPayloadEncode) do
    PayloadEncode.Items.Add(_PayloadEncodeText[lPT]);
  PayloadEncode.ItemIndex := 0;

  PayloadAdvanced.Visible := MainDataModule.Settings.AdvancedOptions;
  PayloadPasswordLayout.Visible := False;
  FeeLayout.Visible := MainDataModule.Settings.AdvancedOptions;

  sAccount := MainDataModule.AccountsDataAccountNumber.Value;
  tAccount := '';
  MainDataModule.DisableAccountData;
  try
    MainDataModule.AccountsData.First;
    while not MainDataModule.AccountsData.Eof do
    begin
      if MainDataModule.AccountsDataBalance.Value > 0 then
      begin
        lAccount := MainDataModule.AccountsDataAccountNumChkSum.Value;

        if MainDataModule.AccountsDataAccountName.Value <> '' then
          lAccount := lAccount + ' | ' +
            MainDataModule.AccountsDataAccountName.Value;
        lAccount := lAccount + ' | ' +
          CurrToStrF(MainDataModule.AccountsDataBalance.Value, ffCurrency, 4);

        AccountNumber.Items.Add(lAccount);
        if MainDataModule.AccountsDataAccountNumber.Value = sAccount then
          tAccount := lAccount;

      end;
      MainDataModule.AccountsData.Next;
    end;
  finally
    MainDataModule.EnableAccountData;
  end;

  if tAccount <> '' then
    AccountNumber.ItemIndex := AccountNumber.Items.IndexOf(tAccount)
  else
    AccountNumber.ItemIndex := 0;

end;

procedure TSendFrame.AccountNumberChange(Sender: TObject);
var
  lAccount: TArray<string>;
  lBalance: string;
begin
  FSendFromValid := (AccountNumber.ItemIndex > -1);
  if FSendFromValid then
  begin
    lAccount := AccountNumber.Selected.Text.Split(['|']);
    MainDataModule.Utils.SplitAccount(lAccount[0].Trim, FSenderAccount,
      FSenderCheckSum);

    lBalance := lAccount[length(lAccount) - 1];
    lBalance := lBalance.Substring
      (lBalance.IndexOf(FormatSettings.CurrencyString) +
      length(FormatSettings.CurrencyString)).Trim;

    FAvaliableBalance := StrToCurr(lBalance);

    FSendFromValid := CheckEnoughPasc;

  end;

  DataChanged;
end;

procedure TSendFrame.AmountChange(Sender: TObject);
begin
  FAmountValid := Amount.Value > 0;
  if FAmountValid then
    FSendFromValid := CheckEnoughPasc;

  DataChanged;
end;

procedure TSendFrame.DataChanged;
begin
  SendButton.Enabled := FSendFromValid and FAmountValid and FSendToValid;
end;

procedure TSendFrame.SendButtonClick(Sender: TObject);
var
  Ops: IRawOperations;
  Tx: IRawTransactionOp;
  Retval: IPascalCoinOperation;
  sAccount: IPascalCoinAccount;
  lWalletKey: IWalletKey;
  lPayload, lHexPayload: string;
  lEncrypt: TPayloadEncryption;
begin

  sAccount := MainDataModule.API.getaccount(FSenderAccount);

  if sAccount.balance < Amount.Value then
  begin
    ShowMessage('Not enough PASC for this');
    Exit;
  end;

  lHexPayload := MainDataModule.Utils.StrToHex(Payload.Text);
  lEncrypt := TPayloadEncryption(PayloadEncrypt.ItemIndex);

  case lEncrypt of
    TPayloadEncryption.None:
      lPayload := lHexPayload;

    TPayloadEncryption.SendersKey:
      begin
        lWalletKey := MainDataModule.Wallet.FindKey(sAccount.enc_pubkey);
        lPayload := MainDataModule.KeyTools.EncryptPayloadWithPublicKey
          (lWalletKey.KeyType, lWalletKey.PublicKey.AsBase58, lHexPayload);
      end;

    TPayloadEncryption.RecipientsKey:
      lPayload := MainDataModule.API.payloadEncryptWithPublicKey(lHexPayload,
        FRecipientAccount.enc_pubkey, TKeyStyle.ksEncKey);

    TPayloadEncryption.Password:
      lPayload := MainDataModule.KeyTools.EncryptPayloadWithPassword
        (PayloadPassword.Text, Payload.Text);
  end;

  Ops := MainDataModule.Config.Container.Resolve<IRawOperations>;

  { TODO :
    if MainDataModule.Settings.AutoMultiAccountTransactions then
    Add a trawl through accounts and create multiple transactions to create
    until the amount is reached
  }

  Tx := MainDataModule.Config.Container.Resolve<IRawTransactionOp>;

  Tx.SendFrom := FSenderAccount;
  Tx.SendTo := FRecipientAccountNumber;
  Tx.NOp := sAccount.n_operation + 1;
  Tx.Amount := Amount.Value;
  Tx.Fee := Fee.Value;

  Tx.Key := MainDataModule.Wallet.FindKey(sAccount.enc_pubkey).PrivateKey;
  Tx.Payload := lPayload;

  Ops.AddRawOperation(Tx);

  MainDataModule.UpdatesPause;
  try
    Retval := MainDataModule.API.executeoperation(Ops.RawData);
  finally
   MainDataModule.UpdatesRestart;
  end;
end;

procedure TSendFrame.SendToChange(Sender: TObject);
begin
  FSendToValid := SendTo.Text <> '';
  if FSendToValid then
    FSendToValid := CheckSendToValid;
  DataChanged;
end;

end.
