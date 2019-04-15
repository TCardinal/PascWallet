unit PascalCoin.RPC.Test.Account;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation, FMX.Edit, PascalCoin.RPC.Interfaces;

type
  TAccountFrame = class(TFrame)
    Layout1: TLayout;
    AcctNum: TEdit;
    Label1: TLabel;
    Button1: TButton;
    ListBox1: TListBox;
    PubKeyCopy: TButton;
    procedure Button1Click(Sender: TObject);
    procedure PubKeyCopyClick(Sender: TObject);
  private
     FAccount: IPascalCoinAccount;
    { Private declarations }
    function AccountNumber: Integer;
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses FMX.Platform, FMX.Surfaces, Spring.Container, PascalCoin.RPC.Test.DM;

function TAccountFrame.AccountNumber: Integer;
var lPos: Integer;
begin
  lPos := AcctNum.Text.IndexOf('-');
  if lPos > 0 then
     result := AcctNum.Text.Substring(0, lPos).ToInteger
  else
     result := AcctNum.Text.ToInteger;
end;

procedure TAccountFrame.Button1Click(Sender: TObject);
var lAPI: IPascalCoinAPI;
begin
  FAccount := nil;
  ListBox1.BeginUpdate;
  try
    ListBox1.Clear;
    lAPI := GlobalContainer.Resolve<IPascalCoinAPI>.URI(DM.URI);
    FAccount := lAPI.getaccount(AccountNumber);
    ListBox1.Items.Add('account : ' + FAccount.account.ToString);
    ListBox1.Items.Add('enc_pubkey : ' + FAccount.enc_pubkey);
    ListBox1.Items.Add('balance : ' + FloatToStr(FAccount.balance));
    ListBox1.Items.Add('n_operation : ' + FAccount.n_operation.ToString);
    ListBox1.Items.Add('updated_b : ' + FAccount.updated_b.ToString);
    ListBox1.Items.Add('state : ' + FAccount.state);
    ListBox1.Items.Add('locked_until_block : ' + FAccount.locked_until_block.ToString);
    ListBox1.Items.Add('price : ' + FloatToStr(FAccount.price));
    ListBox1.Items.Add('seller_account : ' + FAccount.seller_account.ToString);
    ListBox1.Items.Add('private_sale : ' + FAccount.private_sale.ToString);
    ListBox1.Items.Add('new_enc_pubkey : ' + FAccount.new_enc_pubkey);
    ListBox1.Items.Add('name : ' + FAccount.name);
    ListBox1.Items.Add('account_type : ' + FAccount.account_type.ToString);
  finally
    ListBox1.EndUpdate;
  end;
end;

procedure TAccountFrame.PubKeyCopyClick(Sender: TObject);
var
  Svc: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, Svc) then
      Svc.SetClipboard(FAccount.enc_pubkey);
end;

end.
