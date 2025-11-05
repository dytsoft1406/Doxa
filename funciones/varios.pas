unit varios;

interface

uses System.DateUtils, System.Classes, System.SysUtils, DB, System.JSON, FireDAC.Stan.Param, System.Hash;

procedure SetParametroAuto(Body: TJSONObject; const Parametro: string; Param: TFDParam);
function GenerarSalt(largo: Integer): string ;
function hashassword(const Password, Salt: string): string ;


implementation

procedure SetParametroAuto(Body: TJSONObject; const Parametro: string; Param: TFDParam);
var
  ValueStr: string;
  ValueDate: TDateTime ;
begin
  if Body.TryGetValue<string>(Parametro, ValueStr) then
  begin
 // Asignamos según el tipo de dato del parámetro
    if Param.DataType = ftString then
    begin
      Param.AsString := ValueStr;
    end
    else if Param.DataType = ftInteger then
    begin
      Param.AsInteger := StrToIntDef(ValueStr, 0);
    end
    else if Param.DataType = ftBoolean then
    begin
      Param.AsBoolean := SameText(ValueStr, 'true') or (ValueStr = '1');
    end
    else if (Param.DataType = ftDate) or (Param.DataType = ftDateTime) then
    begin
      // Si es una fecha, la convertimos a TDateTime
      ValueDate := ISO8601ToDate(ValueStr, True);
      Param.AsDateTime := ValueDate;
    end
    else
      raise Exception.CreateFmt('Tipo de parámetro "%s" no soportado automáticamente.', [Parametro]);
  end
  else begin
     case Param.DataType of
      ftString, ftWideString:
        begin
          Param.DataType := ftString;
          Param.Clear;
        end;
      ftInteger, ftSmallint, ftWord:
        begin
          Param.DataType := ftInteger;
          Param.Clear;
        end;
      ftBoolean:
        begin
          Param.DataType := ftBoolean;
          Param.Clear;
        end;
      ftDate, ftTime, ftDateTime:
        begin
          Param.DataType := ftDateTime;
          Param.Clear;
        end;
      else
        raise Exception.Create('Tipo de parámetro no soportado al limpiar: ' + Param.Name);
    end;


  end;
end;


function GenerarSalt(largo: Integer): string ;
const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
var I : integer ;
begin
  Result := '' ;
  Randomize ;


  for I := 1 to largo do
    Result := Result + chars[Random(Length(chars)+ 1)];

end;

function hashassword(const Password, Salt: string): string ;
begin
   Result := THashSHA2.GetHashString(Password + Salt) ;
end;


end.
