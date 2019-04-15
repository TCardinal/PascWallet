unit PascalCoin.HTTPClient.Delphi;

interface

uses System.Classes, System.Net.HTTPClient, PascalCoin.RPC.Interfaces;

type

  TDelphiHTTP = class(TInterfacedObject, IRPCHTTPRequest)
  private
    FHTTP: THTTPClient;
    FResponse: IHTTPResponse;
    FStatusCode: Integer;
    FStatusText: string;
    FStatusType: THTTPStatusType;
  protected
    function GetResponseStr: string;
    function GetStatusCode: Integer;
    function GetStatusText: string;
    function GetStatusType: THTTPStatusType;

    procedure Clear;
    function Post(AURL: string; AData: string): boolean;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils;

{ TDelphiHTTP }

procedure TDelphiHTTP.Clear;
begin
  FResponse := nil;
  FStatusCode := -1;
  FStatusText := '';
end;

constructor TDelphiHTTP.Create;
begin
  inherited Create;
  FHTTP := THTTPClient.Create;
end;

destructor TDelphiHTTP.Destroy;
begin
  FHTTP.Free;
  inherited;
end;

function TDelphiHTTP.GetResponseStr: string;
begin
  result := FResponse.ContentAsString;
end;

function TDelphiHTTP.GetStatusCode: Integer;
begin
  result := FStatusCode;
end;

function TDelphiHTTP.GetStatusText: string;
begin
  result := FStatusText;
end;

function TDelphiHTTP.GetStatusType: THTTPStatusType;
begin
  result := FStatusType;
end;

function TDelphiHTTP.Post(AURL, AData: string): boolean;
var
  lStream: TStringStream;
begin
  FStatusText := '';
  lStream := TStringStream.Create(AData);
  try
    lStream.Position := 0;
    try
      FResponse := FHTTP.Post(AURL, lStream);
      FStatusCode := FResponse.StatusCode;

      result := (FResponse.StatusCode >= 200) AND (FResponse.StatusCode <= 299);
      if result then
        FStatusType := THTTPStatusType.OK
      else
      begin
        FStatusType := THTTPStatusType.Fail;
        try
          FStatusText := FResponse.StatusText;
        except
        end;
      end;
    except
      on E: Exception do
      begin
        FStatusType := THTTPStatusType.Exception;
        FStatusText := E.ClassName + ':' + E.Message;
        result := False;
      end;
    end;
  finally
    lStream.Free;
  end;
end;

end.
