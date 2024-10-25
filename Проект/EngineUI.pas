unit EngineUI;

interface

uses
  ExtCtrls, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, Math, StdCtrls, pngimage;

function PickPawnPromotion : byte;

implementation

function PickPawnPromotion : byte;
var
  frm : TForm;
  rgn: HRGN;
  Done : boolean;
  lbl : TLabel;
  sR : array of string;
  i, y, i2 : integer;
  clickRegions : array of trect;
  rects : array of TShape;
begin
  Done := false;

  frm := TForm.CreateNew(nil, 0);
  frm.BorderStyle := bsNone;
  frm.AlphaBlend := true;
  frm.AlphaBlendValue := 0;

  lbl := TLabel.Create(frm);
  lbl.Parent := frm;
  lbl.Caption := '� � � � � � � � � � �  � � � � �';
  lbl.Font.Name := 'Arial';
  lbl.Font.Size := 18;
  lbl.Font.Color := $5D2FFF;
  lbl.Font.Style := [fsBold];

  frm.ClientWidth := lbl.Width + 40;

  lbl.left := round((frm.ClientWidth/2) - (lbl.Width/2));
  lbl.Top := 20;

  i := 0;
  for i := 1 to 4 do
  begin
    SetLength(rects, i);
    SetLength(clickRegions, i);
    SetLength(sR, i);
    rects[i-1] := TShape.Create(frm);
    with rects[i-1] do
    begin
      Parent := frm;
      Width := frm.ClientWidth;
      brush.Color := $FFDD69;
      top := i*(height+5);
      pen.Style := psClear;
    end;
    case i of
      1: sr[i - 1] := '�����';
      2: sr[i - 1] := '����';
      3: sr[i - 1] := '����';
      4: sr[i - 1] := '�����';
    end;
    lbl := TLabel.Create(frm);
    with lbl do
    begin
      parent := frm;
      Font.Name := 'Arial';
      Font.Size := 18;
      Font.Color := rgb(105,97,225);
      Font.Style := [fsBold];
      Top := round(rects[i-1].Top + (rects[i-1].Height/2) - (Height/2)) ;
      Caption := sR[i-1];
      Left := round((frm.Width/2) - (lbl.Width/2));
    end;
  end;

  frm.ClientHeight := rects[i-2].Top + rects[i-2].Height + 20;
  frm.Position := poScreenCenter;

  rgn := CreateRoundRectRgn(0,
    0,
    frm.ClientWidth,
    frm.ClientHeight,
    20,
    20);
  SetWindowRgn(frm.Handle, rgn, True);
  frm.Color := rgb(168,244,255);
  frm.DoubleBuffered := true;
  frm.Show;

  i2 := 0;
  while i2 < 250 do
  begin
    inc(i2, 2);
    frm.AlphaBlendValue := i2;
    Application.ProcessMessages;
  end;

  for y := 0 to i - 2 do
  begin
    clickRegions[y].Left := rects[y].ClientToScreen(point(0,0)).x;
    clickRegions[y].Top := rects[y].ClientToScreen(point(0,0)).y;
    clickRegions[y].Bottom := rects[y].ClientToScreen(point(0,0 + rects[y].height)).y;
    clickRegions[y].Right := rects[y].ClientToScreen(point(0 + rects[y].width,0)).x;
  end;

  while not done do
  begin
    frm.BringToFront;
    for Y := 0 to i - 2 do
    begin
      if (mouse.CursorPos.X >= clickRegions[y].Left) AND
        (mouse.CursorPos.X <= clickRegions[y].Right) AND
        (mouse.CursorPos.Y >= clickRegions[y].Top) AND
        (mouse.CursorPos.Y <= clickRegions[y].Bottom) then
      begin
        while GETGVALUE(rects[y].Brush.Color) > $BE do
        begin
          rects[y].Brush.Color := rects[y].Brush.Color - $000100;
          Application.ProcessMessages;
        end;
        if GetKeyState(VK_LBUTTON) < 0 then
          Done := True;
          case sR[y][1] of
            '�' : result := 2;
            '�' : result := 3;
            '�' : result := 4;
            '�' : result := 5;
          end;
      end
      else
      begin
        while GETGVALUE(rects[y].Brush.Color) < $DD do
        begin
          rects[y].Brush.Color := rects[y].Brush.Color + $000100;
          Application.ProcessMessages;
        end;
      end;
      Application.ProcessMessages;
    end;
    Application.ProcessMessages;
  end;
  i2 := 250;
  while i2 > 2 do
  begin
    dec(i2, 2);
    frm.AlphaBlendValue := i2;
    Application.ProcessMessages;
  end;
  frm.Destroy;
end;

end.
