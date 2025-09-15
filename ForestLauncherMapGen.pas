unit ForestLauncherMapGen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin, ShellAPI;

type
  TDWordPoint = array[0..1] of DWord;

  TMapGenForm = class(TForm)
    MapImage: TImage;
    ControlPanel: TPanel;
    ShowPathCheckbox: TCheckBox;
    RegenerateBtn: TButton;
    SeedSpinEdit: TSpinEdit;
    SeedLabel: TLabel;
    SaveBtn: TButton;
    procedure RegenerateBtnClick(Sender: TObject);
    procedure ShowPathCheckboxClick(Sender: TObject);
    procedure SeedSpinEditChange(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    mbTrees, mbWayPoints: array of TDWordPoint;
    nwaypoints: integer;
    miniatureFactor: DWord;
    procedure DrawCircle(x, y, r: integer; color: TColor);
    procedure RedrawMap;
    procedure ResizeMapForm;
    procedure GenMapSeed(seed: integer);
  end;

var
  MapGenForm: TMapGenForm;

implementation

uses
  ForestDLL_Import, ForestLauncherMain;

{$R *.dfm}

{ TMapGenForm }

procedure TMapGenForm.DrawCircle(x, y, r: integer; color: TColor);
begin
  MapImage.Canvas.Brush.Color := color;
  MapImage.Canvas.Pen.Color := color;
  MapImage.Canvas.Ellipse(X-r, Y-r, X+r, Y+r);
end;

procedure TMapGenForm.ResizeMapForm;
begin
  // TODO: when the form will become bigger than the screen, we need to adjust the miniatureFactor
  ClientWidth := MainForm.seMapSizeX.Value div miniatureFactor;
  ClientHeight := MainForm.seMapSizeZ.Value div miniatureFactor + Cardinal(ControlPanel.Height);
end;

procedure TMapGenForm.GenMapSeed(seed: integer);
begin
  MAP_UseSeed(seed);

  nwaypoints := MAP_GetWaypointArrayElements(MainForm.seTrees.Value);

  SetLength(mbTrees, MainForm.seTrees.Value);
  SetLength(mbWayPoints, nwaypoints);

  MAP_GenerateMap(MainForm.seTrees.Value, MainForm.treeradius, MainForm.seMapSizeX.Value, MainForm.seMapSizeZ.Value, @mbTrees[0][0], @mbWayPoints[0][0]);

  RedrawMap;
end;

procedure TMapGenForm.FormShow(Sender: TObject);
begin
  Tag := 1; // avoid that the VCL causes a redraw before everything is initialized
  try
    MAP_LoadParameters;

    ShowPathCheckbox.Checked := INI_ReadBool('MapViewer', 'DefaultDrawWaypoints', 1) = 1;
    miniatureFactor := INI_ReadInt('MapViewer', 'miniatureFactor', 20);

    ResizeMapForm;

    SeedSpinEdit.Clear; // to enforce that SeedSpinEditChange() will trigger GenMapSeed()
  finally
    Tag := 0;
  end;

  SeedSpinEdit.Value := MainForm.seed_value; // SeedSpinEditChange() will trigger GenMapSeed()
end;

procedure TMapGenForm.RegenerateBtnClick(Sender: TObject);
begin
  SeedSpinEdit.Value := MAP_RandomSeed; // SeedSpinEditChange() will trigger GenMapSeed()
end;

procedure TMapGenForm.ShowPathCheckboxClick(Sender: TObject);
begin
  if Tag = 1 then exit;
  RedrawMap;
end;

procedure TMapGenForm.RedrawMap;
var
  i: integer;
begin
  MapImage.Picture := nil;

  MapImage.Canvas.Brush.Color := clOlive;
  MapImage.Canvas.Pen.Color := clBlack;
  MapImage.Canvas.Rectangle(0, 0, MainForm.seMapSizeX.Value div miniatureFactor, MainForm.seMapSizeZ.Value div miniatureFactor);

  if ShowPathCheckbox.Checked then
  begin
    for i := 0 to nwaypoints-1 do
    begin
      // Paths
      // TODO: use a new variable "pathradius" instead of "treeradius"?
      DrawCircle(mbWayPoints[i][0] div miniatureFactor, mbWayPoints[i][1] div miniatureFactor, MainForm.treeradius div miniatureFactor, clGreen);
    end;
  end;

  for i := 0 to MainForm.seTrees.Value-1 do
  begin
    // Tree
    DrawCircle(mbTrees[i][0] div miniatureFactor, mbTrees[i][1] div miniatureFactor, MainForm.treeradius div miniatureFactor, clMaroon);
  end;

  // Player
  DrawCircle(MainForm.seMapSizeX.Value div 2 div miniatureFactor, MainForm.seMapSizeZ.Value div 2 div miniatureFactor, MainForm.treeradius div miniatureFactor, clBlue);
end;

procedure TMapGenForm.SeedSpinEditChange(Sender: TObject);
begin
  if Tag = 1 then exit;
  if SeedSpinEdit.Text <> '' then
  begin
    GenMapSeed(SeedSpinEdit.Value);
  end;
end;

procedure TMapGenForm.SaveBtnClick(Sender: TObject);
begin
  MainForm.seed_value := StrToInt(SeedSpinEdit.Text);
  Close;
end;

end.
