unit PascalCoin.Update.Classes;

interface

uses Spring, System.SysUtils, System.Classes, System.Generics.Collections,
PascalCoin.Update.Interfaces, PascalCoin.RPC.Interfaces;

type

  TUpdatedAccount = class(TInterfacedObject, IUpdatedAccount)
  private
    FAccount: IPascalCoinAccount;
    FStatus: TAccountUpdateStatus;
    FUpdateId: Integer;
  protected
    function GetAccount: IPascalCoinAccount;
    procedure SetAccount(Value: IPascalCoinAccount);
    function GetStatus: TAccountUpdateStatus;
    procedure SetStatus(const Value: TAccountUpdateStatus);
    function GetUpdateId: Integer;
    procedure SetUpdateId(const Value: Integer);
  public
    constructor Create;
  end;

  TPascalCoinFetchThread = Class(TThread)
  private
    FAPI: IPascalCoinAPI;
    FKeyList: TStrings;
    FSleepInterval: Integer;
    FSyncMethod: TThreadMethod;
    FAccounts: IPascalCoinAccounts;
    FAccountsStore: TDictionary<Int64, IUpdatedAccount>;
    FUpdatedAccounts: IUpdatedAccounts;
    FKeyStyle: TKeyStyle;
    FSyncSuccess: boolean;
    FUpdateId: Integer;
    FPaused: boolean;
    procedure ProcessKeys;
    procedure SetNodeURI(const Value: String);
  protected
    procedure Execute; override;
  public
    constructor Create(rpcAPI: IPascalCoinAPI;
      AAccountsList: IPascalCoinAccounts);
    destructor Destroy; override;

    /// <summary>
    /// Only call this in Create and SyncMethod until I sort it out properly or
    /// Omni Thread Library is multi platform.
    /// </summary>
    procedure UpdateList(AKeyList: TStrings);
    property SleepInterval: Integer write FSleepInterval;
    property SyncMethod: TThreadMethod write FSyncMethod;
    property Accounts: IPascalCoinAccounts read FAccounts;
    property UpdatedAccounts: IUpdatedAccounts read FUpdatedAccounts;
    property KeyStyle: TKeyStyle write FKeyStyle;
    property SyncSuccess: boolean read FSyncSuccess;
    property NodeURI: String write SetNodeURI;
    property Pause: boolean write FPaused;
  End;

  TFetchAccountData = class(TInterfacedObject, IFetchAccountData)
  private
    FKeyStyle: TKeyStyle;
    FPublicKeys: TStringList;
    FKeysAdded: boolean;
    FSleepInterval: Integer;
    FThread: TPascalCoinFetchThread;
    FOnSync: Event<TOnAccountsUpdated>;
    FInitialised: boolean;
    FFailedInitProcessed: boolean;
    FIsRunning: boolean;
    FAccountsList: IPascalCoinAccounts;
    FPause: Boolean;
    procedure InitialiseThread;
    procedure ThreadSync;
  protected
    procedure SetURI(const Value: string);
    function GetIsRunning: boolean;
    function GetOnSync: IEvent<TOnAccountsUpdated>;
    function GetSleepInterval: Integer;
    procedure SetSleepInterval(const Value: Integer);
    procedure SetKeyStyle(const Value: TKeyStyle);
    function GetPause: Boolean;
    procedure SetPause(const Value: boolean);


    procedure AddPublicKey(const Value: string);
    procedure AddPublicKeys(Value: TStrings);

    function Execute: boolean;
    procedure Terminate;

  public
    constructor Create(AAPI: IPascalCoinAPI; AAccountsList: IPascalCoinAccounts);
    destructor Destroy; override;

  end;

implementation

uses PascalCoin.Utils.Classes, PascalCoin.RPC.Account;

{ TFetchAccountData }

procedure TFetchAccountData.AddPublicKey(const Value: string);
var
  lCount: Integer;
begin
  lCount := FPublicKeys.Count;
  FPublicKeys.Add(Value);
  FKeysAdded := FKeysAdded or (FPublicKeys.Count > lCount);
end;

procedure TFetchAccountData.AddPublicKeys(Value: TStrings);
var
  S: String;
