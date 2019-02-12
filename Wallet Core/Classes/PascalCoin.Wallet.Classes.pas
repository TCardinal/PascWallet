/// <summary>
///   <para>
///     These components are for reading and writing the Wallet Keys to a
///     local file.
///   </para>
///   <para>
///     The File Structure is as follows:
///   </para>
///   <list type="table">
///     <listheader>
///       <term>Byte Length</term>
///       <description>Description</description>
///     </listheader>
///     <item>
///       <term>2</term>
///       <description><i>idLength</i>: Integer- Length of wallet
///         identifier.</description>
///     </item>
///     <item>
///       <term>idLength</term>
///       <description>Needs to match the const CT_PrivateKeyFile_Magic
///         if it is a valid wallet</description>
///     </item>
///     <item>
///       <term>4 Bytes</term>
///       <description>File Version</description>
///     </item>
///     <item>
///       <term>4 Bytes</term>
///       <description>Number of Keys</description>
///     </item>
///     <item>
///       <term>Keys</term>
///       <description>For each key:</description>
///     </item>
///     <item>
///       <term>2 Bytes</term>
///       <description><i>keyNameLength</i>: Length of Key Name</description>
///     </item>
///     <item>
///       <term>KeyNameLength</term>
///       <description>Key Name</description>
///     </item>
///   </list>
/// </summary>
unit PascalCoin.Wallet.Classes;


interface

uses System.Classes, System.Generics.Collections, System.SysUtils,
PascalCoin.Wallet.Interfaces;

Type

TWallet = class(TInterfacedObject, IWallet)
private
  FKeyTools: IKeyTools;
  FStreamOp: IStreamOp;
  FPassword: String;

  /// <summary>
  ///   This is used to lock wallets that aren't encrypted, just a way to
  ///   prevent silly mistakes - a double check
  /// </summary>
  FLocked: Boolean;
  FState: TEncryptionState;
  FWalletFileStream: TFileStream;
  FIsReadingStream: Boolean;
  FKeys: TList<IWalletKey>;
  FFileVersion: Integer;
  FOnLockChange: TProc<boolean>;
  procedure LoadWallet;
  function SetPassword(const Value: string): boolean;
protected
  function GetWalletKey(const Index: Integer): IWalletKey;

  function GetState: TEncryptionState;
  function GetLocked: Boolean;
  procedure Lock;
  function Unlock(const APassword: string): boolean;
  procedure SetOnLockChange(Value: TProc<boolean>);

  function ChangePassword(const Value: string): boolean;

  function GetWalletFileName: String;
  function AddWalletKey(Value: IWalletKey): Integer;
  function CreateNewKey(const AKeyType: TKeyType; const AName: string): Integer;
  function Count: Integer;
  procedure SaveToStream;

public
  constructor Create(ATools: IKeyTools; AStreamOp: IStreamOp);
  destructor Destroy; override;
  procedure LoadWalletFromStream(Stream: TStream);
end;

TWalletKey = class(TInterfacedObject, IWalletKey)
private
  FKeyTools: IKeyTools;
  FName: String;
  FAccountKey: IPublicKey;
  FCryptedKey: TRawBytes;
  FPrivateKey: IPrivateKey;
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

  function HasPrivateKey : boolean;

public
  constructor Create(AKeyTools: IKeyTools);
end;

TPublicKey = class(TInterfacedObject, IPublicKey)
private
  FKeyTools: IKeyTools;
  FNID: Word;
  FX: TBytes;
  FY: TBytes;
protected
  function GetNID: Word;
  procedure SetNID(const Value: word);
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


implementation

uses System.IOUtils, System.Rtti,
PascalCoin.Utils.Classes, PascalCoin.ResourceStrings, PascalCoin.Helpers,
ClpIAsymmetricCipherKeyPair, PascalCoin.FMX.Strings;

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

function TWallet.CreateNewKey(const AKeyType: TKeyType; const AName: string): Integer;
var
  lWalletKey: IWalletKey;
  lKeyPair: IAsymmetricCipherKeyPair;
  lPrivateKey: TRawBytes;
  lPrivateKeyAsHex: String;
