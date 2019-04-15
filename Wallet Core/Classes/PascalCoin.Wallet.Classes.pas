/// <summary>
/// <para>
/// These components are for reading and writing the Wallet Keys to a
/// local file.
/// </para>
/// <para>
/// The File Structure is as follows:
/// </para>
/// <list type="table">
/// <listheader>
/// <term>Byte Length</term>
/// <description>Description</description>
/// </listheader>
/// <item>
/// <term>2</term>
/// <description><i>idLength</i>: Integer- Length of wallet
/// identifier.</description>
/// </item>
/// <item>
/// <term>idLength</term>
/// <description>Needs to match the const CT_PrivateKeyFile_Magic
/// if it is a valid wallet</description>
/// </item>
/// <item>
/// <term>4 Bytes</term>
/// <description>File Version</description>
/// </item>
/// <item>
/// <term>4 Bytes</term>
/// <description>Number of Keys</description>
/// </item>
/// <item>
/// <term>Keys</term>
/// <description>For each key:</description>
/// </item>
/// <item>
/// <term>2 Bytes</term>
/// <description><i>keyNameLength</i>: Length of Key Name</description>
/// </item>
/// <item>
/// <term>KeyNameLength</term>
/// <description>Key Name</description>
/// </item>
/// </list>
/// </summary>
unit PascalCoin.Wallet.Classes;

interface

uses System.Classes, System.Generics.Collections, System.SysUtils,
  PascalCoin.Wallet.Interfaces, PascalCoin.Utils.Interfaces, Spring;

Type

  TOnNeedPassword = procedure(const APassword: string) of object;

  TWallet = class(TInterfacedObject, IWallet)
  private
    FKeyTools: IKeyTools;
    FStreamOp: IStreamOp;
    FPassword: String;

    /// <summary>
    /// This is used to lock wallets that aren't encrypted, just a way to
    /// prevent silly mistakes - a double check
    /// </summary>
    FLocked: Boolean;
    FState: TEncryptionState;
    FWalletFileStream: TFileStream;
    FIsReadingStream: Boolean;
    // Probably better to use a TDictionary for this
    FKeys: TList<IWalletKey>;
    FFileVersion: Integer;
    FOnLockChange: Event<TPascalCoinBooleanEvent>;
    procedure LoadWallet;
    procedure LoadWalletFromStream(Stream: TStream);

  protected
    function SetPassword(const Value: string): Boolean;
    function GetWalletKey(const Index: Integer): IWalletKey;

    function GetState: TEncryptionState;
    function GetLocked: Boolean;
    function GetOnLockChange: IEvent<TPascalCoinBooleanEvent>;

    function Lock: Boolean;
    function Unlock(const APassword: string): Boolean;

    function ChangePassword(const Value: string): Boolean;

    function GetWalletFileName: String;
    function AddWalletKey(Value: IWalletKey): Integer;
    function CreateNewKey(const AKeyType: TKeyType;
      const AName: string): Integer;
    function Count: Integer;
    procedure SaveToStream;

    function FindKey(const Value: string;
      const AEncoding: TKeyEncoding = TKeyEncoding.Hex): IWalletKey;
    procedure PublicKeysToStrings(Value: TStrings;
      const AEncoding: TKeyEncoding);

    property Password: string read FPassword;
  public
    constructor Create(ATools: IKeyTools; AStreamOp: IStreamOp);
    destructor Destroy; override;

  end;

  TWalletKey = class(TInterfacedObject, IWalletKey)
  private
    FWallet: TWallet;
    FKeyTools: IKeyTools;
    FName: String;
    FPublicKey: IPublicKey;
    FCryptedKey: TRawBytes;
    FEncryptionState: TEncryptionState;
    procedure Clear;
  protected
    function GetName: String;
    procedure SetName(const Value: String);
    function GetPublicKey: IPublicKey;
    function GetCryptedKey: TRawBytes;
    procedure SetCryptedKey(const Value: TRawBytes);
    function GetPrivateKey: IPrivateKey;
    function GetState: TEncryptionState;
    function GetKeyType: TKeyType;
    function HasPrivateKey: Boolean;

  public
    constructor Create(AKeyTools: IKeyTools; AWallet: TWallet);
  end;

  TPublicKey = class(TInterfacedObject, IPublicKey)
  private
    FKeyTools: IKeyTools;
    FNID: Word;
    FX: TBytes;
    FY: TBytes;
  protected
    function GetNID: Word;
    procedure SetNID(const Value: Word);
    function GetX: TBytes;
    procedure SetX(const Value: TBytes);
    function GetY: TBytes;
    procedure SetY(const Value: TBytes);
    function GetKeyType: TKeyType;
    procedure SetKeyType(const Value: TKeyType);
    function GetKeyTypeAsStr: string;
    procedure SetKeyTypeAsStr(const Value: string);

    function GetAsHexStr: string;
    function GetAsBase58: string;
  public
    constructor Create(AKeyTools: IKeyTools);
  end;

  TPrivateKey = class(TInterfacedObject, IPrivateKey)
  private
    FKey: TRawBytes;
    FKeyType: TKeyType;
  protected
    function GetKey: TRawBytes;
    procedure SetKey(Value: TRawBytes);
    function GetKeyType: TKeyType;
    procedure SetKeyType(const Value: TKeyType);
    function GetAsHexStr: String;
  public

    constructor Create; overload;
    {$IFDEF UNITTEST}
    constructor Create(AHexKey: string; const AKeyType: TKeyType); overload;
    {$ENDIF UNITTEST}
  end;

