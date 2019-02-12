unit PascalCoin.Utility.Interfaces;

interface

type

IPascalCoinList<T> = Interface
['{18B01A91-8F0E-440E-A6C2-B4B7D4ABA473}']
  function GetItem(const Index: Integer): T;
  function Count: Integer;
  function Add(Item: T): Integer;
  property Item[const Index: Integer]: T read GetItem; default;
End;

implementation

end.
