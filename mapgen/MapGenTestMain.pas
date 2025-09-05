unit MapGenTestMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, IniFiles, Spin, ShellAPI;

type
  TDWordPoint = array[0..1] of DWord;

  TMainForm = class(TForm)
    InitTimer: TTimer;
    INIOpenDialog: TOpenDialog;
    MapImage: TImage;
    ControlPanel: TPanel;
    ShowPathCheckbox: TCheckBox;
    LoadINIButton: TButton;
    GenMapButton: TButton;
    SeedSpinEdit: TSpinEdit;
    SeedLabel: TLabel;
    PlayButton: TButton;
    procedure GenMapButtonClick(Sender: TObject);
    procedure InitTimerTimer(Sender: TObject);
    procedure ShowPathCheckboxClick(Sender: TObject);
    procedure LoadINIButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SeedSpinEditChange(Sender: TObject);
    procedure PlayButtonClick(Sender: TObject);
  private
    mbTrees, mbWayPoints: array of TDWordPoint;
    treeradius, ntrees, nwaypoints, mapX, mapY: DWord;
    miniatureFactor: DWord;
    drawn: boolean;
    loadedINI: string;
    procedure DrawCircle(x, y, r: integer; color: TColor);
    procedure RedrawMap;
    procedure ResizeMapForm;
    function LoadINI(filename: AnsiString): boolean;
    function FindINIFile: string;
    procedure GenMapSeed(seed: integer);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

const
  DEFAULT_INI_PATH = '..\Forest.ini';

resourcestring
  LNG_TITLE = '%s - Map Generation Test';
  LNG_MAPGEN_LOAD_FAILED = 'Map generator initialization failed with code %d';
  LNG_MAPGEN_GEN_FAILED = 'Map generator failed with code %d';
  LNG_GAMEFILE_NOT_FOUND = 'Game file "%s" not found';

type
  TDWordArray = array of DWord;
  PDWordArray = ^TDWordArray;

function GenerateMap(nTrees, treeRadius, mapX, mapY: integer;
  memblockTrees, memblockWayPoints: PDWordArray): DWORD; cdecl;
  external 'MapGen32.dll';

function LoadParametersFromINI(filename: PAnsiChar): DWORD; cdecl;
  external 'MapGen32.dll';

function RandomSeed: integer; cdecl;
  external 'MapGen32.dll';

procedure UseSeed(seed: integer); cdecl;
  external 'MapGen32.dll';

function GetWaypointArrayElements(nTrees: integer): DWORD; cdecl;
  external 'MapGen32.dll';

{ TMainForm }

procedure TMainForm.DrawCircle(x, y, r: integer; color: TColor);
begin
  MapImage.Canvas.Brush.Color := color;
  MapImage.Canvas.Pen.Color := color;
  MapImage.Canvas.Ellipse(X-r, Y-r, X+r, Y+r);
end;

function TMainForm.LoadINI(filename: AnsiString): boolean;
var
  ini: TMemIniFile;
  ec: DWORD;
begin
  result := false;

  ec := LoadParametersFromINI(PAnsiChar(filename));
  if ec <> 0 then
  begin
    ShowMessageFmt(LNG_MAPGEN_LOAD_FAILED, [ec]);
  end;

  ini := TMemIniFile.Create(filename);
  try
    treeradius := ini.ReadInteger('Forest', 'cTreeRadius', 100);
    ntrees := ini.ReadInteger('Forest', 'cMaxTrees', 3000);
    mapX := ini.ReadInteger('Forest', 'cMapSizeX', 10000);
    mapY := ini.ReadInteger('Forest', 'cMapSizeZ', 10000);

    if not drawn then
    begin
      ShowPathCheckbox.Checked := ini.ReadBool('MapViewer', 'DefaultDrawWaypoints', true);
    end;

    miniatureFactor := ini.ReadInteger('MapViewer', 'miniatureFactor', 20);

    Caption := Format(LNG_TITLE, [ini.ReadString('Product', 'Title', '')]);
  finally
    ini.Free;
  end;

  loadedINI := filename;

  ResizeMapForm;

  if drawn then GenMapButton.Click;

  result := true;
end;

procedure TMainForm.ResizeMapForm;
begin
  ClientWidth := mapX div miniatureFactor;
  ClientHeight := mapY div miniatureFactor + Cardinal(ControlPanel.Height);