implementation

uses System.IOUtils, System.Rtti,
  PascalCoin.Utils.Classes, PascalCoin.ResourceStrings, PascalCoin.Helpers,
  ClpIAsymmetricCipherKeyPair, PascalCoin.FMX.Strings, clpEncoders;

Const
  CT_PrivateKeyFile_Magic = 'TWalletKeys';
  CT_PrivateKeyFile_Version = 100;

  { TWallet }

function TWallet.AddWalletKey(Value: IWalletKey): Integer;
begin
  result := FKeys.Add(Value);
end;

function TWallet.Count: Integer;
begin
  result := FKeys.Count;
end;

constructor TWallet.Create(ATools: IKeyTools; AStreamOp: IStreamOp);
begin
  inherited Create;
  FKeyTools := ATools;
  FStreamOp := AStreamOp;
  FKeys := TList<IWalletKey>.Create;
  FState := esPlainText;
  FLocked := True;
  LoadWallet;
end;

function TWallet.CreateNewKey(const AKeyType: TKeyType;
  const AName: string): Integer;
var
  lWalletKey: IWalletKey;
  lKeyPair: IAsymmetricCipherKeyPair;
  lPrivateKey: TRawBytes;
  lPrivateKeyAsHex: String;
begin
  lWalletKey := TWalletKey.Create(FKeyTools, Self);
  lWalletKey.Name := AName;
  lWalletKey.PublicKey.KeyType := AKeyType;
  // This is a bit Nasty, but will do until UGO looks into it
  repeat
    lKeyPair := FKeyTools.GenerateECKeyPair(AKeyType);
    lWalletKey.PublicKey.X := FKeyTools.GetPublicKeyAffineX(lKeyPair);
    lWalletKey.PublicKey.Y := FKeyTools.GetPublicKeyAffineY(lKeyPair);
  until (AKeyType <> TKeyType.SECP256K1) or
    lWalletKey.PublicKey.AsBase58.StartsWith('3Ghhb');

  lPrivateKey := FKeyTools.GetPrivateKey(lKeyPair);
  lPrivateKeyAsHex := FKeyTools.GetPascalCoinPrivateKeyAsHexString(AKeyType,
    lPrivateKey);

  lWalletKey.CryptedKey := FKeyTools.EncryptPascalCoinPrivateKey
    (lPrivateKeyAsHex, FPassword);

  result := AddWalletKey(lWalletKey);
  SaveToStream;
end;

destructor TWallet.Destroy;
begin
  FKeys.Free;
  FWalletFileStream.Free;

  inherited;
end;

function TWallet.FindKey(const Value: string; const AEncoding: TKeyEncoding)
  : IWalletKey;
var
  lKey: IWalletKey;
