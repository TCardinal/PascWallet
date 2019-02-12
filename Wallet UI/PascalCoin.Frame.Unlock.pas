unit PascalCoin.Frame.Unlock;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit;

type
  TUnlockFrame = class(TFrame)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    PasswordEdit: TEdit;
    OKButton: TButton;
    CancelButton: TButton;
  private
    function GetPassword: string;
    { Private declarations }
  public
    { Public declarations }
    OnCancel: TProc;
    OnOk: TProc;
    property Password: string read GetPassword;
  end;

implementation

{$R *.fmx}

{ TUnlockFrame }

function TUnlockFrame.GetPassword: string;
begin
  result := PasswordEdit.Text;
end;

end.
