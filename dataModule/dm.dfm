object datos: Tdatos
  OnCreate = DataModuleCreate
  Height = 201
  Width = 257
  object Conexion: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\Carlos\Documents\Embarcadero\Studio\Projects\D' +
        'oxa\BD\doxa.db'
      'LockingMode=Normal'
      'DriverID=SQLite')
    UpdateOptions.AssignedValues = [uvAutoCommitUpdates]
    ConnectedStoredUsage = []
    LoginPrompt = False
    Left = 56
    Top = 88
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 104
    Top = 16
  end
end
