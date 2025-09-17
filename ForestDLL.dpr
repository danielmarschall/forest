library ForestDLL;

uses
  Winapi.Windows,
  System.SysUtils,
  System.Types,
  System.Classes,
  System.IniFiles,
  System.AnsiStrings;

{$R *.res}

{$REGION '(COR) Core Functions'}

var
  iniDefaults: TMemIniFile = nil;
  iniUser: TMemIniFile = nil;
  iniOnce: TMemIniFile = nil;

function Internal_iniDefaultsFileName: string;
begin
  result := 'ForestDefaults.ini';
end;

function Internal_iniUserFileName: string;
begin
  result := 'ForestUser.ini'; // TODO: user dir
end;

function Internal_iniOnceFileName: string;
begin
  result := 'ForestOnce.ini'; // TODO: user or user-temp dir
end;

const
  COR_INITIALIZE_READ_DEFAULT = 1;
  COR_INITIALIZE_READ_USER = 2;
  COR_INITIALIZE_READ_ONCE = 4;
  COR_INITIALIZE_DELETE_ONCE = 8;
procedure COR_Initialize(source: integer); cdecl;
begin
  {$IF CompilerVersion >= 20.0} // Version guessed
  FormatSettings.DecimalSeparator := '.';
  {$ELSE}
  DecimalSeparator := '.';
  {$ENDIF}

  if ((source and COR_INITIALIZE_READ_DEFAULT) <> 0) and FileExists(Internal_iniDefaultsFileName) then
    iniDefaults := TMemIniFile.Create(Internal_iniDefaultsFileName)
  else
    iniDefaults := nil;

  if ((source and COR_INITIALIZE_READ_USER) <> 0) and FileExists(Internal_iniUserFileName) then
    iniUser := TMemIniFile.Create(Internal_iniUserFileName)
  else
    iniUser := nil;

  if ((source and COR_INITIALIZE_READ_ONCE) <> 0) and FileExists(Internal_iniOnceFileName) then
    iniOnce := TMemIniFile.Create(Internal_iniOnceFileName)
  else
    iniOnce := nil;

  if ((source and COR_INITIALIZE_DELETE_ONCE) <> 0) and FileExists(Internal_iniOnceFileName) then
    DeleteFile(Internal_iniOnceFileName); // to avoid that it is used a second time
end;

procedure COR_Uninitialize; cdecl;
begin
  if Assigned(iniDefaults) then FreeAndNil(iniDefaults);
  if Assigned(iniUser) then FreeAndNil(iniUser);
  if Assigned(iniOnce) then FreeAndNil(iniOnce);
end;

{$ENDREGION}

{$REGION '(INI) Configuration file functions'}

function Internal_ReadInteger(const Section, Ident: string; Default: Integer): integer;
var
  ini: TMemIniFile;
begin
  if Assigned(iniOnce) and iniOnce.ValueExists(section, ident) then ini := iniOnce
  else if Assigned(iniUser) and iniUser.ValueExists(section, ident) then ini := iniUser
  else if Assigned(iniDefaults) then ini := iniDefaults
  else exit(Default);
  result := ini.ReadInteger(section, ident, default);
end;

function INI_ReadInt(section, name: PAnsiChar; default: integer): integer; cdecl;
begin
  result := Internal_ReadInteger(string(section), string(name), default);
end;

procedure INI_WriteInt(section, name: PAnsiChar; value: integer; once: integer); cdecl;
var
  fn: string;
  ini: TMemIniFile;
begin
  if once <> 0 then fn := Internal_iniOnceFileName else fn := Internal_iniUserFileName;
  ini := TMemIniFile.Create(fn);
  try
    ini.WriteInteger(string(section), string(name), value);
    ini.UpdateFile;
  finally
    FreeAndNil(ini);
  end;
end;

function Internal_ReadFloat(const Section, Ident: string; Default: Double): Double;
var
  ini: TMemIniFile;
begin
  if Assigned(iniOnce) and iniOnce.ValueExists(section, ident) then ini := iniOnce
  else if Assigned(iniUser) and iniUser.ValueExists(section, ident) then ini := iniUser
  else if Assigned(iniDefaults) then ini := iniDefaults
  else exit(Default);
  result := ini.ReadFloat(section, ident, default);
