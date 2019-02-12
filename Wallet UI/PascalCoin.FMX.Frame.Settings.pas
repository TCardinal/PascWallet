unit PascalCoin.FMX.Frame.Settings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, System.Actions, FMX.ActnList,
  PascalCoin.FMX.Frame.Base;

type
  TSettingsFrame = class(TBaseFrame)
    ButtonLayout: TLayout;
    SaveButton: TButton;
    CancelButton: TButton;
    MainLayout: TLayout;
    ActionList: TActionList;
    SaveAction: TAction;
    CancelAction: TAction;
    AdvancedOptionsSwitch: TSwitch;
    Layout1: TLayout;
    AdvancedOptionsLabel: TLabel;
    procedure AdvancedOptionsSwitchSwitch(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

uses PascalCoin.FMX.DataModule;

{ TSettingsFrame }

constructor TSettingsFrame.Create(AOwner: TComponent);
begin
  inherited;
  AdvancedOptionsSwitch.OnSwitch := nil;
  AdvancedOptionsSwitch.IsChecked := MainDataModule.Settings.AdvancedOptions;
  AdvancedOptionsSwitch.OnSwitch := AdvancedOptionsSwitchSwitch;
end;

procedure TSettingsFrame.AdvancedOptionsSwitchSwitch(Sender: TObject);
begin
  inherited;
   MainDataModule.Settings.AdvancedOptions := AdvancedOptionsSwitch.IsChecked;
end;

procedure TSettingsFrame.SaveButtonClick(Sender: TObject);
begin
  MainDataModule.SaveSettings;
end;

end.
