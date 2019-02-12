unit PascalCoin.RPC.Node;

interface

uses System.Generics.Collections,
PascalCoin.Utils.Interfaces, PascalCoin.RPC.Interfaces, System.JSON;

type

TPascalCoinNodeStatus = class(TInterfacedObject, IPascalCoinNodeStatus)
private
  FReady: Boolean;
  FReady_S: String;
  FStatus_S: String;
  FPort: Integer;
  FLocked: Boolean;
  FTimeStamp: Integer;
  FVersion: String;
  FNetProtocol: IPascalCoinNetProtocol;
  FBlocks: Integer;
  FNetStats: IPascalNetStats;
  FNdeServers: IPascalCoinList<IPascalCoinServer>;
  FSBH: String;
  FPOW: String;
  FOpenSSL: String;
  procedure LoadFromJSON(const Value: TJSONValue);
protected
  function GetReady: Boolean;
  procedure SetReady(Const Value: Boolean);
  function GetReady_S: String;
  procedure SetReady_S(Const Value: String);
  function GetStatus_S: String;
  procedure SetStatus_S(Const Value: String);
  function GetPort: Integer;
  procedure SetPort(Const Value: Integer);
  function GetLocked: Boolean;
  procedure SetLocked(Const Value: Boolean);
  function GetTimeStamp: Integer;
  procedure SetTimeStamp(Const Value: Integer);
  function GetVersion: String;
  procedure SetVersion(Const Value: String);
  function GetNetProtocol: IPascalCoinNetProtocol;
  function GetBlocks: Integer;
  procedure SetBlocks(Const Value: Integer);
  function GetNetStats: IPascalNetStats;
  function GetNodeServers: IPascalCoinList<IPascalCoinServer>;
  function GetSBH: String;
  procedure SetSBH(const Value: String);
  function GetPOW: String;
  procedure SetPOW(const Value: String);
  function GetOpenSSL: String;
  procedure SetOpenSSL(const Value: String);


  function GetTimeStampAsDateTime: TDateTime;
  procedure SetTimeStampAsDateTime(const Value: TDateTime);

public
  constructor Create(const AJSON: TJSONValue);
end;


TNetProtocol = class(TInterfacedObject, IPascalCoinNetProtocol)
private
  FVer: Integer;
  FVer_A: Integer;
protected
  function GetVer: Integer;
  procedure SetVer(const Value: Integer);
  function GetVer_A: Integer;
  procedure SetVer_A(const Value: Integer);
public
end;

TPascalCoinNetStats = class(TInterfacedObject, IPascalNetStats)
private
 FActive: Integer;
 FClients: Integer;
 FServers: Integer;
 FServers_t: Integer;
 FTotal: Integer;
 FTClients: Integer;
 FTServers: Integer;
 FBReceived: Integer;
 FBSend: Integer;
protected
   function GetActive: Integer;
   procedure SetActive(const Value: Integer);
   function GetClients: Integer;
   procedure SetClients(const Value: Integer);
   function GetServers: Integer;
   procedure SetServers(const Value: Integer);
   function GetServers_t: Integer;
   procedure SetServers_t(const Value: Integer);
   function GetTotal: Integer;
   procedure SetTotal(const Value: Integer);
   function GetTClients: Integer;
   procedure SetTClients(const Value: Integer);
   function GetTServers: Integer;
   procedure SetTServers(const Value: Integer);
   function GetBReceived: Integer;
   procedure SetBReceived(const Value: Integer);
   function GetBSend: Integer;
   procedure SetBSend(const Value: Integer);
public
end;

TPascalCoinServer = class(TInterfacedObject, IPascalCoinServer)
private
  FIP: String;
  FPort: Integer;
  FLastCon: Integer;
  FAttempts: Integer;
protected
  function GetIP: String;
  procedure SetIP(const Value: String);
  function GetPort: Integer;
  procedure SetPort(const Value: Integer);
  function GetLastCon: Integer;
  procedure SetLastCon(const Value: Integer);
  function GetAttempts: Integer;
  procedure SetAttempts(const Value: Integer);
  function GetLastConAsDateTime: TDateTime;
  procedure SetLastConAsDateTime(const Value: TDateTime);