end;

function INI_ReadFloat(section, name: PAnsiChar; default: single): DWORD; cdecl;
var
  s: single;
begin
  s := Internal_ReadFloat(string(section), string(name), default);
  result := DWORD(Pointer(s));
end;

procedure INI_WriteFloat(section, name: PAnsiChar; value: single; once: integer); cdecl;
var
  fn: string;
  ini: TMemIniFile;
begin
  if once <> 0 then fn := Internal_iniOnceFileName else fn := Internal_iniUserFileName;
  ini := TMemIniFile.Create(fn);
  try
    ini.WriteFloat(string(section), string(name), value);
    ini.UpdateFile;
  finally
    FreeAndNil(ini);
  end;
end;

function Internal_ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
var
  ini: TMemIniFile;
begin
  if Assigned(iniOnce) and iniOnce.ValueExists(section, ident) then ini := iniOnce
  else if Assigned(iniUser) and iniUser.ValueExists(section, ident) then ini := iniUser
  else if Assigned(iniDefaults) then ini := iniDefaults
  else exit(Default);
  result := ini.ReadBool(section, ident, default);
end;

function INI_ReadBool(section, name: PAnsiChar; default: integer): integer; cdecl;
begin
  if Internal_ReadBool(string(section), string(name), default<>0) then
    result := 1
  else
    result := 0;
end;

procedure INI_WriteBool(section, name: PAnsiChar; value: integer; once: integer); cdecl;
var
  fn: string;
  ini: TMemIniFile;
begin
  if once <> 0 then fn := Internal_iniOnceFileName else fn := Internal_iniUserFileName;
  ini := TMemIniFile.Create(fn);
  try
    ini.WriteBool(string(section), string(name), value<>0);
    ini.UpdateFile;
  finally
    FreeAndNil(ini);
  end;
end;

function Internal_ReadString(const Section, Ident: string; Default: string): string;
var
  ini: TMemIniFile;
begin
  if Assigned(iniOnce) and iniOnce.ValueExists(section, ident) then ini := iniOnce
  else if Assigned(iniUser) and iniUser.ValueExists(section, ident) then ini := iniUser
  else if Assigned(iniDefaults) then ini := iniDefaults
  else exit(Default);
  result := ini.ReadString(section, ident, default);
end;

function INI_ReadString(section, name, default, buffer: PAnsiChar; bufferSize: DWORD): DWORD; cdecl;
var
  i: integer;
  s: AnsiString;
begin
  s := AnsiString(Internal_ReadString(string(section), string(name), string(default)));

  result := Length(s);

  if Assigned(buffer) then
  begin
    s := Copy(s, 1, bufferSize);

    // Byte für Byte kopieren
    for i := 1 to Length(s) do
      buffer[i-1] := s[i];

    buffer[Length(s)] := #0; // Nullterminator
  end;
end;

procedure INI_WriteString(section, name: PAnsiChar; value: PAnsiChar; once: integer); cdecl;
var
  fn: string;
  ini: TMemIniFile;
begin
  if once <> 0 then fn := Internal_iniOnceFileName else fn := Internal_iniUserFileName;
  ini := TMemIniFile.Create(fn);
  try
    ini.WriteString(string(section), string(name), string(value));
    ini.UpdateFile;
  finally
    FreeAndNil(ini);
  end;
end;

{$ENDREGION}

{$REGION '(SIZ) Image resize functions'}

type
  TImgMemBlockHeader = packed record
    width: cardinal;
    height: cardinal;
    colordepth: cardinal;
  end;
  PImgMemBlockHeader = ^TImgMemBlockHeader;

function _Resize24(srcMemblock, dstMemblock: PImgMemBlockHeader; newWidth, newHeight: Cardinal): integer;
// --- Based on http://www.davdata.nl/math/bmresize.html ---
type
  TBGRATriple = packed record
    B: byte;
    G: byte;
    R: byte;
  end;
  PBGRATriple = ^TBGRATriple;
