unit uAmbulancia;

interface
uses
 Horse, System.JSON, FireDAC.comp.client, System.SysUtils, System.DateUtils, System.Classes, Horse.Jhonson,
 FireDAC.Stan.Intf,
  FireDAC.Stan.Param,
  FireDAC.DApt,
  FireDAC.Stan.Option,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  Data.DB, StrUtils;

  procedure abmAmbulancia ;

implementation

uses recAmbulancia, dm, varios;

procedure getAmbulanciaID(Req: THorseRequest; Res: THorseResponse; Next: TProc) ;
var ambulancia : TAmbulancia ;
    SQLAmbulancia : TFDQuery ;
    ID     : Integer ;
begin
  SQLAmbulancia := datos.CrearQuery ;
  try
    try
       if not TryStrToInt(req.Params['ID'], ID) then
          raise Exception.Create('No existe el ID');

       SQLAmbulancia.SQL.Text := 'SELECT * FROM Ambulancias WHERE ID = :ID';
       SQLAmbulancia.ParamByName('ID').AsInteger := ID ;
       SQLAmbulancia.Open ;


       if SQLAmbulancia.IsEmpty then
          raise Exception.Create('Ambulancia no encontrada');

       ambulancia.ID   := SQLAmbulancia.FieldByName('ID').AsInteger ;
       ambulancia.Nombre := SQLAmbulancia.FieldByName('Nombre').AsString ;
       ambulancia.Patente := SQLAmbulancia.FieldByName('Patente').AsString ;
       ambulancia.Descripcion := SQLAmbulancia.FieldByName('Descripcion').AsString ;
       ambulancia.Activa  := SQLAmbulancia.FieldByName('Activa').AsBoolean ;
       if not SQLAmbulancia.FieldByName('UltimaRevision').IsNull then
          ambulancia.UltimaRevision := SQLAmbulancia.FieldByName('UltimaRevision').AsDateTime
       else
          ambulancia.UltimaRevision := 0;

       Res.Send<TJSONObject>(ambulancia.ToJson) ;

    except
      on E : Exception do
       Res.Status(THTTPStatus.InternalServerError).Send('Error: '+ E.Message);

    end;
  finally
    FreeAndNil(SQLAmbulancia) ;
  end;
end;


procedure getAmbulancia(Req: THorseRequest; Res: THorseResponse; Next: TProc) ;
var ambulancia : TAmbulancia ;
    SQLAmb     : TFDQuery ;
    Lista      : TJSONArray ;
    limit, offset: integer ;
begin
  Lista := TJSONArray.Create ;
  SQLAmb := datos.CrearQuery ;
  try
    try
      limit := StrToIntDef(Req.Query['limit'], 10);    // valor por defecto: 10
      offset := StrToIntDef(Req.Query['offset'], 0);   // por defecto desde el inicio

      SQLAmb.SQL.Text := Format('Select * FROM Ambulancias LIMIT %d OFFSET %d', [limit, offset]) ;
      SQLAmb.Open ;

      WHILE not SQLAmb.Eof do
         begin
           ambulancia.ID             := SQLAmb.FieldByName('ID').AsInteger ;
           ambulancia.Nombre         := SQLAmb.FieldByName('Nombre').AsString ;
           ambulancia.Patente        := SQLAmb.FieldByName('Patente').AsString ;
           ambulancia.Descripcion    := SQLAmb.FieldByName('Descripcion').AsString ;
           ambulancia.Activa         := SQLAmb.FieldByName('Activa').AsBoolean ;
           ambulancia.UltimaRevision := SQLAmb.FieldByName('UltimaRevision').AsDateTime ;

           Lista.AddElement(ambulancia.ToJson) ;
           SQLAmb.Next ;
         end;
       Res.Send<TJSONArray>(Lista) ;

    except
      on E : Exception  do
       Res.Status(THTTPStatus.InternalServerError).Send('Error Interno: '+ E.Message) ;

    end;

  finally
    FreeAndNil(SQLAmb) ;
  end;
