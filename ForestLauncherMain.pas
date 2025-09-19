unit ForestLauncherMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  System.Generics.Collections, System.Generics.Defaults, Vcl.Samples.Spin;

type
  TMainForm = class(TForm)
    Image1: TImage;
    ComboBox1: TComboBox;
    SaveAndPlayBtn: TButton;
    Label1: TLabel;
    seEnemies: TSpinEdit;
    Label2: TLabel;
    MapPreviewBtn: TButton;
    seTrees: TSpinEdit;
    Label3: TLabel;
    seMapSizeX: TSpinEdit;
    seMapSizeZ: TSpinEdit;
    Label4: TLabel;
    Label5: TLabel;
    Button1: TButton;
    InvertMouse: TCheckBox;
    TimeAdvance: TSpinEdit;
    VSync: TCheckBox;
    HitsUntilDeath: TSpinEdit;
    Label6: TLabel;
    Label7: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SaveAndPlayBtnClick(Sender: TObject);
    procedure MapPreviewBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    procedure LoadSettings;
  public
    seed_value: integer;
    treeradius: DWord;
  end;

var
  MainForm: TMainForm;

implementation

uses
  WinApi.ShellApi, System.AnsiStrings, ForestDLL_Import, ForestLauncherMapGen;

{$R *.dfm}

function GetSysDir: string;
var
  Buffer: array[0..MAX_PATH] of Char;
begin
  GetSystemDirectory(Buffer, MAX_PATH - 1);
  SetLength(Result, StrLen(Buffer));
  Result := Buffer;
end;

function BoolTo10(b: boolean): integer;
begin
  if b then
    result := 1
  else
    result := 0;
end;

{$REGION 'List display modes'}

type
  TDisplayMode = record
    Width: Integer;
    Height: Integer;
    Bits: Integer;
    function ToString: string;
  end;

function TDisplayMode.ToString: string;
begin
  Result := Format('%dx%dx%d', [Width, Height, Bits]);
end;

function GetPrimaryDeviceName: string;
var
  dd: TDisplayDevice;
  i: Integer;
begin
  Result := '';
  i := 0;
  ZeroMemory(@dd, SizeOf(dd));
  dd.cb := SizeOf(dd);
  while EnumDisplayDevices(nil, i, dd, 0) do
  begin
    if (dd.StateFlags and DISPLAY_DEVICE_PRIMARY_DEVICE) <> 0 then
      Exit(dd.DeviceName);
    Inc(i);
    ZeroMemory(@dd, SizeOf(dd));
    dd.cb := SizeOf(dd);
  end;
end;

function CompareDisplayModes(const A, B: TDisplayMode): Integer;
begin
  if A.Width <> B.Width then
    result := A.Width - B.Width
  else if A.Height <> B.Height then
    result := A.Height - B.Height
  else
    result := A.Bits - B.Bits;
end;

procedure ListDisplayModes(sl: TStrings);
var
  DevMode: TDevMode;
  ModeNum: Integer;
  ModesDict: TDictionary<string, TDisplayMode>;
  ModeRec: TDisplayMode;
  ModesList: TList<TDisplayMode>;
  Key: string;
  I: Integer;
  dn: string;
  pdn: PChar;
begin
  ModesDict := TDictionary<string, TDisplayMode>.Create;
  try
    ModeNum := 0;
    FillChar(DevMode, SizeOf(DevMode), 0);
    DevMode.dmSize := SizeOf(DevMode);

    dn := GetPrimaryDeviceName;
    if dn <> '' then
      pdn := PChar(dn)
    else
      pdn := nil;
    while EnumDisplaySettings(pdn, ModeNum, DevMode) do
    begin
      ModeRec.Width := DevMode.dmPelsWidth;
      ModeRec.Height := DevMode.dmPelsHeight;
      ModeRec.Bits := DevMode.dmBitsPerPel;

      if (ModeRec.Width = 0) or (ModeRec.Height = 0) then
      begin
        Inc(ModeNum);
        Continue;
      end;

      Key := Format('%dx%dx%d', [ModeRec.Width, ModeRec.Height, ModeRec.Bits]);
      if not ModesDict.ContainsKey(Key) then
        ModesDict.Add(Key, ModeRec);

      Inc(ModeNum);
    end;

    ModesList := TList<TDisplayMode>.Create;
    try
      for ModeRec in ModesDict.Values do
        ModesList.Add(ModeRec);

      ModesList.Sort(
        TComparer<TDisplayMode>.Construct(
          function(const L, R: TDisplayMode): Integer
          begin
            Result := CompareDisplayModes(L, R);
          end
        )
      );

      for I := 0 to ModesList.Count - 1 do
        sl.Add(ModesList[I].ToString);
    finally
      FreeAndNil(ModesList);
    end;
  finally
    FreeAndNil(ModesDict);
  end;
