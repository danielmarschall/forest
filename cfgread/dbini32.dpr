library dbini32;

uses
  SysUtils,
  Classes,
  IniFiles,
  Windows;

{$R *.res}

var
  ini: TMemIniFile = nil;
  iniModified: boolean = false;

procedure UnloadINI; cdecl;
begin
  if iniModified then ini.UpdateFile;
  FreeAndNil(ini);
end;

procedure LoadINI(filename: PAnsiChar); cdecl;
begin
  if Assigned(ini) then UnloadINI;
  ini := TMemIniFile.Create(filename);
  iniModified := false;
end;

function ReadFloat(section, name: PAnsiChar; default: single): DWORD; cdecl;
var
  s: single;
begin
  s := ini.ReadFloat(section, name, default);
  result := DWORD(Pointer(s));
end;

procedure WriteFloat(section, name: PAnsiChar; value: single); cdecl;
begin
  ini.WriteFloat(section, name, value);
  iniModified := true;
end;

function ReadInt(section, name: PAnsiChar; default: integer): integer; cdecl;
begin
  result := ini.ReadInteger(section, name, default);
end;

procedure WriteInt(section, name: PAnsiChar; value: integer); cdecl;
begin
  ini.WriteInteger(section, name, value);
  iniModified := true;
end;

exports
  LoadINI name 'LoadINI',
  ReadFloat name 'ReadFloat',
  ReadInt name 'ReadInt',
  WriteFloat name 'WriteFloat',
  WriteInt name 'WriteInt',
  UnloadINI name 'UnloadINI';

begin
  DecimalSeparator := '.';
end.
