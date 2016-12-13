#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

User Function ClsCliente()
Return Nil

/*/{Protheus.doc} ClienteSP (ClsCliente)
@description Classe Responsavel pela gravacao do Cliente via MsExecAuto
@author Amedeo D. Paoli Filho
@version 1.0
/*/
Class ClienteSP From uExecAuto
	Data cCodigo
	Data cLoja
	Data cChave
	Data cTpCli
	Data cCidade
	Data cCodMun
	Data cUF

	Method New()
	Method AddValues(cCampo, xValor)
	Method Gravacao(nOpcao)
	Method GetCodigo()
	Method GetLoja()
EndClass

/*/{Protheus.doc} New
@Description Metodo construtor
@author Amedeo D. Paoli Filho
@version 1.0
/*/
Method New() Class ClienteSP
	_Super:New()

	::aTabelas := {"SA1"}
	::cCodigo := ""
	::cLoja := ""
	::cChave := ""
	::cTpCli := ""
	::cCidade := ""
	::cUF := ""
	::cCodMun := ""
	::cFileLog := "MATA030.LOG"
Return Self

/*/{Protheus.doc} AddValues
@Description Metodo AddValues
@param ExpC1, C, Campo
@param ExpC2, C, Valor
@author Amedeo D. Paoli Filho
@version 1.0
/*/
Method AddValues(cCampo, xValor) Class ClienteSP
	If AllTrim(cCampo) == "A1_CGC"
		::cChave := xValor
	EndIf
	If AllTrim(cCampo) == "A1_PESSOA"
		::cTpCli := xValor
	EndIf
	If AllTrim(cCampo) == "A1_COD"
		::cCodigo := PadR(xValor, TamSX3("A1_COD")[1])
	EndIf
	If AllTrim(cCampo) == "A1_LOJA"
		::cLoja := PadR(xValor, TamSX3("A1_LOJA")[1])
	EndIf
	If AllTrim(cCampo) == "A1_MUN"
		xValor := Upper(xValor)
		::cCidade := PadR(xValor, TamSX3("A1_MUN")[1])
	EndIf
	If AllTrim(cCAmpo) == "A1_EST"
		::cUF := PadR(xValor, TamSX3("A1_EST")[1])
	EndIf

	_Super:AddValues(cCampo, xValor)
Return Nil

