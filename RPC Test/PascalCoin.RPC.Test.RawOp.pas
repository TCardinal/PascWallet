unit PascalCoin.RPC.Test.RawOp;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.Layouts, FMX.ScrollBox, FMX.Memo,
  PascalCoin.Utils.Interfaces, FMX.ListBox, PascalCoin.RawOp.Interfaces;

type
  TRawOpFrame = class(TFrame)
    Layout1: TLayout;
    Layout2: TLayout;
    Label1: TLabel;
    FromAccount: TEdit;
    Layout3: TLayout;
    Label2: TLabel;
    NextNOp: TEdit;
    Label3: TLabel;
    ToAccount: TEdit;
    Layout5: TLayout;
    Label4: TLabel;
    Fee: TEdit;
    Label5: TLabel;
    Amount: TEdit;
    StdCheckDataBtn: TButton;
    Layout8: TLayout;
    Label7: TLabel;
    PrivateKey: TEdit;
    Label8: TLabel;
    Payload: TEdit;
    CreateRawOp: TButton;
    Memo1: TMemo;
    KeyTypeCombo: TComboBox;
    Label6: TLabel;
    Layout4: TLayout;
    Label9: TLabel;
    KRandom: TEdit;
    UseClass: TCheckBox;
    OpNumber: TEdit;
    Label10: TLabel;
    procedure CreateRawOpClick(Sender: TObject);
    procedure StdCheckDataBtnClick(Sender: TObject);
  private
    { Private declarations }
    FExpectedSender: string;
    FExpectedNOp: string;
    FExpectedReceiver: string;
    FExpectedAmount: string;
    FExpectedFee: string;
    FExpectedHash: string;
    FExpectedHashSig: string;
    FExpectedPaylen: string;
    FExpectedPayload: string;
    FExpectedRawOp: string;
    FExpectedRLen: string;
    FExpectedSignedTx: string;
    FExpectedStrToHash: string;
    FExpectedSignR: string;
    FExpectedSignS: string;
    FExpectedSLen: string;

    procedure UseObject;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

uses PascalCoin.KeyTool, ClpConverters, clpEncoders, SynCrypto, System.Rtti,
PascalCoin.RawOp.Classes, PascalCoin.Wallet.Classes;

constructor TRawOpFrame.Create(AOwner: TComponent);
var KT: TKeyType;
begin
  inherited;

  for KT := Low(TKeyType) to High(TKeyType) do
      KeyTypeCombo.Items.Add(TRttiEnumerationType.GetName<TKeyType>(KT));

end;

procedure TRawOpFrame.CreateRawOpClick(Sender: TObject);

  procedure AddToMemo(AName, AValue, AExpected: string);
  const
  c_bool: array[boolean] of string = ('No', 'Yes');
  begin
   Memo1.Lines.Add(AName + ' | ' + c_bool[AValue = AExpected] + ' | ' + AValue + ' | ' +
      AExpected
   );
  end;

var KeyTools: IKeyTools;
    lStrToHash, lRawOp: String;
    lSLE: TBytes;
    lSHex: string;
    cAmount: Currency;
    uAmount: uInt64;
    KT: TKeyType;
    lSender, lNOp, lReceiver, lAmount, lFee, lPayload, lHash, SigR, SigS: string;
    lPayLen, lSigRLen, lSigSLen: string;
    lSig: TECDSA_Signature;
    lPayLenI :Integer;
