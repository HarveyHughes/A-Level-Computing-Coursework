object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 625
  Width = 450
  object DBconnection: TADOConnection
    ConnectionString = 
      'Provider=Microsoft.ACE.OLEDB.12.0;Data Source=E:\Harvey\Desktop\' +
      'Maths Flashcard\MathsDB1.accdb;Persist Security Info=False'
    LoginPrompt = False
    Mode = cmShareDenyNone
    Provider = 'Microsoft.ACE.OLEDB.12.0'
    Left = 64
    Top = 40
  end
  object Badgeset: TADODataSet
    Connection = DBconnection
    CursorType = ctStatic
    CommandText = 'select * from Badges'
    Parameters = <>
    Left = 56
    Top = 152
  end
  object Badgesource: TDataSource
    DataSet = Badgeset
    Left = 56
    Top = 208
  end
  object Getbadges: TADOQuery
    Connection = DBconnection
    DataSource = Badgesource
    Parameters = <>
    Left = 56
    Top = 264
  end
  object Achievementset: TADODataSet
    Connection = DBconnection
    CommandText = 'select Badges from Achievements'
    Parameters = <>
    Left = 128
    Top = 152
  end
  object Deckset: TADODataSet
    Connection = DBconnection
    CommandText = 'select * from Deck'
    Parameters = <>
    Left = 208
    Top = 152
  end
  object Packset: TADODataSet
    Connection = DBconnection
    CommandText = 'select * from Pack'
    Parameters = <>
    Left = 264
    Top = 152
  end
  object Packdeckset: TADODataSet
    Connection = DBconnection
    CommandText = 'select * from PackDeck'
    Parameters = <>
    Left = 344
    Top = 152
  end
  object CardPackset: TADODataSet
    Connection = DBconnection
    CommandText = 'select * from CardPack'
    Parameters = <>
    Left = 160
    Top = 392
  end
  object Cardset: TADODataSet
    Connection = DBconnection
    CommandText = 'select * from Card'
    Parameters = <>
    Left = 232
    Top = 392
  end
end
