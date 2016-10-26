#Include "Totvs.ch"

/*/{Protheus.doc} IEXE0001
@description 	Integracao de Execucoes
@author 		Amedeo D. Paoli Filho
@since 			27/06/2016
@version		1.0
@return			Nil
@type 			Function
/*/
User Function IEXE0001( lSched )
	Local aIntegra	:= U_INTPQRY( Nil, Nil, "003", '0' )
	Local aRetProc	:= {}
	Local cXmlRet	:= ""
	Local nX		:= 0

	Local oXml		:= Nil
	Local cError    := ""
	Local cWarning  := ""

	Default lSched	:= .F.

	If Len( aIntegra ) > 0

		For nX := 1 To Len( aIntegra )

			//Faz o Parser no XML
			oXml := XmlParser( aIntegra[nX][10], "_", @cError, @cWarning )

			If Empty( cError )
				aRetProc := ProcRet( oXml, lSched )
			Else
				ConOut( cError )
				aRetProc := { .F., cError, "" }
			EndIf

			//Recebe retorno para atualizar XML
			//Definir retorno que devera ser gravado
			If ValType( aRetProc ) == "A"
				If aRetProc[1]

				Else

				EndIf
			EndIf

		Next nX

	EndIf

Return Nil

/*/{Protheus.doc} ProcRet
@description 	Processa retorno do XML
@author 		Amedeo D. Paoli Filho
@since 			01/07/2016
@version		1.0
@return			Nil
@type 			Function
/*/
Static Function ProcRet( oXml, lSched )
	Local aRetorno	:= Array( 3 )
	Local cContrat	:= ""
	Local cVendedor	:= ""
	Local cCliente	:= ""
	Local cData		:= ""
	Local cHora		:= ""
	Local aContrat	:= {}
	Local aExecut	:= {}
	Local nX		:= 0
	Local nY		:= 0

	Private oXmlRet	:= oXml

	If Type( "oXmlRet:_Contratos:_Contrato" ) <> "U"

		If ValType( oXmlRet:_Contratos:_Contrato ) == "A"
			aContrat	:= oXmlRet:_Contratos:_Contrato
		Else
			aContrat	:= { oXmlRet:_Contratos:_Contrato }
		EndIf

		For nY := 1 To Len( aContrat )

			cContrat	:= aContrat[ nY ]:_Codigo:Text
			cVendedor	:= aContrat[ nY ]:_Vendedor:Text
			cCliente	:= aContrat[ nY ]:_Cliente:Text

			If ValType( aContrat[ nY ]:_Execucoes:_Execucao ) == "O"
				aExecut		:= { aContrat[ nY ]:_Execucoes:_Execucao }
			Else
				aExecut		:= aContrat[ nY ]:_Execucoes:_Execucao
			EndIf

			For nX := 1 To Len( aExecut )

				//Pega data e hora da Execucao
				cData	:= aExecut[ nX ]:_Data:Text
				cHora	:= aExecut[ nX ]:_Hora:Text

				//Atualiza Execucoes


			Next nX

		Next nY
	Else
		aRetorno[1]	:= .F.
		aRetorno[2]	:= "XML DE EXECUCAO COM FORMATO INVALIDO"
		aRetorno[3]	:= ""
	EndIf

Return aRetorno
