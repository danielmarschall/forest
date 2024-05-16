library MapGen32;

uses
  SysUtils,
  Classes,
  Windows,
  IniFiles;

{$R *.res}

type
  TFreeSpot = record
    X: integer;
    Y: integer;
    A: integer;
  end;

var
  FreeSpots: array of TFreeSpot;

var
  cMaxBranchLength: integer = 200;
  cPathFlexibility: integer = 15;
  cMapBorderSize: single = 5;
  cPathWidthFactor: single = 1;
  cPathLength: single = 0.20;
  cTreePlacementMaxAttempts: integer = 1000;
  iniLoaded: boolean = false;
  cPathAcceptCheckCornerCircle: boolean = false;
  cPathAcceptCheckCornerCircleRadius: integer = 500;
  cPathAcceptCheckSquares: boolean = true;
  cPathAcceptCheckSquaresHorizontal: integer = 5;
  cPathAcceptCheckSquaresVertical: integer = 5;
  cPathBuildMaxAttempts: integer = 100;

const
  ERR_OK = 0;
  ERR_NO_INI_LOADED = 2;

function LoadParametersFromINI(filename: PAnsiChar): DWORD; cdecl;
var
  ini: TMemIniFile;
begin
  ini := TMemIniFile.Create(filename);
  try
    DecimalSeparator := '.';

    cMaxBranchLength                   := ini.ReadInteger('MapGen32', 'MaxBranchLength',                   200   );
    cPathFlexibility                   := ini.ReadInteger('MapGen32', 'PathFlexibility',                    15   );
    cMapBorderSize                     := ini.ReadFloat  ('MapGen32', 'MapBorderSize',                       5   );
    cPathWidthFactor                   := ini.ReadFloat  ('MapGen32', 'PathWidthFactor',                     1   );
    cPathLength                        := ini.ReadFloat  ('MapGen32', 'PathLength',                          0.20);
    cTreePlacementMaxAttempts          := ini.ReadInteger('MapGen32', 'TreePlacementMaxAttempts',         1000   );

    cPathAcceptCheckCornerCircle       := ini.ReadBool   ('MapGen32', 'PathAcceptCheckCornerCircle',       false);
    cPathAcceptCheckCornerCircleRadius := ini.ReadInteger('MapGen32', 'PathAcceptCheckCornerCircleRadius', 500);

    cPathAcceptCheckSquares            := ini.readBool   ('MapGen32', 'PathAcceptCheckSquares',           true);
    cPathAcceptCheckSquaresHorizontal  := ini.ReadInteger('MapGen32', 'PathAcceptCheckSquaresHorizontal', 5);
    cPathAcceptCheckSquaresVertical    := ini.ReadInteger('MapGen32', 'PathAcceptCheckSquaresVertical',   5);

    cPathBuildMaxAttempts              := ini.ReadInteger('MapGen32', 'PathBuildMaxAttempts', 100);
  finally
    ini.Free;
  end;

  iniLoaded := true;
  result := ERR_OK;
end;

function RandBetween(a, b: integer): integer;
begin
  result := Random(b-a+1)+a;
end;

function IsInCircle(p, q: TPoint; r: integer): boolean;
begin
  result := sqrt((p.x-q.x)*(p.x-q.x) + (p.y-q.y)*(p.y-q.y)) <= r;
end;

