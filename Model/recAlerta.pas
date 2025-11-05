unit recAlerta;

interface
uses
  System.SysUtils, System.JSON, System.DateUtils;

  type
  TAlerta = record
    ID: Integer;
    Tipo: string;
    MedicamentoID: Integer;
    AmbulanciaID: Integer;
    Mensaje: string;
    FechaGenerada: TDateTime;
    FechaResuelta: TDateTime;
    ResueltaPor: Integer;
    Prioridad: string;

    function ToJson: TJSONObject;
    procedure FromJson(const AJson: TJSONObject);
  end;


implementation

function TAlerta.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('ID', TJSONNumber.Create(ID));
  Result.AddPair('Tipo', Tipo);
  Result.AddPair('MedicamentoID', TJSONNumber.Create(MedicamentoID));
  Result.AddPair('AmbulanciaID', TJSONNumber.Create(AmbulanciaID));
  Result.AddPair('Mensaje', Mensaje);
  Result.AddPair('FechaGenerada', TJSONString.Create(DateToISO8601(FechaGenerada)));
  if FechaResuelta > 0 then
    Result.AddPair('FechaResuelta', TJSONString.Create(DateToISO8601(FechaResuelta)));
  Result.AddPair('ResueltaPor', TJSONNumber.Create(ResueltaPor));
  Result.AddPair('Prioridad', Prioridad);
end;

procedure TAlerta.FromJson(const AJson: TJSONObject);
begin
  if Assigned(AJson) then
  begin
    ID := AJson.GetValue<Integer>('ID', 0);
    Tipo := AJson.GetValue<string>('Tipo', '');
    MedicamentoID := AJson.GetValue<Integer>('MedicamentoID', 0);
    AmbulanciaID := AJson.GetValue<Integer>('AmbulanciaID', 0);
    Mensaje := AJson.GetValue<string>('Mensaje', '');
    FechaGenerada := ISO8601ToDate(AJson.GetValue<string>('FechaGenerada', ''));
    FechaResuelta := ISO8601ToDate(AJson.GetValue<string>('FechaResuelta', ''));
    ResueltaPor := AJson.GetValue<Integer>('ResueltaPor', 0);
    Prioridad := AJson.GetValue<string>('Prioridad', '');
  end;
end;

end.