end;

{$ENDREGION}

procedure TMainForm.SaveAndPlayBtnClick(Sender: TObject);
resourcestring
  LNG_S_IsMissing = '%s is missing.';
var
  Parts: TArray<string>;
  W, H, B: integer;
  S: string;
begin
  {$REGION 'Save resolution'}
  S := ComboBox1.Text;
  Parts := S.Split(['x']);
  if Length(Parts) = 3 then
  begin
    if TryStrToInt(Parts[0], W) and
       TryStrToInt(Parts[1], H) and
       TryStrToInt(Parts[2], B) then
    begin
      INI_WriteInt('Game', 'screenResW', W, 0{not once});
      INI_WriteInt('Game', 'screenResH', H, 0{not once});
      INI_WriteInt('Game', 'screenResB', B, 0{not once});
    end;
  end;
  {$ENDREGION}

  {$REGION 'Save other game settings (for user)'}

  INI_WriteInt('Game', 'cMaxEnemies', seEnemies.Value,  0{not once});
  INI_WriteInt('Game', 'cMaxTrees',   seTrees.Value,    0{not once});
  INI_WriteInt('Game', 'cMapSizeX',   seMapSizeX.Value, 0{not once});
  INI_WriteInt('Game', 'cMapSizeZ',   seMapSizeZ.Value, 0{not once});
  INI_WriteInt('Game', 'cTreeRadius', treeradius,       0{not once});
  INI_WriteBool('Game','invertMouse', BoolTo10(InvertMouse.Checked), 0{not once});
  INI_WriteInt('Game', 'clockSecondsAdvance', TimeAdvance.Value, 0{not once});
  INI_WriteBool('Game','screenVSync', BoolTo10(VSync.Checked), 0{not once});
  INI_WriteInt('Game', 'maxHitsTillDeath', HitsUntilDeath.Value, 0{not once});

  {$ENDREGION}

  {$REGION 'Save game settings only for this session (once)'}

  INI_WriteInt('MapGen32', 'seed_value', seed_value, 1{once});

  {$ENDREGION}

  {$REGION 'Check for DirectX 9.0c'}
  // These two DLL files are required by DBProSetupDebug.dll (that is unpacked into the Temp directory)
  // For Necropolis, an error message shows that DBProSetupDebug.dll cannot be loaded (because DirectX DLL is missing)
  // Forest however, does not show any message and just don't start.
  // d3d9.dll is installed on Windows 10, but d3dx9_35.dll is not, unless the DirectX Runtime is installed.
  if not FileExists(IncludeTrailingPathDelimiter(GetSysDir) + 'd3d9.dll') or
     not FileExists(IncludeTrailingPathDelimiter(GetSysDir) + 'd3dx9_35.dll') then
  begin
    if MessageDlg('You need to install DirectX 9.0c in order to play this game. Download DirectX 9.0c now?', TMsgDlgType.mtInformation, mbYesNoCancel, 0) = mrYes then
      ShellExecute(0, 'open', 'https://github.com/danielmarschall/forest/releases', '', '', SW_NORMAL);
    Abort;
  end;
  {$ENDREGION}

  {$REGION 'Start the game'}

  if not FileExists('Forest.exe') then
    raise Exception.CreateFmt(LNG_S_IsMissing, ['Forest.exe']);
  ShellExecute(0, 'open', PChar('Forest.exe'), '', '', SW_NORMAL);
  // Close;

  {$ENDREGION}
end;

