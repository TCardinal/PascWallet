unit PascalCoin.RawOp.Interfaces;

interface

uses PascalCoin.Wallet.Interfaces;

type

  IRawOperation = interface
    ['{24258076-FBD4-4AB0-BE47-458F7AD00CE7}']
    function GetRawData: string;
    property RawData: string read GetRawData;
  end;

  IRawOperations = interface
    ['{3850F193-355D-402E-8F69-21D35B636DA4}']
    function GetRawOperation(const Index: integer): IRawOperation;
    function GetRawData: string;

    function AddRawOperation(Value: IRawOperation): integer;
    property RawData: string read GetRawData;
    property RawOperation[const Index: integer]: IRawOperation
      read GetRawOperation;
  end;

  IRawTransactionOp = interface(IRawOperation)
    ['{0E4967FF-BB2D-4749-ABE0-B810204455DE}']
    function GetSendFrom: Cardinal;
    function GetNOp: integer;
    function GetSendTo: Cardinal;
    function GetAmount: Currency;
    function GetFee: Currency;
    function GetPayload: string;

    procedure SetSendFrom(const Value: Cardinal);
    procedure SetNOp(const Value: integer);
    procedure SetSendTo(const Value: Cardinal);
    procedure SetAmount(const Value: Currency);
    procedure SetFee(const Value: Currency);
    procedure SetPayload(const Value: string);
    procedure SetKey(Value: IPrivateKey);
    {$IFDEF UNITTEST}
    function GetKRandom: string;
    procedure SetKRandom(const Value: string);
    function TestValue(const AKey: string): string;
    {$ENDIF}

    property SendFrom: Cardinal read GetSendFrom write SetSendFrom;
    property NOp: integer read GetNOp write SetNOp;
    property SendTo: Cardinal read GetSendTo write SetSendTo;
    property Amount: Currency read GetAmount write SetAmount;
    property Fee: Currency read GetFee write SetFee;
    property Payload: string read GetPayload write SetPayload;
    property Key: IPrivateKey write SetKey;
    {$IFDEF UNITTEST}
    property KRandom: string read GetKRandom write SetKRandom;
    {$ENDIF}
  end;

implementation

end.
