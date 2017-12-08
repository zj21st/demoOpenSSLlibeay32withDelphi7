object Form1: TForm1
  Left = 674
  Top = 252
  Width = 853
  Height = 480
  Caption = 'RSA Sample'
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 713
    Top = 0
    Width = 132
    Height = 449
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 8
      Top = 8
      Width = 121
      Height = 25
      Caption = 'Public Crypting'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 8
      Top = 40
      Width = 121
      Height = 25
      Caption = 'Private Decrypting'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 8
      Top = 96
      Width = 121
      Height = 25
      Caption = 'Private Crypting'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 8
      Top = 128
      Width = 121
      Height = 25
      Caption = 'Public Decrypting'
      TabOrder = 3
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 8
      Top = 192
      Width = 121
      Height = 25
      Caption = 'SHA1'
      TabOrder = 4
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 8
      Top = 232
      Width = 121
      Height = 25
      Caption = 'SHA256'
      TabOrder = 5
      OnClick = Button6Click
    end
    object Button7: TButton
      Left = 8
      Top = 272
      Width = 121
      Height = 25
      Caption = 'SHA512'
      TabOrder = 6
      OnClick = Button7Click
    end
    object Button8: TButton
      Left = 16
      Top = 320
      Width = 105
      Height = 25
      Caption = 'SHA1RSA'
      TabOrder = 7
      OnClick = Button8Click
    end
    object Button9: TButton
      Left = 16
      Top = 360
      Width = 105
      Height = 25
      Caption = 'SHA256RSA'
      TabOrder = 8
      OnClick = Button9Click
    end
    object Button10: TButton
      Left = 16
      Top = 400
      Width = 105
      Height = 25
      Caption = 'SHA512RSA'
      TabOrder = 9
      OnClick = Button10Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 713
    Height = 449
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object GroupBox1: TGroupBox
      Left = 0
      Top = 0
      Width = 713
      Height = 89
      Align = alTop
      Caption = 'Data to Crypt'
      TabOrder = 0
      object Memo1: TEdit
        Left = 8
        Top = 24
        Width = 697
        Height = 21
        TabOrder = 0
        Text = 'asdasdsajdsajfgdshfgdshfdsf'
      end
    end
    object GroupBox2: TGroupBox
      Left = 0
      Top = 89
      Width = 713
      Height = 105
      Align = alTop
      Caption = 'Crypted Data'
      TabOrder = 1
      object Memo2: TMemo
        Left = 2
        Top = 15
        Width = 709
        Height = 88
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object GroupBox3: TGroupBox
      Left = 0
      Top = 194
      Width = 713
      Height = 105
      Align = alTop
      Caption = 'Decrypted Data'
      TabOrder = 2
      object Memo3: TMemo
        Left = 2
        Top = 15
        Width = 709
        Height = 88
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object GroupBox4: TGroupBox
      Left = 0
      Top = 299
      Width = 713
      Height = 150
      Align = alClient
      Caption = 'RSA Log'
      TabOrder = 3
      object Memo4: TMemo
        Left = 2
        Top = 15
        Width = 709
        Height = 133
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
end
