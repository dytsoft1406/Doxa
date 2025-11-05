program Doxa;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  dm in 'dataModule\dm.pas' {datos: TDataModule},
  main_api in 'Controller\main_api.pas',
  varios in 'funciones\varios.pas',
  recMedicamento in 'Model\recMedicamento.pas',
  recUsuario in 'Model\recUsuario.pas',
  recStockAmbulancia in 'Model\recStockAmbulancia.pas',
  recAmbulancia in 'Model\recAmbulancia.pas',
  recPedidos in 'Model\recPedidos.pas',
  recPedidoDetalle in 'Model\recPedidoDetalle.pas',
  recMovimiento in 'Model\recMovimiento.pas',
  recAlerta in 'Model\recAlerta.pas',
  uMedicamento in 'Controller\uMedicamento.pas',
  uAmbulancia in 'Controller\uAmbulancia.pas',
  uStockAmbulancia in 'Controller\uStockAmbulancia.pas';

begin
 RunServer ;


end.
