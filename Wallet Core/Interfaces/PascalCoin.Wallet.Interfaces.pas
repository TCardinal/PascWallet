unit PascalCoin.Wallet.Interfaces;

interface

uses System.Classes, System.SysUtils, Spring, Spring.Container,
  PascalCoin.Utils.Interfaces;

type

  /// <summary>
  /// current state of the wallet
  /// </summary>
  TEncryptionState = (
    /// <summary>
    /// The wallet is not encrypted
    /// </summary>
    esPlainText,
    /// <summary>
    /// The wallet is encrypted and no valid password has been entered
    /// </summary>
    esEncrypted,
    /// <summary>
    /// The wallet is encrypted and a valid password is available
    /// </summary>
    esDecrypted);

  IPublicKey = Interface;
  IPrivateKey = interface;

  TPascalCoinBooleanEvent = procedure(const AValue: Boolean) of object;
  TPascalCoinCurrencyEvent = procedure(const AValue: Currency) of object;
  TPascalCoinIntegerEvent = procedure(const AValue: Integer) of object;

  IStreamOp = interface
    ['{31C56DB6-F278-44D1-97F4-CEE099597E95}']
    function ReadRawBytes(Stream: TStream; var Value: TRawBytes): Integer;
    function WriteRawBytes(Stream: TStream; const Value: TRawBytes)
      : Integer; overload;
    function ReadString(Stream: TStream; var Value: String): Integer;
    function WriteAccountKey(Stream: TStream; const Value: IPublicKey): Integer;
    function ReadAccountKey(Stream: TStream; var Value: IPublicKey): Integer;
    function SaveStreamToRawBytes(Stream: TStream): TRawBytes;
    procedure LoadStreamFromRawBytes(Stream: TStream; const raw: TRawBytes);
  end;

  IPascalCoinWalletConfig = interface
    ['{6BE2425B-3C4E-4986-9A01-1725D926820C}']
    function GetContainer: TContainer;
    procedure SetContainer(Value: TContainer);
    property Container: TContainer read GetContainer write SetContainer;
  end;

  IWallet = interface;

  IPrivateKey = Interface
    ['{1AD376BC-F871-4E2E-BB33-9EFF89E6D5DF}']
    function GetKey: TRawBytes;
    procedure SetKey(Value: TRawBytes);
    function GetKeyType: TKeyType;
    procedure SetKeyType(const Value: TKeyType);
    function GetAsHexStr: String;

    property Key: TRawBytes read GetKey write SetKey;
    property KeyType: TKeyType read GetKeyType write SetKeyType;
    property AsHexStr: String read GetAsHexStr;
  End;

  IPublicKey = interface
    ['{95FFFBCC-F067-4FFD-8103-3EEE3C68EA92}']
    function GetNID: Word;
    procedure SetNID(const Value: Word);
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
    /// Key Type as integer. makes reading from wallet simpler
    /// </summary>
    property NID: Word read GetNID write SetNID;
    property X: TRawBytes read GetX write SetX;
    property Y: TRawBytes read GetY write SetY;
    /// <summary>
    /// converts NID to TKeyType
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
    function GetKeyType: TKeyType;
    function GetPublicKey: IPublicKey;
    function GetCryptedKey: TRawBytes;
    procedure SetCryptedKey(const Value: TBytes);
    function GetState: TEncryptionState;

    function GetPrivateKey: IPrivateKey;

    Function HasPrivateKey: Boolean;

    property Name: String read GetName write SetName;
    property KeyType: TKeyType read GetKeyType;
    property CryptedKey: TRawBytes read GetCryptedKey write SetCryptedKey;
    property PublicKey: IPublicKey read GetPublicKey;
    property PrivateKey: IPrivateKey read GetPrivateKey;
    property State: TEncryptionState read GetState;
  end;

  IWallet = interface
    ['{A954381D-7085-46CE-82A1-87CCA6554309}']
    function GetWalletKey(const Index: Integer): IWalletKey;

    /// <summary>
    /// Value is True if the new state is Locked
    /// </summary>
    function GetOnLockChange: IEvent<TPascalCoinBooleanEvent>;

    function ChangePassword(const Value: string): Boolean;
    function GetWalletFileName: String;
    function GetState: TEncryptionState;
    function GetLocked: Boolean;

    /// <summary>
    /// The result is the success of the function not the state on the lock
    /// </summary>
    function Lock: Boolean;
    function Unlock(const APassword: string): Boolean;

    function AddWalletKey(Value: IWalletKey): Integer;
    function Count: Integer;
    procedure SaveToStream;
    function CreateNewKey(const AKeyType: TKeyType;
      const AName: string): Integer;

    /// <summary>
    /// adds all encoded public keys to a TStrings
    /// </summary>
    /// <param name="AEncoding">
    /// base58 or Hex
    /// </param>
    procedure PublicKeysToStrings(Value: TStrings;
      const AEncoding: TKeyEncoding);

    /// <summary>
    /// Finds a key based on a search for an encoded public key
    /// </summary>
    /// <param name="Value">
    /// encoded public key
    /// </param>
    /// <param name="AEncoding">
    /// encoding used, default is Hex
    /// </param>
    function FindKey(const Value: string;
      const AEncoding: TKeyEncoding = TKeyEncoding.Hex): IWalletKey;

    property Key[const Index: Integer]: IWalletKey read GetWalletKey; default;
    property State: TEncryptionState read GetState;
    property Locked: Boolean read GetLocked;

    /// <summary>
    /// The Value in the procedure is the current state of the wallet lock
    /// </summary>
    property OnLockChange: IEvent<TPascalCoinBooleanEvent> read GetOnLockChange;
  end;

  TPascalCoinNetType = (ntLive, ntTestNet, ntPrivate);

implementation

end.
