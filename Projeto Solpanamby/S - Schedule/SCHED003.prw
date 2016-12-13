#Include "Totvs.ch"

/*/{Protheus.doc} SCHED003
@description	Schedule JET (Funcao executada por JOB)
@author			Amedeo D. Paoli filho
@version		1.0
@return			Nil
@type			Function
/*/
User Function SCHED003( cEmpJob, cFilJob )
Local cNomBlk := "U_ISCH0001"
Local lSeguir := LS_GETTOTAL(1) < 0
Local lProcessa := .T.

ConOut(PadC( Replicate("=",60),60 ))
ConOut(PadC( DtoC( Date() ) + ' - ' + Time() + " INICIANDO JOB - ISCH0001",60))
ConOut(PadC( Replicate("=",60),60 ))

If ValType( cEmpJob ) == "U" .Or. ValType( cFilJob ) == "U" .OR. Empty( cEmpJob ) .OR. Empty( cFilJob )
	Conout( "Empresa ou Filial faltando, verifique agendamento" )
Else
	RpcClearEnv()
	RPCSetType( 3 )
	RpcSetEnv( cEmpJob, cFilJob, Nil, Nil, "FAT", Nil, {"SA1","SA2","SA3"} )

	//Verifica Lock de processamento
	While ! LockbyName( cNomBlk, .T., .F., lSeguir )
		Sleep(50)
		nCont++
		ConOut(PadC("JOB - ISCH0001 ( Em Execucao, Aguardando Liberação ) Tentativa: " + StrZero(nCont,3) ,80))
		If nCont > 5
			ConOut(PadC("JOB - ISCH0001 ( Abortado por tempo limite )" ,80))
			lProcessa := .F.
			Exit
		EndIf
	End

	If lProcessa
		U_fProcess( .T. )
	EndIf

	//Desbloqueia Semaforo
	UnLockbyName( cNomBlk, .T., .F., lSeguir )
EndIf

ConOut(PadC( Replicate("=",60),60 ))
ConOut(PadC( DtoC( Date() ) + ' - ' + Time() + " FINALIZANDO JOB - ISCH0001",60))
ConOut(PadC( Replicate("=",60),60 ))
Return(Nil)

/*/{Protheus.doc} fProcess
@description	Rotina de Execucao (Acionada manualmente / chamada pelo JOB)
@author			Amedeo D. Paoli filho
@version		1.0
@return			Nil
@type			Function
/*/
User Function fProcess( lSched, cProcess, nID )
Local lIntregCom := SuperGetMv('PY_INT001',.T.,.F.) //Parametro responsável por ligar a integração do faturamento com os sistemas legados das empresas de comunicação

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

//Chama o processo de Título Financeiro (PARCELA)
If cProcess == "0" .OR. cProcess == "005"
	If ! lSched
		FwMsgRun( ,{|| U_ISE10001( .F., .F., .T., nID ) } , , 'Integrando Títulos do Financeiro, Por favor aguarde' )
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