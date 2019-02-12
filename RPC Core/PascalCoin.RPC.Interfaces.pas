unit PascalCoin.RPC.Interfaces;

//==========================================================================//
//
//
// Documentation for RPC: https://www.pascalcoin.org/development/rpc

//Every call MUST include 3 params: {"jsonrpc": "2.0", "method": "XXX", "id": YYY}
//jsonrpc : String value = "2.0"
//method : String value, name of the method to call
//id : Integer value
//Optionally can contain another param called "params" holding an object. Inside we will include params to send to the method
//{"jsonrpc": "2.0", "method": "XXX", "id": YYY, "params":{"p1":" ","p2":" "}}

interface

uses System.Classes, System.JSON, System.SysUtils, System.Rtti,
System.Generics.Collections, Spring.Container, PascalCoin.Utils.Interfaces;

type

ErpcHTTPException = class(Exception);
ERPCException = class(Exception);

//IParam<T> = interface
//['{3ACCF84B-47A7-4E64-9D74-2065C50CEF37}']
//  function GetKey: String;
//  procedure SetKey(const Value: String);
//  function GetValue: T;
//  procedure SetValue(const Value: T);
//  property Key: String read GetKey write SetKey;
//  property Value: T read GetValue write SetValue;
//end;

TStringPair = TPair<string, string>;
TParamPair = TPair<string, variant>;

IRPCHTTPRequest  = interface(IInvokable)
['{67CDB48B-C4F4-4C0F-BE61-BDA3497CF892}']
  function GetResponseStr: string;
  function GetStatusCode: integer;
  function GetStatusText: string;

  procedure Clear;
  function Post(AURL: string; AData: string): boolean;

  property ResponseStr: string read GetResponseStr;
  property StatusCode: integer read GetStatusCode;
  property StatusText: string read GetStatusText;
end;

IPascalCoinRPCConfig = interface
['{6BE2425B-3C4E-4986-9A01-1725D926820C}']
  function GetNodeName: string;
  procedure SetNodeName(const Value: string);
  function GetNodeURL: string;
  procedure SetNodeURL(const Value: string);
  function GetContainer: TContainer;
  procedure SetContainer(Value: TContainer);
  function GetNodeList: TArray<TStringPair>;
  procedure SetNodeListItemIndex(const Value: Integer);
  function NextId: string;
  property NodeName: string read GetNodeName write SetNodeName;
  property NodeURL: string read GetNodeURL write SetNodeURL;
  property Container: TContainer read GetContainer write SetContainer;
  property NodeList: TArray<TStringPair> read GetNodeList;
  property NodeListItemIndex: Integer write SetNodeListItemIndex;
end;

IPascalCoinRPCClient = interface
['{A04B65F9-345E-44F7-B834-88CCFFFAC4B6}']
  function GetResult: TJSONObject;
  function GetResultStr: string;

  function RPCCall(const AMethod: String; const AParams: Array of TParamPair): Boolean;
  property Result: TJSONObject read GetResult;
  property ResultStr: String read GetResultStr;
end;

TKeyStyle = (ksUnkown, ksEncKey, ksB58Key);

IPascalCoinAccount = interface
['{10B1816D-A796-46E6-94DA-A4C6C2125F82}']

  function GetAccount: Integer;
  procedure SetAccount(const Value: Integer);
  function GetPubKey: String;
  procedure SetPubKey(const Value: String);
  function GetBalance: Currency;
  procedure SetBalance(const Value: Currency);
  function GetN_Operation: Integer;
  procedure SetN_Operation(const Value: Integer);
  function GetUpdated_b: Integer;
  procedure SetUpdated_b(const Value: Integer);
  function GetState: String;
  procedure SetState(const Value: String);
  function GetLocked_Until_Block: Integer;
  procedure SetLocked_Until_Block(const Value: Integer);
  function GetPrice: Currency;
  procedure SetPrice(const Value: Currency);
  function GetSeller_Account: Integer;
  procedure SetSeller_Account(const Value: Integer);
  function GetPrivate_Sale: Boolean;
  procedure SetPrivate_Sale(const Value: Boolean);
  function GetNew_Enc_PubKey: String;
  procedure SetNew_Enc_PubKey(const Value: String);
  function GetName: String;
  procedure SetName(const Value: String);
  function GetAccount_Type: Integer;
  procedure SetAccount_Type(const Value: Integer);

  property account : Integer read GetAccount write SetAccount;  //Account number
  property enc_pubkey : String read GetPubKey write SetPubKey;  //HEXASTRING - Encoded public key value (See decodepubkey)
  property balance : Currency read GetBalance write SetBalance; //PASCURRENCY - Account balance
  property n_operation : Integer read GetN_Operation write SetN_Operation;// - Operations made by this account _(Note: When an account receives a transaction, n_operation is not changed)_
  property updated_b : Integer read GetUpdated_b write SetUpdated_b; //- Last block that updated this account. If equal to blockchain blocks count it means that it has pending operations to be included to the blockchain.
  property state : String read GetState write SetState; //- Values can be normal or listed. When listed then account is for sale
  property locked_until_block : Integer read GetLocked_Until_Block write SetLocked_Until_Block;//- Until what block this account is locked. Only set if state is listed
  property price : Currency read GetPrice write SetPrice; //PASCURRENCY - Price of account. Only set if state is listed
  property seller_account : Integer read GetSeller_Account write SetSeller_Account; //- Seller's account number. Only set if state is listed
  property private_sale : Boolean read GetPrivate_Sale write SetPrivate_Sale; //- Whether sale is private. Only set if state is listed
  property new_enc_pubkey : String read GetNew_Enc_PubKey write SetNew_Enc_PubKey; //HEXSTRING - Private buyers public key. Only set if state is listed and private_sale is true
  property name : String read GetName write SetName; //- Public name of account. Follows PascalCoin64 Encoding
  property account_type : Integer read GetAccount_Type write SetAccount_Type; //- Type of account. Valid values range from 0..65535

