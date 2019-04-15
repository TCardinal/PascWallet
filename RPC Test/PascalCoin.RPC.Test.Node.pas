unit PascalCoin.RPC.Test.Node;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo;

type
  TNodeStatusFrame = class(TFrame)
    Go: TButton;
    ListBox1: TListBox;
    Memo1: TMemo;
    procedure GoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AComponent: TComponent); override;
  end;

implementation

{$R *.fmx}

uses PascalCoin.RPC.Interfaces, PascalCoin.RPC.Test.DM, Spring.Container;

constructor TNodeStatusFrame.Create(AComponent: TComponent);
begin
  inherited;
end;

procedure TNodeStatusFrame.GoClick(Sender: TObject);
var lNodeStatus: IPascalCoinNodeStatus;
    lAPI: IPascalCoinAPI;
  I: Integer;
begin
  ListBox1.BeginUpdate;
  try
    ListBox1.Clear;
    Memo1.Lines.Clear;

    lAPI := GlobalContainer.Resolve<IPascalCoinAPI>.URI(DM.URI);

    lNodeStatus := lAPI.nodestatus;
    Memo1.Lines.Text := lAPI.JSONResult.Format;

    ListBox1.Items.Add('ready: ' + lNodeStatus.ready.ToString);
    ListBox1.Items.Add('ready_s: ' + lNodeStatus.ready_s);
    ListBox1.Items.Add('status_s: ' + lNodeStatus.status_s);
    ListBox1.Items.Add('port: ' + lNodeStatus.port.ToString);
    ListBox1.Items.Add('locked: ' + lNodeStatus.getlocked.ToString);
    ListBox1.Items.Add('timestamp: ' + lNodeStatus.timestamp.ToString);
    ListBox1.Items.Add('TimeStampAsDateTime: ' + DateTimeToStr(lNodeStatus.TimeStampAsDateTime));
    ListBox1.Items.Add('version: ' + lNodeStatus.version);
    ListBox1.Items.Add('blocks: ' + lNodeStatus.blocks.ToString);
    ListBox1.Items.Add('sbh: ' + lNodeStatus.sbh);
    ListBox1.Items.Add('pow: ' + lNodeStatus.pow);
    ListBox1.Items.Add('openssl: ' + lNodeStatus.openssl);

    ListBox1.Items.Add('netprotocol.ver: ' + lNodeStatus.netprotocol.ver.ToString);
    ListBox1.Items.Add('netprotocol.ver_a: ' + lNodeStatus.netprotocol.ver_a.ToString);

    ListBox1.Items.Add('netstats.active: ' + lNodeStatus.netstats.active.ToString);
    ListBox1.Items.Add('netstats.clients: ' + lNodeStatus.netstats.clients.ToString);
    ListBox1.Items.Add('netstats.servers: ' + lNodeStatus.netstats.servers.ToString);
    ListBox1.Items.Add('netstats.servers_t' + lNodeStatus.netstats.servers_t.ToString);
    ListBox1.Items.Add('netstats.total: ' + lNodeStatus.netstats.total.ToString);
    ListBox1.Items.Add('netstats.tclients: ' + lNodeStatus.netstats.tclients.ToString);
    ListBox1.Items.Add('netstats.tservers: ' + lNodeStatus.netstats.tservers.ToString);
    ListBox1.Items.Add('netstats.breceived: ' + lNodeStatus.netstats.breceived.ToString);
    ListBox1.Items.Add('netstats.bsend: ' + lNodeStatus.netstats.bsend.ToString);

    for I := 0 to lNodeStatus.nodeservers.Count - 1 do
    begin
      ListBox1.Items.Add('ndeservers[' + I.ToString + ']: ');
      ListBox1.Items.Add(' -ip: ' + lNodeStatus.nodeservers[I].ip);
      ListBox1.Items.Add(' -port: ' + lNodeStatus.nodeservers[I].port.ToString);
      ListBox1.Items.Add(' -lastcon: ' + lNodeStatus.nodeservers[I].lastcon.ToString);
      ListBox1.Items.Add(' -lastconasdatetime: ' + DateTimeToStr(lNodeStatus.nodeservers[I].LastConAsDateTime));
      ListBox1.Items.Add(' -attempts: ' + lNodeStatus.nodeservers[I].attempts.ToString);
    end;

  finally
    ListBox1.EndUpdate;
  end;
end;

end.
