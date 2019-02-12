unit PascalCoin.FMX.Frame.Wallet;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, System.Rtti, FMX.Grid.Style, FMX.Grid,
  FMX.ScrollBox, PascalCoin.FMX.Frame.Base;

type
  TWalletFrame = class(TBaseFrame)
    MainLayout: TLayout;
    MyBalanceLabel: TLabel;
    Label1: TLabel;
    WalletPanel: TPanel;
    ToolBar2: TToolBar;
    Label2: TLabel;
    AccountShow: TCheckBox;
    Grid1: TGrid;
    Column1: TColumn;
    Column2: TColumn;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure InitialiseFrame; override;
    procedure Showing; override;
    procedure Hiding; override;
  end;

implementation

{$R *.fmx}

{ TWalletFrame }

procedure TWalletFrame.Hiding;
begin
  inherited;

end;

procedure TWalletFrame.InitialiseFrame;
begin
  inherited;

end;

procedure TWalletFrame.Showing;
begin
  inherited;

end;

end.