var
  psStep,pdStep: integer;
  ps0,pd0 : Pointer;       //scanline[0], row steps
  sx1,sy1,sx2,sy2 : single;             //source field positions
  x,y,i,j: word;  //source,dest field pixels
  destR,destG,destB : single;           //destination colors
  src: TBGRATriple;                      //source colors
  fx,fy,fix,fiy,dyf : single;           //factors
  fxstep,fystep, dx,dy : single;
  psi,psj : Pointer;
  AP : single;
  istart,iend,jstart,jend : word;
  devX1,devX2,devY1,devY2 : single;
  DSTPIX: PBGRATriple;
begin
  dstMemblock.width := newWidth;
  dstMemblock.height := newHeight;
  dstMemblock.colordepth := sizeof(TBGRATriple) * 8;

  if srcMemblock.colordepth <> dstMemblock.colordepth then
  begin
    result := -1;
    exit;
  end;

  result := 0;

  ps0 := Pointer(srcMemblock); Inc(pbyte(ps0), SizeOf(TImgMemBlockHeader));
  psstep := -srcMemblock.width * sizeof(TBGRATriple);
  pd0 := Pointer(dstMemblock); Inc(pbyte(pd0), SizeOf(TImgMemBlockHeader));
  pdstep := -dstMemblock.width * sizeof(TBGRATriple);
  fx := srcMemblock.width/ newWidth;
  fy := srcMemblock.height/newHeight;
  fix := 1/fx;
  fiy := 1/fy;
  fxstep := 0.9999 * fx;
  fystep := 0.9999 * fy;
  DSTPIX := PBGRATriple(pd0);
  for y := 0 to newHeight-1 do         //vertical destination pixels
  begin
    sy1 := fy * y;
    sy2 := sy1 + fystep;
    jstart := trunc(sy1);
    jend := trunc(sy2);
    devY1 := 1-sy1+jstart;
    devY2 := jend+1-sy2;
    for x := 0 to newWidth-1 do        //horizontal destination pixels
    begin
      sx1 := fx * x;                        //x related values are repeated
      sx2 := sx1 + fxstep;                  //for each y and may be placed in
      istart := trunc(sx1);                 //lookup table
      iend := trunc(sx2);                   //...

      if istart >= srcMemblock.width then istart := srcMemblock.width-1;
      if iend   >= srcMemblock.width then iend   := srcMemblock.width-1;

      devX1 := 1-sx1+istart;                  //...
      devX2 := iend+1-sx2;                  //...
      destR := 0; destG := 0; destB := 0;   //clear destination colors

      if jstart >= srcMemblock.height then jstart := srcMemblock.height-1;
      if jend   >= srcMemblock.height then jend   := srcMemblock.height-1;

      psj := ps0; dec(pbyte(psj), jstart*psStep);
      dy := devY1;

      for j := jstart to jend do  //vertical source pixels
      begin
        if j = jend then dy := dy - devY2;
        dyf := dy*fiy;
        psi := psj; Inc(pbyte(psi), istart*SizeOf(TBGRATriple));
        dx := devX1;
        for i := istart to iend do //horizontal source pixels
        begin
          if i = iend then dx := dx - devX2;
          AP := dx*dyf*fix;
          src := PBGRATriple(psi)^;

          destB := destB + src.B*AP;
          destG := destG + src.G*AP;
          destR := destR + src.R*AP;

          inc(pbyte(psi), sizeof(TBGRATriple));
          dx := 1;
        end;//for i
        dec(pbyte(psj),psStep);
        dy := 1;
      end;//for j

      src.B := round(destB);
      src.G := round(destG);
      src.R := round(destR);
      DSTPIX^ := src;
      inc(DSTPIX, 1{element});
      inc(result, SizeOf(TBGRATriple));
    end;//for x
  end;//for y
end;

function _Resize32(srcMemblock, dstMemblock: PImgMemBlockHeader; newWidth, newHeight: Cardinal): integer;
// --- Based on http://www.davdata.nl/math/bmresize.html ---
type
  TBGRATriple = packed record
    B: byte;
    G: byte;
    R: byte;
    A: byte;
  end;
  PBGRATriple = ^TBGRATriple;
