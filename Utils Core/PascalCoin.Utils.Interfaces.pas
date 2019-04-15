unit PascalCoin.Utils.Interfaces;

interface

uses System.Classes, System.SysUtils, System.Generics.Collections,
  ClpIAsymmetricCipherKeyPair;

type

  TRawBytes = TBytes;
  HexStr = string;

  TStringPair = TPair<string, string>;
  TParamPair = TPair<string, variant>;

  TECDSA_Signature = record
    R: string;
    RLen: Integer;
    S: string;
    SLen: Integer;
  end;

  TPascalOutcome = (poFalse, poTrue, poCancelled);
{$SCOPEDENUMS ON}
  TKeyType = (SECP256K1, SECP384R1, SECP521R1, SECT283K1);
  TKeyEncoding = (Base58, Hex);

  TPayloadEncryption = (
    /// <summary>
    /// Not encrypted. Will be visible for everybody
    /// </summary>
    None,
    /// <summary>
    /// Using sender Public key. Only "sender" will be able to decrypt this
    /// payload
    /// </summary>
    SendersKey,
    /// <summary>
    /// (default) : Using Public key of "target" account. Only "target" will be
    /// able to decrypt this payload
    /// </summary>
    RecipientsKey,
    /// <summary>
    /// Encrypted data using pwd param, needs password to decrypt
    /// </summary>
    Password);

  TPayloadEncode = (Hex, Base58, ASCII);
{$SCOPEDENUMS OFF}

  IPascalCoinList<T> = Interface
    ['{18B01A91-8F0E-440E-A6C2-B4B7D4ABA473}']
    function GetItem(const Index: Integer): T;
    procedure Delete(const Index: Integer);
    function Count: Integer;
    function Add(Item: T): Integer;
    procedure Clear;
    property Item[const Index: Integer]: T read GetItem; default;
  End;

  IPascalCoinTools = interface
    ['{BC2151DE-5278-4B11-AB7C-28120557E88C}']
    function IsHexaString(const Value: string): boolean;
    function AccountNumberCheckSum(const Value: Cardinal): Integer;
    function ValidAccountNumber(const Value: string): boolean;
    function SplitAccount(const Value: string; out AccountNumber: Cardinal;
      out CheckSum: Integer): boolean;
    function ValidateAccountName(const Value: string): boolean;
    function UnixToLocalDate(const Value: Integer): TDateTime;
    function StrToHex(const Value: string): string;
  end;

  IKeyTools = interface
    ['{16D43FE0-6A73-446D-A95E-2C7250C10DA4}']

    function UInt32ToLittleEndianByteArrayTwoBytes(AValue: UInt32): TBytes;
    function TwoBytesByteArrayToDec(const AValue: TBytes): Int32;

    function RetrieveKeyType(AValue: Int32): TKeyType;
    function GetKeyTypeNumericValue(AKeyType: TKeyType): Int32;
    function GetPascalCoinPublicKeyAsHexString(AKeyType: TKeyType;
      const AXInput, AYInput: TRawBytes): string;
    function GetPascalCoinPublicKeyAsBase58(const APascalCoinPublicKey
      : string): String;

    function DecryptPascalCoinPrivateKey(const AEncryptedPascalCoinPrivateKey,
      APassword: string; out ADecryptedPascalCoinPrivateKey: TRawBytes)
      : boolean;
    function EncryptPascalCoinPrivateKey(const APascalCoinPrivateKey,
      APassword: string): TRawBytes;
    function GetPascalCoinPrivateKeyAsHexString(AKeyType: TKeyType;
      const AInput: TRawBytes): string;
    function GetPascalCoinPrivateKeyEncryptedAsHexString
      (const APascalCoinPrivateKey, APassword: string): string;

    function GenerateECKeyPair(AKeyType: TKeyType): IAsymmetricCipherKeyPair;
    function GetPrivateKey(const AKeyPair: IAsymmetricCipherKeyPair): TRawBytes;
    function GetPublicKeyAffineX(const AKeyPair: IAsymmetricCipherKeyPair)
      : TRawBytes;
    function GetPublicKeyAffineY(const AKeyPair: IAsymmetricCipherKeyPair)
      : TRawBytes;

    function ComputeSHA2_256_ToBytes(const AInput: TBytes): TBytes;
    function EncryptPayloadWithPassword(const APassword,
      APayload: string): string;
    function EncryptPayloadWithPublicKey(const AKeyType: TKeyType;
      const ABase58PublicKey, APayload: string): string;