function _AcceptedPath(maxX, maxY: integer): boolean;

  function __CheckCircle(x, y: integer): boolean;
  var
    i: integer;
    p, q: TPoint;
  begin
    p := Point(x, y);
    result := false;
    for i := Low(FreeSpots) to High(FreeSpots) do
    begin
      q := Point(FreeSpots[i].X, FreeSpots[i].Y);
      if IsInCircle(p, q, cPathAcceptCheckCornerCircleRadius) then
      begin
        result := true;
        Break;
      end;
    end;
  end;

  function __CheckSquare(left, top, width, height: integer): boolean;
  var
    i: integer;
  begin
    result := false;
    for i := Low(FreeSpots) to High(FreeSpots) do
    begin
      if (FreeSpots[i].X >= left) and
         (FreeSpots[i].Y >= top) and
         (FreeSpots[i].X <= left+width) and
         (FreeSpots[i].Y <= top+height) then
      begin
        result := true;
        break;
      end;
    end;
  end;

  function __AcceptCircleCheck: boolean;
  begin
    result :=
      __CheckCircle(     cPathAcceptCheckCornerCircleRadius,      cPathAcceptCheckCornerCircleRadius) and // oben links
      __CheckCircle(maxX-cPathAcceptCheckCornerCircleRadius,      cPathAcceptCheckCornerCircleRadius) and // oben rechts
      __CheckCircle(     cPathAcceptCheckCornerCircleRadius, maxY-cPathAcceptCheckCornerCircleRadius) and // unten links
      __CheckCircle(maxX-cPathAcceptCheckCornerCircleRadius, maxY-cPathAcceptCheckCornerCircleRadius);    // unten rechts
  end;

  function __AcceptSquaresCheck: boolean;
  var
    ix, iy: integer;
    left, top: integer;
    squareWidth, squareHeight: integer;
  begin
    squareWidth  := maxX div cPathAcceptCheckSquaresHorizontal;
    squareHeight := maxY div cPathAcceptCheckSquaresVertical;
    for ix := 0 to cPathAcceptCheckSquaresHorizontal-1 do
    begin
      left := ix * squareWidth;
      for iy := 0 to cPathAcceptCheckSquaresVertical-1 do
      begin
        top := iy * squareHeight;
        if not __CheckSquare(left, top, squareWidth, squareHeight) then
        begin
          result := false;
          exit;
        end;
      end;
    end;
    result := true;
  end;

begin
  result := true;

  if result and cPathAcceptCheckCornerCircle then
  begin
    result := result and __AcceptCircleCheck;
  end;

  if result and cPathAcceptCheckSquares then
  begin
    result := result and __AcceptSquaresCheck;
  end;
end;

procedure _BuildPaths(nFreespots, maxX, maxY, nTrees, r, startX, startY, angle: integer);
var
  i: integer;
  x: integer;
  maxdrawn: integer;
  iBeginBranch: integer;
//  midDistance: extended;
  locFlexibility: integer;
//  midDeltaX, midDeltaY: integer;
begin
  SetLength(FreeSpots, nFreespots);

  FreeSpots[0].A := angle;
  FreeSpots[0].X := startX;
  FreeSpots[0].Y := startY;

  iBeginBranch := 1;

  while true do
  begin
    maxdrawn := 0;
    for i := iBeginBranch to iBeginBranch+cMaxBranchLength do
    begin
      if i > High(FreeSpots) then Exit;

//      midDeltaX := FreeSpots[i-1].X - startX;
//      midDeltaY := FreeSpots[i-1].Y - startY;
//      midDistance := sqrt(midDeltaX*midDeltaX + midDeltaY*midDeltaY);

(*
      if midDistance > 4000 then
        locFlexibility := Round(cPathFlexibility + midDistance/5000)
      else
        locFlexibility := cPathFlexibility;
*)
      locFlexibility := cPathFlexibility;

      FreeSpots[i].A := RandBetween(FreeSpots[i-1].A-locFlexibility, FreeSpots[i-1].A+locFlexibility);
      FreeSpots[i].X := FreeSpots[i-1].X + round(r*cos(FreeSpots[i].A/360*2*pi));
      FreeSpots[i].Y := FreeSpots[i-1].Y + round(r*sin(FreeSpots[i].A/360*2*pi));

      if FreeSpots[i].X > maxX-cMapBorderSize*r then break;
      if FreeSpots[i].Y > maxY-cMapBorderSize*r then break;
      if FreeSpots[i].X < cMapBorderSize*r then break;
      if FreeSpots[i].Y < cMapBorderSize*r then break;

      maxdrawn := i;
    end;

    x := RandBetween(maxdrawn div 2, maxdrawn); // RandBetween(0, maxdrawn);
    FreeSpots[maxdrawn+1] := FreeSpots[x]; // virtual free spot

    if RandBetween(0,1) = 0 then
      FreeSpots[maxdrawn+1].A := FreeSpots[x].A-90
    else
      FreeSpots[maxdrawn+1].A := FreeSpots[x].A+90;

    iBeginBranch := maxdrawn+2;
  end;
