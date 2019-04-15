/// <summary>
/// <para>
/// Documentation for RPC: <see href="https://www.pascalcoin.org/development/rpc" />
/// </para>
/// <para>
/// <br />Every call MUST include 3 params: {"jsonrpc": "2.0", "method":
/// "XXX", "id": YYY}
/// </para>
/// <para>
/// <br />jsonrpc : String value = "2.0" <br />method : String value,
/// name of the method to call <br />id : Integer value <br />
/// </para>
/// <para>
/// Optionally can contain another param called "params" holding an
/// object. Inside we will include params to send to the method <br />
/// {"jsonrpc": "2.0", "method": "XXX", "id": YYY, "params":{"p1":"
/// ","p2":" "}}
/// </para>
/// </summary>
unit PascalCoin.RPC.Interfaces;

interface

uses System.Classes, System.JSON, System.SysUtils, System.Rtti,
  System.Generics.Collections, Spring.Container, PascalCoin.Utils.Interfaces;

type

  ErpcHTTPException = class(Exception);
  ERPCException = class(Exception);
{$SCOPEDENUMS ON}
  THTTPStatusType = (OK, Fail, Exception);
  TNodeAvailability = (NotTested, NotAvailable, Avaialable);
{$SCOPEDENUMS OFF}

  IRPCHTTPRequest = interface(IInvokable)
    ['{67CDB48B-C4F4-4C0F-BE61-BDA3497CF892}']
    function GetResponseStr: string;
    function GetStatusCode: integer;
    function GetStatusText: string;
    function GetStatusType: THTTPStatusType;

    procedure Clear;
    function Post(AURL: string; AData: string): boolean;

    property ResponseStr: string read GetResponseStr;
    property StatusCode: integer read GetStatusCode;
    property StatusText: string read GetStatusText;
    property StstusType: THTTPStatusType read GetStatusType;
  end;

  IPascalCoinNodeStatus = interface;

  IPascalCoinRPCClient = interface
    ['{A04B65F9-345E-44F7-B834-88CCFFFAC4B6}']
    function GetResult: TJSONObject;
    function GetResultStr: string;
    function GetNodeURI: String;
    procedure SetNodeURI(const Value: string);

    function RPCCall(const AMethod: String;
      const AParams: Array of TParamPair): boolean;
    property Result: TJSONObject read GetResult;
    property ResultStr: String read GetResultStr;
    property NodeURI: string read GetNodeURI write SetNodeURI;
  end;

  TKeyStyle = (ksUnkown, ksEncKey, ksB58Key);

  IPascalCoinAccount = interface
    ['{10B1816D-A796-46E6-94DA-A4C6C2125F82}']

    function GetAccount: Int64;
    procedure SetAccount(const Value: Int64);
    function GetPubKey: String;
    procedure SetPubKey(const Value: String);
    function GetBalance: Currency;
    procedure SetBalance(const Value: Currency);
    function GetN_Operation: integer;
    procedure SetN_Operation(const Value: integer);
    function GetUpdated_b: integer;
    procedure SetUpdated_b(const Value: integer);
    function GetState: String;
    procedure SetState(const Value: String);
    function GetLocked_Until_Block: integer;
    procedure SetLocked_Until_Block(const Value: integer);
    function GetPrice: Currency;
    procedure SetPrice(const Value: Currency);
    function GetSeller_Account: integer;
    procedure SetSeller_Account(const Value: integer);
    function GetPrivate_Sale: boolean;
    procedure SetPrivate_Sale(const Value: boolean);
    function GetNew_Enc_PubKey: String;
    procedure SetNew_Enc_PubKey(const Value: String);
    function GetName: String;
    procedure SetName(const Value: String);
    function GetAccount_Type: integer;
    procedure SetAccount_Type(const Value: integer);

    function SameAs(AAccount: IPascalCoinAccount): Boolean;
    procedure Assign(AAccount: IPascalCoinAccount);

    /// <summary>
    /// Account Number (PASA)
    /// </summary>
    property account: Int64 read GetAccount write SetAccount;
    /// <summary>
    /// HEXASTRING - Encoded public key value (See decodepubkey)
    /// </summary>
    property enc_pubkey: String read GetPubKey write SetPubKey;
    /// <summary>
    /// Account Balance
    /// </summary>
    property balance: Currency read GetBalance write SetBalance;
    /// <summary>
    /// Operations made by this account (Note: When an account receives a
    /// transaction, n_operation is not changed)
    /// </summary>
    property n_operation: integer read GetN_Operation write SetN_Operation;
    /// <summary>
    /// Last block that updated this account. If equal to blockchain blocks
    /// count it means that it has pending operations to be included to the
    /// blockchain.
    /// </summary>
    property updated_b: integer read GetUpdated_b write SetUpdated_b;
    /// <summary>
    /// Values can be normal or listed. When listed then account is for sale
    /// </summary>
    property state: String read GetState write SetState;
    /// <summary>
    /// Until what block this account is locked. Only set if state is listed
    /// </summary>
    property locked_until_block: integer read GetLocked_Until_Block
      write SetLocked_Until_Block;
    /// <summary>
    /// Price of account. Only set if state is listed
    /// </summary>
    property price: Currency read GetPrice write SetPrice;
    /// <summary>
    /// Seller's account number. Only set if state is listed
    /// </summary>
    property seller_account: integer read GetSeller_Account
      write SetSeller_Account;
    /// <summary>
    /// Whether sale is private. Only set if state is listed
    /// </summary>
    property private_sale: boolean read GetPrivate_Sale write SetPrivate_Sale;
    /// <summary>
    /// HEXSTRING - Private buyers public key. Only set if state is listed and
    /// private_sale is true
    /// </summary>
    property new_enc_pubkey: HexStr read GetNew_Enc_PubKey
      write SetNew_Enc_PubKey;
    /// <summary>
    /// Public name of account. Follows PascalCoin64 Encoding. Min Length = 3;
    /// Max Length = 64
    /// </summary>
    property name: String read GetName write SetName;
    /// <summary>
    /// Type of account. Valid values range from 0..65535
    /// </summary>
    property account_type: integer read GetAccount_Type write SetAccount_Type;

  end;

  IPascalCoinAccounts = interface
    ['{4C039C2C-4BED-4002-9EA2-7F16843A6860}']
    function GetAccount(const Index: integer): IPascalCoinAccount;
    function Count: integer;
    procedure Clear;
    function AddAccount(Value: IPascalCoinAccount): integer;
    // procedure AddAccounts(Value: IPascalCoinAccounts);
    function FindAccount(const Value: integer): IPascalCoinAccount; overload;
    function FindAccount(const Value: String): IPascalCoinAccount; overload;
    property account[const Index: integer]: IPascalCoinAccount
      read GetAccount; default;
  end;

  IPascalNetStats = interface
    ['{0F8214FA-D42F-44A7-9B5B-4D6B3285E860}']
    function GetActive: integer;
    procedure SetActive(const Value: integer);
    function GetClients: integer;
    procedure SetClients(const Value: integer);
    function GetServers: integer;
    procedure SetServers(const Value: integer);
    function GetServers_t: integer;
    procedure SetServers_t(const Value: integer);
    function GetTotal: integer;
    procedure SetTotal(const Value: integer);
    function GetTClients: integer;
    procedure SetTClients(const Value: integer);
    function GetTServers: integer;
    procedure SetTServers(const Value: integer);
    function GetBReceived: integer;
    procedure SetBReceived(const Value: integer);
    function GetBSend: integer;
    procedure SetBSend(const Value: integer);

    property active: integer read GetActive write SetActive;
    property clients: integer read GetClients write SetClients;
    property servers: integer read GetServers write SetServers;
    property servers_t: integer read GetServers_t write SetServers_t;
    property total: integer read GetTotal write SetTotal;
    property tclients: integer read GetTClients write SetTClients;
    property tservers: integer read GetTServers write SetTServers;
    property breceived: integer read GetBReceived write SetBReceived;
    property bsend: integer read GetBSend write SetBSend;
  end;

  IPascalCoinServer = interface
    ['{E9878551-ADDF-4D22-93A5-3832588ACC45}']
    function GetIP: String;
    procedure SetIP(const Value: String);
    function GetPort: integer;
    procedure SetPort(const Value: integer);
    function GetLastCon: integer;
    procedure SetLastCon(const Value: integer);
    function GetAttempts: integer;
    procedure SetAttempts(const Value: integer);
    function GetLastConAsDateTime: TDateTime;
    procedure SetLastConAsDateTime(const Value: TDateTime);
    property ip: String read GetIP write SetIP;
    property port: integer read GetPort write SetPort;
    property lastcon: integer read GetLastCon write SetLastCon;
    property LastConAsDateTime: TDateTime read GetLastConAsDateTime
      write SetLastConAsDateTime;
    property attempts: integer read GetAttempts write SetAttempts;
  end;

  IPascalCoinNetProtocol = interface
    ['{DBAAA45D-5AC1-4805-9FDB-5A6B66B193DC}']
    function GetVer: integer;
    procedure SetVer(const Value: integer);
    function GetVer_A: integer;
    procedure SetVer_A(const Value: integer);
    property ver: integer read GetVer write SetVer; // Net protocol version
    property ver_a: integer read GetVer_A write SetVer_A;
    // Net protocol available
  end;

  IPascalCoinNodeStatus = interface
    ['{9CDDF2CB-3064-4CD6-859A-9E11348FF621}']
    function GetReady: boolean;
    procedure SetReady(Const Value: boolean);
    function GetReady_S: String;
    procedure SetReady_S(Const Value: String);
    function GetStatus_S: String;
    procedure SetStatus_S(Const Value: String);
    function GetPort: integer;
    procedure SetPort(Const Value: integer);
    function GetLocked: boolean;
    procedure SetLocked(Const Value: boolean);
    function GetTimeStamp: integer;
    procedure SetTimeStamp(Const Value: integer);
    function GetVersion: String;
    procedure SetVersion(Const Value: String);
    function GetNetProtocol: IPascalCoinNetProtocol;
    function GetBlocks: integer;
    procedure SetBlocks(Const Value: integer);
    function GetNetStats: IPascalNetStats;
    function GetNodeServers: IPascalCoinList<IPascalCoinServer>;
    function GetSBH: String;
    procedure SetSBH(const Value: String);
    function GetPOW: String;
    procedure SetPOW(const Value: String);
    function GetOpenSSL: String;
    procedure SetOpenSSL(const Value: String);

    function GetTimeStampAsDateTime: TDateTime;
    procedure SetTimeStampAsDateTime(const Value: TDateTime);

    property ready: boolean read GetReady write SetReady;
    // Must be true, otherwise Node is not ready to execute operations
    property ready_s: String read GetReady_S write SetReady_S;
    // Human readable information about ready or not
    property status_s: String read GetStatus_S write SetStatus_S;
    // Human readable information about node status... Running, downloading blockchain, discovering servers...
    property port: integer read GetPort write SetPort; // Server port
    property locked: boolean read GetLocked write SetLocked;
    // True when this wallet is locked, false otherwise
    property timestamp: integer read GetTimeStamp write SetTimeStamp;
    // Timestamp of the Node
    property TimeStampAsDateTime: TDateTime read GetTimeStampAsDateTime
      write SetTimeStampAsDateTime;
    property version: String read GetVersion write SetVersion; // Server version
    property netprotocol: IPascalCoinNetProtocol read GetNetProtocol;
    property blocks: integer read GetBlocks write SetBlocks;
    // Blockchain blocks
    property netstats: IPascalNetStats read GetNetStats;
    // -JSON Object with net information
    property nodeservers: IPascalCoinList<IPascalCoinServer>
      read GetNodeServers; // JSON Array with servers candidates
    property sbh: string read GetSBH write SetSBH;
    property pow: string read GetPOW write SetPOW;
    property openssl: string read GetOpenSSL write SetOpenSSL;

  end;

  IPascalCoinBlock = interface
    ['{9BAA406C-BC52-4DB6-987D-BD458C0766E5}']
    function GetBlock: integer;
    function GetEnc_PubKey: String;
    function GetFee: Currency;
    function GetHashRateKHS: integer;
    function GetMaturation: integer;
    function GetNonce: integer;
    function GetOperations: integer;
    function GetOPH: String;
    function GetPayload: String;
    function GetPOW: String;
    function GetReward: Currency;
    function GetSBH: String;
    function GetTarget: integer;
    function GetTimeStamp: integer;
    function GetVer: integer;
    function GetVer_A: integer;
    procedure SetBlock(const Value: integer);
    procedure SetEnc_PubKey(const Value: String);
    procedure SetFee(const Value: Currency);
    procedure SetHashRateKHS(const Value: integer);
    procedure SetMaturation(const Value: integer);
    procedure SetNonce(const Value: integer);
    procedure SetOperations(const Value: integer);
    procedure SetOPH(const Value: String);
    procedure SetPayload(const Value: String);
    procedure SetPOW(const Value: String);
    procedure SetReward(const Value: Currency);
    procedure SetSBH(const Value: String);
    procedure SetTarget(const Value: integer);
    procedure SetTimeStamp(const Value: integer);
    procedure SetVer(const Value: integer);
    procedure SetVer_A(const Value: integer);

    function GetDelphiTimeStamp: TDateTime;
    procedure SetDelphiTimeStamp(const Value: TDateTime);

    property block: integer read GetBlock write SetBlock; // Block number
    property enc_pubkey: String read GetEnc_PubKey write SetEnc_PubKey;
    // Encoded public key value used to init 5 created accounts of this block (See decodepubkey )
    property reward: Currency read GetReward write SetReward;
    // Reward of first account's block
    property fee: Currency read GetFee write SetFee;
    // Fee obtained by operations
    property ver: integer read GetVer write SetVer; // Pascal Coin protocol used
    property ver_a: integer read GetVer_A write SetVer_A;
    // Pascal Coin protocol available by the miner
    property timestamp: integer read GetTimeStamp write SetTimeStamp;
    // Unix timestamp
    property target: integer read GetTarget write SetTarget; // Target used
    property nonce: integer read GetNonce write SetNonce; // Nonce used
    property payload: String read GetPayload write SetPayload;
    // Miner's payload
    property sbh: String read GetSBH write SetSBH; // SafeBox Hash
    property oph: String read GetOPH write SetOPH; // Operations hash
    property pow: String read GetPOW write SetPOW; // Proof of work
    property operations: integer read GetOperations write SetOperations;
    // Number of operations included in this block
    property hashratekhs: integer read GetHashRateKHS write SetHashRateKHS;
    // Estimated network hashrate calculated by previous 50 blocks average
    property maturation: integer read GetMaturation write SetMaturation;
    // Number of blocks in the blockchain higher than this

    property DelphiTimeStamp: TDateTime Read GetDelphiTimeStamp
      write SetDelphiTimeStamp;
  end;

  /// <summary>
  /// straight integer mapping from the returned opType value
  /// </summary>
  TOperationType = (
    /// <summary>
    /// 0 - Blockchain Reward
    /// </summary>
    BlockchainReward,
    /// <summary>
    /// 1 = Transaction
    /// </summary>
    Transaction,
    /// <summary>
    /// 2 = Change Key
    /// </summary>
    ChangeKey,
    /// <summary>
    /// 3 = Recover Funds (lost keys)
    /// </summary>
    RecoverFunds, // (lost keys)
    /// <summary>
    /// 4 = List account for sale
    /// </summary>
    ListAccountForSale,
    /// <summary>
    /// 5 = Delist account (not for sale)
    /// </summary>
    DelistAccountForSale, // (not for sale)
    /// <summary>
    /// 6 = Buy account
    /// </summary>
    BuyAccount,
    /// <summary>
    /// 7 = Change Key signed by another account
    /// </summary>
    ChangeAccountKey, // (signed by another account)
    /// <summary>
    /// 8 = Change account info
    /// </summary>
    ChangeAccountInfo,
    /// <summary>
    /// 9 = Multi operation (introduced on Build 3.0)
    /// </summary>
    Multioperation);

  IPascalCoinSender = interface
    ['{F66B882F-C16E-4447-B881-CC3CFFABD287}']
    function GetAccount: Cardinal;
    procedure SetAccount(const Value: Cardinal);
    function GetN_Operation: integer;
    procedure SetN_Operation(const Value: integer);
    function GetAmount: Currency;
    procedure SetAmount(const Value: Currency);
    function GetPayload: HexStr;
    procedure SetPayload(const Value: HexStr);

    /// <summary>
    /// Sending account (PASA)
    /// </summary>
    property account: Cardinal read GetAccount write SetAccount;
    property n_operation: integer read GetN_Operation write SetN_Operation;
    /// <summary>
    /// In negative value, due it's outgoing from "account"
    /// </summary>
    property amount: Currency read GetAmount write SetAmount;
    property payload: HexStr read GetPayload write SetPayload;
  end;

  IPascalCoinReceiver = interface
    ['{3036AE17-52D6-4FF5-9541-E0B211FFE049}']
    function GetAccount: Cardinal;
    procedure SetAccount(const Value: Cardinal);
    function GetAmount: Currency;
    procedure SetAmount(const Value: Currency);
    function GetPayload: HexStr;
    procedure SetPayload(const Value: HexStr);

    /// <summary>
    /// Receiving account (PASA)
    /// </summary>
    property account: Cardinal read GetAccount write SetAccount;
    /// <summary>
    /// In positive value, due it's incoming from a sender to "account"
    /// </summary>
    property amount: Currency read GetAmount write SetAmount;
    property payload: HexStr read GetPayload write SetPayload;
  end;

  IPascalCoinChanger = interface
    ['{860CE51D-D0D5-4AF0-9BD3-E2858BF1C59F}']
    function GetAccount: Cardinal;
    procedure SetAccount(const Value: Cardinal);
    function GetN_Operation: integer;
    procedure SetN_Operation(const Value: integer);
    function GetNew_Enc_PubKey: string;
    procedure SetNew_Enc_PubKey(const Value: string);
    function GetNew_Type: string;
    procedure SetNew_Type(const Value: string);
    function GetSeller_Account: Cardinal;
    procedure SetSeller_Account(const Value: Cardinal);
    function GetAccount_price: Currency;
    procedure SetAccount_price(const Value: Currency);
    function GetLocked_Until_Block: UInt64;
    procedure SetLocked_Until_Block(const Value: UInt64);
    function GetFee: Currency;
    procedure SetFee(const Value: Currency);

    /// <summary>
    /// changing Account
    /// </summary>
    property account: Cardinal read GetAccount write SetAccount;
    property n_operation: integer read GetN_Operation write SetN_Operation;
    /// <summary>
    /// If public key is changed or when is listed for a private sale <br />
    /// property new_name: If name is changed
    /// </summary>
    property new_enc_pubkey: string read GetNew_Enc_PubKey
      write SetNew_Enc_PubKey;
    /// <summary>
    /// if type is changed
    /// </summary>
    property new_type: string read GetNew_Type write SetNew_Type;
    /// <summary>
    /// If is listed for sale (public or private) will show seller account
    /// </summary>
    property seller_account: Cardinal read GetSeller_Account
      write SetSeller_Account;
    /// <summary>
    /// If is listed for sale (public or private) will show account price
    /// </summary>
    property account_price: Currency read GetAccount_price
      write SetAccount_price;
    /// <summary>
    /// If is listed for private sale will show block locked
    /// </summary>
    property locked_until_block: UInt64 read GetLocked_Until_Block
      write SetLocked_Until_Block;
    /// <summary>
    /// In negative value, due it's outgoing from "account"
    /// </summary>
    property fee: Currency read GetFee write SetFee;
  end;

  IPascalCoinOperation = interface
    ['{0C059E68-CE57-4F06-9411-AAD2382246DE}']
    function GetValid: boolean;
    procedure SetValid(const Value: boolean);
    function GetErrors: string;
    procedure SetErrors(const Value: string);
    function GetBlock: UInt64;
    procedure SetBlock(const Value: UInt64);
    function GetTime: integer;
    procedure SetTime(const Value: integer);
    function GetOpblock: integer;
    procedure SetOpblock(const Value: integer);
    function GetMaturation: integer;
    procedure SetMaturation(const Value: integer);
    function GetOptype: integer;
    procedure SetOptype(const Value: integer);
    function GetOperationType: TOperationType;
    procedure SetOperationType(const Value: TOperationType);
    function GetOptxt: string;
    procedure SetOptxt(const Value: string);
    function GetAccount: Cardinal;
    procedure SetAccount(const Value: Cardinal);
    function GetAmount: Currency;
    procedure SetAmount(const Value: Currency);
    function GetFee: Currency;
    procedure SetFee(const Value: Currency);
    function GetBalance: Currency;
    procedure SetBalance(const Value: Currency);
    function GetSender_account: Cardinal;
    procedure SetSender_Account(const Value: Cardinal);
    function GetDest_account: Cardinal;
    procedure SetDest_Account(const Value: Cardinal);
    function GetEnc_PubKey: HexStr;
    procedure SetEnc_PubKey(const Value: HexStr);
    function GetOphash: HexStr;
    procedure SetOphash(const Value: HexStr);
    function GetOld_ophash: HexStr;
    procedure SetOld_ophash(const Value: HexStr);
    function GetSubtype: string;
    procedure SetSubtype(const Value: string);
    function GetSigner_account: Cardinal;
    procedure SetSigner_account(const Value: Cardinal);
    function GetN_Operation: integer;
    procedure SetN_Operation(const Value: integer);
    function GetPayload: HexStr;
    procedure SetPayload(const Value: HexStr);

    function GetSenders: IPascalCoinList<IPascalCoinSender>;
    procedure SetSenders(Value: IPascalCoinList<IPascalCoinSender>);
    function GetReceivers: IPascalCoinList<IPascalCoinReceiver>;
    procedure SetReceivers(Value: IPascalCoinList<IPascalCoinReceiver>);
    function GetChangers: IPascalCoinList<IPascalCoinChanger>;
    procedure SetChangers(Value: IPascalCoinList<IPascalCoinChanger>);

    /// <summary>
    /// (optional) - If operation is invalid, value=false
    /// </summary>
    property valid: boolean read GetValid write SetValid;
    /// <summary>
    /// (optional) - If operation is invalid, an error description
    /// </summary>
    property errors: String read GetErrors write SetErrors;
    /// <summary>
    /// Block number (only when valid)
    /// </summary>
    property block: UInt64 read GetBlock write SetBlock;
    /// <summary>
    /// Block timestamp (only when valid)
    /// </summary>
    property time: integer read GetTime write SetTime;
    /// <summary>
    /// Operation index inside a block (0..operations-1). Note: If opblock=-1
    /// means that is a blockchain reward (only when valid)
    /// </summary>
    property opblock: integer read GetOpblock write SetOpblock;
    /// <summary>
    /// Return null when operation is not included on a blockchain yet, 0 means
    /// that is included in highest block and so on...
    /// </summary>
    property maturation: integer read GetMaturation write SetMaturation;
    /// <summary>
    /// see TOperationType above
    /// </summary>
    property optype: integer read GetOptype write SetOptype;
    /// <summary>
    /// converts optype to TOperationType
    /// </summary>
    property OperationType: TOperationType read GetOperationType
      write SetOperationType;
    /// <summary>
    /// Human readable operation type
    /// </summary>
    property optxt: String read GetOptxt write SetOptxt;
    /// <summary>
    /// Account affected by this operation. Note: A transaction has 2 affected
    /// accounts.
    /// </summary>
    property account: Cardinal read GetAccount write SetAccount;
    /// <summary>
    /// Amount of coins transferred from sender_account to dest_account (Only
    /// apply when optype=1)
    /// </summary>
    property amount: Currency read GetAmount write SetAmount;
    /// <summary>
    /// Fee of this operation
    /// </summary>
    property fee: Currency read GetFee write SetFee;
    /// <summary>
    /// Balance of account after this block is introduced in the Blockchain.
    /// Note: balance is a calculation based on current safebox account balance
    /// and previous operations, it's only returned on pending operations and
    /// account operations <br />
    /// </summary>
    property balance: Currency read GetBalance write SetBalance;
    /// <summary>
    /// Sender account in a transaction (only when optype = 1) <b>DEPRECATED</b>,
    /// use senders array instead
    /// </summary>
    property sender_account: Cardinal read GetSender_account
      write SetSender_Account;
    /// <summary>
    /// Destination account in a transaction (only when optype = 1) <b>DEPRECATED</b>
    /// , use receivers array instead
    /// </summary>
    property dest_account: Cardinal read GetDest_account write SetDest_Account;
    /// <summary>
    /// HEXASTRING - Encoded public key in a change key operation (only when
    /// optype = 2). See decodepubkey <b>DEPRECATED</b>, use changers array
    /// instead. See commented out enc_pubkey below. A second definition for use
    /// with other operation types: Will return both change key and the private
    /// sale public key value <b>DEPRECATED</b><br />
    /// </summary>
    property enc_pubkey: HexStr read GetEnc_PubKey write SetEnc_PubKey;
    /// <summary>
    /// HEXASTRING - Operation hash used to find this operation in the blockchain
    /// </summary>
    property ophash: HexStr read GetOphash write SetOphash;
    /// <summary>
    /// /// &lt;summary&gt; <br />/// HEXSTRING - Operation hash as calculated
    /// prior to V2. Will only be <br />/// populated for blocks prior to V2
    /// activation. &lt;b&gt;DEPRECATED&lt;/b&gt; <br />/// &lt;/summary&gt;
    /// </summary>
    property old_ophash: HexStr read GetOld_ophash write SetOld_ophash;
    /// <summary>
    /// Associated with optype param, can be used to discriminate from the point
    /// of view of operation (sender/receiver/buyer/seller ...)
    /// </summary>
    property subtype: String read GetSubtype write SetSubtype;
    /// <summary>
    /// Will return the account that signed (and payed fee) for this operation.
    /// Not used when is a Multioperation (optype = 9)
    /// </summary>
    property signer_account: Cardinal read GetSigner_account
      write SetSigner_account;

    property n_operation: integer read GetN_Operation write SetN_Operation;
    property payload: HexStr read GetPayload write SetPayload;

    // property enc_pubkey: HexStr HEXSTRING - Will return both change key and the private sale public key value DEPRECATED, use changers array instead

    /// <summary>
    /// ARRAY of objects with senders, for example in a transaction (optype = 1)
    /// or multioperation senders (optype = 9)
    /// </summary>
    property senders: IPascalCoinList<IPascalCoinSender> read GetSenders
      write SetSenders;
    /// <summary>
    /// ARRAY of objects - When is a transaction or multioperation, this array
    /// contains each receiver
    /// </summary>
    property receivers: IPascalCoinList<IPascalCoinReceiver> read GetReceivers
      write SetReceivers;
    /// <summary>
    /// ARRAY of objects - When accounts changed state
    /// </summary>
    property changers: IPascalCoinList<IPascalCoinChanger> read GetChangers
      write SetChangers;

  end;

  IPascalCoinAPI = interface
    ['{310A40ED-F917-4075-B495-5E4906C4D8EB}']
    function GetNodeURI: String;
    procedure SetNodeURI(const Value: string);

    function GetCurrentNodeStatus: IPascalCoinNodeStatus;
    function GetNodeAvailability: TNodeAvailability;
    function GetIsTestNet: Boolean;

    function GetLastError: String;

    function GetJSONResult: TJSONValue;
    function GetJSONResultStr: string;

    function URI(const Value: string): IPascalCoinAPI;

    function GetAccount(const AAccountNumber: Cardinal): IPascalCoinAccount;
    function getwalletaccounts(const APublicKey: String;
      const AKeyStyle: TKeyStyle; const AMaxCount: integer = -1)
      : IPascalCoinAccounts;
    function getwalletaccountscount(const APublicKey: String;
      const AKeyStyle: TKeyStyle): integer;
    function GetBlock(const BlockNumber: integer): IPascalCoinBlock;

    /// <summary>
    /// Get operations made to an account <br />
    /// </summary>
    /// <param name="AAcoount">
    /// Account number (0..accounts count-1)
    /// </param>
    /// <param name="ADepth">
    /// Optional, default value 100 Depth to search on blocks where this
    /// account has been affected. Allowed to use deep as a param name too.
    /// </param>
    /// <param name="AStart">
    /// Optional, default = 0. If provided, will start at this position (index
    /// starts at position 0). If start is -1, then will include pending
    /// operations, otherwise only operations included on the blockchain
    /// </param>
    /// <param name="AMax">
    /// Optional, default = 100. If provided, will return max registers. If not
    /// provided, max=100 by default
    /// </param>
    function getaccountoperations(const AAccount: Cardinal;
      const ADepth: integer = 100; const AStart: integer = 0;
      const AMax: integer = 100): IPascalCoinList<IPascalCoinOperation>;
    function NodeStatus: IPascalCoinNodeStatus;

    function executeoperation(const RawOperation: string): IPascalCoinOperation;

    /// <summary>
    /// Encrypt a text "payload" using "payload_method" <br /><br /><br /><br />
    /// </summary>
    /// <param name="APayload">
    /// HEXASTRING - Text to encrypt in hexadecimal format
    /// </param>
    /// <param name="AKey">
    /// enc_pubkey : HEXASTRING <br />or <br />b58_pubkey : String
    /// </param>
    /// <param name="AKeyStyle">
    /// ksEncKey or ksB58Key
    /// </param>
    /// <returns>
    /// Returns a HEXASTRING with encrypted payload
    /// </returns>
    function payloadEncryptWithPublicKey(const APayload: string;
      const AKey: string; const AKeyStyle: TKeyStyle): string;

    // function getwalletcoins(const APublicKey: String): Currency;
    // getblocks - Get a list of blocks (last n blocks, or from start to end)
    // getblockcount - Get blockchain high in this node
    // getblockoperation - Get an operation of the block information
    // getblockoperations - Get all operations of specified block
    // getpendings - Get pendings operations to be included in the blockchain
    // getpendingscount - Returns node pending buffer count ( New on Build 3.0 )
    // findoperation - Find

    property JSONResult: TJSONValue read GetJSONResult;
    property JSONResultStr: string read GetJSONResultStr;
    property NodeURI: string read GetNodeURI write SetNodeURI;
    property CurrenNodeStatus: IPascalCoinNodeStatus read GetCurrentNodeStatus;
    property NodeAvailability: TNodeAvailability read GetNodeAvailability;
    property IsTestNet: Boolean read GetIsTestNet;
    property LastError: String read GetLastError;
  end;

implementation

end.
