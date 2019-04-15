unit PascalCoin.RPC.Test.DM;

interface

uses
  System.SysUtils, System.Classes, Spring;

type
  TDM = class(TDataModule)
  private
    FOnURIChange: Event<TGetStrProc>;
    FURI: string;
    function GetOnURIChange: IEvent<TGetStrProc>;
    procedure SetURI(const Value: string);
    { Private declarations }
  public
    { Public declarations }

    property OnURIChange: IEvent<TGetStrProc> read GetOnURIChange;
    property URI: string read FURI write SetURI;
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TDataModule1 }

function TDM.GetOnURIChange: IEvent<TGetStrProc>;
begin
  result := FOnURIChange;
end;

procedure TDM.SetURI(const Value: string);
begin
  FURI := Value;
  FOnURIChange.Invoke(Value);
end;

end.