var
  psStep,pdStep: integer;
  ps0,pd0 : Pointer;       //scanline[0], row steps
  sx1,sy1,sx2,sy2 : single;             //source field positions
  x,y,i,j: word;  //source,dest field pixels
  destA,destR,destG,destB : single;           //destination colors
  src: TBGRATriple;                      //source colors
  fx,fy,fix,fiy,dyf : single;           //factors
  fxstep,fystep, dx,dy : single;
  psi,psj : Pointer;
  AP : single;
  istart,iend,jstart,jend : word;
  devX1,devX2,devY1,devY2 : single;
  DSTPIX: PBGRATriple;
begin
  dstMemblock.width := newWidth;
  dstMemblock.height := newHeight;
  dstMemblock.colordepth := sizeof(TBGRATriple) * 8;

  if srcMemblock.colordepth <> dstMemblock.colordepth then
  begin
    result := -1;
    exit;
  end;

  result := 0;

  ps0 := Pointer(srcMemblock); Inc(pbyte(ps0), SizeOf(TImgMemBlockHeader));
  psstep := -srcMemblock.width * sizeof(TBGRATriple);
  pd0 := Pointer(dstMemblock); Inc(pbyte(pd0), SizeOf(TImgMemBlockHeader));
  pdstep := -dstMemblock.width * sizeof(TBGRATriple);
  fx := srcMemblock.width/ newWidth;
  fy := srcMemblock.height/newHeight;
  fix := 1/fx;
  fiy := 1/fy;
  fxstep := 0.9999 * fx;
  fystep := 0.9999 * fy;
  DSTPIX := PBGRATriple(pd0);
  for y := 0 to newHeight-1 do         //vertical destination pixels
  begin
    sy1 := fy * y;
    sy2 := sy1 + fystep;
    jstart := trunc(sy1);
    jend := trunc(sy2);
    devY1 := 1-sy1+jstart;
    devY2 := jend+1-sy2;
    for x := 0 to newWidth-1 do        //horizontal destination pixels
    begin
      sx1 := fx * x;                        //x related values are repeated
      sx2 := sx1 + fxstep;                  //for each y and may be placed in
      istart := trunc(sx1);                 //lookup table
      iend := trunc(sx2);                   //...

      if istart >= srcMemblock.width then istart := srcMemblock.width-1;
      if iend   >= srcMemblock.width then iend   := srcMemblock.width-1;

      devX1 := 1-sx1+istart;                  //...
      devX2 := iend+1-sx2;                  //...
      destR := 0; destG := 0; destB := 0; destA := 0;   //clear destination colors

      if jstart >= srcMemblock.height then jstart := srcMemblock.height-1;
      if jend   >= srcMemblock.height then jend   := srcMemblock.height-1;

      psj := ps0; dec(pbyte(psj), jstart*psStep);
      dy := devY1;

      for j := jstart to jend do  //vertical source pixels
      begin
        if j = jend then dy := dy - devY2;
        dyf := dy*fiy;
        psi := psj; Inc(pbyte(psi), istart*SizeOf(TBGRATriple));
        dx := devX1;
        for i := istart to iend do //horizontal source pixels
        begin
          if i = iend then dx := dx - devX2;
          AP := dx*dyf*fix;
          src := PBGRATriple(psi)^;

          destB := destB + src.B*AP;
          destG := destG + src.G*AP;
          destR := destR + src.R*AP;
          destA := destA + src.A*AP;

          inc(pbyte(psi), sizeof(TBGRATriple));
          dx := 1;
        end;//for i
        dec(pbyte(psj),psStep);
        dy := 1;
      end;//for j

      src.B := round(destB);
      src.G := round(destG);
      src.R := round(destR);
      src.A := round(destA);
      DSTPIX^ := src;
      inc(DSTPIX, 1{element});
      inc(result, SizeOf(TBGRATriple));
    end;//for x
  end;//for y
end;

function SIZ_DestSize(memblock: PImgMemBlockHeader; newWidth, newHeight: Cardinal): integer; cdecl;
begin
  // TODO: Implement 16 bit color mode
  if memblock.colordepth = 32 then
    result := SizeOf(TImgMemBlockHeader) + newWidth * newHeight * 4
  else if memblock.colordepth = 24 then
    result := SizeOf(TImgMemBlockHeader) + newWidth * newHeight * 3
  else
    result := -1;
