#Include "Totvs.ch"

/*/{Protheus.doc} IFAT0001
@description 	Integracao de Faturamento
@author 		Amedeo D. Paoli Filho
@since 			27/06/2016
@version		1.0
@return			Nil
@type 			Function
/*/
User Function IFAT0001( nID )
Local aIntegra := {}
//Local aRetProc	:= {}
//Local cXmlRet	:= ""
Local cError := ""
Local cWarning := ""
Local nX := 0
Local oXML

Default nID := 0

aIntegra := U_INTPQRY( SM0->M0_CODIGO, SM0->M0_CODFIL, "002", "0", , ,nID ) //RETORNO AGUARDANDO PROCESSAMENTO

If Len( aIntegra ) > 0
//		cXmlRet	:= "<Faturamento>"
//		cXmlRet	+= "<Contratos>"

	For nX := 1 To Len( aIntegra )
		//Faz o Parser no XML
		oXML := XmlParser( NoAcento(aIntegra[nX][11]), "_", @cError, @cWarning )

		If Empty( cError ) .AND. Empty( cWarning )
			aRetProc := ProcRet( oXML )
		Else
//			ConOut( cError )
//			aRetProc := { .F., cError, "" }
		EndIf

//			cXmlRet	+= "<Contrato>"

			//Recebe retorno para atualizar XML
			//Definir retorno que devera ser gravado
//			If ValType( aRetProc ) == "A"
//				If aRetProc[1]

//				Else

//				EndIf
//			EndIf

//			cXmlRet	+= "</Contrato>"
	Next(nX)

//		cXmlRet	+= "</Contratos>"
//		cXmlRet	+= "</Faturamento>"

EndIf
Return(Nil)

/*/{Protheus.doc} ProcRet
@description 	Processa retorno do XML
@author 		Amedeo D. Paoli Filho
@since 			01/07/2016
@version		1.0
@return			Nil
@type 			Function
/*/
Static Function ProcRet( oXML )
Local aFaturamento := {}
Local nX := 0
Local oPedido
Local oXMLTmp := oXML

//	Local cTesPed	:= SuperGetMV( "SP_TESPVPU", Nil, "501" )
//	Local aRetorno	:= Array( 3 )

//	Local nItem		:= 0

If ValType( oXML:_Contrato ) <> "U"
	/* **** CLIENTE SA1 **** */
	SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	If ! SA1->( dbSeek( xFilial("SA1") + oXML:_CONTRATO:_CLIENTE:Text ) )
//		lIntegra := .F.
//		cErroInt += "Cliente ID_ENT: " + oXML:_CONTRATO:_CLIENTE::Text + " - ID_ERP: " + oXML:_CONTRATO:_CLIENTE:Text + " não cadastrado no Protheus." + Chr(13) + Chr(10)
//		ConOut( "Cliente ID_ENT: " + oXML:_CONTRATO:_CLIENTE::Text + " - ID_ERP: " + oXML:_CONTRATO:_CLIENTE:Text + " não cadastrado no Protheus." )
	EndIf
	/* **** AGENCIA SA1 **** */
	If ! SA1->( dbSeek( xFilial("SA1") + oXML:_CONTRATO:_AGENCIA:Text ) )
//		lIntegra := .F.
//		cErroInt += "Agencia ID_ENT: " + oXML:_CONTRATO:_AGENCIA:Text + " - ID_ERP: " + oXML:_CONTRATO:_AGENCIA:Text + " não cadastrado no Protheus." + Chr(13) + Chr(10)
//		ConOut( "Agencia ID_ENT: " + oXML:_CONTRATO:_AGENCIA:Text + " - ID_ERP: " + oXML:_CONTRATO:_AGENCIA:Text + " não cadastrado no Protheus." )
	EndIf

	XmlNode2Arr( oXMLTmp:_CONTRATO, "_CONTRATO" )
	aFaturamento := oXMLTmp:_CONTRATO[1]
Else
//	aRetorno[1]	:= .F.
//	aRetorno[2]	:= "XML DE CONTRATO COM FORMATO INVALIDO"
//	aRetorno[3]	:= ""
EndIf