public
end;

implementation

uses System.DateUtils, Rest.JSON, PascalCoin.Utils.Classes;

{ TPascalCoinNodeStatus }

constructor TPascalCoinNodeStatus.Create(const AJSON: TJSONValue);
begin
  inherited Create;
  FNdeServers := TPascalCoinList<IPascalCoinServer>.Create;
  if AJSON <> nil then
     LoadFromJSON(AJSON);
end;

function TPascalCoinNodeStatus.GetBlocks: Integer;
begin
  result := FBlocks;
end;

function TPascalCoinNodeStatus.GetLocked: Boolean;
begin
  result := FLocked;
end;

function TPascalCoinNodeStatus.GetNodeServers: IPascalCoinList<IPascalCoinServer>;
begin
  result := FNdeServers;
end;

function TPascalCoinNodeStatus.GetNetProtocol: IPascalCoinNetProtocol;
begin
  if FNetProtocol = nil then
     FNetProtocol := TNetProtocol.Create;
  result := FNetProtocol;
end;

function TPascalCoinNodeStatus.GetNetStats: IPascalNetStats;
begin
  result := FNetStats;
end;

function TPascalCoinNodeStatus.GetOpenSSL: String;
begin
  result := FOpenSSL;
end;

function TPascalCoinNodeStatus.GetPort: Integer;
begin
  result := FPort;
end;

function TPascalCoinNodeStatus.GetPOW: String;
begin
  result := FPOW;
end;

function TPascalCoinNodeStatus.GetReady: Boolean;
begin
  result := FReady;
end;

function TPascalCoinNodeStatus.GetReady_S: String;
begin
  result := FReady_S;
end;

function TPascalCoinNodeStatus.GetSBH: String;
begin
  result := FSBH;
end;

function TPascalCoinNodeStatus.GetStatus_S: String;
begin
  result := FStatus_S;
end;

function TPascalCoinNodeStatus.GetTimeStamp: Integer;
begin
  result := FTimeStamp;
end;

function TPascalCoinNodeStatus.GetTimeStampAsDateTime: TDateTime;
begin
  result := UnixToDateTime(FTimeStamp);
end;

function TPascalCoinNodeStatus.GetVersion: String;
begin
  result := FVersion;
end;

procedure TPascalCoinNodeStatus.LoadFromJSON(const Value: TJSONValue);
var lObj, sObj: TJSONObject;
    lArr: TJSONArray;
    lJV: TJSONValue;
    lServer: IPascalCoinServer;
begin
  lObj := (Value as TJSONObject);
  TJSON.JSONToObject(Self, lObj);
  sObj := lObj.GetValue('netprotocol') as TJSONObject;
  FNetProtocol := TJSON.JsonToObject<TNetProtocol>(sObj);
  sObj := lObj.GetValue('netstats') as TJSONObject;
  FNetStats := TJSON.JsonToObject<TPascalCoinNetStats>(sObj);
  lArr := lObj.GetValue('nodeservers') as TJSONArray;
  if Assigned(lArr) and (lArr.Count > 0) then
  begin
    for lJV in lArr do
    begin
      lServer := TJSON.JsonToObject<TPascalCoinServer>(lJV as TJSONObject);
      FNdeServers.Add(lServer)
    end;
  end;
end;

procedure TPascalCoinNodeStatus.SetBlocks(const Value: Integer);
begin
  FBlocks := Value;
end;

procedure TPascalCoinNodeStatus.SetLocked(const Value: Boolean);
begin
  FLocked := Value;
end;

procedure TPascalCoinNodeStatus.SetOpenSSL(const Value: String);
begin
  FOpenSSL := Value;
end;

procedure TPascalCoinNodeStatus.SetPort(const Value: Integer);
begin
  FPort := Value;
end;

procedure TPascalCoinNodeStatus.SetPOW(const Value: String);
begin
  FPOW := Value;
end;

procedure TPascalCoinNodeStatus.SetReady(const Value: Boolean);
begin
  FReady := Value;
end;

procedure TPascalCoinNodeStatus.SetReady_S(const Value: String);
begin
  FReady_S := Value;
end;

