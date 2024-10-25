object Loading_Screen: TLoading_Screen
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Loading_Screen'
  ClientHeight = 724
  ClientWidth = 761
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 761
    Height = 729
  end
  object Label1: TLabel
    Left = 80
    Top = 8
    Width = 648
    Height = 60
    Caption = #1050#1090#1086' '#1080#1079' '#1085#1072#1089' '#1043#1088#1086#1089#1089#1084#1077#1081#1089#1090#1077#1088'?'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlight
    Font.Height = 60
    Font.Name = 'Cascadia Mono'
    Font.Style = []
    ParentFont = False
  end
  object ProgressBar1: TProgressBar
    Left = 160
    Top = 656
    Width = 449
    Height = 41
    ParentCustomHint = False
    DoubleBuffered = True
    ParentDoubleBuffered = False
    ParentShowHint = False
    BarColor = clBlue
    BackgroundColor = clBlue
    ShowHint = False
    TabOrder = 0
    StyleElements = []
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 8
    Top = 24
  end
end
