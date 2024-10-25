unit LoadU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Imaging.GIFImg, Vcl.Imaging.pngimage, Vcl.StdCtrls;

type
  TLoading_Screen = class(TForm)
    ProgressBar1: TProgressBar;
    Timer1: TTimer;
    Image1: TImage;
    Label1: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Loading_Screen: TLoading_Screen;

implementation
uses Launcher;
{$R *.dfm}

procedure TLoading_Screen.FormCreate(Sender: TObject);
begin
Image1.Picture.LoadFromFile('Images\load.png');
PostMessage(ProgressBar1.Handle, $0409, 0, clBlue);
progressbar1.BarColor:=clblue;
end;

procedure TLoading_Screen.Timer1Timer(Sender: TObject);
begin
Progressbar1.Position:=Progressbar1.Position+25;
if progressbar1.position=100 then
begin
  Timer1.Enabled:=false;
  frmLauncher.Show;
  Loading_Screen.Hide;
end;
end;

end.
