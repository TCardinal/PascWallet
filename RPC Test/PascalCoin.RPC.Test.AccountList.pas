unit PascalCoin.RPC.Test.AccountList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Edit, FMX.Controls.Presentation;

type
  TAccountsList = class(TFrame)
    Layout1: TLayout;
    Label1: TLabel;
    PubKey: TEdit;
    Button1: TButton;
    ListBox1: TListBox;
    PasteButton: TButton;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure PasteButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses PascalCoin.RPC.Interfaces, Spring.Container,
FMX.Platform, FMX.Surfaces, System.Rtti, PascalCoin.RPC.Test.DM;

procedure TAccountsList.Button1Click(Sender: TObject);
var lAPI: IPascalCoinAPI;
    lAccounts: IPascalCoinAccounts;
    I: Integer;
begin
  ListBox1.BeginUpdate;
  try
    ListBox1.Clear;
    lAPI := GlobalContainer.Resolve<IPascalCoinAPI>.URI(DM.URI);

    Label2.Text := 'Number of Accounts: ' + lAPI.getwalletaccountscount(PubKey.Text, TKeyStyle.ksB58Key).ToString;
    lAccounts := lAPI.getwalletaccounts(Pubkey.Text, TKeyStyle.ksB58Key);
    for I := 0 to lAccounts.Count - 1 do
    begin
      ListBox1.Items.Add(
        lAccounts[I].account.ToString + ': ' + FloatToStr(lAccounts[I].balance));
    end;
  finally
    ListBox1.EndUpdate
  end;
end;

procedure TAccountsList.PasteButtonClick(Sender: TObject);
var
  Svc: IFMXClipboardService;
  Value: TValue;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, Svc) then
  begin
    Value := Svc.GetClipboard;
    if not Value.IsEmpty then
    begin
      if Value.IsType<string> then
      begin
        PubKey.Text := Value.ToString;
      end
    end;
  end;
end;


end.