end;


procedure postAmbulancia(Req: THorseRequest; Res: THorseResponse; Next: TProc) ;
var amb : TAmbulancia ;
    body: TJSONObject ;
    sqlAmb, sqlVerificar : TFDQuery ;
    esDuplicado : Boolean ;
begin
  body := nil ;
  sqlAmb := datos.CrearQuery ;
  sqlVerificar := datos.CrearQuery ;
  try
    try
      body := Req.Body<TJSONObject> ;
      amb.FromJson(body);

      //Validacion de campos
      if Trim(amb.Nombre) = '' then
         raise Exception.Create('El nombre no puede quedar vacío, Verifique!!');

      if Trim(amb.Patente) = '' then
         raise Exception.Create('Es necesario ssaber el Dominio del Vehículo');

      //Verificamos si no existe una ambulancia con los mismos datos
      sqlVerificar.SQL.Text := 'Select 1 From Ambulancias WHERE Patente = :Patente LIMIT 1' ;
      sqlVerificar.ParamByName('Patente').AsString := amb.Patente ;
      sqlVerificar.Open ;
      esDuplicado := not sqlVerificar.Eof ;
      sqlVerificar.Close ;

      if esDuplicado then
           raise Exception.Create('Ya existe una unidad con el mismo dominio');

      //INgresamos datos
      datos.IniciarTransaccion ;
      try
        sqlAmb.SQL.Text := 'INSERT INTO Ambulancias (Nombre, Patente, Descripcion, Activa, UltimaRevision) '+
                           'VALUES (:Nombre, :Patente, :Descripcion, :Activa, :UltimaRevision)';
        sqlAmb.ParamByName('Nombre').AsString := amb.Nombre ;
        sqlAmb.ParamByName('Patente').AsString := amb.Patente ;
        sqlAmb.ParamByName('Descripcion').AsString := amb.Descripcion ;
        sqlAmb.ParamByName('Activa').AsBoolean := amb.Activa ;
        sqlAmb.ParamByName('UltimaRevision').AsDateTime := amb.UltimaRevision ;

        sqlAmb.ExecSQL ;

        //Obtener el ultimo ID
        amb.ID := datos.ObtenerUltimoIDGenerado ;

        datos.ConfirmarTransaccion ;
        Res.Status(THTTPStatus.OK).Send<TJSONObject>(amb.ToJson) ;

      except
        on E : exception do
         begin
           datos.RevertirTransaccion ;
           res.Status(THTTPStatus.BadRequest).Send('Error al intentar ingresar un nuevo registro '+ E.Message) ;
         end;
      end;

    except
       on E : exception do
           res.Status(THTTPStatus.BadRequest).Send('JSON Incorrecto: '+ E.Message) ;
    end;
  finally
    FreeAndNil(sqlAmb);
    FreeAndNil(sqlVerificar);
  end;

end;

procedure putAmbulancia(Req: THorseRequest; Res: THorseResponse; Next: TProc) ;
var sqlEdit  : TFDQuery ;
    body : TJSONObject ;
    ID : Integer ;
