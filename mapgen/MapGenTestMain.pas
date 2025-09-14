unit MapGenTestMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin, ShellAPI;

type
  TDWordPoint = array[0..1] of DWord;

  TMainForm = class(TForm)
    InitTimer: TTimer;
    MapImage: TImage;
    ControlPanel: TPanel;
    ShowPathCheckbox: TCheckBox;
    GenMapButton: TButton;
    SeedSpinEdit: TSpinEdit;
    SeedLabel: TLabel;
    PlayButton: TButton;
    procedure GenMapButtonClick(Sender: TObject);
    procedure InitTimerTimer(Sender: TObject);
    procedure ShowPathCheckboxClick(Sender: TObject);
    procedure SeedSpinEditChange(Sender: TObject);
    procedure PlayButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    mbTrees, mbWayPoints: array of TDWordPoint;
    treeradius, ntrees, nwaypoints, mapX, mapY: DWord;
    miniatureFactor: DWord;
    drawn: boolean;
    procedure DrawCircle(x, y, r: integer; color: TColor);
    procedure RedrawMap;
    procedure ResizeMapForm;
    procedure GenMapSeed(seed: integer);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

type
  TDWordArray = array of DWord;
  PDWordArray = ^TDWordArray;

procedure COR_Initialize; cdecl; external 'ForestDLL.dll';

procedure COR_Uninitialize; cdecl; external 'ForestDLL.dll';

procedure MAP_GenerateMap(nTrees, treeRadius, mapX, mapY: integer;
  memblockTrees, memblockWayPoints: PDWordArray); cdecl;
  external 'ForestDLL.dll';

procedure MAP_LoadParameters; cdecl;
  external 'ForestDLL.dll';

function MAP_RandomSeed: integer; cdecl;
  external 'ForestDLL.dll';

procedure MAP_UseSeed(seed: integer); cdecl;
  external 'ForestDLL.dll';

function MAP_GetWaypointArrayElements(nTrees: integer): DWORD; cdecl;
  external 'ForestDLL.dll';

function INI_ReadInt(section, name: PAnsiChar; default: integer): integer; cdecl;
  external 'ForestDLL.dll';

function INI_ReadBool(section, name: PAnsiChar; default: integer): integer; cdecl;
  external 'ForestDLL.dll';

procedure INI_WriteInt(section, name: PAnsiChar; value: integer); cdecl;
  external 'ForestDLL.dll';

{ TMainForm }

procedure TMainForm.DrawCircle(x, y, r: integer; color: TColor);
begin
  MapImage.Canvas.Brush.Color := color;
  MapImage.Canvas.Pen.Color := color;
  MapImage.Canvas.Ellipse(X-r, Y-r, X+r, Y+r);
end;

procedure TMainForm.ResizeMapForm;
begin
  ClientWidth := mapX div miniatureFactor;
  ClientHeight := mapY div miniatureFactor + Cardinal(ControlPanel.Height);
end;

procedure TMainForm.GenMapSeed(seed: integer);
begin
  MAP_UseSeed(seed);

  nwaypoints := MAP_GetWaypointArrayElements(ntrees);

  SetLength(mbTrees, ntrees);
  SetLength(mbWayPoints, nwaypoints);

  MAP_GenerateMap(ntrees, treeradius, mapx, mapy, @mbTrees[0][0], @mbWayPoints[0][0]);

  RedrawMap;
  drawn := true;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  COR_Uninitialize;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  COR_Initialize;

  MAP_LoadParameters;

  treeradius := INI_ReadInt('Game', 'cTreeRadius', 100);
  ntrees := INI_ReadInt('Game', 'cMaxTrees', 3000);
  mapX := INI_ReadInt('Game', 'cMapSizeX', 10000);
  mapY := INI_ReadInt('Game', 'cMapSizeZ', 10000);

  if not drawn then
  begin
    ShowPathCheckbox.Checked := INI_ReadBool('MapViewer', 'DefaultDrawWaypoints', 1) = 1;
  end;

  miniatureFactor := INI_ReadInt('MapViewer', 'miniatureFactor', 20);

  ResizeMapForm;

  if drawn then GenMapButton.Click;
end;

procedure TMainForm.GenMapButtonClick(Sender: TObject);
begin
  SeedSpinEdit.Value := MAP_RandomSeed;
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

procedure TMainForm.SeedSpinEditChange(Sender: TObject);
begin
  if SeedSpinEdit.Text <> '' then
  begin
    GenMapSeed(SeedSpinEdit.Value);
  end;
end;

procedure TMainForm.PlayButtonClick(Sender: TObject);
resourcestring
  LNG_GAMEFILE_NOT_FOUND = 'Game file "%s" not found';
var
  seedfile, gamefile: string;
begin
  gamefile := 'Forest.exe';
  if not FileExists(gamefile) then
  begin
    ShowMessageFmt(LNG_GAMEFILE_NOT_FOUND, [gamefile]);
    Exit;
  end;

  INI_WriteInt('MapGen32', 'seed_value', SeedSpinEdit.Value);

  ShellExecute(0, 'open', PChar(gamefile), '', '', SW_NORMAL);
  
  Close;
end;

end.
