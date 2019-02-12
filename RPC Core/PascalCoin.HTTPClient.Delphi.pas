unit PascalCoin.HTTPClient.Delphi;

interface

uses System.Classes, System.Net.HttpClient, PascalCoin.RPC.Interfaces;

type

TDelphiHTTP = class(TInterfacedObject, IRPCHTTPRequest)
private
  FHTTP: THTTPClient;
  FResponse: IHTTPResponse;
  FStatusCode: Integer;
  FStatusText: string;
protected
  function GetResponseStr: string;
  function GetStatusCode: integer;
  function GetStatusText: string;

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

function TDelphiHTTP.GetStatusCode: integer;
begin
  result := FStatusCode;
end;

function TDelphiHTTP.GetStatusText: string;
begin
  result := FStatusText;
end;

function TDelphiHTTP.Post(AURL, AData: string): boolean;
var lStream: TStringStream;
begin
  lStream := TStringStream.Create(AData);
  try
    lStream.Position := 0;
    try
      FResponse := FHTTP.Post(AURL, lStream);
      FStatusCode := FResponse.StatusCode;
     // FStatusText := FResponse.StatusText;
      Result := (FResponse.StatusCode >= 200) AND (FResponse.StatusCode <= 299);
    except
      on E: Exception do
      begin
        Result := False;
      end;
    end;
  finally
    lStream.Free;
  end;
end;

end.
