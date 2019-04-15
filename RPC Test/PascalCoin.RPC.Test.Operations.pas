unit PascalCoin.RPC.Test.Operations;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Layouts,
  FMX.ListBox, System.Rtti, FMX.Grid.Style, FMX.Grid;

type
  TOperationsFrame = class(TFrame)
    Label1: TLabel;
    AccountNumber: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    CheckBox1: TCheckBox;
    ListBox1: TListBox;
    Layout1: TLayout;
    Layout2: TLayout;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses PascalCoin.RPC.Interfaces,PascalCoin.Utils.Interfaces,
PascalCoin.RPC.Test.DM, Spring.Container;

procedure TOperationsFrame.Button1Click(Sender: TObject);
var lAPI: IPascalCoinAPI;
    lAN: Cardinal;
    lOps: IPascalCoinList<IPascalCoinOperation>;
    lOp: IPascalCoinOperation;
    lStart: Integer;
  I: Integer;
  lTools: IPascalCoinTools;
  S: String;
begin
  if CheckBox1.IsChecked then
     lStart := -1
  else
     lStart := 0;
  lAPI :=GlobalContainer.Resolve<IPascalCoinAPI>.URI(DM.URI);
  lAN := AccountNumber.Text.ToInt64;
  lOPs := lAPI.getaccountoperations(lAN, 100, lStart);
  Memo1.ClearContent;
  Memo1.Lines.Text := lAPI.JSONResultStr;

  lTools := GlobalContainer.Resolve<IPascalCoinTools>;

  ListBox1.BeginUpdate;

  for I := 0 to lOps.Count - 1 do
  begin
    lOp := lOps[I];
    if lOp.time = 0 then
       S  := 'pending'
    else
       S := DateTimeToStr(lTools.UnixToLocalDate(lOp.Time));

    S := S + ' | ' + lOp.block.ToString + '/' + lOp.opblock.ToString;

    S := S + ' | ' + lOp.optxt;

    ListBox1.Items.Add(S);
  end;

  ListBox1.EndUpdate;
end;

end.
