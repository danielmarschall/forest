program ForestLauncher;

uses
  Vcl.Forms,
  ForestLauncherMain in 'ForestLauncherMain.pas' {MainForm},
  ForestLauncherMapGen in 'ForestLauncherMapGen.pas' {MapGenForm},
  ForestDLL_Import in 'ext\ForestDLL_Import.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TMapGenForm, MapGenForm);
  Application.Run;
end.
