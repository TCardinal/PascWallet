unit PascalCoin.Utility.Classes;

interface

uses System.Generics.Collections, System.Classes, System.SysUtils,
PascalCoin.Utility.Interfaces;

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


end.
