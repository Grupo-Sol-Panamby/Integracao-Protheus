#Include "Totvs.ch"

/*/{Protheus.doc} ISCH0002
@description	Rotina de Execucao (Acionada manualmente / chamada pelo JOB)
@author			Amedeo D. Paoli filho
@version		1.0
@return			Nil
@type			Function
/*/
User Function ISCH0002( lSched, cProcess, nID )
Local lIntregCom := SuperGetMv('PY_INT001',.T.,.F.) //Parametro respons�vel por ligar a integra��o do faturamento com os sistemas legados das empresas de comunica��o

Default lSched := .F.
Default cProcess := "0"
Default nID := 0

//Chama processo de cliente
If cProcess == "0" .OR. cProcess == "001"
	If ! lSched
		FwMsgRun( ,{|| U_ISA10001( .F., .F., .T., nID ) } , , 'Integrando Clientes, Por favor aguarde' )
	Else
		U_ISA10001( .F., .F., .T., nID )
	EndIf
EndIf

//Chama processo do faturamento
If cProcess == "0" .OR. cProcess == "002"
	If ! lSched
		FwMsgRun( ,{|| U_IFAT0002( nID ) }			, , 'Integrando Faturamento, Por favor aguarde' )
	Else
		U_IFAT0002( nID )
	EndIf
EndIf

//Chama o processo do Pedido de Venda
If cProcess == "0" .OR. cProcess == "003"
	If ! lSched
		FwMsgRun( ,{|| U_ISC50001( .F., .F., .T., nID ) } , , 'Integrando Pedidos de Venda, Por favor aguarde' )
	Else
		U_ISC50001( .F., .F., .T., nID )
	EndIf
EndIf

//Chama o processo de Nota Fiscal
If cProcess == "0" .OR. cProcess == "004"
	If ! lSched
		FwMsgRun( ,{|| U_ISF20001( .F., .F., .T., nID ) } , , 'Integrando Notas Fiscais, Por favor aguarde' )
	Else
		U_ISF20001( .F., .F., .T., nID )
	EndIf
EndIf

//Chama o processo de T�tulo Financeiro (PARCELA)
If cProcess == "0" .OR. cProcess == "005"
	If ! lSched
		FwMsgRun( ,{|| U_ISE10001( .F., .F., .T., nID ) } , , 'Integrando T�tulos do Financeiro, Por favor aguarde' )
	Else
		U_ISE10001( .F., .F., .T., nID )
	EndIf
EndIf

//Chama processo de vendedor
If cProcess == "0" .OR. cProcess == "006"
	If ! lSched
		FwMsgRun( ,{|| U_ISA30001( .F., .F., .T., nID ) } , , 'Integrando Vendedores, Por favor aguarde' )
	Else
		U_ISA30001( .F., .F., .T., nID )
	EndIf
EndIf

Return(Nil)