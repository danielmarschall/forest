object MainForm: TMainForm
  Left = 190
  Top = 121
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 565
  ClientWidth = 589
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 13
  object MapImage: TImage
    Left = 0
    Top = 0
    Width = 589
    Height = 520
    Align = alClient
  end
  object ControlPanel: TPanel
    Left = 0
    Top = 520
    Width = 589
    Height = 45
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      589
      45)
    object SeedLabel: TLabel
      Left = 216
      Top = 12
      Width = 36
      Height = 16
      Anchors = [akTop, akRight]
      Caption = 'Seed:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object ShowPathCheckbox: TCheckBox
      Left = 8
      Top = 20
      Width = 97
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Show path'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = ShowPathCheckboxClick
    end
    object LoadINIButton: TButton
      Left = 432
      Top = 8
      Width = 65
      Height = 29
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Load INI'
      TabOrder = 4
      OnClick = LoadINIButtonClick
    end
    object GenMapButton: TButton
      Left = 504
      Top = 8
      Width = 77
      Height = 29
      Anchors = [akTop, akRight, akBottom]
      Caption = 'New map'
      Default = True
      TabOrder = 0
      OnClick = GenMapButtonClick
    end
    object SeedSpinEdit: TSpinEdit
      Left = 256
      Top = 8
      Width = 97
      Height = 26
      Anchors = [akTop, akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 1
      Value = 0
      OnChange = SeedSpinEditChange
    end
    object PlayButton: TButton
      Left = 360
      Top = 8
      Width = 65
      Height = 29
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Play'
      TabOrder = 3
      OnClick = PlayButtonClick
    end
  end
  object InitTimer: TTimer
    Interval = 200
    OnTimer = InitTimerTimer
    Left = 512
    Top = 16
  end
  object INIOpenDialog: TOpenDialog
    DefaultExt = 'ini'
    Filter = 'INI Files (*.ini)|*.ini|All files (*.*)|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Title = 'Select Forest.ini'
    Left = 544
    Top = 16
  end
end
