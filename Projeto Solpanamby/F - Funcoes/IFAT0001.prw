#Include "Totvs.ch"

/*/{Protheus.doc} IFAT0001
@description 	Integracao de Faturamento
@author 		Amedeo D. Paoli Filho
@since 			27/06/2016
@version		1.0
@return			Nil
@type 			Function
/*/
User Function IFAT0001( lSched )
	Local aIntegra	:= U_INTPQRY( Nil, Nil, "004", '0' )
	Local aRetProc	:= {}
	Local cXmlRet	:= ""
	Local nX		:= 0

	Local oXml		:= Nil
	Local cError    := ""
	Local cWarning  := ""
	
	Default lSched	:= .F.
	
	If Len( aIntegra ) > 0
		
		cXmlRet	:= "<Faturamento>"
		cXmlRet	+= "<Contratos>"
		
		For nX := 1 To Len( aIntegra )
			
			//Faz o Parser no XML
			oXml := XmlParser( aIntegra[nX][10], "_", @cError, @cWarning )
		
			If Empty( cError )
				aRetProc := ProcRet( oXml, lSched )
			Else
				ConOut( cError )
				aRetProc := { .F., cError, "" }
			EndIf
			
			cXmlRet	+= "<Contrato>"

			//Recebe retorno para atualizar XML
			//Definir retorno que devera ser gravado
			If ValType( aRetProc ) == "A"
				If aRetProc[1]
				
				Else
				
				EndIf
			EndIf
			
			cXmlRet	+= "</Contrato>"
			
		Next nX
	
		cXmlRet	+= "</Contratos>"
		cXmlRet	+= "</Faturamento>"

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
	Local cTesPed	:= SuperGetMV( "SP_TESPVPU", Nil, "501" )
	Local aRetorno	:= Array( 3 )
	Local oPedido	:= Nil
	Local cContrato	:= ""
	Local aContrato	:= {}
	Local nItem		:= 0
	Local nX		:= 0
	
	Private oXmlRet	:= oXml
	
	If Type( "oXmlRet:_Faturamento:_Contratos" ) <> "U"
		If ValType( oXmlRet:_Faturamento:_Contratos:_Contrato ) == "A"
			aContrato := oXmlRet:_Faturamento:_Contratos:_Contrato
		Else
			aContrato := { oXmlRet:_Faturamento:_Contratos:_Contrato }
		EndIf
	Else
		aRetorno[1]	:= .F.
		aRetorno[2]	:= "XML DE CONTRATO COM FORMATO INVALIDO"
		aRetorno[3]	:= ""
	EndIf
	
	For nX := 1 To Len( aContrato )
		
		cContrato	:= aContrato[ nX ]:_Codigo:Text
	
		//Posiciona AV
		DbSelectarea("ZCA")
		ZCA->( DbSetorder(1) )
		If ZCA->( DbSeek( xFilial("ZCA") + cContrato ) )
			
			//Instancia Classe
			oPedido	:= PedVenda():New()
			
			//Armazena Cabecalho
			oPedido:AddCabec( "C5_FILIAL"	, xFilial("SC5") 	)
			oPedido:AddCabec( "C5_CLIENTE"	, ZCA->ZCA_CLIENTE	)
			oPedido:AddCabec( "C5_LOJACLI"	, ZCA->ZCA_LOJA		)
			oPedido:AddCabec( "C5_CONDPAG"	, ZCA->ZCA_CONDPG	)
			
			DbSelectarea("ZCB")
			ZBC->( DbSetorder(1) )
			If ZCB->( DbSeek( xFilial("ZCB") + ZCA->ZCA_CODAV ) )
				While ZCB->( Eof() ) .And. 	ZCB->ZCB_FILIAL == xFilial("ZCB") .And.;
											ZCB->ZCB_CODAV == ZCA->ZCA_CODAV
					nItem ++
					
					oPedido:AddItem( "C6_FILIAL"	, xFilial("SC6")							)
					oPedido:AddItem( "C6_ITEM"		, StrZero( nItem, TamSx3("C6_ITEM")[1] )	)
					oPedido:AddItem( "C6_PRODUTO"	, ZCB->ZCB_PRODUT							)
					oPedido:AddItem( "C6_QTDVEN"	, 1											)
					oPedido:AddItem( "C6_PRCVEN"	, 1											)
					oPedido:AddItem( "C6_TES"		, cTesPed									)
					oPedido:SetItem()
					
					ZCB->( DbSkip() )
				End
				
				If oPedido:Gravacao(3)
					FatPed( oPedido:GetNumero(), @aRetorno )
				Else
					aRetorno[1]	:= .F.
					aRetorno[2]	:= oPedido:GetMensagem()
					aRetorno[3]	:= ""
				EndIf
				
			Else
				aRetorno[1]	:= .F.
				aRetorno[2]	:= "CONTRATO " + cContrato + " SEM ITENS, VERIFIQUE"
				aRetorno[3]	:= ""
			EndIf
						
		Else
			aRetorno[1]	:= .F.
			aRetorno[2]	:= "CONTRATO " + cContrato + " NAO ENCONTRADO, VERIFIQUE"
			aRetorno[3]	:= ""
		EndIf
		
	Next nX
	
Return aRetorno

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
	
Return Nil
