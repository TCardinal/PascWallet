unit PascalCoin.FMX.Frame.Send;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, System.Actions, FMX.ActnList;

type
  TSendFrame = class(TFrame)
    ButtonLayout: TLayout;
    SaveButton: TButton;
    CancelButton: TButton;
    MainLayout: TLayout;
    ToolBar1: TToolBar;
    TitleLabel: TLabel;
    SpeedButton1: TSpeedButton;
    ActionList1: TActionList;
    SendAction: TAction;
    CancelAction: TAction;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses PascalCoin.FMX.DataModule;

end.
