unit PlayerU;
interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, EngineClasses, jpeg, math, StdCtrls, ImgList, ExtCtrls, pngimage,
  Menus, ActnList, EngineUI, System.Actions, System.ImageList, Vcl.Buttons;
type
  TChessForm = class(TForm)
    PlayerRefresh: TTimer;
    lblWhiteTitle: TLabel;
    lblBlackTitle: TLabel;
    lblWPiecesTook: TLabel;
    lblBPiecesTook: TLabel;
    highlightblock: TImage;
    imgClose: TImage;
    imgCloseHover: TImage;
    imgCloseDef: TImage;
    Settings: TActionList;
    setWhiteColor: TAction;
    setBlackColor: TAction;
    setOutlineColor: TAction;
    setBackColor: TAction;
    autoDeselect: TAction;
    saveDirSet: TAction;
    saveSettings: TAction;
    resetSettings: TAction;
    setAssetsPath: TAction;
    setUIScale: TAction;
    AssetsList: TImageList;
    cldlg: TColorDialog;
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PlayerRefreshTimer(Sender: TObject);
    procedure imgCloseClick(Sender: TObject);
    procedure imgCloseMouseEnter(Sender: TObject);
    procedure imgCloseMouseLeave(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure setWhiteColorExecute(Sender: TObject);
    procedure setBlackColorExecute(Sender: TObject);
    procedure setOutlineColorExecute(Sender: TObject);
    procedure setBackColorExecute(Sender: TObject);
    procedure autoDeselectExecute(Sender: TObject);
    procedure SetSettings;
    procedure saveSettingsExecute(Sender: TObject);
    procedure showDebugExecute(Sender: TObject);
    procedure resetSettingsExecute(Sender: TObject);
    procedure reloadGame;
    procedure setAssetsPathExecute(Sender: TObject);
    procedure roundEdges;
    procedure ScaleComponents;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure setUIScaleExecute(Sender: TObject);
    procedure exitButtonClick(Sender: TObject);
    function GetData(FilePath : string; Tag : string) : string;
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  ChessForm: TChessForm;
  BoardMannager: TBoardMannager;
  highlightblock: TImage;
  SaveManager: TSaveManager;
  AssetPath: string = 'default';
  turnColor : TColor;
  selectColor : TColor;
  scaleMultplier : real = 1;
implementation
{$R *.dfm}
procedure TChessForm.autoDeselectExecute(Sender: TObject);
begin
  BoardMannager.autoDeselect := not BoardMannager.autoDeselect;
  autoDeselect.Checked := BoardMannager.autoDeselect
end;
function TChessForm.GetData(FilePath : string; Tag : string) : string;
var
  tS : TextFile;
  s : string;
begin
  if not fileExists(filepath) then
  begin
    result := 'default';
    exit;
  end;
  AssignFile(ts, FilePath);
  reset(ts);
  while (Pos(Tag, s) = 0) AND (not eof(tS)) do
    readln(ts, s);
  if eof(ts) then begin closeFile(tS); exit end;
  delete(s, 1, pos('[', s));
  Result := Copy(s, 1,  pos(']', s) - 1);
  closeFile(tS);
end;
procedure TChessForm.FormCreate(Sender: TObject);
var
  tempbm: TBitmap;
  settingDat: string;
begin
  highlightblock.Picture.LoadFromFile('Images\block.png');
  imgClose.Picture.LoadFromFile('Images\close.png');
  imgCloseDef.Picture.LoadFromFile('Images\white_block.png');
  imgCloseHover.Picture.LoadFromFile('Images\close.png');
  settingDat := getdata('_SETTINGS.DWCS', 'AssetsDir');
  if DirectoryExists(settingDat) then
    AssetPath := settingDat
  else
    AssetPath := 'default';
  if AssetPath <> 'default' then
    imageSize := StrToInt(getdata(AssetPath + '\_SETUP.DWCS', 'ImageSize'))
  else
    imageSize := 32;
  tempbm := TBitmap.Create;
  with tempbm do
  begin
    PixelFormat := pf32bit;
    Height := imageSize;
    Width := Height;
  end;
  BoardMannager := TBoardMannager.Create(Self);
  SaveManager := TSaveManager.Create(Self);
  SaveManager.LinkedBoard := BoardMannager;
  color := rgb(102, 202, 255);
  SetSettings;
  if AssetPath = 'default' then
    try
      AssetsList.Draw(BoardMannager.Bishop.Canvas, 0, 0, 0, true);
      AssetsList.Draw(BoardMannager.Castle.Canvas, 0, 0, 1, true);
      AssetsList.Draw(BoardMannager.horse.Canvas, 0, 0, 2, true);
      AssetsList.Draw(BoardMannager.king.Canvas, 0, 0, 3, true);
      AssetsList.Draw(BoardMannager.pawn.Canvas, 0, 0, 4, true);
      AssetsList.Draw(BoardMannager.queen.Canvas, 0, 0, 5, true);
    finally
      BoardMannager.Orientation := orTop_Bottom;
      BoardMannager.InitialDraw;
    end;
  scalecomponents;
  autoDeselect.Checked := BoardMannager.autoDeselect;
end;
procedure TChessForm.FormDestroy(Sender: TObject);
begin
  BoardMannager.destroy;
end;
procedure TChessForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    VK_ESCAPE:
    begin
      if boardmannager.selected then
      begin
      boardmannager.selected := false;
      if boardmannager.Turn = 1 then
        boardmannager.turn := 2
      else
        boardmannager.turn := 1;
      boardmannager.debug.println('��� �������� �' + IntToStr(boardmannager.Turn) + nl);
      end;
    end;
    VK_END:
    begin
      BoardMannager.Clear;
      BoardMannager.InitialDraw;
    end;
  end;
end;
procedure TChessForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  SC_DRAGMOVE = $F012;
begin
  if WindowState = wsNormal then
    if Button = mbLeft then
    begin
      ReleaseCapture;
      Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
    end;
end;
procedure TChessForm.imgCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;
procedure TChessForm.imgCloseMouseEnter(Sender: TObject);
begin
  imgClose.Picture := imgCloseHover.Picture;
end;
procedure TChessForm.imgCloseMouseLeave(Sender: TObject);
begin
  imgClose.Picture := imgCloseDef.Picture;
end;

procedure TChessForm.PlayerRefreshTimer(Sender: TObject);
var
  sWPT, sBPT : string;
  I: Integer;
  y, x, newKind: Integer;
begin

  turnColor := RGB(GetGValue(Color), GetBValue(Color), GetRValue(Color));
  selectColor := RGB(GetBValue(Color), GetRValue(Color), GetGValue(Color));
  lblWhiteTitle.Caption := '����� �����';
  lblBlackTitle.Caption := '������ �����';

  for I := 0 to boardmannager.getBlackTooklength  do
  begin
    case boardMannager.BlackPiecesTook[i] of
      0: ;
      1: sBPT := sBPT + '�����' + nl;
      2: sBPT := sBPT + '�����' + nl;
      3: sBPT := sBPT + '����' + nl;
      4: sBPT := sBPT + '����' + nl;
      5: sBPT := sBPT + '�����' + nl;
    end;
  end;
  for I := 0 to boardmannager.getWhiteTooklength  do
  begin
    case boardMannager.WhitePiecesTook[i] of
      0: ;
      1: sWPT := sWPT + '�����' + nl;
      2: sWPT := sWPT + '�����' + nl;
      3: sWPT := sWPT + '����' + nl;
      4: sWPT := sWPT + '����' + nl;
      5: sWPT := sWPT + '�����' + nl;
    end;
  end;
  lblWPiecesTook.caption := sWPT;
  lblBPiecesTook.Caption := sBPT;
  if (BoardMannager.turn = 1) AND (Not BoardMannager.Selected) then
  begin
    lblWhiteTitle.font.Color := turncolor;
    lblBlackTitle.font.Color := clblack;
  end
  else if (BoardMannager.turn = 2) AND (Not BoardMannager.Selected) then
  begin
    lblWhiteTitle.font.Color := clblack;
    lblBlackTitle.font.Color := turncolor;
  end
  else if (BoardMannager.turn = 2) AND (BoardMannager.Selected) then
  begin
    lblWhiteTitle.font.Color := selectcolor;
    lblBlackTitle.font.Color := clblack;
  end
  else if (BoardMannager.turn = 1) AND (BoardMannager.Selected) then
  begin
    lblWhiteTitle.font.Color := clblack;
    lblBlackTitle.font.Color := selectcolor;
  end;
  with boardmannager do
  begin
    if Orientation = orTop_Bottom then
    begin
    for y := 1 to 2 do
      for x := 1 to 8 do
        if (board[x, y * 7 -6].kind = 1) then
        begin
          board[x, y * 7 -6].Kind := 0;
          newKind := pickpawnpromotion;
          SetSquareTo(point(x, y* 7 -6), newKind);
        end
        else if (board[x, y * 7 -6].kind = -1) then
        begin
          board[x, y * 7 -6].Kind := 0;
          newKind := pickpawnpromotion;
          SetSquareTo(point(x, y* 7 -6), -1 * newKind);
        end;
    end
    else
    begin
    for x := 1 to 2 do
      for y := 1 to 8 do
        if board[x * 7 -6, y].kind = 1 then
        begin
          board[x * 7 -6, y].Kind := 0;
          newKind := pickpawnpromotion;
          SetSquareTo(point(x * 7 -6, y), newKind);
        end
        else if board[x * 7 -6, y].kind = -1 then
        begin
          board[x * 7 -6, y].Kind := 0;
          newKind := pickpawnpromotion;
          SetSquareTo(point(x * 7 -6, y), -1 * newKind);
        end;
    end;
  end;
  if boardmannager.selected then
  begin
    highlightblock.Visible := true;
    highlightblock.Top := boardmannager.SelectedSqr.Top;
    highlightblock.Left := boardmannager.SelectedSqr.left;
  end
  else
    highlightblock.Visible := false;
end;
procedure TChessForm.reloadGame;
begin
  SaveManager.SaveToFileOverwrite('_RESETTEMP.DWCS');
  PlayerRefresh.Enabled := false;
  BoardMannager.destroy;
  BoardMannager := nil;
  SaveManager.Destroy;
  FormCreate(nil);
  SaveManager.LoadFromFile('_RESETTEMP.DWCS');
  DeleteFile('_RESETTEMP.DWCS');
  DeleteFile('_RESETTEMP.PGN');
  PlayerRefresh.Enabled := true;
end;
procedure TChessForm.resetSettingsExecute(Sender: TObject);
var
  tS : textfile;
begin
  assignfile(ts, '_SETTINGS.DWCS');
  rewrite(ts);
  write(tS, 'WhiteColor=[default]'#13#10'BlackColor=[default]'#13#10'OutlineColor=[default]'#13#10'BackColor=[default]'#13#10'SaveDir=[default]'#13#10'AutoDeselect=[default]'#13#10'ShowDebug=[default]'#13#10'AssetsDir=[default]'#13#10'END');
  closefile(tS);
  reloadGame;
end;
procedure TChessForm.roundEdges;
var
  rgn : HRGN;
begin
  rgn := CreateRoundRectRgn(0,
    0,
    chessform.ClientWidth,
    chessform.ClientHeight,
    40,
    40);
  SetWindowRgn(chessform.Handle, rgn, True);
end;
procedure TChessForm.saveSettingsExecute(Sender: TObject);
var
 tS : textFile;
 showDebug, autoDeselect : string;
begin
  if NOT BoardMannager.Debug.Visible then
    showdebug := 'false'
  else
    showdebug := 'true';
  if NOT BoardMannager.AutoDeselect then
    autoDeselect := 'false'
  else
    autoDeselect := 'true';
  assignfile(ts, '_SETTINGS.DWCS');
  rewrite(ts);
  write(tS, format(
      'WhiteColor=[%d]'#13#10'BlackColor=[%d]'#13#10'OutlineColor=[%d]'#13#10''
       + 'BackColor=[%d]'#13#10'SaveDir=[%s]'#13#10'AutoDeselect=[%s]'#13#10'ShowDebug=[%s]'#13#10'AssetsDir=[%s]'#13#10'END',
       [rgb(GetBValue(BoardMannager.WhiteColor), GetGValue(BoardMannager.WhiteColor),GetRValue(BoardMannager.WhiteColor)),
        rgb(GetBValue(BoardMannager.BlackColor), GetGValue(BoardMannager.BlackColor),GetRValue(BoardMannager.BlackColor)),
        rgb(GetBValue(BoardMannager.OutlineColor), GetGValue(BoardMannager.OutlineColor),GetRValue(BoardMannager.OutlineColor)),
        color, savemanager.rootDir, autoDeselect, showdebug, assetPath]));
  closefile(tS);
end;
procedure TChessForm.ScaleComponents;
begin
  lblWhiteTitle.Top := 8;
  lblWhiteTitle.Font.Size := Ceil((20 / (1080/ClientHeight)) * scaleMultplier);
  lblWhiteTitle.Left := 8;
  lblBPiecesTook.Left := 8;
  lblBPiecesTook.Top := lblWhiteTitle.Top + lblWhiteTitle.Height + 8;
  lblBlackTitle.Top := 8;
  lblBPiecesTook.Font.Size := Ceil((12 / (1080/ClientHeight))* scaleMultplier);
  lblBlackTitle.Font.Size := Ceil((20 / (1080/ClientHeight))* scaleMultplier);
  lblBlackTitle.Left := BoardMannager.getLastSquareLeft +
    BoardMannager.getSquareHeightWidth + 8;
  lblWPiecesTook.Top := lblBlackTitle.Top + lblBlackTitle.Height + 8;
  lblWPiecesTook.Font.Size := Ceil((12 / (1080/ClientHeight))* scaleMultplier);
  lblWPiecesTook.Left := BoardMannager.getLastSquareLeft +
    BoardMannager.getSquareHeightWidth + 8;

  highlightblock.BringToFront;
  highlightblock.Parent := Self;
  highlightblock.Stretch := true;
  highlightblock.Visible := false;
  highlightblock.Height := BoardMannager.Board[1, 1].Height;
  highlightblock.Width := BoardMannager.Board[1, 1].Width;

  imgClose.Width := Ceil((45 / (1080/ClientHeight))* scaleMultplier);
  imgClose.Height := Ceil((45 / (1080/ClientHeight))* scaleMultplier);
  imgClose.Left := chessform.Width - imgClose.Width - 8;
  BoardMannager.Debug.Font.Size := Ceil((10 / (1080/ClientHeight))* scaleMultplier);
end;
procedure TChessForm.setAssetsPathExecute(Sender: TObject);
var
  prePath : string;
  accept : integer;
begin
  prePath := AssetPath;
  AssetPath := InputBox('', '', AssetPath);
  if prePath <> AssetPath then
    accept := MessageDlg('' , mtConfirmation, [mbYes, mbNo], 0);
  if accept = mrYes then
  begin
    saveSettingsExecute(nil);
    reloadGame;
  end;
end;

procedure TChessForm.setBackColorExecute(Sender: TObject);
begin
  cldlg.Color := color;
  clDlg.Execute();
  Color := clDlg.Color;
end;
procedure TChessForm.setBlackColorExecute(Sender: TObject);
begin

  clDlg.Color := rgb(GetBValue(BoardMannager.BlackColor), GetGValue(BoardMannager.BlackColor),GetRValue(BoardMannager.BlackColor));
  clDlg.Execute();
  if clDlg.Color = $000000 then
    clDlg.Color := $000001;
  if clDlg.Color = $FFFFFF then
    clDlg.Color := $FFFFFE;
  BoardMannager.BlackColor := clDlg.Color;

  end;
procedure TChessForm.setOutlineColorExecute(Sender: TObject);
begin
  clDlg.Color := rgb(GetBValue(BoardMannager.OutlineColor), GetGValue(BoardMannager.OutlineColor),GetRValue(BoardMannager.OutlineColor));
  clDlg.Execute();
  if clDlg.Color = $000000 then
    clDlg.Color := $000001;
  if clDlg.Color = $FFFFFF then
    clDlg.Color := $FFFFFE;
  BoardMannager.OutlineColor := clDlg.Color;


end;
procedure TChessForm.SetSettings;
var
  settingDat : string;
begin

  if fileexists('_SETTINGS.DWCS') then
  begin
    settingDat := getdata('_SETTINGS.DWCS', 'WhiteColor');
    if settingDat <> 'default' then
      BoardMannager.WhiteColor := StrToInt(settingDat);
    settingDat := getdata('_SETTINGS.DWCS', 'BlackColor');
    if settingDat <> 'default' then
      BoardMannager.BlackColor := StrToInt(settingDat);
    settingDat := getdata('_SETTINGS.DWCS', 'OutlineColor');
    if settingDat <> 'default' then
      BoardMannager.OutlineColor := StrToInt(settingDat);
    settingDat := getdata('_SETTINGS.DWCS', 'BackColor');
    if settingDat <> 'default' then
      chessForm.Color := StrToInt(settingDat);
    settingDat := getdata('_SETTINGS.DWCS', 'SaveDir');
    if settingDat <> 'default' then
      SaveManager.rootDir := settingDat;
    settingDat := getdata('_SETTINGS.DWCS', 'ShowDebug');
      if settingDat <> 'default' then
        if settingDat = 'false' then
          BoardMannager.Debug.Visible := false;
    settingDat := getdata('_SETTINGS.DWCS', 'AutoDeselect');
    if settingDat <> 'default' then
      if settingDat = 'false' then
        BoardMannager.AutoDeselect := false;
  end;
end;
procedure TChessForm.setUIScaleExecute(Sender: TObject);
var
  newScaleM : real;
begin
  newScaleM := strtofloat(inputbox('Set new UI Scale', 'Enter a scale multiplier [Any real number]', FloatToStr(scaleMultplier)));
  scaleMultplier := newscaleM;
  ScaleComponents;
end;
procedure TChessForm.setWhiteColorExecute(Sender: TObject);
begin
  clDlg.Color := rgb(GetBValue(BoardMannager.WhiteColor), GetGValue(BoardMannager.WhiteColor),GetRValue(BoardMannager.WhiteColor));
  clDlg.Execute();
  if clDlg.Color = $000000 then
    clDlg.Color := $000001;
  if clDlg.Color = $FFFFFF then
    clDlg.Color := $FFFFFE;
  BoardMannager.WhiteColor := clDlg.Color;

  SaveManager.SaveToFileOverwrite(SaveManager.rootDir + '\_TEMPSAVE.DWCS');
  SaveManager.LoadFromFile(SaveManager.rootDir + '\_TEMPSAVE.DWCS');
  deleteFile(SaveManager.rootDir + '\_TEMPSAVE.DWCS');
  deletefile(SaveManager.rootDir + '\_TEMPSAVE.PGN');
end;
procedure TChessForm.showDebugExecute(Sender: TObject);
begin
  BoardMannager.Debug.Visible := not BoardMannager.Debug.Visible;
end;
procedure TChessForm.ExitButtonClick(Sender: TObject);
begin
   self.Close();

end;

end.
