unit PascalCoin.Frame.NewKey;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListBox, FMX.Edit, FMX.Controls.Presentation, FMX.Layouts,
  PascalCoin.Wallet.Interfaces;

type
  TNewKeyFrame = class(TFrame)
    Layout1: TLayout;
    Layout2: TLayout;
    TitleLabel: TLabel;
    Name: TLabel;
    NameEdit: TEdit;
    KeyTypeLayout: TLayout;
    Label1: TLabel;
    KeyTypeCombo: TComboBox;
    CancelButton: TButton;
    CreateButton: TButton;
    Panel1: TPanel;
    procedure CancelButtonClick(Sender: TObject);
    procedure CreateButtonClick(Sender: TObject);
  private
    FKeyIndex: Integer;
    function CreateNewKey: boolean;
    { Private declarations }
  public
    { Public declarations }
    OnCancel: TProc;
    OnCreateKey: TProc<Integer>;
    constructor Create(AComponent: TComponent); override;
    property KeyIndex: Integer read FKeyIndex;
  end;

implementation

{$R *.fmx}

uses PascalCoin.FMX.DataModule, System.Rtti;

{ TNewKeyFrame }

constructor TNewKeyFrame.Create(AComponent: TComponent);
var
  lKeyType: TKeyType;
  lName: String;
begin
  inherited;
  FKeyIndex := -1;
  for lKeyType := Low(TKeyType) to High(TKeyType) do
  begin
    lName := TRttiEnumerationType.GetName<TKeyType>(lKeyType);
    KeyTypeCombo.Items.Add(lName);
  end;
  KeyTypeCombo.ItemIndex := KeyTypeCombo.Items.IndexOf('SECP256K1');

  KeyTypeLayout.Visible := MainDataModule.Settings.AdvancedOptions;
  if not KeyTypeLayout.Visible then
     Height := Height - KeyTypeLayout.Height;


end;

procedure TNewKeyFrame.CancelButtonClick(Sender: TObject);
begin
  OnCancel;
end;

procedure TNewKeyFrame.CreateButtonClick(Sender: TObject);
begin
  if CreateNewKey then
     OnCreateKey(FKeyIndex);
end;

function TNewKeyFrame.CreateNewKey: boolean;
var lName: string;
    lKeyType: TKeyType;
begin
  result := False;
  lName := NameEdit.Text.Trim;
  if lName = '' then
  begin
    ShowMessage('Please enter a name for this key');
    Exit;
  end;
  lKeyType := TRttiEnumerationType.GetValue<TKeyType>(KeyTypeCombo.Selected.Text);
  FKeyIndex := MainDataModule.Wallet.CreateNewKey(lKeyType, lName);
  Result := KeyIndex > -1;
end;

end.