begin

  if UseClass.IsChecked then
  begin
    UseObject;
    Exit;
  end;

  KeyTools := TPascalCoinKeyTools.Create;
  Memo1.ClearContent;

  lSLE := TConverters.ReadUInt32AsBytesLE(FromAccount.Text.ToInteger);
  lSender := THEX.EnCode(lSLE);//    TConverters.ConvertBytesToHexString(lSLE, False);
  AddToMemo('Sender', lSender, FExpectedSender);

  lSLE := TConverters.ReadUInt32AsBytesLE(NextNOp.Text.ToInteger);
  lNOp := THEX.EnCode(lSLE);//TConverters.ConvertBytesToHexString(lSLE, False);
  AddToMemo('NOp', lNOp, FExpectedNOp);

  lSLE := TConverters.ReadUInt32AsBytesLE(ToAccount.Text.ToInteger);
  lReceiver := THEX.EnCode(lSLE);//TConverters.ConvertBytesToHexString(lSLE, False);
  AddToMemo('Receiver', lReceiver,  FExpectedReceiver);

  cAmount := Amount.Text.ToDouble;
  uAmount := Trunc(cAmount * 10000);
  AddToMemo('Amount', uAmount.ToString, '35000');

  lSLE := TConverters.ReadUInt64AsBytesLE(uAmount);
  lAmount := THEX.EnCode(lSLE);//TConverters.ConvertBytesToHexString(lSLE, False);
  AddToMemo('Amount Hex', lAmount, FExpectedAmount);

  cAmount := Fee.Text.ToDouble;
  uAmount := Trunc(cAmount * 10000);
  AddToMemo('Fee', uAmount.ToString, '1');

  lSLE := TConverters.ReadUInt64AsBytesLE(uAmount);
  lFee := THEX.EnCode(lSLE);//TConverters.ConvertBytesToHexString(lSLE, False);
  AddToMemo('Fee HEX', lFee, FExpectedFee);

  lSLE := TConverters.ConvertStringToBytes(Payload.Text, TEncoding.ANSI);
  lPayload := THex.Encode(lSLE, True);
  AddToMemo('Payload', lPayload, FExpectedPayload);

  lPayLenI := Payload.Text.Length;
  lSLE := KeyTools.UInt32ToLittleEndianByteArrayTwoBytes(lPayLenI);
  lPayLen := THEX.EnCode(lSLE);//TConverters.ConvertBytesToHexString(lSLE, False);
  AddToMemo('Payload Length', lPaylen, FExpectedPaylen);

  lStrToHash := lSender + lNOp + lReceiver + lAmount + lFee + lPayload + '0000' + '01';

  AddToMemo('StringToHash', lStrToHash, FExpectedStrToHash);

  lHash := THEX.Encode(
    KeyTools.ComputeSHA2_256_ToBytes(THEX.Decode(lStrToHash)));
  AddToMemo('HASH', lHash, FExpectedHash);

  KT := TRttiEnumerationType.GetValue<TKeyType>(KeyTypeCombo.Items[KeyTypeCombo.ItemIndex]);
  KeyTools.SignOperation(PrivateKey.Text, KT, lHash, lSig, KRandom.Text);

  SigR := lSig.R;
  SigS := lSig.S;

  AddToMemo('Sig.R', SigR, FExpectedSignR);
  AddToMemo('Sig.S', SigS, FExpectedSignS);

  lSLE := KeyTools.UInt32ToLittleEndianByteArrayTwoBytes(lSig.RLen);
  lSigRLen := THEX.EnCode(lSLE);

  lSLE := KeyTools.UInt32ToLittleEndianByteArrayTwoBytes(lSig.SLen);
  lSigSLen := THEX.EnCode(lSLE);

  AddToMemo('Sig.R.Len', lSigRLen, FExpectedRLen);
  AddToMemo('Sig.S.Len', lSigSLen, FExpectedSLen);


  lRawOp :=
  THEX.Encode(TConverters.ReadUInt32AsBytesLE(1)) + lSender + lNOp + lReceiver + lAmount + lFee + lPayLen + lPayload +
  '000000000000' + lSigRLen + SigR + lSigSLen + SigS;

  //prefix with count of operations
  lRawOp := '01000000' + lRawOp;

  AddToMemo('Raw Op', lRawOp, FExpectedRawOp);


end;

