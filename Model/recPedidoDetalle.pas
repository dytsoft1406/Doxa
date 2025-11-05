unit recPedidoDetalle;

interface
uses
  System.SysUtils, System.JSON, System.DateUtils;

  type
  TPedidoDetalle = record
    ID: Integer;
    PedidoID: Integer;
    MedicamentoID: Integer;
    CantidadSolicitada: Integer;
    CantidadEntregada: Integer;
    Lote: string;
    Caducidad: TDate;
    Estado: string;

    function ToJson: TJSONObject;
    procedure FromJson(const AJson: TJSONObject);
  end;

implementation

function TPedidoDetalle.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('ID', TJSONNumber.Create(ID));
  Result.AddPair('PedidoID', TJSONNumber.Create(PedidoID));
  Result.AddPair('MedicamentoID', TJSONNumber.Create(MedicamentoID));
  Result.AddPair('CantidadSolicitada', TJSONNumber.Create(CantidadSolicitada));
  Result.AddPair('CantidadEntregada', TJSONNumber.Create(CantidadEntregada));
  Result.AddPair('Lote', Lote);
  Result.AddPair('Caducidad', TJSONString.Create(DateToISO8601(Caducidad)));
  Result.AddPair('Estado', Estado);
end;

procedure TPedidoDetalle.FromJson(const AJson: TJSONObject);
begin
  if Assigned(AJson) then
  begin
    ID := AJson.GetValue<Integer>('ID', 0);
    PedidoID := AJson.GetValue<Integer>('PedidoID', 0);
    MedicamentoID := AJson.GetValue<Integer>('MedicamentoID', 0);
    CantidadSolicitada := AJson.GetValue<Integer>('CantidadSolicitada', 0);
    CantidadEntregada := AJson.GetValue<Integer>('CantidadEntregada', 0);
    Lote := AJson.GetValue<string>('Lote', '');
    Caducidad := ISO8601ToDate(AJson.GetValue<string>('Caducidad', ''));
    Estado := AJson.GetValue<string>('Estado', '');
  end;
end;


end.