begin
  // If Keys was a TDictioary this would be faster
  for lKey in FKeys do
  begin
    case AEncoding of
      TKeyEncoding.Hex:
        if lKey.PublicKey.AsHexStr = Value then
          Exit(lKey);
      TKeyEncoding.Base58:
        if lKey.PublicKey.AsBase58 = Value then
          Exit(lKey);
    end;
  end;
end;

function TWallet.GetLocked: Boolean;
begin
  result := ((FState = esPlainText) and FLocked) or
    ((FState <> esPlainText) and (FPassword = ''));
end;

function TWallet.GetOnLockChange: IEvent<TPascalCoinBooleanEvent>;
begin
  result := FOnLockChange;
end;

function TWallet.GetState: TEncryptionState;
begin
  result := FState;
end;

function TWallet.GetWalletFileName: String;
begin
{$IFDEF TESTNET}
  result := TPath.Combine(TPath.GetHomePath, 'PascalCoin_URBAN');
{$ELSE}
  result := TPath.Combine(TPath.GetHomePath, 'PascalCoin');
{$ENDIF}
  result := TPath.Combine(result, 'WalletKeys.dat');
end;

function TWallet.GetWalletKey(const Index: Integer): IWalletKey;
begin
  result := FKeys[Index];
end;

procedure TWallet.LoadWallet;
var
  lFileName: string;
begin
  FIsReadingStream := True;
  try
    if Assigned(FWalletFileStream) then
    begin
      FWalletFileStream.Free;
      FWalletFileStream := nil;
    end;

    lFileName := GetWalletFileName;

    if TFile.Exists(lFileName) then
      FWalletFileStream := TFileStream.Create(lFileName, fmOpenReadWrite or
        fmShareDenyWrite)
    else
      FWalletFileStream := TFileStream.Create(lFileName,
        fmCreate or fmShareDenyWrite);

    FWalletFileStream.Position := 0;

    if (FWalletFileStream.Size - FWalletFileStream.Position > 0) then
    begin
      try
        LoadWalletFromStream(FWalletFileStream);
        if Count > 0 then
          FState := FKeys[0].State;
      except
        FWalletFileStream.Free;
      end;
    end;

  finally
    FIsReadingStream := False;
  end;

end;

procedure TWallet.LoadWalletFromStream(Stream: TStream);
var
  s: String;
  lRaw, LX, LY: TRawBytes;
  nKeys: Integer;
  I: Integer;
  lWalletKey: IWalletKey;
  lNid: Word;
  lStr: String;
begin

  FStreamOp.ReadRawBytes(Stream, lRaw);

  lStr := TEncoding.ASCII.GetString(lRaw);

  if Not(String.Compare(lStr, CT_PrivateKeyFile_Magic) = 0) then
    raise Exception.Create(InvalidStream + ': ' + Classname);
  // Read version:
  Stream.Read(FFileVersion, 4);
  if (FFileVersion <> CT_PrivateKeyFile_Version) then
  begin
    // Old version
    Stream.Position := Stream.Position - 4;
    raise Exception.Create(Classname + ':' + InvalidPrivateKeysFileVersion +
      ': ' + FFileVersion.ToString);
  end;

  Stream.Read(nKeys, 4);
  for I := 0 to nKeys - 1 do
  begin
    lWalletKey := TWalletKey.Create(FKeyTools, Self);

    FStreamOp.ReadRawBytes(Stream, lRaw);
    lWalletKey.Name := TEncoding.ASCII.GetString(lRaw);

    Stream.Read(lNid, SizeOf(lNid));
    lWalletKey.PublicKey.NID := lNid;

    FStreamOp.ReadRawBytes(Stream, LX);
    lWalletKey.PublicKey.X := LX;

    FStreamOp.ReadRawBytes(Stream, LY);
    lWalletKey.PublicKey.Y := LY;

    FStreamOp.ReadRawBytes(Stream, lRaw);
    lWalletKey.CryptedKey := lRaw;

    AddWalletKey(lWalletKey);

  end;

end;

function TWallet.Lock: Boolean;
begin
  result := True;
  if not FLocked then
  begin
    FLocked := True;
    FPassword := '';
    FOnLockChange.Invoke(True);
  end;
end;

procedure TWallet.PublicKeysToStrings(Value: TStrings;
  const AEncoding: TKeyEncoding);
