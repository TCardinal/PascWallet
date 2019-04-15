unit PascalCoin.FMX.Frame.Receive;

/// <summary>
/// <para>
/// For QRCode URL see
/// </para>
/// <para>
/// PIP-0026: a URI scheme for making PascalCoin payments.
/// </para>
/// <para>
/// <see href="https://github.com/PascalCoin/PascalCoin/blob/master/PIP/PIP-0026.md" /><br />
/// </para>
/// <para>
/// and
/// </para>
/// <para>
/// PIP-0027: E-PASA - Layer 2 Addresses:
/// </para>
/// <para>
/// <see href="https://github.com/PascalCoin/PascalCoin/blob/master/PIP/PIP-0027.md" />
/// </para>
/// </summary>
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  PascalCoin.FMX.Frame.Base, FMX.Edit, FMX.EditBox, FMX.NumberBox, FMX.ListBox,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Objects,
  PascalCoin.Wallet.Interfaces,
  PascalCoin.Utils.Interfaces;

type
  TReceiveFrame = class(TBaseFrame)
    FooterLayout: TLayout;
    MainLayout: TLayout;
    AccountLayout: TLayout;
    AccountLabel: TLabel;
    PayloadEncryptLayout: TLayout;
    PayloadEncryptLabel: TLabel;
    PayloadLayout: TLayout;
    PayloadLabel: TLabel;
    AmountLayout: TLayout;
    AmountLabel: TLabel;
    AccountNumber: TComboBox;
    Amount: TNumberBox;
    PascLabel: TLabel;
    Payload: TEdit;
    PayloadEncrypt: TComboBox;
    QRCodeLayout: TLayout;
    QRCodeImage: TImage;
    PayloadEncodeLayout: TLayout;
    PayloadEncodeLabel: TLabel;
    PayloadEncode: TComboBox;
    PayloadPasswordLayout: TLayout;
    PasswordLabel: TLabel;
    PayloadPassword: TEdit;
    PayloadAdvanced: TLayout;
    procedure AccountNumberChange(Sender: TObject);
    procedure AmountChange(Sender: TObject);
    procedure PayloadChange(Sender: TObject);
    procedure PayloadEncodeChange(Sender: TObject);
    procedure PayloadEncryptChange(Sender: TObject);
    procedure PayloadPasswordChange(Sender: TObject);
  private
    { Private declarations }
    FURI: IPascalCoinURI;
    procedure DataChanged;
    procedure UpdateQRCode;
    function CalcURI: string;
    procedure OnAdvancedOptionsChanged(const AValue: Boolean);
  public
    { Public declarations }
    constructor Create(AComponent: TComponent); override;
    destructor Destroy; override;
  end;

var
  ReceiveFrame: TReceiveFrame;

implementation

{$R *.fmx}

uses DelphiZXIngQRCode, PascalCoin.FMX.DataModule, PascalCoin.FMX.Wallet.Shared;


// 'pasc:<account>[?amount=<amount>][?label=<label>][?message=<message>]'

{ TBaseFrame1 }

function TReceiveFrame.CalcURI: string;
begin
  result := '';
  if AccountNumber.ItemIndex < 0 then
    Exit;
  result := 'pasc:' + AccountNumber.Items[AccountNumber.ItemIndex];

end;

constructor TReceiveFrame.Create(AComponent: TComponent);
var
  lPE: TPayloadEncryption;
  lPT: TPayloadEncode;
  lAccount, tAccount: string;
  sAccount: Int64;
begin
  inherited;

  MainDataModule.Settings.OnAdvancedOptionsChange.Add(OnAdvancedOptionsChanged);
  PascLabel.Text := FormatSettings.CurrencyString;
  FURI := MainDataModule.Config.Container.Resolve<IPascalCoinURI>;

  for lPE := Low(TPayloadEncryption) to High(TPayloadEncryption) do
    PayloadEncrypt.Items.Add(_PayloadEncryptText[lPE]);
  PayloadEncrypt.ItemIndex := 0;

  for lPT := Low(TPayloadEncode) to High(TPayloadEncode) do
    PayloadEncode.Items.Add(_PayloadEncodeText[lPT]);
  PayloadEncode.ItemIndex := 2;

  PayloadPasswordLayout.Visible := False;
  OnAdvancedOptionsChanged(MainDataModule.Settings.AdvancedOptions);

  sAccount := MainDataModule.AccountsDataAccountNumber.Value;
  tAccount := '';

  MainDataModule.DisableAccountData;
  try
    MainDataModule.AccountsData.First;
    while not MainDataModule.AccountsData.Eof do
    begin
      lAccount := MainDataModule.AccountsDataAccountNumChkSum.Value;
      if MainDataModule.AccountsDataAccountName.Value <> '' then
        lAccount := lAccount + ' [' + MainDataModule.AccountsDataAccountName.
          Value + ']';

      AccountNumber.Items.Add(lAccount);

      if MainDataModule.AccountsDataAccountNumber.Value = sAccount then
        tAccount := lAccount;

      MainDataModule.AccountsData.Next;
    end;
  finally
    MainDataModule.EnableAccountData;
  end;

  if tAccount <> '' then
    AccountNumber.ItemIndex := AccountNumber.Items.IndexOf(tAccount)
  else
    AccountNumber.ItemIndex := 0;

  QRCodeImage.DisableInterpolation := True;
  QRCodeImage.WrapMode := TImageWrapMode.Stretch;
  UpdateQRCode;