procedure TMainForm.MapPreviewBtnClick(Sender: TObject);
begin
  MapGenForm.ShowModal;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  COR_Uninitialize;
  try
    COR_Initialize(COR_INITIALIZE_READ_DEFAULT);
    try
      LoadSettings;
    finally
      COR_Uninitialize;
    end;
  finally
    COR_Initialize(COR_INITIALIZE_READ_DEFAULT or COR_INITIALIZE_READ_USER);
  end;
end;

procedure TMainForm.LoadSettings;
resourcestring
  LNG_TITLE = '%s by %s, Version %s';
var
  Mode: TDisplayMode;
  idx: integer;
  pcTitle, pcAuthor, pcVersion: array[0..255] of AnsiChar;
begin
  {$REGION 'Determine product title and version'}
  INI_ReadString('Product', 'Title', '', pcTitle, SizeOf(pcTitle));
  INI_ReadString('Product', 'Author', '', pcAuthor, SizeOf(pcAuthor));
  INI_ReadString('Product', 'Version', '', pcVersion, SizeOf(pcTitle));
  Caption := Format(LNG_TITLE, [
    string(System.AnsiStrings.StrPas(pcTitle)),
    string(System.AnsiStrings.StrPas(pcAuthor)),
    string(System.AnsiStrings.StrPas(pcVersion))
  ]);
  {$ENDREGION}

  {$REGION 'Select current chosen screen resolution (default or user)'}
  Mode.Width  := INI_ReadInt('Game', 'screenResW', 800);
  Mode.Height := INI_ReadInt('Game', 'screenResH', 600);
  Mode.Bits   := INI_ReadInt('Game', 'screenResB', 32);
  idx := ComboBox1.Items.IndexOf(Mode.ToString);
  if idx = -1 then idx := 0;
  ComboBox1.ItemIndex := idx;
  {$ENDREGION}

  {$REGION 'Load game settings'}

  seEnemies.Value  := INI_ReadInt('Game', 'cMaxEnemies', 50);
  seTrees.Value    := INI_ReadInt('Game', 'cMaxTrees',   1200);
  seMapSizeX.Value := INI_ReadInt('Game', 'cMapSizeX',   10000);
  seMapSizeZ.Value := INI_ReadInt('Game', 'cMapSizeZ',   10000);
  treeradius       := INI_ReadInt('Game', 'cTreeRadius', 100); // not to be edited by the user for now
  InvertMouse.Checked := INI_ReadBool('Game', 'invertMouse', 0) = 1;
  TimeAdvance.Value := INI_ReadInt('Game', 'clockSecondsAdvance', 60);
  VSync.Checked := INI_ReadBool('Game', 'screenVSync', 0) = 1;
  HitsUntilDeath.Value := INI_ReadInt('Game', 'maxHitsTillDeath', 50);

  {$ENDREGION}
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  SetCurrentDir(ExtractFilePath(ParamStr(0)));

  {$REGION 'List screen resolutions'}
  ComboBox1.Clear;
  ListDisplayModes(ComboBox1.Items);
  if ComboBox1.Items.Count = 0 then
  begin
    ComboBox1.Items.Add('640x480x16');
    ComboBox1.Items.Add('640x480x24');
    ComboBox1.Items.Add('640x480x32');
    ComboBox1.Items.Add('800x600x16');
    ComboBox1.Items.Add('800x600x24');
    ComboBox1.Items.Add('800x600x32');
    ComboBox1.Items.Add('1024x768x16');
    ComboBox1.Items.Add('1024x768x24');
    ComboBox1.Items.Add('1024x768x32');
    ComboBox1.Items.Add('1280x800x16');
    ComboBox1.Items.Add('1280x800x24');
    ComboBox1.Items.Add('1280x800x32');
    ComboBox1.Items.Add('1366x768x16');
    ComboBox1.Items.Add('1366x768x24');
    ComboBox1.Items.Add('1366x768x32');
    ComboBox1.Items.Add('1920x1080x16');
    ComboBox1.Items.Add('1920x1080x24');
    ComboBox1.Items.Add('1920x1080x32');
  end;
  {$ENDREGION}

  COR_Initialize(COR_INITIALIZE_READ_DEFAULT or COR_INITIALIZE_READ_USER);

  LoadSettings;

  seed_value := MAP_RandomSeed;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  COR_Uninitialize;
end;

end.
