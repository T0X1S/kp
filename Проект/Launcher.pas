unit Launcher;
interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, pngimage, ExtCtrls, PlayerU, EngineUI, Spin,
  engineclasses, math, Vcl.Menus, ShellAPI,
  Vcl.Buttons, Vcl.MPlayer;
type
  TfrmLauncher = class(TForm)
    Image1: TImage;
    sedMonitor: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    sedWidth: TSpinEdit;
    lblHeight: TLabel;
    shpPlay: TShape;
    Label3: TLabel;
    Label4: TLabel;
    tmr: TTimer;
    Label5: TLabel;
    shpClose: TShape;
    Image2: TImage;
    Label6: TLabel;
    shpDisplaySettings: TShape;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Panel1: TPanel;
    MediaPlayer1: TMediaPlayer;
    VolumeButton: TSpeedButton;
    cbxWindowed: TCheckBox;
    procedure LaunchGame;
    procedure FormCreate(Sender: TObject);
    procedure sedWidthChange(Sender: TObject);
    procedure tmrTimer(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure VolumeButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    isMusicAllowed:boolean;
  end;
var
  frmLauncher: TfrmLauncher;
  showingSettings : boolean = false;
  iHeight : integer = 360;
  rectPlay, rectSettings : TShape;
const
  heightWOSettings = 335;
  heightWSettings = 460;
implementation
{$R *.dfm}

procedure TfrmLauncher.LaunchGame;
begin
  ChessForm.PlayerRefresh.Enabled := false;
  ChessForm.WindowState := wsNormal;
  ChessForm.Show;
  if not cbxWindowed.checked then
  begin
    ChessForm.Top := screen.Monitors[sedMonitor.Value - 1].Top;
    ChessForm.Left := screen.Monitors[sedMonitor.Value - 1].Left;
    gameHeight := screen.Monitors[sedMonitor.Value - 1].Height;
    gameWidth := screen.Monitors[sedMonitor.Value - 1].Width;
    ChessForm.WindowState := wsMaximized;
  end
  else
  begin
    ChessForm.Top := screen.Monitors[sedMonitor.Value - 1].Top;
    ChessForm.Left := screen.Monitors[sedMonitor.Value - 1].Left;
    gameHeight := iHeight;
    gameWidth := sedWidth.Value;
    ChessForm.ClientHeight := gameHeight;
    ChessForm.ClientWidth := gameWidth;
    ChessForm.roundEdges;
  end;
  ChessForm.reloadGame;
end;

procedure TfrmLauncher.N2Click(Sender: TObject);
begin
ShellExecute(0, PChar ('Open'), PChar ('Manual.chm'), nil, nil, SW_SHOW);
end;

procedure TfrmLauncher.N3Click(Sender: TObject);
begin
Application.Terminate;
end;

procedure TfrmLauncher.FormCreate(Sender: TObject);
var
  rgn : HRGN;
begin


  isMusicAllowed:=true;

  Image1.Picture.LoadFromFile('Images\Launch_horse.bmp');
  Image2.Picture.LoadFromFile('Images\close.png');
  label6.Caption := '� � � � � � � �  ' + #13 + '� � � �';
  sedMonitor.MaxValue := screen.MonitorCount;
  if screen.MonitorCount = 1 then
    sedMonitor.Enabled := false;
  sedWidth.MaxValue := screen.Width;
  lblHeight.Caption := format('X %d', [iHeight]);
  rgn := CreateRoundRectRgn(0,
    0,
    ClientWidth,
    ClientHeight,
    20,
    20);
  SetWindowRgn(Handle, rgn, True);
end;

procedure TfrmLauncher.FormShow(Sender: TObject);
begin
   var path:string:=ExtractFilePath((Application.ExeName) );

    self.MediaPlayer1.FileName := path + '\Images\TheHappyBride.mp3';

   try
      self.MediaPlayer1.Open();
       self.MediaPlayer1.Play();
   except
       begin
         MessageDlg('�������� ���� � �����. �������� ��� ������ �� ����������. ���������� ���.',vcl.Dialogs.mtError, mbOKCancel, 0);
         exit;
       end;

   end;
end;


procedure TfrmLauncher.sedWidthChange(Sender: TObject);
begin
  if sedWidth.Text <> '' then
    iHeight := ceil(sedWidth.value/(16/9));
  lblHeight.Caption := format('X %d', [iHeight]);
end;

procedure TfrmLauncher.tmrTimer(Sender: TObject);
begin


  if (mouse.CursorPos.X >= shpPlay.ClientToScreen(Point(0, 0)).X) AND
    (mouse.CursorPos.X <= shpPlay.ClientToScreen(Point(shpPlay.Width, 0)).X)
    AND (mouse.CursorPos.Y >= shpPlay.ClientToScreen(Point(0, 0)).Y) AND
    (mouse.CursorPos.Y <= shpPlay.ClientToScreen(Point(0, shpPlay.Height)).Y)
    then
  begin
    while GETGVALUE(shpPlay.Brush.color) > $BE do
    begin
      shpPlay.Brush.color := shpPlay.Brush.color - $000100;
      Application.ProcessMessages;
    end;
    if GetKeyState(VK_LBUTTON) < 0 then
    begin
      tmr.Enabled := false;
      LaunchGame;
    end;
  end
  else
  begin
    while GETGVALUE(shpPlay.Brush.color) < $DD do
    begin
      shpPlay.Brush.color := shpPlay.Brush.color + $000100;
      Application.ProcessMessages;
    end;
  end;

  if (mouse.CursorPos.X >= shpDisplaySettings.ClientToScreen(Point(0, 0)).X) AND
    (mouse.CursorPos.X <= shpDisplaySettings.ClientToScreen(Point(shpDisplaySettings.Width, 0)).X)
    AND (mouse.CursorPos.Y >= shpDisplaySettings.ClientToScreen(Point(0, 0)).Y) AND
    (mouse.CursorPos.Y <= shpDisplaySettings.ClientToScreen(Point(0, shpDisplaySettings.Height)).Y)
    then
  begin
    while GETGVALUE(shpDisplaySettings.Brush.color) > $BE do
    begin
      shpDisplaySettings.Brush.color := shpDisplaySettings.Brush.color - $000100;
      Application.ProcessMessages;
      cbxWindowed.Color := shpDisplaySettings.Brush.Color;
    end;
  end
  else
  begin
    while GETGVALUE(shpDisplaySettings.Brush.color) < $DD do
    begin
      shpDisplaySettings.Brush.color := shpDisplaySettings.Brush.color + $000100;
      Application.ProcessMessages;
      cbxWindowed.Color := shpDisplaySettings.Brush.Color;
    end;
  end;

  if (mouse.CursorPos.X >= shpClose.ClientToScreen(Point(0, 0)).X) AND
    (mouse.CursorPos.X <= shpClose.ClientToScreen(Point(shpClose.Width, 0)).X)
    AND (mouse.CursorPos.Y >= shpClose.ClientToScreen(Point(0, 0)).Y) AND
    (mouse.CursorPos.Y <= shpClose.ClientToScreen(Point(0, shpClose.Height)).Y)
    then
  begin
    while GETGVALUE(shpClose.Brush.color) > $BE do
    begin
      shpClose.Brush.color := shpClose.Brush.color - $000100;
      Application.ProcessMessages;
    end;
    if GetKeyState(VK_LBUTTON) < 0 then
    begin
      tmr.Enabled := false;
      Application.Terminate;
    end;
  end
  else
  begin
    while GETGVALUE(shpClose.Brush.color) < $DD do
    begin
      shpClose.Brush.color := shpClose.Brush.color + $000100;
      Application.ProcessMessages;
    end;
  end;

end;
procedure TfrmLauncher.VolumeButtonClick(Sender: TObject);
begin
if self.isMusicAllowed then
  begin
    self.isMusicAllowed:=false;
    self.VolumeButton.Glyph.LoadFromFile(ExtractFilePath(Application.ExeName) +'/Images/mute.bmp');
     self.MediaPlayer1.Stop
  end
  else
  begin
      self.isMusicAllowed:=true;
     self.VolumeButton.Glyph.LoadFromFile(ExtractFilePath(Application.ExeName) +'/Images/speaker.bmp');
     try

        MediaPlayer1.FileName:=ExtractFilePath(Application.ExeName)+ '\Images\TheHappyBride.mp3';

        self.MediaPlayer1.Open();
        MediaPlayer1.Play
     except
       begin
         MessageDlg('�������� ���� � �����. �������� ��� ������ �� ����������. ���������� ���.',vcl.Dialogs.mtError, mbOKCancel, 0);
         exit;
       end;
     end;

  end;
end;

end.