end;

function SIZ_Resize(srcMemblock, dstMemblock: PImgMemBlockHeader; newWidth, newHeight: Cardinal): integer; cdecl;
begin
  // TODO: Implement 16 bit color mode
  if srcMemblock.colordepth = 32 then
    result := _Resize32(srcMemblock, dstMemblock, newWidth, newHeight)
  else if srcMemblock.colordepth = 24 then
    result := _Resize24(srcMemblock, dstMemblock, newWidth, newHeight)
  else
    result := -1;
end;

{$ENDREGION}

{$REGION '(MAP) Map generator functions'}

type
  TFreeSpot = record
    X: integer;
    Y: integer;
    A: integer;
  end;
  TDWordArray = array of DWord;
  PDWordArray = ^TDWordArray;

var
  FreeSpots: array of TFreeSpot;

var
  // TODO: For the future, maybe having a setting for defining the width of a path
  cMaxBranchLength: integer = 200;
  cPathFlexibility: integer = 15;
  cMapBorderSize: single = 5;
  cPathWidthFactor: single = 1;
  cPathLength: single = 0.20;
  cTreePlacementMaxAttempts: integer = 1000;
  cPathAcceptCheckCornerCircle: boolean = false;
  cPathAcceptCheckCornerCircleRadius: integer = 500;
  cPathAcceptCheckSquares: boolean = true;
  cPathAcceptCheckSquaresHorizontal: integer = 5;
  cPathAcceptCheckSquaresVertical: integer = 5;
  cPathBuildMaxAttempts: integer = 100;

const
  ERR_OK = 0;
  ERR_NO_INI_LOADED = 2;

function MAP_RandomSeed: integer; cdecl;
begin
  Randomize;
  result := RandSeed;
end;

procedure MAP_UseSeed(seed: integer); cdecl;
begin
  RandSeed := seed;
end;

procedure MAP_LoadParameters; cdecl;
var
  seedValue: integer;
begin
  cMaxBranchLength                   := Internal_ReadInteger('MapGen32', 'MaxBranchLength',                   200   );
  cPathFlexibility                   := Internal_ReadInteger('MapGen32', 'PathFlexibility',                    15   );
  cMapBorderSize                     := Internal_ReadFloat  ('MapGen32', 'MapBorderSize',                       5   );
  cPathWidthFactor                   := Internal_ReadFloat  ('MapGen32', 'PathWidthFactor',                     1   );
  cPathLength                        := Internal_ReadFloat  ('MapGen32', 'PathLength',                          0.20);
  cTreePlacementMaxAttempts          := Internal_ReadInteger('MapGen32', 'TreePlacementMaxAttempts',         1000   );

  cPathAcceptCheckCornerCircle       := Internal_ReadBool   ('MapGen32', 'PathAcceptCheckCornerCircle',       false);
  cPathAcceptCheckCornerCircleRadius := Internal_ReadInteger('MapGen32', 'PathAcceptCheckCornerCircleRadius', 500);

  cPathAcceptCheckSquares            := Internal_readBool   ('MapGen32', 'PathAcceptCheckSquares',           true);
  cPathAcceptCheckSquaresHorizontal  := Internal_ReadInteger('MapGen32', 'PathAcceptCheckSquaresHorizontal', 5);
  cPathAcceptCheckSquaresVertical    := Internal_ReadInteger('MapGen32', 'PathAcceptCheckSquaresVertical',   5);

  cPathBuildMaxAttempts              := Internal_ReadInteger('MapGen32', 'PathBuildMaxAttempts', 100);

  seedValue                          := Internal_ReadInteger('MapGen32', 'seed_value', 0);
  if seedValue = 0 then
    MAP_RandomSeed
  else
    MAP_UseSeed(seedValue);
end;

function _RandBetween(a, b: integer): integer;
begin
  result := Random(b-a+1)+a;
end;