var
  lKey: IWalletKey;
begin
  for lKey in FKeys do
  begin
    case AEncoding of
      TKeyEncoding.Base58:
        Value.Add(lKey.PublicKey.AsBase58);
      TKeyEncoding.Hex:
        Value.Add(lKey.PublicKey.AsHexStr);
    end;
  end;
end;

procedure TWallet.SaveToStream;
var
  I: Integer;
  W: IWalletKey;
  lNid: Word;
begin
  if FIsReadingStream then
    Exit;
  if Not Assigned(FWalletFileStream) then
    Exit;
  FWalletFileStream.Size := 0;
  FWalletFileStream.Position := 0;
  FStreamOp.WriteRawBytes(FWalletFileStream,
    TEncoding.ASCII.GetBytes(CT_PrivateKeyFile_Magic));
  I := CT_PrivateKeyFile_Version;
  FWalletFileStream.Write(I, 4);
  I := FKeys.Count;
  FWalletFileStream.Write(I, 4);
  for I := 0 to FKeys.Count - 1 do
  begin
    W := FKeys[I];
    FStreamOp.WriteRawBytes(FWalletFileStream,
      TEncoding.ASCII.GetBytes(W.Name));
    lNid := W.PublicKey.NID;
    FWalletFileStream.Write(lNid, SizeOf(lNid));
    FStreamOp.WriteRawBytes(FWalletFileStream, W.PublicKey.X);
    FStreamOp.WriteRawBytes(FWalletFileStream, W.PublicKey.Y);
    FStreamOp.WriteRawBytes(FWalletFileStream, W.CryptedKey);
  end;
end;

function TWallet.SetPassword(const Value: string): Boolean;
var
  lPlainKey: TRawBytes;
begin
  if Value = FPassword then
    Exit(True);

  if FState = esPlainText then
    raise Exception.Create(STheWalletIsNotEncrypted);

  if (FPassword <> '') then
    raise Exception.Create(SThisDoesnTMatchThePasswordAlread);

  if Count = 0 then
  begin
    FPassword := Value;
    Exit(True);
  end;

  // does it work?
  result := FKeyTools.DecryptPascalCoinPrivateKey
    (FKeys[0].CryptedKey.ToHexaString, Value, lPlainKey);

  if result then
    FPassword := Value;

end;

function TWallet.ChangePassword(const Value: string): Boolean;
var
  lOldPassword, lHexKey: string;
  lPlainKey, lPassword: TRawBytes;
  lWalletKey: IWalletKey;
begin
  if FPassword = Value then
  begin
    Exit(Unlock(Value));
  end;

  lOldPassword := FPassword;
  lPassword.FromString(lOldPassword);

  for lWalletKey in FKeys do
  begin

    if not FKeyTools.DecryptPascalCoinPrivateKey
      (lWalletKey.CryptedKey.ToHexaString, lOldPassword, lPlainKey) then
    begin
      raise Exception.Create('Unable to decrypt key!');
    end;

    lHexKey := lPlainKey.ToHexaString;
    lWalletKey.CryptedKey := FKeyTools.EncryptPascalCoinPrivateKey
      (lHexKey, Value);

  end;

  FPassword := Value;
  SaveToStream;
  result := Unlock(Value);

end;

function TWallet.Unlock(const APassword: string): Boolean;
begin
  // Check for already Unlocked
  if not GetLocked then
    Exit(True);

  if (FState = esEncrypted) then
  begin
    if (APassword = '') then
      Exit(False);

    result := SetPassword(APassword);

  end
  else
    result := True;

  if result then
  begin
    FLocked := False;
    FOnLockChange.Invoke(False);
  end;

end;

{ TWalletKey }

procedure TWalletKey.Clear;
begin
  FPublicKey := nil;
  FEncryptionState := esPlainText;
  SetLength(FCryptedKey, 0);
end;

constructor TWalletKey.Create(AKeyTools: IKeyTools; AWallet: TWallet);
begin
  inherited Create;
  FKeyTools := AKeyTools;
  FWallet := AWallet;
  Clear;
end;

function TWalletKey.GetPublicKey: IPublicKey;
begin
  if FPublicKey = nil then
    FPublicKey := TPublicKey.Create(FKeyTools);
  result := FPublicKey;
