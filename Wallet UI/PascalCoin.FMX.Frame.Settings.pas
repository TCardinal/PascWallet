unit PascalCoin.FMX.Frame.Settings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, System.Actions, FMX.ActnList,
  PascalCoin.FMX.Frame.Base, FMX.ListBox, FrameStand,
  PascalCoin.FMX.Frame.Settings.Node;

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
    AdvancedOptionsLayout: TLayout;
    AdvancedOptionsLabel: TLabel;
    NodesLayout: TLayout;
    NodesHeadingLayout: TLayout;
    NodesHeadingLabel: TLabel;
    NodesList: TListBox;
    ListBoxItem1: TListBoxItem;
    SettingsFrameStand: TFrameStand;
    AddNodeButton: TSpeedButton;
    MultiAccountLayout: TLayout;
    MultiAccountLabel: TLabel;
    MultiAccountSwitch: TSwitch;
    UnlockTimeLayout: TLayout;
    UnlockTimeLabel: TLabel;
    UnlockTimeCombo: TComboBox;
    SpeedButton1: TSpeedButton;
    AddNodeAction: TAction;
    SelectNodeAction: TAction;
    procedure AddNodeActionExecute(Sender: TObject);
    procedure AdvancedOptionsSwitchSwitch(Sender: TObject);
    procedure CancelActionExecute(Sender: TObject);
    procedure MultiAccountSwitchSwitch(Sender: TObject);
    procedure SaveActionExecute(Sender: TObject);
    procedure UnlockTimeComboChange(Sender: TObject);
  private
    { Private declarations }
    FNodeFrame: TFrameInfo<TEditNodeFrame>;
    procedure LoadValues;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

uses PascalCoin.FMX.DataModule, PascalCoin.FMX.Wallet.Shared,
  PascalCoin.FMX.Strings;

{ TSettingsFrame }

constructor TSettingsFrame.Create(AOwner: TComponent);
begin
  inherited;
  LoadValues;

  MultiAccountLabel.Hint := SEnablingThisWillAllowYouToAutoma;

end;

procedure TSettingsFrame.AddNodeActionExecute(Sender: TObject);
var
  lName, lURI: string;
begin
  FNodeFrame := SettingsFrameStand.New<TEditNodeFrame>(NodesList);
  FNodeFrame.Frame.OnCancel := procedure
    begin
      FNodeFrame.Hide(100,
        procedure
        begin
          FNodeFrame.Close;
          FNodeFrame := nil;
        end);
    end;

  FNodeFrame.Frame.OnOk := procedure
    begin
      lName := FNodeFrame.Frame.NodeName;
      lURI := FNodeFrame.Frame.URI;

      FNodeFrame.Hide(100,
        procedure
        begin
          FNodeFrame.Close;
          FNodeFrame := nil;
        end);
    end;

  FNodeFrame.Show;

end;

procedure TSettingsFrame.LoadValues;
var
  lNode: TNodeRecord;
  lItem: TListBoxItem;
begin
  AdvancedOptionsSwitch.OnSwitch := nil;
  AdvancedOptionsSwitch.IsChecked := MainDataModule.Settings.AdvancedOptions;
  AdvancedOptionsSwitch.OnSwitch := AdvancedOptionsSwitchSwitch;

  MultiAccountSwitch.OnSwitch := nil;
  MultiAccountSwitch.IsChecked :=
    MainDataModule.Settings.AutoMultiAccountTransactions;
  MultiAccountSwitch.OnSwitch := MultiAccountSwitchSwitch;

  UnlockTimeCombo.OnChange := nil;

  case MainDataModule.Settings.UnlockTime of
    0:
      UnlockTimeCombo.ItemIndex := 0;
    1:
      UnlockTimeCombo.ItemIndex := 1;
    10:
      UnlockTimeCombo.ItemIndex := 3;
    30:
      UnlockTimeCombo.ItemIndex := 4;
    60:
      UnlockTimeCombo.ItemIndex := 5;
  end;

  UnlockTimeCombo.OnChange := UnlockTimeComboChange;

  NodesList.BeginUpdate;
  NodesList.Clear;
  for lNode in MainDataModule.Settings.Nodes do
  begin
    lItem := TListBoxItem.Create(NodesList);
    lItem.Parent := NodesList;
    lItem.ItemData.Text := lNode.Name;
    lItem.ItemData.Detail := lNode.URI;
    if SameText(lNode.URI, MainDataModule.Settings.SelectedNodeURI) then
      lItem.ItemData.Accessory := TListBoxItemData.TAccessory.aCheckmark;
  end;
  NodesList.EndUpdate;

end;

procedure TSettingsFrame.MultiAccountSwitchSwitch(Sender: TObject);
begin
  MainDataModule.Settings.AutoMultiAccountTransactions :=
    MultiAccountSwitch.IsChecked;
end;

procedure TSettingsFrame.AdvancedOptionsSwitchSwitch(Sender: TObject);
begin
  MainDataModule.Settings.AdvancedOptions := AdvancedOptionsSwitch.IsChecked;
end;

procedure TSettingsFrame.CancelActionExecute(Sender: TObject);
begin
  LoadValues;
end;

procedure TSettingsFrame.SaveActionExecute(Sender: TObject);
begin
  MainDataModule.SaveSettings;
end;

procedure TSettingsFrame.UnlockTimeComboChange(Sender: TObject);
var
  lMinutes: Integer;
begin
  case UnlockTimeCombo.ItemIndex of
    0:
      MainDataModule.Settings.UnlockTime := 0;
    1:
      MainDataModule.Settings.UnlockTime := 1;
    2:
      MainDataModule.Settings.UnlockTime := 10;
    3:
      MainDataModule.Settings.UnlockTime := 30;
    4:
      MainDataModule.Settings.UnlockTime := 60;
  end;
end;

end.