procedure TPascalCoinNodeStatus.SetSBH(const Value: String);
begin
  FSBH := Value;
end;

procedure TPascalCoinNodeStatus.SetStatus_S(const Value: String);
begin
  FStatus_S := Value;
end;

procedure TPascalCoinNodeStatus.SetTimeStamp(const Value: Integer);
begin
  FTimeStamp := Value;
end;

procedure TPascalCoinNodeStatus.SetTimeStampAsDateTime(const Value: TDateTime);
begin
  FTimeStamp := DateTimeToUnix(Value);
end;

procedure TPascalCoinNodeStatus.SetVersion(const Value: String);
begin
  FVersion := Value;
end;

{ TNetProtocol }

function TNetProtocol.GetVer: Integer;
begin
  result := FVer;
end;

function TNetProtocol.GetVer_A: Integer;
begin
  result := FVer_A;
end;

procedure TNetProtocol.SetVer(const Value: Integer);
begin
  FVer := Value;
end;

procedure TNetProtocol.SetVer_A(const Value: Integer);
begin
  FVer_A := Value;
end;

{ TPascalCoinServer }

function TPascalCoinServer.GetAttempts: Integer;
begin
  result := FAttempts;
end;

function TPascalCoinServer.GetIP: String;
begin
  result := FIP;
end;

function TPascalCoinServer.GetLastCon: Integer;
begin
  result := FLastCon;
end;

function TPascalCoinServer.GetLastConAsDateTime: TDateTime;
begin
  result := UnixToDateTime(FLastCon);
end;

function TPascalCoinServer.GetPort: Integer;
begin
  result := FPort;
end;

procedure TPascalCoinServer.SetAttempts(const Value: Integer);
begin
  FAttempts := Value;
end;

procedure TPascalCoinServer.SetIP(const Value: String);
begin
  FIP := Value;
end;

procedure TPascalCoinServer.SetLastCon(const Value: Integer);
begin
  FLastCon := Value;
end;

procedure TPascalCoinServer.SetLastConAsDateTime(const Value: TDateTime);
begin
  FLastCon := DateTimeToUnix(Value);
end;

procedure TPascalCoinServer.SetPort(const Value: Integer);
begin
  FPort := Value;
end;

{ TPascalCoinNetStats }

function TPascalCoinNetStats.GetActive: Integer;
begin
  result := FActive;
end;

function TPascalCoinNetStats.GetBReceived: Integer;
begin
  result := FBReceived;
end;

function TPascalCoinNetStats.GetBSend: Integer;
begin
  result := FBSend;
end;

function TPascalCoinNetStats.GetClients: Integer;
begin
  result := FClients;
end;

function TPascalCoinNetStats.GetServers: Integer;
begin
  result := FServers;
end;

function TPascalCoinNetStats.GetServers_t: Integer;
begin
  result := FServers_t;
end;

function TPascalCoinNetStats.GetTClients: Integer;
begin
  result := FTClients;
end;

function TPascalCoinNetStats.GetTotal: Integer;
begin
  result := FTotal;
end;

function TPascalCoinNetStats.GetTServers: Integer;
begin
  result := FTServers;
end;

procedure TPascalCoinNetStats.SetActive(const Value: Integer);
begin
  FActive := Value;
end;

procedure TPascalCoinNetStats.SetBReceived(const Value: Integer);
begin
  FBReceived := Value;
end;

procedure TPascalCoinNetStats.SetBSend(const Value: Integer);
begin
  FBSend := Value;
end;

procedure TPascalCoinNetStats.SetClients(const Value: Integer);
begin
  FClients := Value;
end;

procedure TPascalCoinNetStats.SetServers(const Value: Integer);
begin
  FServers := Value;
end;

procedure TPascalCoinNetStats.SetServers_t(const Value: Integer);
begin
  FServers_t := Value;
end;

procedure TPascalCoinNetStats.SetTClients(const Value: Integer);
begin
  FTClients := Value;
end;

procedure TPascalCoinNetStats.SetTotal(const Value: Integer);
begin
  FTotal := Value;
end;

procedure TPascalCoinNetStats.SetTServers(const Value: Integer);
begin
  FTServers := Value;
end;

end.
