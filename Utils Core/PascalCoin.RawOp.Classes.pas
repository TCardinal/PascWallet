unit PascalCoin.RawOp.Classes;

interface

uses System.SysUtils, System.Generics.Collections, PascalCoin.Wallet.Interfaces,
  PascalCoin.Utils.Interfaces, PascalCoin.RawOp.Interfaces;

type

  TRawOperations = class(TInterfacedObject, IRawOperations)
  private
    FList: TList<IRawOperation>;
  protected
    function GetRawOperation(const Index: integer): IRawOperation;
    function GetRawData: string;
    function AddRawOperation(Value: IRawOperation): integer;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TBaseRawOp = class(TInterfacedObject, IRawOperation)
  private
  protected
    FKeyTools: IKeyTools;
    function AsHex(const Value: Cardinal): String; overload;
    function AsHex(const Value: Integer): String; overload;
    function AsHex(const Value: Currency): String; overload;
    function AsHex(const Value: String; var lLen: integer): String; overload;
    function GetRawData: String; virtual; abstract;
  public
    constructor Create(AKeyTools: IKeyTools);
  end;

  TRawTransactionOp = class(TBaseRawOp, IRawTransactionOp)
  private
    FSendFrom: Cardinal;
    FNOp: Integer;
    FSendTo: Cardinal;
    FAmount: Currency;
    FFee: Currency;
    FPayload: String;
    FKey: IPrivateKey;
    FPayloadLength: integer;
    {$IFDEF UNITTEST}
    FKRandom: string;
    FDelim: string;
    {$ENDIF UNITTEST}


    function ValueToHash: String;
    function HashValue(const Value: string): String;
    function Signature: TECDSA_Signature;
    function LenAs2ByteHex(const Value: Integer): string;
  protected
    function GetRawData: String; override;

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
    procedure SetPayload(const Value: String);
    procedure SetKey(Value: IPrivateKey);
    {$IFDEF UNITTEST}
    function GetKRandom: string;
    procedure SetKRandom(const Value: string);
    function TestValue(const AKey: string): string;
    {$ENDIF}
  public
  end;

implementation

uses clpConverters, clpEncoders;

const
Op_Transaction = 1;

{ TRawOperations }

function TRawOperations.AddRawOperation(Value: IRawOperation): integer;
begin
  Result := FList.Add(Value);
end;

constructor TRawOperations.Create;
begin
  inherited Create;
  FList := TList<IRawOperation>.Create;
end;

destructor TRawOperations.Destroy;
begin
  FList.Free;
  inherited;
end;

function TRawOperations.GetRawData: string;
var
  I: integer;
begin
  Result := THEX.Encode(TConverters.ReadUInt32AsBytesLE(FList.Count));
  for I := 0 to FList.Count - 1 do
    Result := Result + FList[I].RawData;
end;

function TRawOperations.GetRawOperation(const Index: integer): IRawOperation;
begin
  Result := FList[Index];
end;

{ TBaseRawOp }

function TBaseRawOp.AsHex(const Value: Cardinal): String;
begin
  Result := THEX.Encode(TConverters.ReadUInt32AsBytesLE(Value), True);
end;

function TBaseRawOp.AsHex(const Value: Currency): String;
var
  lVal: Int64;
begin
  lVal := Trunc(Value * 10000);
  Result := THEX.Encode(TConverters.ReadUInt64AsBytesLE(lVal), True);
end;

function TBaseRawOp.AsHex(const Value: String; var lLen: integer): String;
var
  lVal: TBytes;
begin
  lVal := TConverters.ConvertStringToBytes(Value, TEncoding.ANSI);
  lLen := Length(lVal);
  Result := THEX.Encode(lVal, True);
end;

function TBaseRawOp.AsHex(const Value: Integer): String;
begin
  Result := THEX.Encode(TConverters.ReadUInt32AsBytesLE(Value), True);
end;

constructor TBaseRawOp.Create(AKeyTools: IKeyTools);
begin
  inherited Create;
  FKeyTools := AKeyTools;
end;

{ TTransactionOp }

function TRawTransactionOp.GetAmount: Currency;
begin
  result := FAmount;
end;

function TRawTransactionOp.GetFee: Currency;
begin
  result := FFee;
end;

function TRawTransactionOp.GetNOp: integer;
begin
  result := FNOp;
end;

function TRawTransactionOp.GetPayload: string;
begin
  result := FPayload;
end;

function TRawTransactionOp.GetRawData: String;
var
  lSig: TECDSA_Signature;
