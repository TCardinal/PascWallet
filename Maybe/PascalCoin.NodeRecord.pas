unit PascalCoin.NodeRecord;

interface

uses PascalCoin.Wallet.Interfaces, System.Generics.Collections;

type

IPascalCoinNodeRec = interface
['{D550EB51-DB79-4C81-B485-2B4DF03D2059}']
  function GetName: string;
  procedure SetName(const Value: string);
  function GetURL: string;
  procedure SetURL(const Value: string);
  function GetNetType: TPascalCoinNetType;
  procedure SetNetType(const Value: TPascalCoinNetType);

  property Name: string read GetName write SetName;
  property URL: string read GetURL write SetURL;
  property NetType: TPascalCoinNetType read GetNetType write SetNetType;
end;

IPascalCoinNodeRecList = interface
['{75AD7A89-B00E-42BA-B71A-4BD32374FBBF}']
  function GetNode(const Index: Integer): IPascalCoinNodeRec;
  procedure Delete(const index: Integer);
  function Count: Integer;
  function Add(ANode: IPascalCoinNodeRec): Integer;
  procedure AddNode(const AName: string; const AURL: string;
     const ANetType: string);
  function NodeByURL(const AURL: string): IPascalCoinNodeRec;
  function NodeIndexByURL(const AURL: string): Integer;

  property Node[const Index: Integer]: IPascalCoinNodeRec read GetNode; default;
end;



TPascalCoinNodeRec = Class(TInterfacedObject, IPascalCoinNodeRec)
private
  FName: string;
  FURL: string;
  FNetType: TPascalCoinNetType;
protected
  function GetName: string;
  procedure SetName(const Value: string);
  function GetURL: string;
  procedure SetURL(const Value: string);
  function GetNetType: TPascalCoinNetType;
  procedure SetNetType(const Value: TPascalCoinNetType);
End;

TPascalCoinNodeRecList = class(TInterfacedObject, IPascalCoinNodeRecList)
private
  FNodes: TList<IPascalCoinNodeRec>;
protected
  function GetNode(const Index: Integer): IPascalCoinNodeRec;
  procedure Delete(const index: Integer);
  function Count: Integer;
  function Add(ANode: IPascalCoinNodeRec): Integer;
  procedure AddNode(const AName: string; const AURL: string;
     const ANetType: string);
  function NodeByURL(const AURL: string): IPascalCoinNodeRec;
  function NodeIndexByURL(const AURL: string): Integer;
public
  constructor Create;
  destructor Destroy; override;
end;

implementation

uses System.SysUtils, System.Rtti;

{ TPascalCoinNodeRec }

function TPascalCoinNodeRec.GetName: string;
begin
  result := FName;
end;

function TPascalCoinNodeRec.GetNetType: TPascalCoinNetType;
begin
  result := FNetType;
end;

function TPascalCoinNodeRec.GetURL: string;
begin
  result := FURL;
end;

procedure TPascalCoinNodeRec.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TPascalCoinNodeRec.SetNetType(const Value: TPascalCoinNetType);
begin
  FNetType := Value;
end;

procedure TPascalCoinNodeRec.SetURL(const Value: string);
begin
  FURL := Value;
end;

{ TPascalCoinNodeRecList }

function TPascalCoinNodeRecList.Add(ANode: IPascalCoinNodeRec): Integer;
begin
 //Exists?
 result := FNodes.Add(ANode);
end;

procedure TPascalCoinNodeRecList.AddNode(const AName: string; const AURL:
    string; const ANetType: string);
var lNode: IPascalCoinNodeRec;
begin
  if NodeByURL(AURL) = nil then
  begin
    lNode := TPascalCoinNodeRec.Create;
    lNode.Name := AName;
    lNode.URL := AURL;
    lNode.NetType := TRttiEnumerationType.GetValue<TPascalCoinNetType>(ANetType);
    Add(lNode);
  end;
end;

function TPascalCoinNodeRecList.Count: Integer;
begin
  result := FNodes.Count;
end;

constructor TPascalCoinNodeRecList.Create;
begin
  inherited Create;
  FNodes := TList<IPascalCoinNodeRec>.Create;
end;

procedure TPascalCoinNodeRecList.Delete(const index: Integer);
begin
  FNodes.Delete(index);
end;

destructor TPascalCoinNodeRecList.Destroy;
begin
  FNodes.Free;
  inherited;
end;

function TPascalCoinNodeRecList.GetNode(
  const Index: Integer): IPascalCoinNodeRec;
begin
  result := FNodes[index];
end;

function TPascalCoinNodeRecList.NodeByURL(
  const AURL: string): IPascalCoinNodeRec;
var lNode: IPascalCoinNodeRec;
begin
  result := nil;
  for lNode in FNodes do
  begin
    if SameText(lNode.URL, AURL) then
       Exit(lNode);
  end;

end;

function TPascalCoinNodeRecList.NodeIndexByURL(const AURL: string): Integer;
var
  I: Integer;
begin
  result := -1;
  for I := 0 to FNodes.Count - 1 do
  begin
    if SameText(FNodes[I].URL, AURL) then
    begin
      Exit(I);
    end;
  end;
end;

end.
