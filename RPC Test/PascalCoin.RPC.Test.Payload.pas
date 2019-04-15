unit PascalCoin.RPC.Test.Payload;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ScrollBox, FMX.Memo, FMX.ListBox, FMX.Edit, FMX.Controls.Presentation,
  FMX.Layouts;

type
  TPayloadTest = class(TFrame)
    Layout1: TLayout;
    Label1: TLabel;
    Payload: TEdit;
    Layout2: TLayout;
    Label2: TLabel;
    EncMethod: TComboBox;
    Layout3: TLayout;
    Label3: TLabel;
    PayloadEncryptor: TEdit;
    Layout4: TLayout;
    Button1: TButton;
    Memo1: TMemo;
    Layout5: TLayout;
    Label4: TLabel;
    ComboBox1: TComboBox;
    Button2: TButton;
    Layout6: TLayout;
    Label5: TLabel;
    PrivateKey: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FExpected: string;
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses PascalCoin.RPC.Interfaces, PascalCoin.Utils.Interfaces, clpConverters, clpEncoders,
PascalCoin.RPC.Test.DM, Spring.Container;

procedure TPayloadTest.Button1Click(Sender: TObject);
var lAPI: IPascalCoinAPI;
    lPayload, lEncrypted, lDecrypted: string;

begin
  Memo1.ClearContent;

  lPayload := GlobalContainer.Resolve<IPascalCoinTools>.StrToHex(Payload.Text);
  Memo1.Lines.Add('Payload As HEX');
  Memo1.Lines.Add(lPayload);

  lAPI := GlobalContainer.Resolve<IPascalCoinAPI>.URI(DM.URI);

  if EncMethod.ItemIndex = 0 then
  begin
    lEncrypted := lAPI.payloadEncryptWithPublicKey(lPayload, PayloadEncryptor.Text, TKeyStyle.ksEncKey);
  end
  else if EncMethod.ItemIndex = 1 then
  begin
    lEncrypted := lAPI.payloadEncryptWithPublicKey(lPayload, PayloadEncryptor.Text, TKeyStyle.ksB58Key);
  end
  else
  begin

  end;

  Memo1.Lines.Add('Encrypted Payload');
  Memo1.Lines.Add(lEncrypted);

// To do this need to use fixed random
//  if FExpected <> '' then
//  begin
//    if lEncrypted = FExpected then
//       Memo1.Lines.Add('as expected')
//    else
//    begin
//       Memo1.Lines.Add('not as expected');
//       Memo1.Lines.Add(FExpected);
//    end;
//  end;
end;

procedure TPayloadTest.Button2Click(Sender: TObject);
begin
  if ComboBox1.ItemIndex = 0 then
  begin
    FExpected := '';
    Payload.Text := '';
    EncMethod.ItemIndex := 0;
    PayloadEncryptor.Text := '';
    PrivateKey.Text := '';
  end
  else if ComboBox1.ItemIndex = 1 then
  begin
    FExpected := '21100F001000031D0F2029F0A0BDFB7C5E9873D744FE43C26F543C8D1317915E23AD9DA5280F16E4B0D47337128C85B1AB638201B9CBE082BC941A446A4711D8D3B701D2B6C3B3';
    Payload.Text := 'EXAMPLE PAYLOAD';
    EncMethod.ItemIndex := 1;
    PayloadEncryptor.Text := '3GhhbourL5nUHEze1UWHDEdcCX9UMmtNTextd72qDcMuFcwcxnuGV89q2ThCKTKnpg6bAKrQu5JAiFWL1zoUTmq1BQUmDf4yC3VeCd';
    PrivateKey.Text := '53616C7465645F5F83AEC09CE4EE2921A75CC62BFBF78C935A45473BF4C5205315B7981E036368B0C24C43E2A0E54F4159DC8A303204892D125F4CCFA1203560';
  end;

end;

end.