begin
  ID := Req.Params['ID'].ToInteger ;
  body := Req.Body<TJSONObject> ;
  sqlEdit := datos.CrearQuery ;

  try
      try
       sqlEdit.SQL.Text := 'SELECT * FROM Ambulancias WHERE ID = :ID';
       sqlEdit.ParamByName('ID').AsInteger := ID ;
       sqlEdit.Open ;

       if sqlEdit.IsEmpty then
          begin
           Res.Status(THTTPStatus.NotFound).Send('No existe la Ambulancia') ;
           Exit  ;
          end;


       //ejecuta la actualizacion de los datos
       datos.IniciarTransaccion ;
       sqlEdit.SQL.Text :=
       'UPDATE Ambulancias SET '+
       'Nombre                = COALESCE(:nombre, Nombre), ' +
       'Patente               = COALESCE(:patente, Patente), '+
       'Descripcion           = COALESCE(:descripcion, Descripcion), ' +
       'Activa                = COALESCE(:activa, Activa), '+
       'UltimaRevision        = COALESCE(:ultimarevision, UltimaRevision) '+
       'WHERE ID = :id' ;

       sqlEdit.ParamByName('ID').AsInteger := ID ;
       //false determinar el tipo de los datos para poder usar la funcion setparametroauto
       sqlEdit.ParamByName('Nombre').DataType := ftString ;
       sqlEdit.ParamByName('Patente').DataType := ftString ;
       sqlEdit.ParamByName('Descripcion').DataType := ftString ;
       sqlEdit.ParamByName('Activa').DataType := ftBoolean ;
       sqlEdit.ParamByName('UltimaRevision').DataType := ftDateTime ;


      //si no modifica todos los campos quedan como estan
          //nombre

       SetParametroAuto(body, 'Nombre', sqlEdit.ParamByName('Nombre')) ;
       SetParametroAuto(body, 'Patente', sqlEdit.ParamByName('Patente')) ;
       SetParametroAuto(body, 'Descripcion', sqlEdit.ParamByName('Descripcion')) ;
       SetParametroAuto(body, 'Activa', sqlEdit.ParamByName('Activa')) ;
       SetParametroAuto(body, 'UltimaRevision', sqlEdit.ParamByName('UltimaRevision')) ;

       sqlEdit.ExecSQL ;

       datos.ConfirmarTransaccion ;
       Res.Status(THTTPStatus.OK).Send('Esta ambulancia se ha modificado satisfactoriamente') ;
      except
         on E: Exception do
         begin
           datos.RevertirTransaccion ;
           res.Status(THTTPStatus.BadRequest).Send('Error al editar la ambulancia: '+ E.Message);
         end;
      end;


  finally
    FreeAndNil(sqlEdit) ;
  end;


end;


procedure delAmbulancia(Req: THorseRequest; Res: THorseResponse; Next: TProc) ;
var ID : Integer ;
    sqlDel : TFDQuery ;
    nombreAmb, patente : string ;
begin
 ID := Req.Params['ID'].ToInteger ;
 sqlDel := datos.CrearQuery ;
 try
    sqlDel.SQL.Text := 'SELECT * FROM Ambulancias WHERE ID = :ID';
    sqlDel.ParamByName('ID').AsInteger := ID ;
    sqlDel.Open ;

    if sqlDel.IsEmpty then
       begin
         Res.Status(THTTPStatus.NotFound).Send('No existe esa Ambulancia') ;
         Exit  ;
       end;

    nombreAmb := sqlDel.FieldByName('Nombre').AsString ;
    patente := sqlDel.FieldByName('Patente').AsString ;

    sqlDel.Close ;
    datos.IniciarTransaccion ;
    sqlDel.SQL.Text := 'DELETE From Ambulancias WHERE ID = :ID' ;
    sqlDel.ParamByName('ID').AsInteger := ID ;
    sqlDel.ExecSQL ;

    datos.ConfirmarTransaccion ;
    Res.Status(THTTPStatus.OK).Send('La ambulancia '+nombreAmb+', Dominio '+patente+' ha sido eliminado correctamente') ;

 Except
   on E : Exception do
   begin
    datos.RevertirTransaccion ;
    Res.Status(THTTPStatus.InternalServerError).Send('Error inesperado: '+ E.Message)  ;
   end;
 end;

end;


procedure abmAmbulancia ;
begin
  THorse.Get('/ambulancia', getAmbulancia);
  THorse.Get('/ambulancia/:Id', getAmbulanciaID);
  THorse.Post('/ambulancia', postAmbulancia) ;
  THorse.Put('/ambulancia/:Id', putAmbulancia) ;
  THorse.Delete('/ambulancia/:Id', delAmbulancia) ;

end;

end.
