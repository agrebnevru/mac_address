unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NB30, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    function GetMACAddress: string;
    function GetAdapterInfo(Lana: Char): String;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
label1.Caption := GetMACAddress;
end;

function TForm1.GetAdapterInfo(Lana: Char): String;
var
  Adapter: TAdapterStatus;
  NCB: TNCB;
begin
  FillChar(NCB, SizeOf(NCB), 0);
  NCB.ncb_command := Char(NCBRESET);
  NCB.ncb_lana_num := AnsiChar(Lana);
  if Netbios(@NCB) <> Char(NRC_GOODRET) then
  begin
    Result := 'mac not found';
    Exit;
  end;

  FillChar(NCB, SizeOf(NCB), 0);
  NCB.ncb_command := Char(NCBASTAT);
  NCB.ncb_lana_num := AnsiChar(Lana);
  NCB.ncb_callname := '*';

  FillChar(Adapter, SizeOf(Adapter), 0);
  NCB.ncb_buffer := @Adapter;
  NCB.ncb_length := SizeOf(Adapter);
  if Netbios(@NCB) <> Char(NRC_GOODRET) then
  begin
    Result := 'mac not found';
    Exit;
  end;
  Result :=
    IntToHex(Byte(Adapter.adapter_address[0]), 2) + '-' +
    IntToHex(Byte(Adapter.adapter_address[1]), 2) + '-' +
    IntToHex(Byte(Adapter.adapter_address[2]), 2) + '-' +
    IntToHex(Byte(Adapter.adapter_address[3]), 2) + '-' +
    IntToHex(Byte(Adapter.adapter_address[4]), 2) + '-' +
    IntToHex(Byte(Adapter.adapter_address[5]), 2);
end;

function TForm1.GetMACAddress: string;
var
  AdapterList: TLanaEnum;
  NCB: TNCB;
begin
  FillChar(NCB, SizeOf(NCB), 0);
  NCB.ncb_command := Char(NCBENUM);
  NCB.ncb_buffer := @AdapterList;
  NCB.ncb_length := SizeOf(AdapterList);
  Netbios(@NCB);
  if Byte(AdapterList.length) > 0 then
    Result := GetAdapterInfo(Char(AdapterList.lana[0]))
  else
    Result := 'mac not found';
end;

end.