begin
  for S in Value do
    AddPublicKey(S);
end;

constructor TFetchAccountData.Create(AAPI: IPascalCoinAPI; AAccountsList:
    IPascalCoinAccounts);
begin
  inherited Create;
  FSleepInterval := 10000;
  FFailedInitProcessed := False;
  FPublicKeys := TStringList.Create;
  FPublicKeys.Sorted := True;
  FPublicKeys.Duplicates := dupIgnore;
  FAccountsList := AAccountsList;

  FThread := TPascalCoinFetchThread.Create(AAPI, FAccountsList);
  FThread.SyncMethod := ThreadSync;
  FThread.SleepInterval := FSleepInterval;

end;

destructor TFetchAccountData.Destroy;
begin
  Terminate;
  FPublicKeys.Free;
  inherited;
end;

function TFetchAccountData.Execute: boolean;
begin
  InitialiseThread;
  if FThread.Suspended then
    FThread.Start;
  FIsRunning := True;
  Result := True;
end;

function TFetchAccountData.GetOnSync: IEvent<TOnAccountsUpdated>;
begin
  result := FOnSync;
end;

function TFetchAccountData.GetPause: Boolean;
begin
  result := FPause;
end;

function TFetchAccountData.GetSleepInterval: Integer;
begin
  result := FSleepInterval;
end;

procedure TFetchAccountData.InitialiseThread;
begin
  if FInitialised then
    Exit;

  FThread.UpdateList(FPublicKeys);
  FKeysAdded := False;
  FThread.KeyStyle := FKeyStyle;
  FInitialised := True;
end;

function TFetchAccountData.GetIsRunning: boolean;
begin
  result := FIsRunning;
end;

procedure TFetchAccountData.SetKeyStyle(const Value: TKeyStyle);
begin
  FKeyStyle := Value;
end;

procedure TFetchAccountData.SetPause(const Value: boolean);
begin
  FPause := Value;
  FThread.Pause := FPause;
end;

procedure TFetchAccountData.SetSleepInterval(const Value: Integer);
begin
  FSleepInterval := Value;
end;

procedure TFetchAccountData.SetURI(const Value: string);
begin
  FThread.NodeURI := Value;
end;

procedure TFetchAccountData.Terminate;
begin
  // waitfor?
  FThread.Terminate;
  FIsRunning := False;
end;

procedure TFetchAccountData.ThreadSync;
begin
  if FThread.SyncSuccess then
  begin
    if (FThread.UpdatedAccounts.Count = 0) then
       Exit;

    FOnSync.Invoke(FThread.UpdatedAccounts);
    FThread.SleepInterval := FSleepInterval;
    if FKeysAdded then
    begin
      FThread.UpdateList(FPublicKeys);
      FKeysAdded := False;
      FThread.KeyStyle := FKeyStyle;
    end;
    FFailedInitProcessed := False;
  end
  else
  begin
    if not FFailedInitProcessed then
    begin
      FOnSync.Invoke(nil);
      FFailedInitProcessed := True;
      FIsRunning := False;
    end;
  end;
end;

{ TPascalCoinFetchThread }

constructor TPascalCoinFetchThread.Create(rpcAPI: IPascalCoinAPI;
  AAccountsList: IPascalCoinAccounts);
begin
  inherited Create(True);
  FUpdateId := -1;
  FKeyList := TStringList.Create;
  TStringList(FKeyList).Sorted := True;
  TStringList(FKeyList).Duplicates := dupIgnore;
  FAPI := rpcAPI;
  FAccounts := AAccountsList;
  FAccountsStore := TDictionary<Int64, IUpdatedAccount>.Create;
  FUpdatedAccounts := TPascalCoinList<IUpdatedAccount>.Create;
end;

destructor TPascalCoinFetchThread.Destroy;
begin
  FKeyList.Free;
  FAccountsStore.Free;
  inherited;
end;

