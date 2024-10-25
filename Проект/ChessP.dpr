program ChessP;
uses
  Forms,
  PlayerU in 'PlayerU.pas' {ChessForm},
  EngineClasses in 'EngineClasses.pas',
  Launcher in 'Launcher.pas' {frmLauncher},
  EngineUI in 'EngineUI.pas',
  LoadU in 'LoadU.pas' {Loading_Screen};

{$R *.res}
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TLoading_Screen, Loading_Screen);
  Application.CreateForm(TfrmLauncher, frmLauncher);
  Application.CreateForm(TChessForm, ChessForm);
  Application.Run;
end.