/*/{Protheus.doc} Gravacao
@Description Metodo Gravacao
@author Amedeo D. Paoli Filho
@version 1.0
/*/
Method Gravacao(nOpcao) Class ClienteSP
	Local cSeek := ""
	Local lAchou := .F.
	Local lReserva := .F.
	Local lRetorno := .T.

	::SetEnv(1, "FAT")

	dbSelectArea("SA1")

	//=========================================
	// Inicia transacao
	//=========================================
	Begin Transaction
		If nOpcao == 3
			If ! Empty(::cCodigo) .AND. ! Empty(::cLoja)

				ConOut( "Inclusao de cliente - Codigo e Loja preenchido" )

				SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
				If SA1->(dbSeek(xFilial("SA1") + ::cCodigo + ::cLoja))
					lRetorno := .F.
					::cMensagem := "Cliente / Loja já cadastrado.
				EndIf
			Else

				ConOut( "Inclusao de cliente" )

				SA1->(dbSetOrder(3)) //A1_FILIAL+A1_CGC
				If Empty(::cTpCli) .OR. Empty(::cChave)
					lRetorno := .F.
					::cMensagem := "Um dos campos Obrigatorios não foi informado. (ClsCliente)"
				Else
					If ::cTpCli == "J"
						cSeek := Substr(::cChave, 1, 8)
						lAchou := SA1->(dbSeek(xFilial("SA1") + cSeek))
					Else
						cSeek := AllTrim(::cChave)
						lAchou := SA1->(dbSeek(xFilial("SA1") + cSeek))
					EndIf

					SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

					If lAchou
						ConOut("Verificando base de CNPJ")

						//Guarda o Codigo do Cliente
						::cCodigo := SA1->A1_COD
						::cLoja := SA1->A1_LOJA

						While ! SA1->(EOF()) .AND. SA1->(A1_FILIAL + A1_COD) == xFilial("SA1") + ::cCodigo
							If AllTrim(::cChave) == AllTrim(SA1->A1_CGC)
								//Caso o Cliente Ja exista, atualiza os dados
								nOpcao := 4
							EndIf

							SA1->(dbSkip())
						End

						If lRetorno .AND. nOpcao == 3
							::cLoja := Soma1(::cLoja)
						EndIf
					Else
						ConOut("Nao encontrado base de CNPJ")

						lReserva := .T.
						::cCodigo := GetSX8Num("SA1", "A1_COD")
						::cLoja := StrZero( 1, TamSX3("A1_LOJA")[1] )
					EndIf

					::AddValues("A1_COD", ::cCodigo)
					::AddValues("A1_LOJA", ::cLoja)
				EndIf
			EndIf
		Else
			SA1->(dbSetOrder(1) ) //A1_FILIAL+A1_COD+A1_LOJA

			If Empty(::cCodigo) .OR. Empty(::cLoja)
				lRetorno := .F.
				::cMensagem := "Cliente / Loja não informados."
			Else
				If ! SA1->(dbSeek(xFilial("SA1") + ::cCodigo + ::cLoja))
					If nOpcao <> 4
						lRetorno := .F.
						::cMensagem := "Cliente / Loja: " + ::cCodigo + "/" + ::cLoja + " não localizado."
					Else
						nOpcao := 3 //Caso nao encontre, inclui novo
					EndIf
				EndIf
			EndIf
		EndIf

		//Atualiza Codigo de Municipio
		If lRetorno
			If Empty(::cCodMun)
				If ! Empty(::cCidade) .AND. ! Empty(::cUF)
					CC2->(dbSetOrder(2))

					If CC2->(dbSeek(xFilial("CC2") + ::cCidade))
						While ! CC2->( EOF() ) .AND. CC2->(CC2_FILIAL + AllTrim(CC2_MUN)) == xFilial("CC2") + AllTrim(::cCidade)
							If AllTrim(CC2->CC2_EST) == AllTrim(::cUF)
								::cCodMun := AllTrim(CC2->CC2_CODMUN)
							EndIf

							CC2->( dbSkip() )
						End
					EndIf

					CC2->(dbSetOrder(1))
					CC2->(dbGoTop())

					aAdd(::aValues, { "A1_COD_MUN", ::cCodMun, Nil })
				EndIf
			EndIf
		EndIf

		If lRetorno
			::AddValues("A1_FILIAL", xFilial("SA1"))

			//Inicia Variavel como .F. caso o Execauto caia, o retorno sera .F.
			lRetorno := .F.

			//Gravacao do Cliente
			MsExecAuto({|a, b| MATA030(a, b)}, ::aValues, nOpcao)

			If lMsErroAuto
				lRetorno := .F.

				If ::lExibeTela
					MostraErro()
				EndIf

				If ::lGravaLog
					::cMensagem := MostraErro(::cPathLog, ::cFileLog)
				EndIf
			Else
				lRetorno := .T.

				If lReserva
					::cCodigo := SA1->A1_COD
					::cLoja := SA1->A1_LOJA
					ConfirmSX8()
				EndIf

			EndIf
		EndIf

		If ! lRetorno
			DisarmTransaction()
		EndIf

	//=========================================
	// Encerra a Transacao.
	//=========================================
	End Transaction

	::SetEnv(2, "FAT")
Return lRetorno

/*/{Protheus.doc} GetCodigo
@Description Retorna o codigo do cliente
@author Amedeo D. Paoli Filho
@version 1.0
/*/
Method GetCodigo() Class ClienteSP
Return ::cCodigo

/*/{Protheus.doc} GetLoja
@Description Retorna a loja do cliente
@author Amedeo D. Paoli Filho
@version 1.0
/*/
Method GetLoja() Class ClienteSP
Return ::cLoja