end;

IPascalCoinAccounts = interface
['{4C039C2C-4BED-4002-9EA2-7F16843A6860}']
  function GetAccount(const Index: Integer): IPascalCoinAccount;
  function Count: Integer;
  function AddAccount(Value: IPascalCoinAccount): Integer;
  property Account[const Index: Integer]: IPascalCoinAccount read GetAccount; default;
end;

IPascalNetStats = interface
['{0F8214FA-D42F-44A7-9B5B-4D6B3285E860}']
   function GetActive: Integer;
   procedure SetActive(const Value: Integer);
   function GetClients: Integer;
   procedure SetClients(const Value: Integer);
   function GetServers: Integer;
   procedure SetServers(const Value: Integer);
   function GetServers_t: Integer;
   procedure SetServers_t(const Value: Integer);
   function GetTotal: Integer;
   procedure SetTotal(const Value: Integer);
   function GetTClients: Integer;
   procedure SetTClients(const Value: Integer);
   function GetTServers: Integer;
   procedure SetTServers(const Value: Integer);
   function GetBReceived: Integer;
   procedure SetBReceived(const Value: Integer);
   function GetBSend: Integer;
   procedure SetBSend(const Value: Integer);

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
  function GetPort: Integer;
  procedure SetPort(const Value: Integer);
  function GetLastCon: Integer;
  procedure SetLastCon(const Value: Integer);
  function GetAttempts: Integer;
  procedure SetAttempts(const Value: Integer);
  function GetLastConAsDateTime: TDateTime;
  procedure SetLastConAsDateTime(const Value: TDateTime);
  property ip: String read GetIP write SetIP;
  property port: Integer read GetPort write SetPort;
  property lastcon: Integer read GetLastCon write SetLastCon;
  property LastConAsDateTime: TDateTime read GetLastConAsDateTime write SetLastConAsDateTime;
  property attempts: Integer read GetAttempts write SetAttempts;
end;

IPascalCoinNetProtocol = interface
['{DBAAA45D-5AC1-4805-9FDB-5A6B66B193DC}']
function GetVer: Integer;
procedure SetVer(const Value: Integer);
function GetVer_A: Integer;
procedure SetVer_A(const Value: Integer);
property ver : Integer read GetVer write SetVer; // Net protocol version
property ver_a : Integer read GetVer_A write SetVer_A ; // Net protocol available
end;

IPascalCoinNodeStatus = interface
['{9CDDF2CB-3064-4CD6-859A-9E11348FF621}']
function GetReady: Boolean;
procedure SetReady(Const Value: Boolean);
function GetReady_S: String;
procedure SetReady_S(Const Value: String);
function GetStatus_S: String;
procedure SetStatus_S(Const Value: String);
function GetPort: Integer;
procedure SetPort(Const Value: Integer);
function GetLocked: Boolean;
procedure SetLocked(Const Value: Boolean);
function GetTimeStamp: Integer;
procedure SetTimeStamp(Const Value: Integer);
function GetVersion: String;
procedure SetVersion(Const Value: String);
function GetNetProtocol: IPascalCoinNetProtocol;
function GetBlocks: Integer;
procedure SetBlocks(Const Value: Integer);
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

property ready : Boolean read GetReady write SetReady ; // Must be true, otherwise Node is not ready to execute operations
property ready_s : String read GetReady_S write SetReady_S ; // Human readable information about ready or not
property status_s : String read GetStatus_S write SetStatus_S ; // Human readable information about node status... Running, downloading blockchain, discovering servers...
property port : Integer read GetPort write SetPort ; // Server port
property locked : Boolean read GetLocked write SetLocked ; // True when this wallet is locked, false otherwise
property timestamp : Integer read GetTimeStamp write SetTimeStamp ; // Timestamp of the Node
property TimeStampAsDateTime: TDateTime read GetTimeStampAsDateTime write SetTimeStampAsDateTime;
property version : String read GetVersion write SetVersion ; // Server version
property netprotocol : IPascalCoinNetProtocol read GetNetProtocol;
property blocks : Integer read GetBlocks write SetBlocks ; // Blockchain blocks
property netstats : IPascalNetStats read GetNetStats; //-JSON Object with net information
property nodeservers : IPascalCoinList<IPascalCoinServer> read GetNodeServers; //JSON Array with servers candidates
property sbh: string read GetSBH write SetSBH;
property pow: string read GetPOW write SetPOW;
property openssl: string read GetOpenSSL write SetOpenSSL;


