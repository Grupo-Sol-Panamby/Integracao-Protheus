#Include "Totvs.ch"

/*/{Protheus.doc} ISCH0002
@description	Rotina de Execucao (Acionada manualmente / chamada pelo JOB)
@author			Amedeo D. Paoli filho
@version		1.0
@return			Nil
@type			Function
/*/
User Function ISCH0002( lSched, cProcess, nID )
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
		FwMsgRun( ,{|| U_IFAT0001( nID ) }			, , 'Integrando Faturamento, Por favor aguarde' )
	Else
		U_IFAT0001( nID )
	EndIf
EndIf

Return(Nil)