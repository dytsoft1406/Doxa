unit recStockAmbulancia;

interface
uses
  System.SysUtils, System.JSON, System.DateUtils;

  type
  TStockAmbulancia = record
    ID: Integer;
    AmbulanciaID: Integer;
    MedicamentoID: Integer;
    Lote: string;
    Caducidad: TDate;
    Cantidad: Integer;
    Ubicacion: string;

    function ToJson: TJSONObject;
    procedure FromJson(const AJson: TJSONObject);
  end;

implementation

function TStockAmbulancia.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('ID', TJSONNumber.Create(ID));
  Result.AddPair('AmbulanciaID', TJSONNumber.Create(AmbulanciaID));
  Result.AddPair('MedicamentoID', TJSONNumber.Create(MedicamentoID));
  Result.AddPair('Lote', Lote);
  Result.AddPair('Caducidad', TJSONString.Create(DateToISO8601(Caducidad)));
  Result.AddPair('Cantidad', TJSONNumber.Create(Cantidad));
  Result.AddPair('Ubicacion', Ubicacion);
end;

procedure TStockAmbulancia.FromJson(const AJson: TJSONObject);
begin
  if Assigned(AJson) then
  begin
    ID := AJson.GetValue<Integer>('ID', 0);
    AmbulanciaID := AJson.GetValue<Integer>('AmbulanciaID', 0);
    MedicamentoID := AJson.GetValue<Integer>('MedicamentoID', 0);
    Lote := AJson.GetValue<string>('Lote', '');
    Caducidad := ISO8601ToDate(AJson.GetValue<string>('Caducidad', ''));
    Cantidad := AJson.GetValue<Integer>('Cantidad', 0);
    Ubicacion := AJson.GetValue<string>('Ubicacion', '');
  end;
end;

end.
