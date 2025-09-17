unit ForestDLL_Import;

interface

uses
  Winapi.Windows;

{$REGION '(COR) Core Functions'}
const
  COR_INITIALIZE_READ_DEFAULT = 1;
  COR_INITIALIZE_READ_USER = 2;
  COR_INITIALIZE_READ_ONCE = 4;
  COR_INITIALIZE_DELETE_ONCE = 8;

procedure COR_Initialize(source: integer); cdecl; external 'ForestDLL.dll';
procedure COR_Uninitialize; cdecl; external 'ForestDLL.dll';
{$ENDREGION}

{$REGION '(INI) Configuration file functions'}

function INI_ReadInt(section, name: PAnsiChar; default: integer): integer; cdecl; external 'ForestDLL.dll';
procedure INI_WriteInt(section, name: PAnsiChar; value: integer; once: integer); cdecl; external 'ForestDLL.dll';

function INI_ReadFloat(section, name: PAnsiChar; default: single): DWORD; cdecl; external 'ForestDLL.dll';
procedure INI_WriteFloat(section, name: PAnsiChar; value: single; once: integer); cdecl; external 'ForestDLL.dll';

function INI_ReadBool(section, name: PAnsiChar; default: integer): integer; cdecl; external 'ForestDLL.dll';
procedure INI_WriteBool(section, name: PAnsiChar; value: integer; once: integer); cdecl; external 'ForestDLL.dll';

function INI_ReadString(section, name, default, buffer: PAnsiChar; bufferSize: DWORD): DWORD; cdecl; external 'ForestDLL.dll';
procedure INI_WriteString(section, name: PAnsiChar; value: PAnsiChar; once: integer); cdecl; external 'ForestDLL.dll';

{$ENDREGION}

{$REGION '(SIZ) Image resize functions'}

type
  TImgMemBlockHeader = packed record
    width: cardinal;
    height: cardinal;
    colordepth: cardinal;
  end;
  PImgMemBlockHeader = ^TImgMemBlockHeader;

function SIZ_DestSize(memblock: PImgMemBlockHeader; newWidth, newHeight: Cardinal): integer; cdecl; external 'ForestDLL.dll';
function SIZ_Resize(srcMemblock, dstMemblock: PImgMemBlockHeader; newWidth, newHeight: Cardinal): integer; cdecl; external 'ForestDLL.dll';

{$ENDREGION}

{$REGION '(MAP) Map generator functions'}

type
  TDWordArray = array of DWord;
  PDWordArray = ^TDWordArray;

function MAP_RandomSeed: integer; cdecl; external 'ForestDLL.dll';
procedure MAP_UseSeed(seed: integer); cdecl; external 'ForestDLL.dll';
procedure MAP_LoadParameters; cdecl; external 'ForestDLL.dll';
function MAP_GetWaypointArrayElements(nTrees: integer): DWORD; cdecl; external 'ForestDLL.dll';
procedure MAP_GenerateMap(nTrees, treeRadius, mapX, mapY: integer; memblockTrees, memblockWayPoints: PDWordArray); cdecl; external 'ForestDLL.dll';

{$ENDREGION}

implementation

end.
