unit Crypto.Test;

interface
uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TCryptoTest = class(TObject) 
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
  end;

implementation

procedure TCryptoTest.Setup;
begin
end;

procedure TCryptoTest.TearDown;
begin
end;


initialization
  TDUnitX.RegisterTestFixture(TCryptoTest);
end.