procedure TRawOpFrame.StdCheckDataBtnClick(Sender: TObject);
begin
  FromAccount.Text := '3700';
  ToAccount.Text := '7890';
  NextNOp.Text := '2';
  Amount.Text := '3.5';
  Fee.Text := '0.0001';
  Payload.Text := 'EXAMPLE';
  PrivateKey.Text := '37B799726961D231492823513F5686B3F7C7909DEFF20907D91BF4D24A356624';
  KeyTypeCombo.ItemIndex := KeyTypeCombo.Items.IndexOf('SECP256K1');
  KRandom.Text := 'A235553C44D970D0FC4D0C6C1AF80330BF06E3B4A6C039A7B9E8A2B5D3722D1F';
  OpNumber.Text := '1';

  FExpectedSender := '740E0000';
  FExpectedNOp := '02000000';
  FExpectedReceiver := 'D21E0000';
  FExpectedAmount := 'B888000000000000';
  FExpectedFee := '0100000000000000';
  FExpectedPayload := '4558414D504C45';
  FExpectedPaylen := '0700';
  FExpectedStrToHash := '740E000002000000D21E0000B88800000000000001000000000000004558414D504C45000001';

  FExpectedHash := 'B8C2057F4BA187B7A29CC810DB56B66C7B9361FA64FD77BADC759DD21FF4ABE7';

  FExpectedHashSig := '37B799726961D231492823513F5686B3F7C7909DEFF20907D91BF4D24A356624';
  FExpectedSignR := 'EFD5CBC12F6CC347ED55F26471E046CF59C87E099513F56F4F1DD49BDFA84C0E';
  FExpectedRLen := '2000';
  FExpectedSignS := '7BCB0D96A93202A9C6F11D90BFDCAB99F513C880C4888FECAC74D9B09618C06E';
  FExpectedSLen := '2000';
  FExpectedSignedTx := '01000000740E000002000000D21E0000B888000000000000010000000000000007004558414D504C450000000000002000EFD5CBC12F6CC347ED55F26471E046CF59C87E099513F56F4F1DD49BDFA84C0E20007BCB0D96A93202A9C6F11D90BFDCAB99F513C880C4888FECAC74D9B09618C06E';
  FExpectedRawOp := '01000000' + FExpectedSignedTx;

end;

procedure TRawOpFrame.UseObject;

  procedure AddToMemo(AName, AValue, AExpected: string);
  const
  c_bool: array[boolean] of string = ('No', 'Yes');
  begin
   Memo1.Lines.Add(AName + ' | ' + c_bool[AValue = AExpected]);
   Memo1.Lines.Add('Val: ' + AValue);
   Memo1.Lines.Add('Exp: ' + AExpected);
   Memo1.Lines.Add('');
  end;

var lOp: IRawTransactionOp;
    lMultiOp: IRawOperations;
    KT: TKeyType;
begin
  lOp := TRawTransactionOp.Create(TPascalCoinKeyTools.Create);

  Memo1.ClearContent;

  KT := TRttiEnumerationType.GetValue<TKeyType>(KeyTypeCombo.Items[KeyTypeCombo.ItemIndex]);
  lOp.Key := TPrivateKey.Create(PrivateKey.Text, KT);
  AddToMemo('KeyHex', lOp.TestValue('Key.Hex'), PrivateKey.Text);

  lOp.KRandom := KRandom.Text;
  AddToMemo('KRandom', lOp.TestValue('KRandom'), KRandom.Text);

  lOp.SendFrom := FromAccount.Text.ToInteger;
  AddToMemo('Sender', lOp.TestValue('SENDFROM'), FExpectedSender);

  lOp.NOp := NextNOp.Text.ToInteger;
  AddToMemo('NOp', lOp.TestValue('NOP'), FExpectedNOp);

  lOp.SendTo := ToAccount.Text.ToInteger;
  AddToMemo('Receiver', lOp.TestValue('SendTo'),  FExpectedReceiver);

  lOp.Amount := Amount.Text.ToDouble;
  AddToMemo('Amount Hex', lOp.TestValue('Amount'), FExpectedAmount);

  lOp.Fee := Fee.Text.ToDouble;
  AddToMemo('Fee HEX', lOp.TestValue('Fee'), FExpectedFee);

  lOp.Payload :=
    THex.Encode(TConverters.ConvertStringToBytes(Payload.Text, TEncoding.ANSI), True);
  AddToMemo('Payload', lOp.Payload, FExpectedPayload);

  AddToMemo('PayloadLen', lOp.TestValue('PayloadLen'), FExpectedPaylen);

  AddToMemo('ValueToHash', lOp.TestValue('ValueToHash'), FExpectedStrToHash);

  AddToMemo('HASH', lOp.TestValue('Hash'), FExpectedHash);

  AddToMemo('Sig.R', lOp.TestValue('SIG.R'), FExpectedSignR);
  AddToMemo('Sig.S', lOp.TestValue('SIG.S'), FExpectedSignS);

  AddToMemo('Sig.R.Len', lOp.TestValue('Sig.R.Len'), FExpectedRLen);
  AddToMemo('Sig.S.Len', lOp.TestValue('Sig.S.Len'), FExpectedSLen);
  AddToMemo('SignedTx', lOp.TestValue('SignedTx'), FExpectedSignedTx);

  lMultiOp := TRawOperations.Create;

  lMultiOp.AddRawOperation(lOp);

  AddToMemo('Raw Op', lMultiOp.RawData, FExpectedRawOp);

end;

end.