procedure TPascalCoinFetchThread.Execute;
begin
  while not Terminated do
  begin

    if FPaused then
    begin
      Sleep(100);
      Continue;
    end;

    if FAPI.NodeAvailability = TNodeAvailability.Avaialable then
      ProcessKeys
    else
      FSyncSuccess := False;

    Synchronize(FSyncMethod);
    // if not FSyncSuccess then
    // begin
    // Terminate;
    // Break;
    // end;

    Sleep(FSleepInterval)
  end;

end;

procedure TPascalCoinFetchThread.ProcessKeys;

  procedure AddUpdatedAccount(AUpdAcct: IUpdatedAccount);
  var lAcct: IUpdatedAccount;
  begin
    lAcct := TUpdatedAccount.Create;
    lAcct.Status := AUpdAcct.Status;
    lAcct.UpdateId := AUpdAcct.UpdateId;
    lAcct.Account.Assign(AUpdAcct.Account);
    FUpdatedAccounts.Add(lAcct);
  end;

var
  I, J: Integer;
  ISF: Int64;
  lAccts: IPascalCoinAccounts;
  lUpdAcct: IUpdatedAccount;
begin
  FAccounts.Clear;
  FUpdatedAccounts.Clear;

  for I := 0 to FKeyList.Count - 1 do
  begin
    try
      lAccts := FAPI.getwalletaccounts(FKeyList[I], FKeyStyle);
      for J := 0 to lAccts.Count - 1 do
      begin
        FAccounts.AddAccount(lAccts.Account[J]);
      end;
      FSyncSuccess := True;
    except
      on e: exception do
        FSyncSuccess := False;
    end;
  end;


  if not FSyncSuccess then
     Exit;

  Inc(FUpdateId);

  for I := 0 to FAccounts.Count -1 do
  begin
    if FAccountsStore.TryGetValue(FAccounts[I].account, lUpdAcct) then
    begin
      lUpdAcct.UpdateId := FUpdateId;
      if not lUpdAcct.Account.SameAs(FAccounts[I]) then
      begin
        lUpdAcct.Account.Assign(FAccounts[I]);
        lUpdAcct.Status := TAccountUpdateStatus.Changed;
      end
      else
        lUpdAcct.Status := TAccountUpdateStatus.NoChange;
    end
    else //Need to create one
    begin
      lUpdAcct := TUpdatedAccount.Create;
      lUpdAcct.Status := TAccountUpdateStatus.Added;
      lUpdAcct.UpdateId := FUpdateId;
      lUpdAcct.Account.Assign(FAccounts[I]);
      FAccountsStore.TryAdd(FAccounts[I].account, lUpdAcct);
      AddUpdatedAccount(lUpdAcct);
    end;

  end;

  //now are there any too delete?

  for ISF In FAccountsStore.Keys do
  begin
    lUpdAcct := FAccountsStore.Items[ISF];
    if lUpdAcct.UpdateId <> FUpdateId then
    begin
      lUpdAcct.Status := TAccountUpdateStatus.Deleted;
      AddUpdatedAccount(lUpdAcct);
      FAccountsStore.Remove(ISF);
    end;
  end;

end;

procedure TPascalCoinFetchThread.SetNodeURI(const Value: String);
begin
  FAPI.NodeURI := Value;
end;

procedure TPascalCoinFetchThread.UpdateList(AKeyList: TStrings);
begin
  FKeyList.Assign(AKeyList);
end;

{ TUpdatedAccount }

constructor TUpdatedAccount.Create;
begin
  { TODO : This is lazy }
  FAccount := TPascalCoinAccount.Create;
end;

function TUpdatedAccount.GetAccount: IPascalCoinAccount;
begin
  result := FAccount;
end;

function TUpdatedAccount.GetStatus: TAccountUpdateStatus;
begin
  result := FStatus;
end;

function TUpdatedAccount.GetUpdateId: Integer;
begin
  result := FUpdateId;
end;

procedure TUpdatedAccount.SetAccount(Value: IPascalCoinAccount);
begin
  FAccount := Value;
end;

procedure TUpdatedAccount.SetStatus(const Value: TAccountUpdateStatus);
begin
  FStatus := Value;
end;

procedure TUpdatedAccount.SetUpdateId(const Value: Integer);
begin
  FUpdateId := Value;
end;

end.
