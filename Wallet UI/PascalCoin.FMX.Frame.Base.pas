unit PascalCoin.FMX.Frame.Base;

interface

uses
  System.SysUtils, System.Types, System.Classes, System.UITypes,
  System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls;

type
  TBaseFrame = class(TFrame)
  private
    FOnStatusBarWrite: TGetStrProc;
    { Private declarations }
  protected
    procedure WriteToStatusBar(const Value: string);
  public
    { Public declarations }
    procedure InitialiseFrame; virtual;
    procedure Showing; virtual;
    procedure Hiding; virtual;

    property OnStatusBarWrite: TGetStrProc write FOnStatusBarWrite;
  end;

implementation

{$R *.fmx}
{ TBaseFrame }

procedure TBaseFrame.Hiding;
begin
  //
end;

procedure TBaseFrame.InitialiseFrame;
begin
  //
end;

procedure TBaseFrame.Showing;
begin
  //
end;

procedure TBaseFrame.WriteToStatusBar(const Value: string);
begin
  if Assigned(FOnStatusBarWrite) then
    FOnStatusBarWrite(Value);
end;

end.
