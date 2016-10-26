#Include "Totvs.ch"

/*/{Protheus.doc} ISCH0002
@description	Rotina de Execucao (Acionada manualmente / chamada pelo JOB)
@author			Amedeo D. Paoli filho
@version		1.0
@return			Nil
@type			Function
/*/
User Function ISCH0002( lSched, cProcess )
Default lSched := .F.
Default cProcess := "0"

//Chama processo de cliente
If cProcess == "0" .OR. cProcess == "001"
	If ! lSched
		FwMsgRun( ,{|| U_ISA10001( .F., .F., .T. ) } , , 'Integrando Clientes, Por favor aguarde' )
	Else
		U_ISA10001( .F., .F., .T. )
	EndIf
EndIf

//	//Chama processo de contrato
//	If !lSched
//		FwMsgRun( ,{|| U_ICON0001( lSched ) }			, , 'Integrando Contratos, Por favor aguarde' )
//	Else
//		U_ICON0001( lSched )
//	EndIf
//
//	//Chama processo de execucao
//	If !lSched
//		FwMsgRun( ,{|| U_IEXE0001( lSched ) }			, , 'Integrando Execuções, Por favor aguarde' )
//	Else
//		U_IEXE0001( lSched )
//	EndIf
//
//	//Chama processo de faturamento
//	If !lSched
//		FwMsgRun( ,{|| U_IFAT0001( lSched ) }			, , 'Integrando Faturamento, Por favor aguarde' )
//	Else
//		U_IFAT0001( lSched )
//	EndIf
Return(Nil)