end;

function TWalletKey.GetState: TEncryptionState;
begin
  result := FEncryptionState;
end;

function TWalletKey.GetCryptedKey: TBytes;
begin
  result := FCryptedKey;
end;

function TWalletKey.GetKeyType: TKeyType;
begin
  result := FPublicKey.KeyType;
end;

function TWalletKey.GetName: String;
begin
  result := FName;
end;

function TWalletKey.GetPrivateKey: IPrivateKey;
var
  lKey: TRawBytes;
begin
  result := TPrivateKey.Create;
  result.KeyType := FPublicKey.KeyType;

  if FKeyTools.DecryptPascalCoinPrivateKey(FCryptedKey.ToHexaString,
    FWallet.Password, lKey) then
    result.Key := lKey;
end;

function TWalletKey.HasPrivateKey: Boolean;
begin
  result := Length(FCryptedKey) > 0;
end;

procedure TWalletKey.SetCryptedKey(const Value: TBytes);
var
  lVal: TRawBytes;
  lRetval: Boolean;
  lTestVal: string;
begin
  FCryptedKey := Value;
  try
    lRetval := FKeyTools.DecryptPascalCoinPrivateKey(FCryptedKey.ToHexaString,
      '', lVal);
  except
    on e: Exception do
    begin
      lTestVal := Self.FName;
    end;
  end;
  if lRetval then
    FEncryptionState := esPlainText
  else
    FEncryptionState := esEncrypted;
end;

procedure TWalletKey.SetName(const Value: String);
begin
  FName := Value;
end;

{ TPublicKey }

constructor TPublicKey.Create(AKeyTools: IKeyTools);
begin
  inherited Create;
  FKeyTools := AKeyTools;
end;

function TPublicKey.GetNID: Word;
begin
  result := FNID;
end;

function TPublicKey.GetX: TBytes;
begin
  result := FX;
end;

function TPublicKey.GetY: TBytes;
begin
  result := FY;
end;

function TPublicKey.GetAsBase58: string;
begin
  result := FKeyTools.GetPascalCoinPublicKeyAsBase58(GetAsHexStr);
end;

function TPublicKey.GetAsHexStr: string;
begin
  result := FKeyTools.GetPascalCoinPublicKeyAsHexString(GetKeyType, FX, FY);
end;

function TPublicKey.GetKeyType: TKeyType;
begin
  result := FKeyTools.RetrieveKeyType(FNID);
end;

function TPublicKey.GetKeyTypeAsStr: string;
begin
  result := TRttiEnumerationType.GetName<TKeyType>(GetKeyType);
end;

procedure TPublicKey.SetKeyType(const Value: TKeyType);
begin
  FNID := FKeyTools.GetKeyTypeNumericValue(Value);
end;

procedure TPublicKey.SetKeyTypeAsStr(const Value: string);
begin
  SetKeyType(TRttiEnumerationType.GetValue<TKeyType>(Value));
end;

procedure TPublicKey.SetNID(const Value: Word);
begin
  FNID := Value;
end;

procedure TPublicKey.SetX(const Value: TBytes);
begin
  FX := Value;
end;

procedure TPublicKey.SetY(const Value: TBytes);
begin
  FY := Value;
end;

{ TPrivateKey }

 {$IFDEF UNITTEST}
constructor TPrivateKey.Create(AHexKey: string; const AKeyType: TKeyType);
begin
  Create;
  FKey := THex.Decode(AHexKey);
  FKeyType := AKeyType;
end;
{$ENDIF}

constructor TPrivateKey.Create;
begin
  inherited Create;
end;

function TPrivateKey.GetAsHexStr: String;
begin
  result := FKey.ToHexaString;
end;

function TPrivateKey.GetKey: TRawBytes;
begin
  result := FKey;
end;

function TPrivateKey.GetKeyType: TKeyType;
begin
  result := FKeyType;
end;

procedure TPrivateKey.SetKey(Value: TRawBytes);
begin
  FKey := Value;
end;

procedure TPrivateKey.SetKeyType(const Value: TKeyType);
begin
  FKeyType := Value;
end;

end.
