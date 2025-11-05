unit recMovimiento;

interface

uses
  System.SysUtils, System.JSON, System.DateUtils;

  type
  TMovimiento = record
    ID: Integer;
    Tipo: string;
    AmbulanciaOrigenID: Integer;
    AmbulanciaDestinoID: Integer;
    MedicamentoID: Integer;
    StockID: Integer;
    Cantidad: Integer;
    Lote: string;
    Caducidad: TDate;
    UsuarioID: Integer;
    FechaHora: TDateTime;
    Motivo: string;
    PedidoID: Integer;

    function ToJson: TJSONObject;
    procedure FromJson(const AJson: TJSONObject);

  end;

implementation

function TMovimiento.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('ID', TJSONNumber.Create(ID));
  Result.AddPair('Tipo', Tipo);
  Result.AddPair('AmbulanciaOrigenID', TJSONNumber.Create(AmbulanciaOrigenID));
  Result.AddPair('AmbulanciaDestinoID', TJSONNumber.Create(AmbulanciaDestinoID));
  Result.AddPair('MedicamentoID', TJSONNumber.Create(MedicamentoID));
  Result.AddPair('StockID', TJSONNumber.Create(StockID));
  Result.AddPair('Cantidad', TJSONNumber.Create(Cantidad));
  Result.AddPair('Lote', Lote);
  Result.AddPair('Caducidad', TJSONString.Create(DateToISO8601(Caducidad)));
  Result.AddPair('UsuarioID', TJSONNumber.Create(UsuarioID));
  Result.AddPair('FechaHora', TJSONString.Create(DateToISO8601(FechaHora)));
  Result.AddPair('Motivo', Motivo);
  Result.AddPair('PedidoID', TJSONNumber.Create(PedidoID));
end;

procedure TMovimiento.FromJson(const AJson: TJSONObject);
begin
  if Assigned(AJson) then
  begin
    ID := AJson.GetValue<Integer>('ID', 0);
    Tipo := AJson.GetValue<string>('Tipo', '');
    AmbulanciaOrigenID := AJson.GetValue<Integer>('AmbulanciaOrigenID', 0);
    AmbulanciaDestinoID := AJson.GetValue<Integer>('AmbulanciaDestinoID', 0);
    MedicamentoID := AJson.GetValue<Integer>('MedicamentoID', 0);
    StockID := AJson.GetValue<Integer>('StockID', 0);
    Cantidad := AJson.GetValue<Integer>('Cantidad', 0);
    Lote := AJson.GetValue<string>('Lote', '');
    Caducidad := ISO8601ToDate(AJson.GetValue<string>('Caducidad', ''));
    UsuarioID := AJson.GetValue<Integer>('UsuarioID', 0);
    FechaHora := ISO8601ToDate(AJson.GetValue<string>('FechaHora', ''));
    Motivo := AJson.GetValue<string>('Motivo', '');
    PedidoID := AJson.GetValue<Integer>('PedidoID', 0);
  end;
end;

end.
