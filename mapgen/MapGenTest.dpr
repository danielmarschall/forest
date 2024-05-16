program MapGenTest;

uses
  Forms,
  MapGenTestMain in 'MapGenTestMain.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
