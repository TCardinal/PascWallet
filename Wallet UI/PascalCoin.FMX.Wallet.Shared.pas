unit PascalCoin.FMX.Wallet.Shared;

interface

uses PascalCoin.FMX.Strings, PascalCoin.Wallet.Interfaces,
  PascalCoin.Utils.Interfaces,
  System.Generics.Collections, Spring;

Type

  TNodeRecord = record
    Name: string;
    URI: string;
    NetType: string;
    constructor Create(const AName, AURL, ANetType: string);
  end;

  TWalletAppSettings = class
  private
    FAdvancedOptions: boolean;
    FAdvancedOptionsChanged: Event<TPascalCoinBooleanEvent>;
    FNodes: TList<TNodeRecord>;
    FUnlockTimeChange: Event<TPascalCoinIntegerEvent>;
    FSelected: Integer;
    FSelectedNodeURI: String;
    FAutoMultiAccountTransactions: boolean;
    FUnlockTime: Integer;
    function GetAdvancedOptionsChanged: IEvent<TPascalCoinBooleanEvent>;
    procedure SetAdvancedOptions(const Value: boolean);
    procedure SetAutoMultiAccountTransactions(const Value: boolean);
    procedure SetUnlockTime(const Value: Integer);
    function GetOnUnlockTimeChange: IEvent<TPascalCoinIntegerEvent>;
    function GetAsJSON: string;
    procedure SetAsJSON(const Value: String);
  public
    constructor Create;
    destructor Destroy; override;
    property AdvancedOptions: boolean read FAdvancedOptions
      write SetAdvancedOptions;
    property AutoMultiAccountTransactions: boolean
      read FAutoMultiAccountTransactions write SetAutoMultiAccountTransactions;

    /// <summary>
    /// Number of minutes to keep the wallet unlocked with no activity. 0 means
    /// never lock
    /// </summary>
    property UnlockTime: Integer read FUnlockTime write SetUnlockTime;
    property SelectedNodeURI: string read FSelectedNodeURI
      write FSelectedNodeURI;
    property Nodes: TList<TNodeRecord> read FNodes;
    property OnAdvancedOptionsChange: IEvent<TPascalCoinBooleanEvent>
      read GetAdvancedOptionsChanged;
    property OnUnlockTimeChange: IEvent<TPascalCoinIntegerEvent>
      read GetOnUnlockTimeChange;
    property AsJSON: String read GetAsJSON write SetAsJSON;
  end;

var
  UConfig: IPascalCoinWalletConfig;

const

  cStateText: array [TEncryptionState] of string = (statePlainText,
    stateEncrypted, stateDecrypted);

  _PayloadEncryptText: array [TPayloadEncryption] of string = ('Nothing',
    'My Key', 'Their Key', 'a Password');

  _PayloadEncodeText: array [TPayloadEncode] of string = ('Hex',
    'Base58', 'ASCII');

implementation

uses System.IOUtils, System.SysUtils, System.JSON, REST.Json;

{ TWalletAppSettings }

function TWalletAppSettings.GetAsJSON: string;
var lObj, lNode: TJSONObject;
    lNodes: TJSONArray;
    nR: TNodeRecord;
begin
  Result := '';
  lObj := TJSONObject.Create;
  try
    lObj.AddPair('FAdvancedOptions', TJSONBool.Create(FAdvancedOptions));
    lObj.AddPair('FAutoMultiAccountTransactions', TJSONBool.Create(FAutoMultiAccountTransactions));
    lObj.AddPair('FUnlockTime',  TJSONNumber.Create(FUnlockTime));
    lObj.AddPair('FSelectedNodeURI', FSelectedNodeURI);
    lObj.AddPair('FSelected', TJSONNumber.Create(FSelected));

    lNodes := TJSONArray.Create;
    for nr in FNodes do
    begin
      lNode := TJSONObject.Create;
      lNode.AddPair('Name', nr.Name);
      lNode.AddPair('URI', nr.URI);
      lNode.AddPair('NetType', nr.NetType);
      lNodes.AddElement(lNode);
    end;

    lObj.AddPair('FNodes', lNodes);

    Result := lObj.ToJSON;
  finally
    lObj.Free;
  end;
end;

constructor TWalletAppSettings.Create;
begin
  inherited Create;
  FNodes := TList<TNodeRecord>.Create;
end;

destructor TWalletAppSettings.Destroy;
begin
  FNodes.Free;
  inherited;
end;

function TWalletAppSettings.GetAdvancedOptionsChanged
  : IEvent<TPascalCoinBooleanEvent>;
begin
  result := FAdvancedOptionsChanged;
end;

function TWalletAppSettings.GetOnUnlockTimeChange
  : IEvent<TPascalCoinIntegerEvent>;
begin
  result := FUnlockTimeChange;
end;

procedure TWalletAppSettings.SetAdvancedOptions(const Value: boolean);
begin
  if FAdvancedOptions = Value then
    Exit;
  FAdvancedOptions := Value;
  FAdvancedOptionsChanged.Invoke(FAdvancedOptions);
end;

procedure TWalletAppSettings.SetAsJSON(const Value: String);
var
lObj,nObj: TJSONObject;
lNodes: TJSONArray;
lVal: TJSONValue;
begin
  lObj := TJSONObject.ParseJSONValue(Value) as TJSONObject;

  FAdvancedOptions := lObj.Values['FAdvancedOptions'].AsType<Boolean>;
  FAutoMultiAccountTransactions := lObj.Values['FAutoMultiAccountTransactions'].AsType<boolean>;
  FUnlockTime := lObj.Values['FUnlockTime'].AsType<Integer>;
  FSelectedNodeURI := lObj.Values['FSelectedNodeURI'].AsType<String>;
  FSelected := lObj.Values['FSelected'].AsType<Integer>;

  FNodes.Clear;
  lNodes := lObj.Values['FNodes'] as TJSONArray;
  if lNodes <> nil then
  begin
    for lVal in lNodes do
    begin
      nObj := lVal as TJSONObject;
      FNodes.Add(TNodeRecord.Create(
         nobj.Values['Name'].AsType<string>,
         nobj.Values['URI'].AsType<string>,
         nobj.Values['NetType'].AsType<string>)
      );
    end;
  end;

end;

procedure TWalletAppSettings.SetAutoMultiAccountTransactions
  (const Value: boolean);
begin
  FAutoMultiAccountTransactions := Value;
end;

procedure TWalletAppSettings.SetUnlockTime(const Value: Integer);
begin
  if FUnlockTime <> Value then
  begin
    FUnlockTime := Value;
    FUnlockTimeChange.Invoke(FUnlockTime);
  end;
end;

{ TNodeRecord }

constructor TNodeRecord.Create(const AName, AURL, ANetType: string);
begin
  Name := AName;
  URI := AURL;
  NetType := ANetType;
end;

end.