end;

IPascalCoinBlock = interface
['{9BAA406C-BC52-4DB6-987D-BD458C0766E5}']
  function GetBlock: Integer;
  function GetEnc_PubKey: String;
  function GetFee: Currency;
  function GetHashRateKHS: Integer;
  function GetMaturation: Integer;
  function GetNonce: Integer;
  function GetOperations: Integer;
  function GetOPH: String;
  function GetPayload: String;
  function GetPOW: String;
  function GetReward: Currency;
  function GetSBH: String;
  function GetTarget: Integer;
  function GetTimeStamp: Integer;
  function GetVer: Integer;
  function GetVer_a: Integer;
  procedure SetBlock(const Value: Integer);
  procedure SetEnc_PubKey(const Value: String);
  procedure SetFee(const Value: Currency);
  procedure SetHashRateKHS(const Value: Integer);
  procedure SetMaturation(const Value: Integer);
  procedure SetNonce(const Value: Integer);
  procedure SetOperations(const Value: Integer);
  procedure SetOPH(const Value: String);
  procedure SetPayload(const Value: String);
  procedure SetPOW(const Value: String);
  procedure SetReward(const Value: Currency);
  procedure SetSBH(const Value: String);
  procedure SetTarget(const Value: Integer);
  procedure SetTimeStamp(const Value: Integer);
  procedure SetVer(const Value: Integer);
  procedure SetVer_a(const Value: Integer);

  function GetDelphiTimeStamp: TDateTime;
  procedure SetDelphiTimeStamp(const Value: TDateTime);

  property block: Integer read GetBlock write SetBlock;//Block number
  property enc_pubkey: String read GetEnc_PubKey write SetEnc_PubKey; //Encoded public key value used to init 5 created accounts of this block (See decodepubkey )
  property reward: Currency read GetReward write SetReward; //Reward of first account's block
  property fee: Currency read GetFee write SetFee; //Fee obtained by operations
  property ver: Integer read GetVer write SetVer; //Pascal Coin protocol used
  property ver_a: Integer read GetVer_a write SetVer_a; //Pascal Coin protocol available by the miner
  property timestamp: Integer read GetTimeStamp write SetTimeStamp; //Unix timestamp
  property target: Integer read GetTarget write SetTarget; //Target used
  property nonce: Integer read GetNonce write SetNonce; //Nonce used
  property payload: String read GetPayload write SetPayload; //Miner's payload
  property sbh: String read GetSBH write SetSBH; //SafeBox Hash
  property oph: String read GetOPH write SetOPH; //Operations hash
  property pow: String read GetPOW write SetPOW; //Proof of work
  property operations: Integer read GetOperations write SetOperations; //Number of operations included in this block
  property hashratekhs: Integer read GetHashRateKHS write SetHashRateKHS; //Estimated network hashrate calculated by previous 50 blocks average
  property maturation: Integer read GetMaturation write SetMaturation; //Number of blocks in the blockchain higher than this

  property DelphiTimeStamp: TDateTime Read GetDelphiTimeStamp write SetDelphiTimeStamp;
end;

IPascalCoinAPI = interface
['{310A40ED-F917-4075-B495-5E4906C4D8EB}']
  function GetJSONResult: TJSONValue;
  function GetJSONResultStr: string;

  function getaccount(const AAccountNumber: Integer): IPascalCoinAccount;
  function getwalletaccounts(const APublicKey: String; const AKeyStyle: TKeyStyle): IPascalCoinAccounts;
  function getwalletaccountscount(const APublicKey: String; const AKeyStyle: TKeyStyle): Integer;
//  function getwalletcoins(const APublicKey: String): Currency;
  function getblock(const BlockNumber: Integer): IPascalCoinBlock;
//  getblocks - Get a list of blocks (last n blocks, or from start to end)
//  getblockcount - Get blockchain high in this node
//  getblockoperation - Get an operation of the block information
//  getblockoperations - Get all operations of specified block
//  getaccountoperations - Get operations made to an account
//  getpendings - Get pendings operations to be included in the blockchain
//  getpendingscount - Returns node pending buffer count ( New on Build 3.0 )
//  findoperation - Find
   function nodestatus: IPascalCoinNodeStatus;

   property JSONResult: TJSONValue read GetJSONResult;
   property JSONResultStr: string read GetJSONResultStr;
end;

implementation

end.
