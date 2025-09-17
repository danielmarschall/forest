unit ForestDLL_Import;

interface

uses
  Winapi.Windows;

type
  TDWordArray = array of DWord;
  PDWordArray = ^TDWordArray;

// TODO: Add prototypes of everything here

function INI_ReadString(section, name, default, buffer: PAnsiChar; bufferSize: DWORD): DWORD; cdecl; external 'ForestDLL.dll';

const
  COR_INITIALIZE_READ_DEFAULT = 1;
  COR_INITIALIZE_READ_USER    = 2;
  COR_INITIALIZE_READ_ONCE    = 4;
  COR_INITIALIZE_DELETE_ONCE  = 8;

procedure COR_Initialize(source: integer); cdecl; external 'ForestDLL.dll';

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

procedure INI_WriteInt(section, name: PAnsiChar; value, once: integer); cdecl;
  external 'ForestDLL.dll';

implementation

end.
