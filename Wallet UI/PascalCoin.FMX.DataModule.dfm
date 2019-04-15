object MainDataModule: TMainDataModule
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 375
  Width = 512
  object ImageList: TImageList
    Source = <>
    Destination = <>
    Left = 48
    Top = 96
  end
  object AccountsData: TFDMemTable
    OnCalcFields = AccountsDataCalcFields
    IndexFieldNames = 'AccountNumber'
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvStoreItems, rvSilentMode]
    ResourceOptions.StoreItems = [siMeta, siData]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 48
    Top = 176
    object AccountsDataAccountNumChkSum: TStringField
      DisplayLabel = 'Account'
      DisplayWidth = 35
      FieldKind = fkInternalCalc
      FieldName = 'AccountNumChkSum'
      Size = 25
    end
    object AccountsDataAccountNumber: TIntegerField
      FieldName = 'AccountNumber'
      Visible = False
    end
    object AccountsDataCheckSum: TIntegerField
      FieldName = 'CheckSum'
      Visible = False
    end
    object AccountsDataAccountName: TStringField
      DisplayLabel = 'Account Name'
      FieldName = 'AccountName'
      Size = 75
    end
    object AccountsDataBalance: TCurrencyField
      DisplayWidth = 20
      FieldName = 'Balance'
    end
    object AccountsDataNOps: TIntegerField
      FieldName = 'NOps'
    end
    object AccountsDataAccountState: TStringField
      DisplayLabel = 'State'
      DisplayWidth = 15
      FieldName = 'AccountState'
      Size = 10
    end
  end
  object LockTimer: TTimer
    Enabled = False
    Left = 136
    Top = 96
  end
end
