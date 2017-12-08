unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, RsaOpenSSL;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Memo1: TEdit;
    Button10: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
  private
    { Private declarations }
    fRSAOpenSSL : TRSAOpenSSL;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  aPathToPublickKey, aPathToPrivateKey: string;
begin
  aPathToPublickKey := '1public.pem';
  //aPathToPublickKey := 'public.cer';

  aPathToPrivateKey := 'pro22.pem';
  fRSAOpenSSL := TRSAOpenSSL.Create(aPathToPublickKey, aPathToPrivateKey);


end;

procedure TForm1.Button1Click(Sender: TObject);
var
  aRSAData: TRSAData;
begin
  aRSAData.DecryptedData := Memo1.Text;
  fRSAOpenSSL.PublickEncrypt(aRSAData);
  if aRSAData.ErrorResult = 0 then
  memo2.Lines.Text := aRSAData.CryptedData;
  memo4.Lines.Add(aRSAData.ErrorMessage);

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  aRSAData: TRSAData;
begin
  aRSAData.CryptedData := Memo2.Text;
  fRSAOpenSSL.PrivateDecrypt(aRSAData);
  if aRSAData.ErrorResult = 0 then
  memo3.Lines.Text := aRSAData.DecryptedData;
  memo4.Lines.Add(aRSAData.ErrorMessage);

end;

procedure TForm1.Button3Click(Sender: TObject);
var
  aRSAData: TRSAData;
begin
  aRSAData.DecryptedData := Memo1.Text;
  fRSAOpenSSL.PrivateEncrypt11(aRSAData);
  if aRSAData.ErrorResult = 0 then
  memo2.Lines.Text := aRSAData.CryptedData;
  memo4.Lines.Add(aRSAData.ErrorMessage);

end;

procedure TForm1.Button4Click(Sender: TObject);
var
  aRSAData: TRSAData;
begin
  aRSAData.CryptedData := Memo2.Text;
  fRSAOpenSSL.PublicDecrypt(aRSAData);
  if aRSAData.ErrorResult = 0 then
  memo3.Lines.Text := aRSAData.DecryptedData;
  memo4.Lines.Add(aRSAData.ErrorMessage);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  Memo3.Text := fRSAOpenSSL.SHA1(Memo1.Text);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
 //memo1.Text := 'eNpUjMsKwyAQRf9l1hF8V_M3ozOCXaRtNCVQ-u_VTaDLezj3fKAdCVbo3DrvsAAeNCbX7f2omQfYUoFVOaWVdtLKBXZ-HcMm7NimqiRSNtHGhC5iSuw8S3crWpYQzEzU1v6bfD6vpp_Niv0CZoJ7r-OS0RDZrAT5UoQlHQWSIoFWmug1ac4Bvj8AAAD__w';
  Memo3.Text := fRSAOpenSSL.SHA256('eyJhbGciOiJSUzI1NiIsImNhbGciOiJERUYifQ.eJxUzEEKwyAQheG7zDqCiTpqbjPqDNhF2kZTCqV3r9kEunw_j-8D7UiwQufWeYcJ6Chjct1e95p5hC0JrLObF7RR2zDBzs9jvAt1auMqgouh7FzmIjLrHHwyEoP3sWRn3CBqa_8mvx-XiadZqV_BnOHW62kvwmx0UBGzVVYwqJBSVNpjRFMoiBB8fwAAAP__');
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
Memo3.Text := fRSAOpenSSL.SHA512(Memo1.Text);
end;

procedure TForm1.Button8Click(Sender: TObject);

begin
  memo4.Text :=  fRSAOpenSSL.SHA1_Sign_PK(memo1.Text);

end;

procedure TForm1.Button9Click(Sender: TObject);
var
 s1:string;
begin
    //memo4.Text :=  fRSAOpenSSL.SHA256_Sign_PK(memo1.Text);
    s1 := 'eyJhbGciOiJSUzUxMiIsImNhbGciOiJERUYifQ.eyJzdWIiOiJ0ZXN0IiwiYXVkIjoiZWludm9pY2UiLCJuYmYiOiIxNTEyNjYxNDQ4IiwicmVxdWVzdGRhdGFz'+
    'IjoiZmY2MjNhYzU1Y2VkZmYxMGM4N2IzZjk4Nzc5ZGM1MzUiLCJpc3MiOiJlaW52b2ljZSIsImV4cCI6IjE1MTI2NjIwNDgiLCJpYXQiOiIxNTEyNjYxNzQ4IiwianRpIjoiOTdjNmU4YmUtNDlkOS00MTA1LThjYzQtNjY0MDEzNjdmMDU1In';
    memo4.Text :=  fRSAOpenSSL.SHA256_Sign_PK(s1);
end;



procedure TForm1.Button10Click(Sender: TObject);
begin
   memo4.Text :=  fRSAOpenSSL.SHA512_Sign_PK('eyJhbGciOiJSUzI1NiIsImNhbGciOiJERUYifQ.eJxUzEEKwyAQheG7zDqCiTpqbjPqDNhF2kZTCqV3r9kEunw_j-8D7UiwQufWeYcJ6Chjct1e95p5hC0JrLObF7RR2zDBzs9jvAt1auMqgouh7FzmIjLrHHwyEoP3sWRn3CBqa_8mvx-XiadZqV_BnOHW62kvwmx0UBGzVVYwqJBSVNpjRFMoiBB8fwAAAP__');

end;

end.