For nX := 1 To Len( aFaturamento )

	//Instancia Classe
	oPedido := PedVenda():New()
	//Armazena Cabecalho
	oPedido:AddCabec( "C5_FILIAL"	, xFilial("SC5") )
	oPedido:AddCabec( "C5_ORIFAT"	, "DIR" )
	oPedido:AddCabec( "C5_EMISSAO"	, dDataBase )
	oPedido:AddCabec( "C5_MOEDA"	, "1" )
	oPedido:AddCabec( "C5_DATA5"	, oXML:_CONTRATO:_VIGENCIA:_INICIO:Text )
	oPedido:AddCabec( "C5_DATA6"	, oXML:_CONTRATO:_VIGENCIA:_TERMINO:Text )
	oPedido:AddCabec( "C5_PI2"		, oXML:_CONTRATO:_CODIGO:Text )
	oPedido:AddCabec( "C5_PI"		, oXML:_CONTRATO:_CODIGO:Text )
	oPedido:AddCabec( "C5_CLIENTE"	, Left(oXML:_CONTRATO:_CLIENTE:Text,6) )
	oPedido:AddCabec( "C5_LOJACLI"	, Right(oXML:_CONTRATO:_CLIENTE:Text,2) )
	SA1->( dbSeek( xFilial("SA1") + oXML:_CONTRATO:_CLIENTE:Text ) )
	oPedido:AddCabec( "C5_TIPOCLI"	, SA1->A1_TIPO )
	oPedido:AddCabec( "C5_AGENCIA"	, Left(oXML:_CONTRATO:_AGENCIA:Text,6) )
	oPedido:AddCabec( "C5_AGLOJA"	, Right(oXML:_CONTRATO:_AGENCIA:Text,2) )
	oPedido:AddCabec( "C5_EMISSOR"	, "" )
	oPedido:AddCabec( "C5_EMLOJA"	, "" )
	oPedido:AddCabec( "C5_DESCAGE"	, oXML:_CONTRATO:_DESCONTO_AGENCIA:Text )
	oPedido:AddCabec( "C5_CONDPAG"	, oXML:_CONTRATO:_FORMA_PAGTO_AGENCIA:Text )
	oPedido:AddCabec( "C5_VEND1"	, oXML:_CONTRATO:_CONTATO:Text )
	oPedido:AddCabec( "C5_TIPO"		, "N" )
	oPedido:AddCabec( "C5_MENPAD"	,  )
	oPedido:AddCabec( "C5_MENNOTA"	,  )
	oPedido:AddCabec( "C5_MENS02"	,  )
	oPedido:AddCabec( "C5_MENS03"	,  )
	oPedido:AddCabec( "C5_MENS04"	,  )
	oPedido:AddCabec( "C5_MENS05"	,  )
	oPedido:AddCabec( "C5_MENS06"	,  )

//					nItem ++
//
//					oPedido:AddItem( "C6_FILIAL"	, xFilial("SC6")							)
//					oPedido:AddItem( "C6_ITEM"		, StrZero( nItem, TamSx3("C6_ITEM")[1] )	)
//					oPedido:AddItem( "C6_PRODUTO"	, ZCB->ZCB_PRODUT							)
//					oPedido:AddItem( "C6_QTDVEN"	, 1											)
//					oPedido:AddItem( "C6_PRCVEN"	, 1											)
//					oPedido:AddItem( "C6_TES"		, cTesPed									)
//					oPedido:SetItem()

//				If oPedido:Gravacao(3)
//					FatPed( oPedido:GetNumero(), @aRetorno )
//				Else
//					aRetorno[1]	:= .F.
//					aRetorno[2]	:= oPedido:GetMensagem()
//					aRetorno[3]	:= ""
//				EndIf
//			Else
//				aRetorno[1]	:= .F.
//				aRetorno[2]	:= "CONTRATO " + cContrato + " SEM ITENS, VERIFIQUE"
//				aRetorno[3]	:= ""
//			EndIf
//		Else
//			aRetorno[1]	:= .F.
//			aRetorno[2]	:= "CONTRATO " + cContrato + " NAO ENCONTRADO, VERIFIQUE"
//			aRetorno[3]	:= ""
//		EndIf
Next(nX)
Return(aRetorno)

