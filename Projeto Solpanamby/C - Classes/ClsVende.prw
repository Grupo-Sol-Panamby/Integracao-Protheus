#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

User Function ClsVende()
Return Nil

/*/{Protheus.doc} ClsVende (VendSP)
@description Classe para replica de Vendedores via MsExecAuto
@author Amedeo D. Paoli Filho
@version 1.0
/*/
Class VendSP From uExecAuto
	Data cCodigo

	Method New()
	Method AddValues(cCampo, xValor)
	Method Gravacao(nOpcao)
	Method GetCodigo()
EndClass

/*/{Protheus.doc} new
@Description Metodo construtor
@author Amedeo D. Paoli Filho
@version 1.0
/*/
Method New() Class VendSP
	_Super:New()

	::aTabelas := {"SA3"}
	::cFileLog := "MATA040.LOG"
	::cCodigo := ""
Return Self

/*/{Protheus.doc} AddValues
@Description Metodo AddValues
@author Amedeo D. Paoli Filho
@version 1.0
/*/
Method AddValues(cCampo, xValor) Class VendSP
	If AllTrim(cCampo) == "A3_COD"
		::cCodigo := xValor
	EndIf

	_Super:AddValues(cCampo, xValor)
Return Nil

/*/{Protheus.doc} Gravacao
@Description Metodo Gravacao
@author Amedeo D. Paoli Filho
@version 1.0
/*/
Method Gravacao(nOpcao) Class VendSP
	Local lRetorno := .T.

	Private lMsErroAuto := .F.

	::SetEnv(1, "FAT")

	dbSelectArea("SA3")
	SA3->(dbSetOrder(1))

	// Controle de Transacao
	Begin Transaction
		If nOpcao == 3
			If Empty(::cCodigo)
				lRetorno := .F.
				::cMensagem := "Vendedor não informado."
			EndIf
		Else
			If Empty(::cCodigo)
				lRetorno := .F.
				::cMensagem := "Vendedor não informado."
			Else
				If ! SA3->(dbSeek(xFilial("SA3") + ::cCodigo))
					//Caso for Alteracao e Nao encontrar, inclui o Vendedor
					If nOpcao == 4
						nOpcao := 3
					Else
						lRetorno := .F.
						::cMensagem := "Vendedor " + ::cCodigo + " não cadastrado."
					EndIf
				EndIf
			EndIf
		EndIf

		If lRetorno
			::AddValues("A3_FILIAL", xFilial("SA3"))

			//Gravacao do Pedido de Compra
			MsExecAuto({|a, b| MATA040(a, b)}, ::aValues, nOpcao)

			If lMsErroAuto
				lRetorno := .F.

				If ::lExibeTela
					MostraErro()
				EndIf

				If ::lGravaLog
					::cMensagem := MostraErro(::cPathLog, ::cFileLog)
				EndIf
			EndIf
		EndIf

		If ! lRetorno
			DisarmTransaction()
		EndIf

	//Encerra a Transacao
	End Transaction

	::SetEnv(2, "FAT")
Return lRetorno

/*/{Protheus.doc} GetCodigo
@Description Metodo GetCodigo
@author Amedeo D. Paoli Filho
@version 1.0
/*/
Method GetCodigo() Class VendSP
Return ::cCodigo