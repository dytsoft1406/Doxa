unit main_api;


interface

uses
System.SysUtils ;


procedure runServer;





implementation

uses Horse, Horse.Jhonson, System.JSON , dm, uMedicamento, uAmbulancia, uStockAmbulancia;

procedure runServer ;
begin
 datos := nil ;
 try
  datos := Tdatos.Create(nil);
  THorse.use(Jhonson());
  uMedicamento.abmMedicamento ;
  uAmbulancia.abmAmbulancia ;
  uStockAmbulancia.abmStockAmbulancia ;

  THorse.Listen(9000,
         procedure
         begin
           // Callback cuando el servidor inicia (ACallbackListen)
           Writeln(Format('Servidor ejecutándose en el puerto %d', [9000]));
         end,
         procedure
         begin
           // Callback cuando el servidor se detiene (ACallbackStopListen - Opcional)
           Writeln('Servidor detenido');
           FreeAndNil(datos);
         end );
except
  on E: Exception do
  begin
    Writeln('Error al iniciar servidor: ' + E.Message);
    FreeAndNil(datos);
    Readln;
  end;
end;
end;





end.