begin
  lWalletKey := TWalletKey.Create(FKeyTools);
  lWalletKey.Name := AName;
  lWalletKey.PublicKey.KeyType := AKeyType;
  //This is a bit Nasty, but will do until UGO looks into it
  repeat
    lKeyPair := FKeyTools.GenerateECKeyPair(AKeyType);
    lWalletKey.PublicKey.X:= FKeyTools.GetPublicKeyAffineX(LKeyPair);
    lWalletKey.PublicKey.Y := FKeyTools.GetPublicKeyAffineY(LKeyPair);
  until (AKeyType <> TKeyType.SECP256K1) or lWalletKey.PublicKey.AsBase58.StartsWith('3Ghhb');

  lPrivateKey := FKeyTools.GetPrivateKey(lKeyPair);
  lPrivateKeyAsHex :=
     FKeyTools.GetPascalCoinPrivateKeyAsHexString(AKeyType, lPrivateKey);

  lWalletKey.CryptedKey :=
     FKeyTools.EncryptPascalCoinPrivateKey(lPrivateKeyAsHex, FPassword);

  result := AddWalletKey(lWalletKey);
  SaveToStream;
end;

destructor TWallet.Destroy;
begin
  FKeys.Free;
  FWalletFileStream.Free;

  inherited;
end;

function TWallet.GetLocked: Boolean;
begin
  result := ((FState = esPlainText) and FLocked) or
            ((FState <> esPlainText) and (FPassword = ''));
end;

function TWallet.GetState: TEncryptionState;
begin
  result := FState;
end;

function TWallet.GetWalletFileName: String;
begin
  {$IFDEF TESTNET}
  Result := TPath.Combine(TPath.GetHomePath, 'PascalCoin_URBAN');
  {$ELSE}
  Result := TPath.Combine(TPath.GetHomePath, 'PascalCoin');
  {$ENDIF}
  Result := TPath.Combine(Result, 'WalletKeys.dat');
end;

function TWallet.GetWalletKey(const Index: Integer): IWalletKey;
begin
  result := FKeys[Index];
end;

procedure TWallet.LoadWallet;
var lFileName: string;
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
       FWalletFileStream := TFileStream.Create(lFileName,
            fmOpenReadWrite or fmShareDenyWrite)
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
var s: String;
    lRaw, lX, LY: TRawBytes;
    nKeys: Integer;
    I: Integer;
    lWalletKey: IWalletKey;
    lNid: Word;
    lStr: String;
begin

  FStreamOp.ReadRawBytes(Stream, lRaw);

  lStr := TEncoding.ASCII.GetString(lRaw);

  if Not (String.Compare(lStr, CT_PrivateKeyFile_Magic) = 0) then
     raise Exception.Create(InvalidStream + ': ' + Classname);
      // Read version:
  Stream.Read(FFileVersion,4);
  if (FFileVersion<>CT_PrivateKeyFile_Version) then begin
    // Old version
    Stream.Position := Stream.Position-4;
    raise Exception.Create(ClassName + ':' + InvalidPrivateKeysFileVersion + ': ' +
       FFileVersion.ToString);
  end;

  Stream.Read(nKeys, 4);
  for I := 0 to nKeys - 1 do
  begin
     lWalletKey := TWalletKey.Create(FKeyTools);

     FStreamOp.ReadRawBytes(Stream, lRaw);
     lWalletKey.Name :=  TEncoding.ASCII.GetString(lRaw);

     Stream.Read(lNid, SizeOf(lNid));
     lWalletKey.PublicKey.NID := lNid;

     FStreamOp.ReadRawBytes(Stream, lX);
     lWalletKey.PublicKey.X := lX;

     FStreamOp.ReadRawBytes(Stream, lY);
     lWalletKey.PublicKey.Y := lY;

     FStreamOp.ReadRawBytes(Stream, lRaw);
     lWalletKey.CryptedKey := lRaw;

     AddWalletKey(lWalletKey);

//        P := PWalletKey(FSearchableKeys[j]);
//        P^.CryptedKey := wk.CryptedKey; // Adding encrypted data
      end;

end;

procedure TWallet.Lock;
begin
  if not FLocked then
  begin
    FLocked := True;
    FPassword := '';
    if Assigned(FOnLockChange) then
       FOnLockChange(True);
  end;
end;

procedure TWallet.SaveToStream;
var i : Integer;
    W : IWalletKey;
    lNID: Word;
