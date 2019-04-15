unit PascalCoin.Update.Interfaces;

interface

uses Spring, PascalCoin.RPC.Interfaces, PascalCoin.Utils.Interfaces,
System.Classes;

type

  {$SCOPEDENUMS ON}
  TAccountUpdateStatus = (NotFound, NoChange, Changed, Added, Deleted);
  {$SCOPEDENUMS OFF}

  IUpdatedAccount = Interface
  ['{17DDA9D7-C141-4FAE-BAC6-63E69BE28E76}']
    function GetAccount: IPascalCoinAccount;
    procedure SetAccount(Value: IPascalCoinAccount);
    function GetStatus: TAccountUpdateStatus;
    procedure SetStatus(const Value: TAccountUpdateStatus);
    function GetUpdateId: Integer;
    procedure SetUpdateId(const Value: Integer);

    property Account: IPascalCoinAccount read GetAccount write SetAccount;
    property Status: TAccountUpdateStatus read GetStatus write SetStatus;
    property UpdateId: Integer read GetUpdateId write SetUpdateId;
  End;

  IUpdatedAccounts = IPascalCoinList<IUpdatedAccount>;

  TOnAccountsUpdated = procedure(Value: IUpdatedAccounts) of object;


  IFetchAccountData = interface
    ['{1E8237E8-69F8-4196-A5CB-A0BBE07A6223}']
    function GetOnSync: IEvent<TOnAccountsUpdated>;
    function GetSleepInterval: integer;
    procedure SetSleepInterval(const Value: integer);
    procedure SetKeyStyle(const Value: TKeyStyle);
    function GetIsRunning: boolean;
    function GetPause: Boolean;
    procedure SetPause(const Value: boolean);
    procedure SetURI(const Value: string);

    procedure AddPublicKey(const Value: string);
    procedure AddPublicKeys(Value: TStrings);

    function Execute: boolean;
    procedure Terminate;

    /// <summary>
    /// How long the thread sleeps before iterating through the list again
    /// (milliseconds: default 10000)
    /// </summary>
    property SleepInterval: integer read GetSleepInterval
      write SetSleepInterval;
    property OnSync: IEvent<TOnAccountsUpdated> read GetOnSync;
    property KeyStyle: TKeyStyle write SetKeyStyle;
    property IsRunning: boolean read GetIsRunning;
    property NodeURI: string write SetURI;
    property Pause: boolean read GetPause write SetPause;
  end;

implementation

end.