begin
  lSig := Signature;

  Result := THEX.Encode(TConverters.ReadUInt32AsBytesLE(Op_Transaction)) +
            AsHex(FSendFrom) + AsHex(FNOp) + AsHex(FSendTo) +
            AsHex(FAmount) + AsHex(FFee) +
            LenAs2ByteHex(FPayloadLength) + FPayload +
            '000000000000' +
            LenAs2ByteHex(lSig.RLen) + lSig.R +
            LenAs2ByteHex(lSig.SLen) + lSig.S;
end;

function TRawTransactionOp.ValueToHash: String;
const
NullBytes = '0000';
OpType = '01';
begin
  Result := AsHex(FSendFrom) + AsHex(FNOp) + AsHex(FSendTo) + AsHex(FAmount) +
          AsHex(FFee) + FPayload +
          NullBytes + OpType;
end;

function TRawTransactionOp.GetSendFrom: Cardinal;
begin
  result := FSendFrom;
end;

function TRawTransactionOp.GetSendTo: Cardinal;
begin
  result := FSendTo;
end;

function TRawTransactionOp.HashValue(const Value: string): String;
begin
  Result := THEX.Encode(FKeyTools.ComputeSHA2_256_ToBytes(THEX.Decode(Value)));
end;

procedure TRawTransactionOp.SetAmount(const Value: Currency);
begin
  FAmount := Value;
end;

procedure TRawTransactionOp.SetFee(const Value: Currency);
begin
  FFee := Value;
end;

procedure TRawTransactionOp.SetKey(Value: IPrivateKey);
begin
  FKey := Value;
end;

{$IFDEF UNITTEST}
function TRawTransactionOp.GetKRandom: string;
begin
  result := FKRandom;
end;

procedure TRawTransactionOp.SetKRandom(const Value: string);
begin
  FKRandom := Value;
end;

function TRawTransactionOp.TestValue(const AKey: string): string;
var lKey: String;
begin
  lKey := AKey.ToUpper;

  if lKey.Equals('SENDFROM') then Result := AsHex(FSendFrom)
  else if lKey.Equals('NOP') then Result := AsHex(FNOp)
  else if lKey.Equals('SENDTO') then Result := AsHex(FSendTo)
  else if lKey.Equals('AMOUNT') then Result := AsHex(FAmount)
  else if lKey.Equals('FEE') then Result := AsHex(FFee)
  else if lKey.Equals('PAYLOADLEN') then Result := LenAs2ByteHex(FPayloadLength)
  else if lKey.Equals('VALUETOHASH') then Result := ValueToHash
  else if lKey.Equals('HASH') then Result := HashValue(ValueToHash)
  else if lKey.Equals('SIG.R') then Result := Signature.R
  else if lKey.Equals('SIG.S') then Result := Signature.S
  else if lKey.Equals('SIG.R.LEN') then Result := LenAs2ByteHex(Signature.RLen)
  else if lKey.Equals('SIG.S.LEN') then Result := LenAs2ByteHex(Signature.SLen)
  else if lKey.Equals('KEY.HEX') then Result := FKey.AsHexStr
  else if lKey.Equals('SIGNEDTX') then Result := GetRawData

  {$IFDEF UNITTEST}
  else if lKey.Equals('KRANDOM') then Result := FKRandom
  {$ENDIF}

  else result := 'N/A';
end;

{$ENDIF}

procedure TRawTransactionOp.SetNOp(const Value: integer);
begin
  FNOp := Value;
end;

procedure TRawTransactionOp.SetPayload(const Value: String);
begin
  FPayload := Value;
  FPayloadLength := Length(THEX.Decode(FPayLoad));
end;

procedure TRawTransactionOp.SetSendFrom(const Value: Cardinal);
begin
  FSendFrom := Value;
end;

procedure TRawTransactionOp.SetSendTo(const Value: Cardinal);
begin
  FSendTo := Value;
end;

function TRawTransactionOp.LenAs2ByteHex(const Value: Integer): string;
var lSLE: TBytes;
begin
  lSLE := FKeyTools.UInt32ToLittleEndianByteArrayTwoBytes(Value);
  Result := THEX.EnCode(lSLE);
end;

function TRawTransactionOp.Signature: TECDSA_Signature;
var lHash: string;
begin
  lhash := HashValue(ValueToHash);
  {$IFDEF UNITTEST}
  FKeyTools.SignOperation(FKey.AsHexStr, FKey.KeyType, lHash, Result, FKRandom);
  {$ELSE}
  FKeyTools.SignOperation(FKey, FKey.KeyType, HashValue(ValueToHash), Result);
  {$ENDIF UNITTEST}
end;


end.
