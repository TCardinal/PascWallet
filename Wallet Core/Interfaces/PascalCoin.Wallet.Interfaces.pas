unit PascalCoin.Wallet.Interfaces;

interface

uses System.Classes, System.SysUtils, ClpIAsymmetricCipherKeyPair;

type

{$SCOPEDENUMS ON}
TKeyType = (SECP256K1, SECP384R1, SECP521R1, SECT283K1);
{$SCOPEDENUMS OFF}

TRawBytes = TBytes;

/// <summary>
///   current state of the wallet
/// </summary>
TEncryptionState = (
  /// <summary>
  ///   The wallet is not encrypted
  /// </summary>
  esPlainText,
  /// <summary>
  ///   The wallet is encrypted and no valid password has been entered
  /// </summary>
  esEncrypted,
  /// <summary>
  ///   The wallet is encrypted and a valid password is available
  /// </summary>
  esDecrypted);


IPublicKey = Interface;
IPrivateKey = interface;

IKeyTools = interface
['{16D43FE0-6A73-446D-A95E-2C7250C10DA4}']
 function RetrieveKeyType(AValue: Int32): TKeyType;
 function GetKeyTypeNumericValue(AKeyType: TKeyType): Int32;
 function GetPascalCoinPublicKeyAsHexString(AKeyType: TKeyType; const AXInput, AYInput: TBytes): string;
 function GetPascalCoinPublicKeyAsBase58(const APascalCoinPublicKey: string): String;
 function DecryptPascalCoinPrivateKey(const AEncryptedPascalCoinPrivateKey, APassword: string;
    out ADecryptedPascalCoinPrivateKey: TRawBytes): boolean;
 function EncryptPascalCoinPrivateKey(const APascalCoinPrivateKey, APassword: string): TRawBytes;
 function GetPascalCoinPrivateKeyAsHexString(AKeyType: TKeyType; const AInput: TRawBytes): string;
 function GetPascalCoinPrivateKeyEncryptedAsHexString(const APascalCoinPrivateKey, APassword: string): string;

 function GenerateECKeyPair(AKeyType: TKeyType): IAsymmetricCipherKeyPair;
 function GetPrivateKey(const AKeyPair: IAsymmetricCipherKeyPair): TRawBytes;
 function GetPublicKeyAffineX(const AKeyPair: IAsymmetricCipherKeyPair): TRawBytes;
 function GetPublicKeyAffineY(const AKeyPair: IAsymmetricCipherKeyPair): TRawBytes;

 function DoPascalCoinAESEncrypt(const AMessage, APassword: TRawBytes): TBytes;
 function DoPascalCoinAESDecrypt(const AEncryptedMessage, APassword: TRawBytes; out ADecryptedMessage: TRawBytes): boolean;

end;

IStreamOp = interface
['{31C56DB6-F278-44D1-97F4-CEE099597E95}']
  function ReadRawBytes(Stream: TStream; var Value: TRawBytes): Integer;
  function WriteRawBytes(Stream: TStream; const value: TRawBytes): Integer; overload;
  function ReadString(Stream: TStream; var value: String): Integer;
  function WriteAccountKey(Stream: TStream; const value: IPublicKey): Integer;
  function ReadAccountKey(Stream: TStream; var value : IPublicKey): Integer;
  function SaveStreamToRawBytes(Stream: TStream) : TRawBytes;
  procedure LoadStreamFromRawBytes(Stream: TStream; const raw : TRawBytes);
end;

IPrivateKey = Interface
['{1AD376BC-F871-4E2E-BB33-9EFF89E6D5DF}']
  function GetKey: TBytes;
  procedure SetKey(Value: TBytes);
  function GetKeyType: TKeyType;
  procedure SetKeyType(const Value: TKeyType);
  function GetAsHexStr: String;

  property Key: TBytes read GetKey write SetKey;
  property KeyType: TKeyType read GetKeyType write SetKeyType;
  property AsHexStr: String read GetAsHexStr;
End;


IPublicKey = interface
['{95FFFBCC-F067-4FFD-8103-3EEE3C68EA92}']
  function GetNID: Word;
  procedure SetNID(const Value: word);
  function GetX: TBytes;
  procedure SetX(const Value: TRawBytes);
  function GetY: TBytes;
  procedure SetY(const Value: TRawBytes);

  function GetKeyType: TKeyType;
  procedure SetKeyType(const Value: TKeyType);
  function GetKeyTypeAsStr: string;
  procedure SetKeyTypeAsStr(const Value: string);
  function GetAsHexStr: string;
  function GetAsBase58: string;

  /// <summary>
  ///   Key Type as integer. makes reading from wallet simpler
  /// </summary>
  property NID: Word read GetNID write SetNID;
  property X: TRawBytes read GetX write SetX;
  property Y: TRawBytes read GetY write SetY;
  /// <summary>
  ///   converts NID to TKeyType
  /// </summary>
  property KeyType: TKeyType read GetKeyType write SetKeyType;
  property KeyTypeAsStr: String read GetKeyTypeAsStr write SetKeyTypeAsStr;
  property AsHexStr: string read GetAsHexStr;
  property AsBase58: string read GetAsBase58;
end;


IWalletKey = interface
['{DABC9025-971C-4A59-BCAF-558C385DA379}']
  function GetName: String;
  procedure SetName(const Value: String);
  function GetPublicKey: IPublicKey;
  function GetCryptedKey: TRawBytes;
  procedure SetCryptedKey(const Value: TBytes);
  function GetState: TEncryptionState;

  function GetPrivateKey: IPrivateKey;

  Function HasPrivateKey : boolean;

  property Name : String read GetName write SetName;
  property CryptedKey: TRawBytes read GetCryptedKey write SetCryptedKey;
  property PublicKey : IPublicKey read GetPublicKey;
  property PrivateKey : IPrivateKey read GetPrivateKey;
  property State: TEncryptionState read GetState;
end;


IWallet = interface
['{A954381D-7085-46CE-82A1-87CCA6554309}']
  function GetWalletKey(const Index: Integer): IWalletKey;

  /// <summary>
  ///   Value is True if the new state is Locked
  /// </summary>
  procedure SetOnLockChange(Value: TProc<boolean>);

  function ChangePassword(const Value: string): boolean;
  function GetWalletFileName: String;
  function GetState: TEncryptionState;
  function GetLocked: Boolean;
  procedure Lock;
  function Unlock(const APassword: string): boolean;

  function AddWalletKey(Value: IWalletKey): integer;
  function Count: Integer;
  procedure SaveToStream;
  function CreateNewKey(const AKeyType: TKeyType; const AName: string): Integer;
  property Key[const Index: Integer]: IWalletKey read GetWalletKey; default;
  property State: TEncryptionState read GetState;
  property Locked: Boolean read GetLocked;
  property OnLockChange: TProc<Boolean> write SetOnLockChange;
end;


implementation

end.
