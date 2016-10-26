#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

User Function ClsPedVen()
Return Nil

/*/{Protheus.doc} ClsPedVen (PedVenda)
@description	Classe Responsavel pela gravacao do Pedido de Venda via
				MsExecAuto.
@author 		Amedeo D. Paoli Filho
@version 		1.0
/*/
Class PedVenda From uExecAuto
	Data cPedido
	Data dEmissao
	Data cCondPg
	
	Method New()
	Method AddCabec(cCampo, xValor)
	Method Gravacao(nOpcao)
	Method GetNumero()
EndClass

/*/{Protheus.doc} New
@Description	Metodo construtor
@author 		Amedeo D. Paoli Filho
@version 		1.0
/*/
Method New() Class PedVenda

	_Super:New()

	::aTabelas	:= {"SC5","SC6","SA1","SA2","SB1","SB2","SF4"}
	::dEmissao	:= CtoD("")
	::cFileLog	:= "MATA410.LOG"
	::cPedido	:= ""
	::cCondPg	:= ""

Return Self

/*/{Protheus.doc} AddCabec
@Description	Metodo AddCabec
@author 		Amedeo D. Paoli Filho
@version 		1.0
/*/
Method AddCabec(cCampo, xValor) Class PedVenda
	
	If AllTrim(cCampo) == "C5_NUM"
		::cPedido    := xValor
	ElseIf AllTrim(cCampo) == "C5_EMISSAO"
		::dEmissao	:= xValor
	ElseIf Alltrim(cCampo) == "C5_CONDPAG"
		::cCondPg	:= xValor
	EndIf

	_Super:AddCabec(cCampo, xValor)

Return Nil

/*/{Protheus.doc} Gravacao
@Description	Metodo Gravacao
@author 		Amedeo D. Paoli Filho
@version 		1.0
/*/
Method Gravacao(nOpcao) Class PedVenda
	Local dDataBackup	:= dDataBase
	Local lExecuta		:= .T.
	Local lRetorno		:= .T.
	Local lReserva		:= .F.
	Local lRollback		:= .F.
	Local nX			:= 0
	
	Private lMsErroAuto	:= .F.
		
	::SetEnv(1, "FAT", .T.)

	//=========================================
	// Inicia transacao
	//=========================================
	Begin Transaction
	
	If !Empty(::dEmissao)
		dDataBase := ::dEmissao
	EndIf
	
	DbSelectArea("SC5")
	DbSetOrder(1)
	
	If Type("INCLUI") == "U" .Or. Type("ALTERA") == "U"
		If nOpcao == 3
			INCLUI	:= .T.
			ALTERA	:= .F.
		ElseIf nOpcao == 4
			INCLUI	:= .F.
			ALTERA	:= .T.
		ElseIf nOpcao == 5
			INCLUI	:= .F.
			ALTERA	:= .F.
		EndIf
	EndIf
	
	//Se for inclusao, reserva um numero para o Pedido
	If nOpcao <> 3
		If Empty(::cPedido)
			lRetorno	:= .F.
			::cMensagem	:= "Numero do Pedido não informado."
		Else
			If !SC5->(DbSeek(xFilial("SC5") + ::cPedido))
				lRetorno 	:= .F.
				::cMensagem	:= "Pedido " + ::cPedido + " não cadastrado."
			EndIf
		EndIf
	Else
		If !Empty(::cPedido)
			lRollback	:= .T.
		EndIf
	EndIf
	
	If lRetorno .And. lExecuta
		::AddCabec("C5_FILIAL",	xFilial("SC5"))
		
		//Inicia Variavel como .F. caso o Execauto caia, o retorno sera .F.
		lRetorno := .F.

		//Gravacao do Pedido de Venda
		MSExecAuto( {|a, b, c| MATA410(a, b, c)}, ::aCabec, ::aItens, nOpcao, , Nil )
			
		If lMsErroAuto
			lRetorno := .F.
				
			If ::lExibeTela
				MostraErro()
			EndIf
				
			If ::lGravaLog
				::cMensagem := MostraErro(::cPathLog, ::cFileLog)
			EndIf

			If lReserva
				RollBackSx8()
			EndIf

		Else
			
			lRetorno	:= .T.
			::cPedido 	:= SC5->C5_NUM
			
			If lRollback
				If ( __lSx8 )
					RollBackSx8()
				EndIf
				
			ElseIf lReserva
				ConfirmSx8()
				
			EndIf
			
		EndIf

	EndIf

	If !lRetorno
		DisarmTransaction()
	EndIf
	
	//=========================================
	// Encerra a Transacao.
	//=========================================
	End Transaction
	
	dDataBase := dDataBackup
	
	::SetEnv(2, "FAT", .T.)

Return lRetorno

/*/{Protheus.doc} GetNumero
@Description	Retorna o numero do pedido gerado.
@author 		Amedeo D. Paoli Filho
@version 		1.0
/*/
Method GetNumero() Class PedVenda
Return ::cPedido