function _IsInCircle(p, q: TPoint; r: integer): boolean;
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
      if _IsInCircle(p, q, cPathAcceptCheckCornerCircleRadius) then
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

      FreeSpots[i].A := _RandBetween(FreeSpots[i-1].A-locFlexibility, FreeSpots[i-1].A+locFlexibility);
      FreeSpots[i].X := FreeSpots[i-1].X + round(r*cos(FreeSpots[i].A/360*2*pi));
      FreeSpots[i].Y := FreeSpots[i-1].Y + round(r*sin(FreeSpots[i].A/360*2*pi));

      if FreeSpots[i].X > maxX-cMapBorderSize*r then break;
      if FreeSpots[i].Y > maxY-cMapBorderSize*r then break;
      if FreeSpots[i].X < cMapBorderSize*r then break;
      if FreeSpots[i].Y < cMapBorderSize*r then break;

      maxdrawn := i;
    end;

    x := _RandBetween(maxdrawn div 2, maxdrawn); // RandBetween(0, maxdrawn);
    FreeSpots[maxdrawn+1] := FreeSpots[x]; // virtual free spot

    if _RandBetween(0,1) = 0 then
      FreeSpots[maxdrawn+1].A := FreeSpots[x].A-90
    else
      FreeSpots[maxdrawn+1].A := FreeSpots[x].A+90;

    iBeginBranch := maxdrawn+2;
  end;
end;

function MAP_GetWaypointArrayElements(nTrees: integer): DWORD; cdecl;
begin
  result := Round(cPathLength*nTrees);
end;

procedure MAP_GenerateMap(nTrees, treeRadius, mapX, mapY: integer;
  memblockTrees, memblockWayPoints: PDWordArray); cdecl;
var
  pathSize: integer;
  i, j, k: integer;
  p, q: TPoint;
  ok: boolean;
  nFreespots: integer;
begin
  pathSize := Round(cPathWidthFactor * treeRadius);
  nFreespots := MAP_GetWaypointArrayElements(nTrees);

  k := 0;
  repeat
    Inc(k);
    _BuildPaths(nFreespots, mapx, mapy, nTrees, treeradius, mapX div 2, mapY div 2, _RandBetween(0,359));
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
          if _IsInCircle(p, q, treeRadius + pathSize div 2) then
          begin
            ok := false;
            break;
          end;
        end;

        // Bäume sollen sich nicht überschneiden
        for j := Low(FreeSpots) to High(FreeSpots) do
        begin
          q := Point(FreeSpots[j].X, FreeSpots[j].Y);
          if _IsInCircle(p, q, treeRadius + pathSize div 2) then
          begin
            ok := false;
            break;
          end;
        end;
      until ok or (k > cTreePlacementMaxAttempts);
      CopyMemory(PByte(memblockTrees) + i*8, @p.X, 4);
      CopyMemory(PByte(memblockTrees) + i*8+4, @p.Y, 4);
    end;
  end;

  if memblockWayPoints <> nil then
  begin
    for i := 0 to nFreespots-1 do
    begin
      CopyMemory(PByte(memblockWayPoints) + i*8, @FreeSpots[i].X, 4);
      CopyMemory(PByte(memblockWayPoints) + i*8+4, @FreeSpots[i].Y, 4);
    end;
  end;
end;

{$ENDREGION}

exports
  COR_Initialize               name 'COR_Initialize',
  COR_Uninitialize             name 'COR_Uninitialize',
  INI_ReadInt                  name 'INI_ReadInt',
  INI_WriteInt                 name 'INI_WriteInt',
  INI_ReadFloat                name 'INI_ReadFloat',
  INI_WriteFloat               name 'INI_WriteFloat',
  INI_ReadBool                 name 'INI_ReadBool',
  INI_WriteBool                name 'INI_WriteBool',
  INI_ReadString               name 'INI_ReadString',
  INI_WriteString              name 'INI_WriteString',
  SIZ_Resize                   name 'SIZ_Resize',
  SIZ_DestSize                 name 'SIZ_DestSize',
  MAP_GenerateMap              name 'MAP_GenerateMap',
  MAP_LoadParameters           name 'MAP_LoadParameters',
  MAP_RandomSeed               name 'MAP_RandomSeed',
  MAP_UseSeed                  name 'MAP_UseSeed',
  MAP_GetWaypointArrayElements name 'MAP_GetWaypointArrayElements';

begin
end.
