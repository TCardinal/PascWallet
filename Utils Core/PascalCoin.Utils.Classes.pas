unit PascalCoin.Utils.Classes;

interface

uses System.Generics.Collections, System.Classes, System.SysUtils,
PascalCoin.Utils.Interfaces;

Type

TPascalCoinList<T> = class(TInterfacedObject, IPascalCoinList<T>)
private
  FItems: TList<T>;
protected
  function GetItem(const Index: Integer): T;
  function Count: Integer;
  function Add(Item: T): Integer;
public
  constructor Create;
  destructor Destroy; override;
end;

TPascalCoinTools = class(TInterfacedObject, IPascalCoinTools)
private
protected
  function IsHexaString(const Value: string): Boolean;
end;
implementation

{ TPascalCoinList<T> }

function TPascalCoinList<T>.Add(Item: T): Integer;
begin
  result := FItems.Add(Item);
end;

function TPascalCoinList<T>.Count: Integer;
begin
  result := FItems.Count;
end;

constructor TPascalCoinList<T>.Create;
begin
  inherited Create;
  FItems := TList<T>.Create;
end;

destructor TPascalCoinList<T>.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TPascalCoinList<T>.GetItem(const Index: Integer): T;
begin
  result := FItems[Index];
end;

{ TPascalCoinTools }

function TPascalCoinTools.IsHexaString(const Value: string): Boolean;
var
  i : Integer;
begin
  Result := true;
  for i := Low(Value) to High(Value) do
    if (NOT (Value[i] in ['0'..'9'])) AND
       (NOT (Value[i] in ['a'..'f'])) AND
       (NOT (Value[i] in ['A'..'F'])) then begin
       Result := false;
       exit;
    end;
end;

end.
