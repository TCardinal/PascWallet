unit PascalCoin.Test.Wallet;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, PascalCoin.Wallet.Interfaces, FMX.Layouts,
  FMX.ListBox, FMX.ScrollBox, FMX.Memo, FMX.Edit;

type
  TWalletFrame = class(TFrame)
    LoadButton: TButton;
    ListBox1: TListBox;
    Memo1: TMemo;
    PastedKeyEdit: TEdit;
    KeyCompareLabel: TLabel;
    ExportedKeyEdit: TEdit;
    ScrollBox1: TScrollBox;
    Layout1: TLayout;
    StateLabel: TLabel;
    procedure ListBox1ItemClick(const Sender: TCustomListBox; const Item:
        TListBoxItem);
    procedure LoadButtonClick(Sender: TObject);
    procedure PastedKeyEditChange(Sender: TObject);
  private
    FWallet: IWallet;
    procedure CompareExports;
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses PascalCoin.Wallet.Classes,
  PascalCoin.RPC.Interfaces, PascalCoin.RPC.Test.DM, Spring.Container;

procedure TWalletFrame.CompareExports;
begin
  if (ExportedKeyEdit.Text = '') or (PastedKeyEdit.Text = '') then
  begin
    KeyCompareLabel.Text := 'nothing to compare';
  end;

  if (ExportedKeyEdit.Text = PastedKeyEdit.Text) then
     KeyCompareLabel.Text := 'the keys are the same'
  else
     KeyCompareLabel.Text := 'the keys are different';

end;

procedure TWalletFrame.ListBox1ItemClick(const Sender: TCustomListBox; const
    Item: TListBoxItem);
var lKey: IWalletKey;
    lAPI: IPascalCoinAPI;
    lAccounts: IPascalCoinAccounts;
    I: Integer;
begin
  Memo1.Lines.Clear;
  lKey := FWallet[Item.Index];

  Memo1.Lines.Add('=== Key Name ===');
  Memo1.Lines.Add(lKey.Name);
  Memo1.Lines.Add('');
  Memo1.Lines.Add('=== Key Type ===');
  Memo1.Lines.Add(lKey.PublicKey.KeyTypeAsStr);
  Memo1.Lines.Add('');
  Memo1.Lines.Add('=== Public As Hex ===');
  Memo1.Lines.Add(lKey.PublicKey.AsHexStr);
  Memo1.Lines.Add('');
  ExportedKeyEdit.Text := lKey.PublicKey.AsBase58;
  Memo1.Lines.Add('=== Public As Base58 ===');
  Memo1.Lines.Add(ExportedKeyEdit.Text);

  lAPI := GlobalContainer.Resolve<IPascalCoinAPI>.URI(DM.URI);
  Memo1.Lines.Add('');

  try

  Memo1.Lines.Add('Number of Accounts: ' + lAPI.getwalletaccountscount(lKey.PublicKey.AsBase58, TKeyStyle.ksB58Key).ToString);
  Memo1.Lines.Add('');

  lAccounts := lAPI.getwalletaccounts(lKey.PublicKey.AsBase58, TKeyStyle.ksB58Key);
  for I := 0 to lAccounts.Count - 1 do
  begin
    Memo1.Lines.Add(
      lAccounts[I].account.ToString + ': ' + lAccounts[I].enc_pubkey);
  end;
  Except
   on e: exception do
     Memo1.Lines.Add(e.Message);

  end;



  CompareExports;

end;

procedure TWalletFrame.LoadButtonClick(Sender: TObject);
const
cState: array[TEncryptionState] of string = ('Plain Text', 'Encrypted', 'Decrypted');
var
  I: Integer;
begin
  FWallet := Nil;
  FWallet := GlobalContainer.Resolve<IWallet>;

  ListBox1.Clear;
  StateLabel.Text := cState[FWallet.State];

  for I := 0 to FWallet.Count -1  do
  begin
    ListBox1.Items.Add(FWallet[I].Name + ' (' + cState[FWallet[1].State] + ')');
  end;

end;

procedure TWalletFrame.PastedKeyEditChange(Sender: TObject);
begin
  CompareExports;
end;

end.
