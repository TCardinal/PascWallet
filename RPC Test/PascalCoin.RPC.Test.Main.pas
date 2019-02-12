unit PascalCoin.RPC.Test.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, FrameStand,
  PascalCoin.RPC.Test.Account, PascalCoin.RPC.Test.AccountList,
  PascalCoin.RPC.Test.Node, PascalCoin.Test.Wallet;

type
  TForm1 = class(TForm)
    NodeSelect: TComboBox;
    Layout1: TLayout;
    NodeLabel: TLabel;
    FrameStand1: TFrameStand;
    NodeLayout: TLayout;
    ToolBar1: TToolBar;
    ContentLayout: TLayout;
    AccountButton: TButton;
    NodeURLLabel: TLabel;
    AccountListButton: TButton;
    NodeStatusButton: TButton;
    WalletButton: TButton;
    procedure AccountButtonClick(Sender: TObject);
    procedure AccountListButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NodeSelectChange(Sender: TObject);
    procedure NodeStatusButtonClick(Sender: TObject);
    procedure WalletButtonClick(Sender: TObject);
  private
    { Private declarations }
    FAccountFrame: TFrameInfo<TAccountFrame>;
    FAccountListFrame: TFrameInfo<TAccountsList>;
    FNodeStatusFrame: TFrameInfo<TNodeStatusFrame>;
    FWalletFrame: TFrameInfo<TWalletFrame>;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses PascalCoin.RPC.Shared, PascalCoin.RPC.Interfaces;

procedure TForm1.AccountButtonClick(Sender: TObject);
begin
  if not Assigned(FAccountFrame) then
     FAccountFrame := FrameStand1.New<TAccountFrame>(ContentLayout);
  FAccountFrame.Show();
end;

procedure TForm1.AccountListButtonClick(Sender: TObject);
begin
   if Not Assigned(FAccountListFrame) then
      FAccountListFrame := FrameStand1.New<TAccountsList>(ContentLayout);
   FAccountListFrame.Show();
end;

procedure TForm1.FormCreate(Sender: TObject);
var lNode: TStringPair;
begin
  NodeSelect.Items.Clear;
  for lNode in RPCConfig.NodeList do
  begin
    NodeSelect.Items.Add(lNode.Key);
  end;

  if NodeSelect.Items.Count > 0 then
     NodeSelect.ItemIndex := 0;


end;

procedure TForm1.NodeSelectChange(Sender: TObject);
begin
  RPCConfig.NodeListItemIndex := NodeSelect.ItemIndex;
  NodeURLLabel.Text := RPCConfig.NodeURL;
end;

procedure TForm1.NodeStatusButtonClick(Sender: TObject);
begin
    if not Assigned(FNodeStatusFrame) then
     FNodeStatusFrame := FrameStand1.New<TNodeStatusFrame>(ContentLayout);
  FNodeStatusFrame.Show();
end;

procedure TForm1.WalletButtonClick(Sender: TObject);
begin
  if not Assigned(FWalletFrame) then
     FWalletFrame := FrameStand1.New<TWalletFrame>(ContentLayout);
  FWalletFrame.Show;
end;

end.