end;

procedure TReceiveFrame.DataChanged;
begin
  if csLoading in Self.ComponentState then
    Exit;
  UpdateQRCode;
end;

destructor TReceiveFrame.Destroy;
begin
  MainDataModule.Settings.OnAdvancedOptionsChange.Remove
    (OnAdvancedOptionsChanged);
  inherited;
end;

procedure TReceiveFrame.OnAdvancedOptionsChanged(const AValue: Boolean);
begin
  PayloadAdvanced.Visible := AValue;
end;

procedure TReceiveFrame.AccountNumberChange(Sender: TObject);
begin
  DataChanged;
end;

procedure TReceiveFrame.AmountChange(Sender: TObject);
begin
  DataChanged;
end;

procedure TReceiveFrame.PayloadChange(Sender: TObject);
begin
  DataChanged;
end;

procedure TReceiveFrame.PayloadEncodeChange(Sender: TObject);
begin
  DataChanged;
end;

procedure TReceiveFrame.PayloadEncryptChange(Sender: TObject);
begin
  PayloadPasswordLayout.Visible := TPayloadEncryption(PayloadEncrypt.ItemIndex)
    = TPayloadEncryption.Password;
  DataChanged;
end;

procedure TReceiveFrame.PayloadPasswordChange(Sender: TObject);
begin
  DataChanged;
end;

procedure TReceiveFrame.UpdateQRCode;
var
  QRC: TDelphiZXingQRCode;
  QRCodeBitmap: TBitmap;
  Row, Col: Integer;
  pixelColor: TAlphaColor;
  vBitmapData: TBitmapData;
  rSrc, rDest: TRectF;
  lAccount: string;

begin
  if AccountNumber.ItemIndex = -1 then
    Exit;

  lAccount := AccountNumber.Items[AccountNumber.ItemIndex];
  if lAccount.IndexOf(' ') > -1 then
    lAccount := lAccount.Substring(0, lAccount.IndexOf(' '));
  FURI.AccountNumber := lAccount;
  FURI.Amount := Amount.Value;
  FURI.Payload := Payload.Text;
  FURI.PayloadEncode := TPayloadEncode(PayloadEncode.ItemIndex);
  FURI.PayloadEncrypt := TPayloadEncryption(PayloadEncrypt.ItemIndex);
  FURI.Password := PayloadPassword.Text;

  QRCodeBitmap := TBitmap.Create;
  try
    QRC := TDelphiZXingQRCode.Create;
    try
      QRC.Data := FURI.URI;
      QRC.Encoding := TQRCodeEncoding.qrAuto;
      QRC.QuietZone := 4;

      QRCodeBitmap.SetSize(QRC.Columns, QRC.Rows);

      for Row := 0 to QRC.Rows - 1 do
      begin
        for Col := 0 to QRC.Columns - 1 do
        begin
          if QRC.IsBlack[Row, Col] then
            pixelColor := TAlphaColors.Black
          else
            pixelColor := TAlphaColors.White;

          if QRCodeBitmap.Map(TMapAccess.maWrite, vBitmapData) then
          begin
            try
              vBitmapData.SetPixel(Col, Row, pixelColor);
            finally
              QRCodeBitmap.Unmap(vBitmapData);
            end;
          end;
        end;
      end;

      QRCodeImage.Bitmap.SetSize(QRCodeBitmap.Width, QRCodeBitmap.Height);
      rSrc := TRectF.Create(0, 0, QRCodeBitmap.Width, QRCodeBitmap.Height);
      rDest := TRectF.Create(0, 0, QRCodeImage.Bitmap.Width,
        QRCodeImage.Bitmap.Height);

      if QRCodeImage.Bitmap.Canvas.BeginScene then
      begin
        try
          QRCodeImage.Bitmap.Canvas.Clear(TAlphaColors.White);
          QRCodeImage.Bitmap.Canvas.DrawBitmap(QRCodeBitmap, rSrc, rDest, 1);
        finally
          QRCodeImage.Bitmap.Canvas.EndScene;
        end;
      end;
    finally
      QRC.Free;
    end;

  finally
    QRCodeBitmap.Free;
  end;
end;

end.