end;

type
  TDWordArray = array of DWord;
  PDWordArray = ^TDWordArray;

function GetWaypointArrayElements(nTrees: integer): DWORD; cdecl;
begin
  result := Round(cPathLength*nTrees);
end;

function GenerateMap(nTrees, treeRadius, mapX, mapY: integer;
  memblockTrees, memblockWayPoints: PDWordArray): DWORD; cdecl;
var
  pathSize: integer;
  aryTrees, aryWaypoints: TDWordArray;
  i, j, k: integer;
  p, q: TPoint;
  ok: boolean;
  nFreespots: integer;
begin
  if not iniLoaded then
  begin
    result := ERR_NO_INI_LOADED;
    Exit;
  end;

  if memblockTrees <> nil then
    aryTrees := TDWordArray(memblockTrees)
  else
    SetLength(aryTrees, 0); // prevent compiler warning

  if memblockWayPoints <> nil then
    aryWaypoints := TDWordArray(memblockWayPoints)
  else
    SetLength(aryWaypoints, 0); // prevent compiler warning

  pathSize := Round(cPathWidthFactor * treeRadius);
  nFreespots := GetWaypointArrayElements(nTrees);

  k := 0;
  repeat
    Inc(k);
    _BuildPaths(nFreespots, mapx, mapy, nTrees, treeradius, mapX div 2, mapY div 2, RandBetween(0,359));
  until (k >= cPathBuildMaxAttempts) or _AcceptedPath(mapx, mapy);

  if memblockTrees <> nil then
  begin
    for i := 0 to nTrees-1 do
    begin
      k := 0;
      repeat
        inc(k);
        ok := true;
        p := Point(Random(mapX+1), Random(mapY+1));

        // Bäume nicht in den Weg bauen
        for j := Low(FreeSpots) to High(FreeSpots) do
        begin
          q := Point(FreeSpots[j].X, FreeSpots[j].Y);
          if IsInCircle(p, q, treeRadius + pathSize div 2) then
          begin
            ok := false;
            break;
          end;
        end;

        // Bäume sollen sich nicht überschneiden
        for j := Low(FreeSpots) to High(FreeSpots) do
        begin
          q := Point(FreeSpots[j].X, FreeSpots[j].Y);
          if IsInCircle(p, q, treeRadius + pathSize div 2) then
          begin
            ok := false;
            break;
          end;
        end;
      until ok or (k > cTreePlacementMaxAttempts);

      aryTrees[i*2]   := p.x;
      aryTrees[i*2+1] := p.y;
    end;
  end;

  if memblockWayPoints <> nil then
  begin
    for i := 0 to nFreespots-1 do
    begin
      aryWaypoints[i*2]   := FreeSpots[i].X;
      aryWaypoints[i*2+1] := FreeSpots[i].Y;
    end;
  end;

  result := ERR_OK;
end;

function RandomSeed: integer; cdecl;
begin
  Randomize;
  result := RandSeed;
end;

procedure UseSeed(seed: integer); cdecl;
begin
  RandSeed := seed;
end;

exports
  GenerateMap name 'GenerateMap',
  LoadParametersFromINI name 'LoadParametersFromINI',
  RandomSeed name 'RandomSeed',
  UseSeed name 'UseSeed',
  GetWaypointArrayElements name 'GetWaypointArrayElements';

end.