end;

procedure TMainForm.GenMapSeed(seed: integer);
var
  ec: DWORD;
begin
  UseSeed(seed);

  nwaypoints := GetWaypointArrayElements(ntrees);

  SetLength(mbTrees, ntrees);
  SetLength(mbWayPoints, nwaypoints);

  ec := GenerateMap(ntrees, treeradius, mapx, mapy, @mbTrees[0][0], @mbWayPoints[0][0]);
  if ec <> 0 then
  begin
    ShowMessageFmt(LNG_MAPGEN_GEN_FAILED, [ec]);
    MapImage.Picture := nil;
    Exit;
  end;

  RedrawMap;
  drawn := true;
end;

procedure TMainForm.GenMapButtonClick(Sender: TObject);
begin
  SeedSpinEdit.Value := RandomSeed;
end;

procedure TMainForm.InitTimerTimer(Sender: TObject);
begin
  InitTimer.Enabled := False;
  GenMapButton.Click;
end;

procedure TMainForm.ShowPathCheckboxClick(Sender: TObject);
begin
  if drawn then
  begin
    RedrawMap;
  end;
end;

procedure TMainForm.RedrawMap;
var
  i: integer;
begin
  MapImage.Picture := nil;

  MapImage.Canvas.Brush.Color := clOlive;
  MapImage.Canvas.Pen.Color := clBlack;
  MapImage.Canvas.Rectangle(0, 0, mapx div miniatureFactor, mapy div miniatureFactor);

  if ShowPathCheckbox.Checked then
  begin
    for i := 0 to nwaypoints-1 do
    begin
      // Paths
      // TODO: neue variable pathradius anstelle treeradius?
      DrawCircle(mbWayPoints[i][0] div miniatureFactor, mbWayPoints[i][1] div miniatureFactor, treeradius div miniatureFactor, clGreen);
    end;
  end;

  for i := 0 to ntrees-1 do
  begin
    // Tree
    DrawCircle(mbTrees[i][0] div miniatureFactor, mbTrees[i][1] div miniatureFactor, treeradius div miniatureFactor, clMaroon);
  end;

  // Playef
  DrawCircle(mapX div 2 div miniatureFactor, mapY div 2 div miniatureFactor, treeradius div miniatureFactor, clBlue);
end;

procedure TMainForm.LoadINIButtonClick(Sender: TObject);
begin
  if INIOpenDialog.Execute then
  begin
    LoadINI(INIOpenDialog.FileName);
  end;
end;

function TMainForm.FindINIFile: string;
begin
  if FileExists('Forest.ini') then
    result := 'Forest.ini'
  else if FileExists('..\Forest.ini') then
    result := '..\Forest.ini'
  else if INIOpenDialog.Execute then
    result := INIOpenDialog.FileName
  else
    result := '';
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  ok: boolean;
  filename: string;
begin
  filename := FindINIFile;

  if filename <> '' then
    ok := LoadINI(filename)
  else
    ok := false;

  if not ok then
  begin
    Close;
  end;
end;

procedure TMainForm.SeedSpinEditChange(Sender: TObject);
begin
  if SeedSpinEdit.Text <> '' then
  begin
    GenMapSeed(SeedSpinEdit.Value);
  end;
end;

procedure TMainForm.PlayButtonClick(Sender: TObject);
var
  ini: TMemIniFile;
  seedfile, gamefile: string;
begin
  gamefile := IncludeTrailingPathDelimiter(ExtractFileDir(loadedINI))+'Forest.exe';
  if not FileExists(gamefile) then
  begin
    ShowMessageFmt(LNG_GAMEFILE_NOT_FOUND, [gamefile]);
    Exit;
  end;

  seedfile := IncludeTrailingPathDelimiter(ExtractFileDir(loadedINI))+'Seed.ini';
  ini := TMemIniFile.Create(seedfile);
  try
    ini.WriteInteger('Seed', 'onetime', 1);
    ini.WriteInteger('Seed', 'active', 1);
    ini.WriteInteger('Seed', 'seed', SeedSpinEdit.Value);
    ini.UpdateFile;
  finally
    ini.Free;
  end;

  ShellExecute(0, 'open', PChar(gamefile), '', '', SW_NORMAL);
  
  Close;
end;

end.
