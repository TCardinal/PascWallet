Unit PascalCoin.FMX.Frame.Settings.Node;

Interface

Uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Actions, FMX.ActnList, FMX.Controls.Presentation, FMX.Layouts,
  FMX.Edit;

Type
  TEditNodeFrame = Class(TFrame)
    TitleLayout: TLayout;
    ButtonLayout: TLayout;
    Panel1: TPanel;
    Label1: TLabel;
    OKButton: TButton;
    CancelButton: TButton;
    ActionList1: TActionList;
    OKAction: TAction;
    CancelAction: TAction;
    NameLayout: TLayout;
    NameLabel: TLabel;
    NameEdit: TEdit;
    URILayout: TLayout;
    URILabel: TLabel;
    URIEdit: TEdit;
    TestButton: TSpeedButton;
    StatusLabel: TLabel;
    CheckURIAction: TAction;
    Procedure CancelActionExecute(Sender: TObject);
    Procedure OKActionExecute(Sender: TObject);
  private
    FValidatedURI: boolean;
    FOriginalName: String;
    FOriginalURI: String;
    FTestNet: boolean;
    Function ValidateNode: boolean;
    Function GetNodeName: String;
    Function GetURI: String;
    Procedure SetNodeName(Const Value: String);
    Procedure SetURI(Const Value: String);
    Function GetTestNet: boolean;
    { Private declarations }
  public
    { Public declarations }
    OnCancel: TProc;
    OnOk: TProc;
    Property NodeName: String read GetNodeName write SetNodeName;
    Property URI: String read GetURI write SetURI;
    Property TestNet: boolean read GetTestNet;
  End;

Implementation

{$R *.fmx}

Uses PascalCoin.FMX.DataModule, PascalCoin.RPC.Interfaces,
  System.RegularExpressions, FMX.DialogService, PascalCoin.FMX.Strings;

Procedure TEditNodeFrame.CancelActionExecute(Sender: TObject);
Begin
  OnCancel;
End;

Function TEditNodeFrame.ValidateNode: boolean;
resourcestring
  SurlRegex = '(https?://.*):(\d*)\/?(.*)';
var
  lAPI: IPascalCoinAPI;
Begin

  Result := False;
  if NameEdit.Text.Trim = '' then
  begin
    TDialogService.ShowMessage(SPleaseGiveThisNodeAName);
    Exit;
  end;

  Result := TRegex.IsMatch(URIEdit.Text, SurlRegex);
  if not Result then
  begin
    TDialogService.ShowMessage(STheURLEnteredIsNotValid);
    FValidatedURI := False;
    Exit;
  end;

  lAPI := MainDataModule.NewAPI(URIEdit.Text);
  if lAPI.NodeAvailability <> TNodeAvailability.Avaialable then
  begin
    TDialogService.ShowMessage('Cannot connect to this node. The error was ' + lAPI.LastError);
    FValidatedURI := False;
    Exit;
  end;

  Result := True;

End;

Function TEditNodeFrame.GetNodeName: String;
Begin
  Result := NameEdit.Text;
End;

Function TEditNodeFrame.GetTestNet: boolean;
Begin
  Result := FTestNet;
End;

Function TEditNodeFrame.GetURI: String;
Begin
  Result := URIEdit.Text;
End;

Procedure TEditNodeFrame.OKActionExecute(Sender: TObject);
Begin
  If ValidateNode Then
    OnOk;
End;

Procedure TEditNodeFrame.SetNodeName(Const Value: String);
Begin
  FOriginalName := Value;
  NameEdit.Text := Value;
End;

Procedure TEditNodeFrame.SetURI(Const Value: String);
Begin
  FOriginalURI := Value;
  URIEdit.Text := Value;
End;

End.
