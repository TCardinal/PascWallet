unit PascalCoin.FMX.Wallet.Shared;

interface

uses PascalCoin.FMX.Strings, PascalCoin.Wallet.Interfaces;

Type

TWalletAppSettings = class
private
  FAdvancedOptions: boolean;
public
  property AdvancedOptions: boolean read FAdvancedOptions write FAdvancedOptions;
end;

//TMultiCastEvent<T> = class(TInterfacedObject)
//private
//protected
//public
//  constructor Create;
//  destructor Destroy;
//end;

const

cStateText: array[TEncryptionState] of string = (statePlainText,
  stateEncrypted, stateDecrypted);

implementation

uses System.IOUtils, REST.Json;

{ TWalletAppSettings }

end.
