unit PascalCoin.RPC.Test.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, FrameStand,
  PascalCoin.RPC.Test.Account, PascalCoin.RPC.Test.AccountList,
  PascalCoin.RPC.Test.Node, PascalCoin.Test.Wallet,
  PascalCoin.RPC.Test.Operations, PascalCoin.RPC.Test.RawOp,
  PascalCoin.RPC.Test.Payload, PascalCoin.RPC.Interfaces;

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
    OpsButton: TButton;
    RawOpButton: TButton;
    PayloadButton: TButton;
    procedure AccountButtonClick(Sender: TObject);
    procedure AccountListButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NodeSelectChange(Sender: TObject);
    procedure NodeStatusButtonClick(Sender: TObject);
    procedure OpsButtonClick(Sender: TObject);
    procedure PayloadButtonClick(Sender: TObject);
    procedure RawOpButtonClick(Sender: TObject);
    procedure WalletButtonClick(Sender: TObject);
  private
    { Private declarations }
    FAccountFrame: TFrameInfo<TAccountFrame>;
    FAccountListFrame: TFrameInfo<TAccountsList>;
    FNodeStatusFrame: TFrameInfo<TNodeStatusFrame>;
    FWalletFrame: TFrameInfo<TWalletFrame>;
    FOpsFrame: TFrameInfo<TOperationsFrame>;
    FRawOpFrame: TFrameInfo<TRawOpFrame>;
    FPayloadFrame: TFrameInfo<TPayloadTest>;
    FAPI: IPascalCoinAPI;
    procedure HideLastFrame;
    function GetAPI: IPascalCoinAPI;
  public
    { Public declarations }
    property API: IPascalCoinAPI read GetAPI;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses Spring.Container, PascalCoin.RPC.Test.DM;

procedure TForm1.AccountButtonClick(Sender: TObject);
begin
  HideLastFrame;
  if not Assigned(FAccountFrame) then
     FAccountFrame := FrameStand1.New<TAccountFrame>(ContentLayout);
  FAccountFrame.Show();
end;

procedure TForm1.AccountListButtonClick(Sender: TObject);
begin
  HideLastFrame;
   if Not Assigned(FAccountListFrame) then
      FAccountListFrame := FrameStand1.New<TAccountsList>(ContentLayout);
   FAccountListFrame.Show();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  NodeSelect.Items.Clear;
  NodeSelect.Items.Add('Local TestNet | http://127.0.0.1:4103');

  if NodeSelect.Items.Count > 0 then
     NodeSelect.ItemIndex := 0;


end;

function TForm1.GetAPI: IPascalCoinAPI;
begin
  if FAPI = nil then
     FAPI := GlobalContainer.Resolve<IPascalCoinAPI>;
  Result := FAPI;
end;

procedure TForm1.HideLastFrame;
begin
  if FrameStand1.LastShownFrame <> nil then
  begin
    FrameStand1.FrameInfo(FrameStand1.LastShownFrame).Hide();
  end;
end;

procedure TForm1.NodeSelectChange(Sender: TObject);
var lItem: TArray<string>;
begin
  lItem := NodeSelect.Items[NodeSelect.ItemIndex].Split(['|']);
  DM.URI := lItem[1].Trim;
  API.URI(DM.URI);
  NodeURLLabel.Text := API.nodestatus.version;
end;

procedure TForm1.NodeStatusButtonClick(Sender: TObject);
begin
  HideLastFrame;
  if not Assigned(FNodeStatusFrame) then
     FNodeStatusFrame := FrameStand1.New<TNodeStatusFrame>(ContentLayout);
  FNodeStatusFrame.Show();
end;

procedure TForm1.OpsButtonClick(Sender: TObject);
begin
  HideLastFrame;
  if not Assigned(FOpsFrame) then
     FOpsFrame := FrameStand1.New<TOperationsFrame>(ContentLayout);
  FOpsFrame.Show();
end;

procedure TForm1.PayloadButtonClick(Sender: TObject);
begin
  HideLastFrame;
  if Not Assigned(FPayloadFrame) then
     FPayLoadFrame := FrameStand1.New<TPayloadTest>(ContentLayout);
  FPayloadFrame.Show();
end;

procedure TForm1.RawOpButtonClick(Sender: TObject);
begin
  HideLastFrame;
  if not Assigned(FRawOpFrame) then
     FRawOpFrame := FrameStand1.New<TRawOpFrame>(ContentLayout);
  FRawOpFrame.Show();
end;

procedure TForm1.WalletButtonClick(Sender: TObject);
begin
  HideLastFrame;
  if not Assigned(FWalletFrame) then
     FWalletFrame := FrameStand1.New<TWalletFrame>(ContentLayout);
  FWalletFrame.Show;
end;

end.