{$IFDEF UNITTEST}
    function SignOperation(const APrivateKey: string; const AKeyType: TKeyType;
      const AMessage: string; var ASignature: TECDSA_Signature;
      const K: string = ''): boolean; overload;
{$ELSE}
    function SignOperation(const APrivateKey: string; const AKeyType: TKeyType;
      const AMessage: string; var ASignature: TECDSA_Signature)
      : boolean; overload;
{$ENDIF UNITTEST}
    function SignOperation(const APrivateKey: TBytes; const AKeyType: TKeyType;
      const AMessage: string; var ASignature: TECDSA_Signature)
      : boolean; overload;

  end;

  IPascalCoinURI = interface
    ['{555F182F-0894-49E7-873A-149F37959BC1}']
    function GetAccountNumber: string;
    procedure SetAccountNumber(const Value: string);
    function GetAmount: Currency;
    procedure SetAmount(const Value: Currency);
    function GetPayload: string;
    procedure SetPayload(const Value: string);
    function GetPayLoadEncode: TPayloadEncode;
    procedure SetPayloadEncode(const Value: TPayloadEncode);
    function GetPayloadEncrypt: TPayloadEncryption;
    procedure SetPayloadEncrypt(const Value: TPayloadEncryption);
    function GetPassword: string;
    procedure SetPassword(const Value: string);

    function GetURI: string;
    procedure SetURI(const Value: string);

    property AccountNumber: string read GetAccountNumber write SetAccountNumber;
    property Amount: Currency read GetAmount write SetAmount;
    property Payload: string read GetPayload write SetPayload;
    property PayloadEncode: TPayloadEncode read GetPayLoadEncode
      write SetPayloadEncode;
    property PayloadEncrypt: TPayloadEncryption read GetPayloadEncrypt
      write SetPayloadEncrypt;
    property Password: string read GetPassword write SetPassword;
    property URI: string read GetURI write SetURI;
  end;

const

  PascalCoinEncoding = ['a' .. 'z', '0' .. '9', '!', '@', '#', '$', '%', '^',
    '&', '*', '(', ')', '-', '+', '{', '}', '[', ']', '_', ':', '`', '|', '<',
    '>', ',', '.', '?', '/', '~'];
  PascalCoinNameStart = ['a' .. 'z', '!', '@', '#', '$', '%', '^', '&', '*',
    '(', ')', '-', '+', '{', '}', '[', ']', '_', ':', '`', '|', '<', '>', ',',
    '.', '?', '/', '~'];
  PascalCoinBase58 = ['1' .. '9', 'A' .. 'H', 'J' .. 'N', 'P' .. 'Z',
    'a' .. 'k', 'm' .. 'z'];

  PayloadEncryptionCode: array [TPayloadEncryption] of Char = ('N', 'S',
    'R', 'P');
  PayloadEncryptionFullCode: array [TPayloadEncryption] of String = ('None',
    'Sender', 'Recipient', 'Password');
  PayloadEncrptRPCValue: array [TPayloadEncryption] of string = ('none',
    'sender', 'dest', 'aes');

  PayloadEncodeCode: array [TPayloadEncode] of Char = ('H', 'B', 'A');
  PayloadEncodeFullCode: array [TPayloadEncode] of String = ('Hex',
    'Base58', 'ASCII');

implementation

end.
