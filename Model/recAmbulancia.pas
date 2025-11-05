unit recAmbulancia;

interface
uses
  System.SysUtils, System.JSON, System.DateUtils;

type
  TAmbulancia = record
    ID: Integer;
    Nombre: string;
    Patente: string;
    Descripcion: string;
    Activa: Boolean;
    UltimaRevision: TDate;

    function ToJson: TJSONObject;
    procedure FromJson(const AJson: TJSONObject);
  end;

implementation

function TAmbulancia.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('ID', TJSONNumber.Create(ID));
  Result.AddPair('Nombre', Nombre);
  Result.AddPair('Patente', Patente);
  Result.AddPair('Descripcion', Descripcion);
  Result.AddPair('Activa', TJSONBool.Create(Activa));
  Result.AddPair('UltimaRevision', TJSONString.Create(DateToISO8601(UltimaRevision)));
end;

procedure TAmbulancia.FromJson(const AJson: TJSONObject);
begin
  if Assigned(AJson) then
  begin
    ID := AJson.GetValue<Integer>('ID', 0);
    Nombre := AJson.GetValue<string>('Nombre', '');
    Patente := AJson.GetValue<string>('Patente', '');
    Descripcion := AJson.GetValue<string>('Descripcion', '');
    Activa := AJson.GetValue<Boolean>('Activa', True);
    UltimaRevision := ISO8601ToDate(AJson.GetValue<string>('UltimaRevision', ''));
  end;
end;

end.
