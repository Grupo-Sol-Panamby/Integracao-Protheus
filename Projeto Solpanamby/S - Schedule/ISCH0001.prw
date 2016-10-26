#Include "Totvs.ch"

/*/{Protheus.doc} ISCH0001
@description	Schedule JET (Funcao executada por JOB)
@author			Amedeo D. Paoli filho
@version		1.0
@return			Nil
@type			Function
/*/
User Function ISCH0001( cEmpJob, cFilJob )
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
		U_ISCH0002( .T. )
	EndIf

	//Desbloqueia Semaforo
	UnLockbyName( cNomBlk, .T., .F., lSeguir )
EndIf

ConOut(PadC( Replicate("=",60),60 ))
ConOut(PadC( DtoC( Date() ) + ' - ' + Time() + " FINALIZANDO JOB - ISCH0001",60))
ConOut(PadC( Replicate("=",60),60 ))
Return(Nil)

//==================================================================================
//Programa para teste da Chamada da Rotina
//==================================================================================
User Function TstISC()
	U_ISCH0001( "80", "01" )
Return(Nil)