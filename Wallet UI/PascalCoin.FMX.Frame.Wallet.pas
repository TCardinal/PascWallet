unit PascalCoin.FMX.Frame.Wallet;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, System.Rtti, FMX.Grid.Style, FMX.Grid,
  FMX.ScrollBox, PascalCoin.FMX.Frame.Base, Data.Bind.EngExt, FMX.Bind.DBEngExt,
  FMX.Bind.Grid, System.Bindings.Outputs, FMX.Bind.Editors,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope, System.Actions,
  FMX.ActnList, FMX.Menus;

type
  TWalletFrame = class(TBaseFrame)
    MainLayout: TLayout;
    MyBalanceLabel: TLabel;
    BalanceLabel: TLabel;
    WalletPanel: TPanel;
    ToolBar2: TToolBar;
    AccountShow: TCheckBox;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    AccountGrid: TGrid;
    Layout1: TLayout;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    PopupMenu1: TPopupMenu;
    AccountInfoItem: TMenuItem;
    ActionList1: TActionList;
    AccountInfoAction: TAction;
    PasaCount: TLabel;
    procedure AccountInfoActionExecute(Sender: TObject);
  private
    { Private declarations }
    procedure OnBalanceChange(const Value: Currency);
    procedure OnInitComplete(Sender: TObject);
    procedure OnAccountsUpdated(Sender: TObject);
    procedure OnAdvancedOptionsChanged(const AValue: Boolean);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InitialiseFrame; override;
    procedure Showing; override;
    procedure Hiding; override;
  end;

implementation

{$R *.fmx}

uses PascalCoin.FMX.DataModule, PascalCoin.RPC.Interfaces;

{ TWalletFrame }

constructor TWalletFrame.Create(AOwner: TComponent);
begin
  inherited;
  BalanceLabel.Text := 'loading from safebox';

  MainDataModule.Settings.OnAdvancedOptionsChange.Add(OnAdvancedOptionsChanged);
  OnAdvancedOptionsChanged(MainDataModule.Settings.AdvancedOptions);
  MainDataModule.OnBalanceChangeEvent.Add(OnBalanceChange);
  MainDataModule.OnInitComplete.Add(OnInitComplete);
  MainDataModule.OnAccountsUpdated.Add(OnAccountsUpdated);

end;

destructor TWalletFrame.Destroy;
begin
  MainDataModule.Settings.OnAdvancedOptionsChange.Remove
    (OnAdvancedOptionsChanged);
  MainDataModule.OnBalanceChangeEvent.Remove(OnBalanceChange);
  MainDataModule.OnInitComplete.Remove(OnInitComplete);
  MainDataModule.OnAccountsUpdated.Remove(OnAccountsUpdated);
  inherited;
end;

procedure TWalletFrame.AccountInfoActionExecute(Sender: TObject);
var
  lAccount: IPascalCoinAccount;
begin
  // Need a proper popup frame to do all this
  lAccount := MainDataModule.API.getaccount
    (MainDataModule.AccountsDataAccountNumber.Value);

  ShowMessage(lAccount.enc_pubkey);

end;

procedure TWalletFrame.Hiding;
begin
  inherited;

end;

procedure TWalletFrame.InitialiseFrame;
begin
  inherited;

end;

procedure TWalletFrame.OnAccountsUpdated(Sender: TObject);
begin
  PasaCount.Text := 'Number of PASA shown: ' +
    FormatFloat('', BindSourceDB1.DataSet.RecordCount);
end;

procedure TWalletFrame.OnAdvancedOptionsChanged(const AValue: Boolean);
begin
  LinkGridToDataSourceBindSourceDB1.Columns[4].Visible := AValue;
end;

procedure TWalletFrame.OnBalanceChange(const Value: Currency);
begin
  BalanceLabel.Text := CurrToStrF(Value, ffCurrency, 4);

end;

procedure TWalletFrame.OnInitComplete(Sender: TObject);
begin

end;

procedure TWalletFrame.Showing;
begin
  inherited;

end;

end.