begin
  if FIsReadingStream then exit;
  if Not Assigned(FWalletFileStream) then exit;
  FWalletFileStream.Size := 0;
  FWalletFileStream.Position:=0;
  FStreamOp.WriteRawBytes(FWalletFileStream,TEncoding.ASCII.GetBytes(CT_PrivateKeyFile_Magic));
  i := CT_PrivateKeyFile_Version;
  FWalletFileStream.Write(i,4);
  i := FKeys.Count;
  FWalletFileStream.Write(i,4);
  for i := 0 to FKeys.Count - 1 do
  begin
    W := FKeys[I];
    FStreamOp.WriteRawBytes(FWalletFileStream,TEncoding.ASCII.GetBytes(W.Name));
    lNID := W.PublicKey.NID;
    FWalletFileStream.Write(lNID,sizeof(lNID));
    FStreamOp.WriteRawBytes(FWalletFileStream,W.PublicKey.X);
    FStreamOp.WriteRawBytes(FWalletFileStream,W.PublicKey.Y);
    FStreamOp.WriteRawBytes(FWalletFileStream,W.CryptedKey);
  end;
end;

procedure TWallet.SetOnLockChange(Value: TProc<boolean>);
begin
  FOnLockChange := Value;
end;

function TWallet.SetPassword(const Value: string): boolean;
var lPlainKey: TRawBytes;
begin
  if Value = FPassword then
     Exit(True);

  if FState = esPlainText then
     raise exception.Create(STheWalletIsNotEncrypted);

  if (FPassword <> '') then
     raise Exception.Create(SThisDoesnTMatchThePasswordAlread);

  if Count = 0 then
  begin
    FPassword := Value;
    Exit(True);
  end;

  //does it work?
  result := FKeyTools.DecryptPascalCoinPrivateKey(FKeys[0].CryptedKey.ToHexaString,
         Value, lPlainKey);

  if Result then
     FPassword := Value;

end;

function TWallet.ChangePassword(const Value: string): boolean;
var lOldPassword, lHexKey: string;
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

//     //Already Password protected, Need to Decrypt
//     if (FState in [esEncrypted, esDecrypted]) then
//     begin

       if not FKeyTools.DoPascalCoinAESDecrypt(lWalletKey.CryptedKey,
         lPassword, lPlainKey) then
//       FKeyTools.DecryptPascalCoinPrivateKey(lWalletKey.CryptedKey.ToHexaString,
//         lOldPassword, lPlainKey) then
       begin
         raise exception.Create('Unable to decrypt key!');
       end;
//     end
//     else
//       lPlainKey := lWalletKey.CryptedKey;

     lHexKey := lPlainKey.ToHexaString;
     lWalletKey.CryptedKey := FKeyTools.EncryptPascalCoinPrivateKey(lHexKey, Value);

  end;

  FPassword := Value;
  SaveToStream;
  Result := Unlock(Value);

end;

function TWallet.Unlock(const APassword: string): boolean;
begin
  //Check for already Unlocked
  if not GetLocked then
     Exit(True);

  if (FState = esEncrypted) then
  begin
    if (APassword = '')  then
       Exit(False);

    Result := SetPassword(APassword);

  end
  else
    Result := True;

  if Result then
  begin
    FLocked := False;

    if Assigned(FOnLockChange) then
       FOnLockChange(False);
  end;

end;

{ TWalletKey }

procedure TWalletKey.Clear;
begin
  FAccountKey := nil;
  FPrivateKey := nil;
  FEncryptionState := esPlainText;
  SetLength(FCryptedKey, 0);
end;

constructor TWalletKey.Create(AKeyTools: IKeyTools);
begin
  inherited Create;
  FKeyTools := AKeyTools;
  Clear;
end;

function TWalletKey.GetPublicKey: IPublicKey;
begin
  if FAccountKey = nil then
     FAccountKey := TPublicKey.Create(FKeyTools);
  Result := FAccountKey;
end;

function TWalletKey.GetState: TEncryptionState;
begin
  result := FEncryptionState;
end;

function TWalletKey.GetCryptedKey: TBytes;
begin
  Result := FCryptedKey;
end;

function TWalletKey.GetName: String;
begin
  Result := FName;
end;

function TWalletKey.GetPrivateKey: IPrivateKey;
begin
  Result := FPrivateKey;
end;

function TWalletKey.HasPrivateKey: boolean;
begin
  Result := Length(FCryptedKey) > 0;
end;

procedure TWalletKey.SetCryptedKey(const Value: TBytes);
var lVal: TRawBytes;
    lRetval: boolean;
begin
  FCryptedKey := Value;
  lRetval := FKeyTools.DecryptPascalCoinPrivateKey(FCryptedKey.ToHexaString, '', lVal);
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
  Result := FKeyTools.RetrieveKeyType(FNID);
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

procedure TPublicKey.SetNID(const Value: word);
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

end.
