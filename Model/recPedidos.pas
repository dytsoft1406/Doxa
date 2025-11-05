unit recPedidos;

interface
uses
  System.SysUtils, System.JSON, System.DateUtils;

  type
  TPedido = record
    ID: Integer;
    AmbulanciaID: Integer;
    UsuarioID: Integer;
    FechaCreacion: TDateTime;
    FechaCompletado: TDateTime;
    Estado: string;
    Comentarios: string;

    function ToJson: TJSONObject;
    procedure FromJson(const AJson: TJSONObject);
  end;

implementation

function TPedido.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('ID', TJSONNumber.Create(ID));
  Result.AddPair('AmbulanciaID', TJSONNumber.Create(AmbulanciaID));
  Result.AddPair('UsuarioID', TJSONNumber.Create(UsuarioID));
  Result.AddPair('FechaCreacion', TJSONString.Create(DateToISO8601(FechaCreacion)));
  if FechaCompletado > 0 then
    Result.AddPair('FechaCompletado', TJSONString.Create(DateToISO8601(FechaCompletado)));
  Result.AddPair('Estado', Estado);
  Result.AddPair('Comentarios', Comentarios);
end;

procedure TPedido.FromJson(const AJson: TJSONObject);
begin
  if Assigned(AJson) then
  begin
    ID := AJson.GetValue<Integer>('ID', 0);
    AmbulanciaID := AJson.GetValue<Integer>('AmbulanciaID', 0);
    UsuarioID := AJson.GetValue<Integer>('UsuarioID', 0);
    FechaCreacion := ISO8601ToDate(AJson.GetValue<string>('FechaCreacion', ''));
    FechaCompletado := ISO8601ToDate(AJson.GetValue<string>('FechaCompletado', ''));
    Estado := AJson.GetValue<string>('Estado', '');
    Comentarios := AJson.GetValue<string>('Comentarios', '');
  end;
end;

end.