/*/{Protheus.doc} FatPed
@description 	Fatura pedido de venda gerado
@author 		Amedeo D. Paoli Filho
@since 			01/07/2016
@version		1.0
@return			Nil
@type 			Function
/*/
Static Function FatPed( cPedido, aRetorno )
	Local cSerie	:= SuperGetMV( "SP_SERIPUL", Nil, "001" )
	Local oNotaFis	:= Nil

	DbSelectarea("SC5")
	SC5->( DbSetorder(1) )
	If SC5->( DbSeek( xFilial("SC5") + cPedido ) )
		//Instancia Classe de faturamento
		oNotaFis:NFSaida():New()

		//Armazena Cabecalho
		oNotaFis:AddCabec( "C9_FILIAL"	, xFilial("SC9") 	)
		oNotaFis:AddCabec( "C9_CLIENTE"	, SC5->C5_CLIENT 	)
		oNotaFis:AddCabec( "C9_LOJA"	, SC5->C5_LOJAENT 	)
		oNotaFis:AddCabec( "C9_SERIENF"	, cSerie 			)

		DbSelectarea("SC6")
		SC6->( DbSetorder(1) )
		If SC6->( DbSeek( xFilial("SC6") + SC5->C5_NUM ) )
			While !SC6->( Eof() )	.And.	SC6->C6_FILIAL == xFilial("SC6") .And.;
											SC6->C6_NUM == SC5->C5_NUM
				//Armazena Itens
				oNotaFis:AddItem( "C9_PEDIDO"	, SC6->C6_NUM		)
				oNotaFis:AddItem( "C9_ITEM"		, SC6->C6_ITEM		)
				oNotaFis:AddItem( "C9_PRODUTO"	, SC6->C6_PRODUTO	)
				oNotaFis:AddItem( "C9_QTDLIB"	, SC6->C6_QTDVEN	)
				oNotaFis:SetItem()

				SC6->( DbSkip() )
			End

			//Chama a gravacao da Nota Fiscal
			If oNotaFis:Gravacao(3)
				aRetorno[1]	:= .T.
				aRetorno[2]	:= ""
				aRetorno[3]	:= oNotaFis:GetNumero() + " / " + oNotaFis:GetSerie()
			Else
				aRetorno[1]	:= .F.
				aRetorno[2]	:= oNotaFis:GetMensagem()
				aRetorno[3]	:= ""
			EndIf
		EndIf
	EndIf
Return(Nil)

Static Function NoAcento(cString)
Local cChar := ""
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ"
Local cTio := "ãõÃÕ"
Local cCecid := "çÇ"
Local cMaior := "&lt;"
Local cMenor := "&gt;"
Local nX := 0
Local nY := 0

For nX := 1 To Len(cString)
	cChar := SubStr(cString, nX, 1)
	If cChar $ cAgudo + cCircu + cTrema + cCecid + cTio + cCrase
		nY := At(cChar, cAgudo)
		If nY > 0
			cString := StrTran(cString, cChar, SubStr(cVogal, nY, 1))
		EndIf

		nY:= At(cChar, cCircu)
		If nY > 0
			cString := StrTran(cString, cChar, SubStr(cVogal, nY, 1))
		EndIf

		nY:= At(cChar, cTrema)
		If nY > 0
			cString := StrTran(cString, cChar, SubStr(cVogal, nY, 1))
		EndIf

		nY:= At(cChar, cCrase)
		If nY > 0
			cString := StrTran(cString, cChar, SubStr(cVogal, nY, 1))
		EndIf

		nY:= At(cChar, cTio)
		If nY > 0
			cString := StrTran(cString, cChar, SubStr("aoAO", nY, 1))
		EndIf

		nY:= At(cChar, cCecid)
		If nY > 0
			cString := StrTran(cString, cChar, SubStr("cC", nY, 1))
		EndIf
	EndIf
Next(nX)

If cMaior $ cString
	cString := StrTran( cString, cMaior, "" )
EndIf
If cMenor $ cString
	cString := StrTran( cString, cMenor, "" )
EndIf

cString := StrTran( cString, Chr(13) + Chr(10), " " )

For nX := 1 To Len(cString)
	cChar := SubStr(cString, nX, 1)
	If (Asc(cChar) < 32 .OR. Asc(cChar) > 123) .AND. ! cChar $ '|'
		cString := StrTran(cString, cChar, ".")
	EndIf
Next(nX)
Return(cString)