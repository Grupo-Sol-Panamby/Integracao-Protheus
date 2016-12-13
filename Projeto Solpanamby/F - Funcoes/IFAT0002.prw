#Include "Totvs.ch"

/*/
-------------------------------------------------
Tabelas de Integracao
-------------------------------------------------
ID_EMP	- 80 - RCC

ID_FIL	- 01 - SP
		- 02 - CAMPINAS
		- 03 - PE
		- 04 - DF
		- 05 - BA
		- 06 - RJ

ID_PROC	- 001 - Clientes
		- 002 - Faturamento
		- 003 – Pedido de Venda
		- 004 – Nota Fiscal
		- 005 – Título Financeiro (PARCELA)
		- 006 - Vendedores

ID_TRANS- 1 - Incluir
		- 2 - Alterar
		- 3 - Excluir
		- 4 - Bloquear
		- 5 – Desbloquear
		- 6 – Imprimir
		- 7 – Baixar
		- 8 - Cancelar

ID_ORI	- 1 - Protheus
		- 2 - Pulsar
		- 3 - SCTV (CarTV)
		- 4 - Midia+ (TDS - TV Record)

ID_DES	- 1 - Protheus
		- 2 - Pulsar
		- 3 - SCTV (CarTV)
		- 4 - Midia+ (TDS - TV Record)

STATUS	- 0 - AGUARDANDO PROCESSAMENTO
		- 1 - PROCESSADO COM SUCESSO
		- 2 - PROCESSADO COM ERRO
		- 3 - Reservado
		- 4 - Reservado
		- 5 - RETORNO AGUARDANDO PROCESSAMENTO
		- 6 - RETORNO PROCESSADO COM SUCESSO
		- 7 - RETORNO PROCESSADO COM ERRO
		- 8 - Reservado
		- 9 - Reservado
-------------------------------------------------
/*/

/*/{Protheus.doc} IFAT0002
@description 	Integracao de Faturamento
@author 		Amedeo D. Paoli Filho
@since 			27/06/2016
@version		1.0
@return			Nil
@type 			Function
/*/
User Function IFAT0002( nID )
Local aIntegra := {}
Local aRetProc := {}
Local aRetorno := {}
Local aErro := {}
Local cError := ""
Local cWarning := ""
Local cXML := ""
Local lErro := .F.
Local lNFTit := SuperGetMv('PY_INT002',.T.,.F.) //Parametro responsável por ligar geração da NF e Títulos no financeiro na integração do faturamento com os sistemas legados das empresas de comunicação
Local lRet := .T.
Local nX := 0
Local nCount := 0
Local oXml

Default nID := 0

aIntegra := U_FQRYXML( SM0->M0_CODIGO, SM0->M0_CODFIL, "002", "0", , ,nID ) //RETORNO AGUARDANDO PROCESSAMENTO

If Len( aIntegra ) > 0
	For nX := 1 To Len( aIntegra )
		aAdd(aRetorno, {"ID_EMP"   , aIntegra[nX][2]})  //80 - RCC
		aAdd(aRetorno, {"ID_FIL"   , aIntegra[nX][3]})  //01 – SP | 02 – CAMPINAS | 03 – PE | 04 – DF | 05 – BA | 06 – RJ
		aAdd(aRetorno, {"ID_PROC"  , aIntegra[nX][4]})  //001 – FATURAMENTO
		aAdd(aRetorno, {"PROCES"   , aIntegra[nX][5]})  //DESCRIÇÃO
		aAdd(aRetorno, {"ID_TRANS" , aIntegra[nX][6]})  //1 – INCLUIR | 2 – ALTERAR | 3 – EXCLUIR
		aAdd(aRetorno, {"TRANSAC"  , aIntegra[nX][7]})  //DESCRIÇÃO
		aAdd(aRetorno, {"ID_ORI"   , aIntegra[nX][8]})  //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MÍDIA+
		aAdd(aRetorno, {"ID_DES"   , aIntegra[nX][9]})  //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MÍDIA+
		aAdd(aRetorno, {"ID_FAT"   , aIntegra[nX][10]}) //CODIGO DO FATURAMENTO

		aAdd(aErro, {"ID_EMP"   , aIntegra[nX][2]})  //80 - RCC
		aAdd(aErro, {"ID_FIL"   , aIntegra[nX][3]})  //01 – SP | 02 – CAMPINAS | 03 – PE | 04 – DF | 05 – BA | 06 – RJ
		aAdd(aErro, {"ID_PROC"  , aIntegra[nX][4]})  //001 – FATURAMENTO
		aAdd(aErro, {"PROCES"   , aIntegra[nX][5]})  //DESCRIÇÃO
		aAdd(aErro, {"ID_TRANS" , aIntegra[nX][6]})  //1 – INCLUIR | 2 – ALTERAR | 3 – EXCLUIR
		aAdd(aErro, {"TRANSAC"  , aIntegra[nX][7]})  //DESCRIÇÃO
		aAdd(aErro, {"ID_ORI"   , aIntegra[nX][8]})  //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MÍDIA+
		aAdd(aErro, {"ID_DES"   , aIntegra[nX][9]})  //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MÍDIA+
		aAdd(aErro, {"ID_FAT"   , aIntegra[nX][10]}) //CODIGO DO FATURAMENTO
		aAdd(aErro, {"ID_RET"   , ""              }) //CODIGO DO PEDIDO DE VENDA

		//Faz o Parser no XML
		oXml := XmlParser( NoAcento(aIntegra[nX][11]), "_", @cError, @cWarning )

		If Empty( cError ) .AND. Empty( cWarning )
			lErro := ProcRet( oXml, @aRetorno, @aErro, lNFTit )
		Else
			ConOut( "Erro: " + cError + "  -  Aviso: " + cWarning )
			aAdd(aErro, {"ERRO"     , "Erro: " + cError + "  -  Aviso: " + cWarning})
			lErro := .T.
		EndIf

		//Recebe retorno para atualizar XML
		//Definir retorno que devera ser gravado
		If ! lErro
			cXML += fArToXML(aRetorno, "FATURAMENTO", "1.0", "UTF-8", @nCount)

			cQuery := "UPDATE [INTEGRACAO].[dbo].[XML]" + Chr(13) + Chr(10)
			cQuery += "   SET [XML_RET] = '" + cXML + "'" + Chr(13) + Chr(10)
			cQuery += "      ,[DATERET] = '" + DtoS(Date()) + "'" + Chr(13) + Chr(10)
			cQuery += "      ,[TIMERET] = '" + Time() + "'" + Chr(13) + Chr(10)
			cQuery += "      ,[STATUS] = '5'" + Chr(13) + Chr(10)
			cQuery += "WHERE [ID] = " + lTrim(Str(aIntegra[nX][1])) + ""

			If TCSQLExec(cQuery) < 0
				ConOut( "TCSQLError() " + TCSQLError() )
				lRet := .F.
			Else
				lRet := .T.
			EndIf
		Else //ERRO
			cXML += fArToXML(aErro, "ERRO", "1.0", "UTF-8", @nCount)

			cQuery := "UPDATE [INTEGRACAO].[dbo].[XML]" + Chr(13) + Chr(10)
			cQuery += "   SET [XML_ERR] = '" + cXML + "'" + Chr(13) + Chr(10)
			cQuery += "      ,[DATERET] = '" + DtoS(Date()) + "'" + Chr(13) + Chr(10)
			cQuery += "      ,[TIMERET] = '" + Time() + "'" + Chr(13) + Chr(10)
			cQuery += "      ,[STATUS] = '2'" + Chr(13) + Chr(10)
			cQuery += "WHERE [ID] = " + lTrim(Str(aIntegra[nX][1])) + ""

			If TCSQLExec(cQuery) < 0
				ConOut( "TCSQLError() " + TCSQLError() )
				lRet := .F.
			Else
				ConOut( "Erro: " + cError + "  -  Aviso: " + cWarning )
				lRet := .F.
			EndIf
		EndIf
	Next(nX)
EndIf
Return(lRet)

/*/{Protheus.doc} ProcRet
@description 	Processa retorno do XML
@author 		Amedeo D. Paoli Filho
@since 			01/07/2016
@version		1.0
@return			Nil
@type 			Function
/*/
Static Function ProcRet( oXml, aRetorno, aErro, lNFTit )
Local cParcela := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
Local cTesPed := SuperGetMV( "SP_TESPVPU", Nil, "712" )
Local cCondPag := SuperGetMV( "SP_CONDPPU", Nil, "999" )
Local cProduto := SuperGetMV( "SP_PRODPPU", Nil, "000001" )
Local cSerie := SuperGetMV( "SP_SERIPUL", Nil, "UNI" )
Local lRetErro := .F.

Local aContFat := {}
Local aItemPed := {}
Local aItemFat := {}
Local aNotas := {}
Local aParcela := {}
Local aNF := {}
Local cPedido := ""
Local cFatura := ""
Local cCC := ""

//Local nItem := 0
Local nItFat := 0
Local nFat := 0
Local nNf := 0
Local nX := 0
Local nF := 0
Local nI := 0

Local oPedido := Nil
Local oNotaFis := Nil

Local dVigIni := CtoD("")
Local dVigFim := CtoD("")

If ValType( oXml:_Faturamento ) <> "U"
	If ValType( oXml:_Faturamento ) == "A"
		aContFat := oXml:_Faturamento
	Else
		aContFat := { oXml:_Faturamento }
	EndIf
Else
	lRetErro := .T.
	aAdd(aErro, {"ERRO"     , "Erro: " + "XML DE FATURAMENTO COM FORMATO INVALIDO"})
EndIf

If cFilAnt == "01"
	cCC := "41103" // comercial sp
ElseIf cFilAnt == "02"
	cCC := "41203" // comercial campinas (FM)
ElseIf cFilAnt == "03"
	cCC := "41703" // comercial pe
ElseIf cFilAnt == "04"
	cCC := "41403" // comercial df
ElseIf cFilAnt == "05"
	cCC := "41603" // comercial ba
ElseIf cFilAnt == "06"
	cCC := "41503" // comercial rj
Else
	cCC := "41803" // comercial
EndIf

SA1->( dbSetOrder(1) ) //A1_FILIAL+A1_COD+A1_LOJA
SB1->( dbSetOrder(1) ) //B1_FILIAL+B1_COD
SC5->( dbSetorder(1) ) //C5_FILIAL+C5_NUM
SE1->( dbSetOrder(2) ) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
SF2->( dbSetOrder(1) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
SF4->( dbSetOrder(1) ) //F4_FILIAL+F4_CODIGO

For nX := 1 To Len( aContFat )
	cFatura := aContFat[ nX ]:_ID_FAT:Text
	cCliente := Left( aContFat[ nX ]:_Id_Cli:Text, 6 )
	cLoja := Right( aContFat[ nX ]:_Id_Cli:Text, 2 )
	oPedido := Nil
	cPedido := ""
	aItemPed := {}
	aItemFat := {}
	aNotas := {}
	aParcela := {}

	dVigIni := CtoD( aContFat[ nX ]:_Vig_Ini:Text )
	dVigFim := CtoD( aContFat[ nX ]:_Vig_Fim:Text )

	//Verifica notas fiscais para faturamento
	//Armazena parcelas do pedido
	If ValType( aContFat[ nX ]:_Notas_Fiscais:_Nota_Fiscal ) == "A"
		aNotas := aContFat[ nX ]:_Notas_Fiscais:_Nota_Fiscal
	Else
		aNotas := { aContFat[ nX ]:_Notas_Fiscais:_Nota_Fiscal }
	EndIf

	For nNf := 1 To Len( aNotas )  // **** VERIFICAR CÓDIGO ****
		//Pega parcelas
		If ValType( aNotas[ nNf ]:_Parcelas:_Parcela ) == "A"
			aParcela := aNotas[ nNf ]:_Parcelas:_Parcela
		Else
			aParcela := { aNotas[ nNf ]:_Parcelas:_Parcela }
		EndIf
	Next(nNf)

	//Verifica se precisa gerar pedido ou só faturar o pedido já gerado
	If GeraPed( cFatura, cCliente, cLoja, @cPedido )
		//Armazena itens
		If ValType( aContFat[ nX ]:_Itens:_Item ) == "A"
			aItemPed := aContFat[ nX ]:_Itens:_Item
		Else
			aItemPed := { aContFat[ nX ]:_Itens:_Item }
		EndIf

		//Instancia Classe
		oPedido := PedVenda():New()

		SA1->( dbSeek( xFilial("SA1") + oXML:_FATURAMENTO:_ID_CLI:Text ) )

		//Armazena Cabecalho
		oPedido:AddCabec( "C5_FILIAL"	, xFilial("SC5") 							)
		oPedido:AddCabec( "C5_NUM"		, oPedido:cPedido 							)
		oPedido:AddCabec( "C5_TIPO"		, "N"	 									)
		oPedido:AddCabec( "C5_ORIFAT"	, "DIR" 									)
		oPedido:AddCabec( "C5_EMISSAO"	, dDataBase 								)
		oPedido:AddCabec( "C5_MOEDA"	, 1 										)
		oPedido:AddCabec( "C5_DATA5"	, dVigIni 									)
		oPedido:AddCabec( "C5_DATA6"	, dVigFim 									)
		oPedido:AddCabec( "C5_XCODEXT"	, aContFat[ nX ]:_ID_FAT:Text 				)
		oPedido:AddCabec( "C5_PI2"		, aContFat[ nX ]:_ID_FAT:Text 				)
		oPedido:AddCabec( "C5_PI"		, aContFat[ nX ]:_ID_FAT:Text 				)
		oPedido:AddCabec( "C5_CLIENTE"	, Left( aContFat[ nX ]:_Id_Cli:Text, 6 ) 	)
		oPedido:AddCabec( "C5_LOJACLI"	, Right( aContFat[ nX ]:_Id_Cli:Text, 2 ) 	)
		oPedido:AddCabec( "C5_TIPOCLI"	, SA1->A1_TIPO 								)
		oPedido:AddCabec( "C5_AGENCIA"	, Left( aContFat[ nX ]:_Id_Age:Text, 6 ) 	)
		oPedido:AddCabec( "C5_AGLOJA"	, Right( aContFat[ nX ]:_Id_Age:Text, 2 ) 	)
		oPedido:AddCabec( "C5_EMISSOR"	, "" 										)
		oPedido:AddCabec( "C5_EMLOJA"	, "" 										)
		oPedido:AddCabec( "C5_DESCAGE"	, Val( aContFat[ nX ]:_Desc_Age:Text ) 		)
		oPedido:AddCabec( "C5_CONDPAG"	, cCondPag 									)
		oPedido:AddCabec( "C5_CC"		, cCC 										)
		oPedido:AddCabec( "C5_VEND1"	, aContFat[ nX ]:_Id_Ven:Text 				)
		oPedido:AddCabec( "C5_SITCOBR"	, "0" 										)
		oPedido:AddCabec( "C5_MENPAD"	, ""										)
		oPedido:AddCabec( "C5_MENNOTA"	, ""										)
		oPedido:AddCabec( "C5_MENS02"	, ""										)
		oPedido:AddCabec( "C5_MENS03"	, ""										)
		oPedido:AddCabec( "C5_MENS04"	, ""										)
		oPedido:AddCabec( "C5_MENS05"	, ""										)
		oPedido:AddCabec( "C5_MENS06"	, ""										)

		//Adiciona formas de pagamento
		For nF := 1 To Len( aParcela )
			oPedido:AddCabec( "C5_DATA" + SubStr( cParcela, nF, 1 )	, CtoD( aParcela[ nF ]:_Dt_Venc:Text ) 		)
			oPedido:AddCabec( "C5_PARC" + SubStr( cParcela, nF, 1 )	, Val( aParcela[ nF ]:_Vlr_Liq:Text ) 		)
		Next nF

		For nI := 1 To Len( aItemPed )
//			nItem ++

			SB1->( dbSeek( xFilial("SB1") + cProduto ) )
			SF4->( dbSeek( xFilial("SF4") + cTesPed ) )

			oPedido:AddItem( "C6_FILIAL"	, xFilial("SC6") 							)
			oPedido:AddItem( "C6_NUM"		, oPedido:cPedido 							)
			oPedido:AddItem( "C6_ITEM"		, aItemPed[ nI ]:_SEQ:Text					) //StrZero( nItem, TamSx3("C6_ITEM")[1] )
			oPedido:AddItem( "C6_PRODUTO"	, cProduto 									)
			oPedido:AddItem( "C6_UM"		, SB1->B1_UM 								)
			oPedido:AddItem( "C6_QTDVEN"	, Val( aItemPed[ nI ]:_Qtde:Text )			)
			oPedido:AddItem( "C6_PRUNIT"	, Val( aItemPed[ nI ]:_Vlr_Unit:Text )		)
			oPedido:AddItem( "C6_PRCVEN"	, Val( aItemPed[ nI ]:_Vlr_Unit:Text )		)
			oPedido:AddItem( "C6_TES"		, cTesPed 									)
			oPedido:AddItem( "C6_CF"		, SF4->F4_CF 								)
			oPedido:AddItem( "C6_LOCAL"		, SB1->B1_LOCPAD 							)
			oPedido:AddItem( "C6_CHASSI"	, "000000" 									)
			oPedido:AddItem( "C6_CLASFIS"	, SF4->F4_SITTRIB 							)
			oPedido:AddItem( "C6_TURNO"		, "-" 										)
			oPedido:SetItem()
		Next(nI)

		If oPedido:Gravacao(3)
			cPedido := oPedido:GetNumero()
		Else
			lRetErro := .T.
			aAdd(aErro, {"ERRO"     , "Erro: " + oPedido:GetMensagem()})
		EndIf
	EndIf

	//Verifica se pedido sera faturado (Caso retorne numero de criacao / ja criado anteriormente)
	If ! Empty( cPedido ) .AND. lNFTit
		aAdd(aRetorno, {"ID_RET"   , cPedido}) //CODIGO DO PEDIDO DE VENDA

		If SC5->( dbSeek( xFilial("SC5") + cPedido ) )
			For nFat := 1 To Len( aNotas )
				//Instancia Classe de faturamento
				oNotaFis := NFSaida():New()

				//Armazena Cabecalho
				oNotaFis:AddCabec( "C9_FILIAL"	, xFilial("SC9") 	)
				oNotaFis:AddCabec( "C9_CLIENTE"	, SC5->C5_CLIENT 	)
				oNotaFis:AddCabec( "C9_LOJA"	, SC5->C5_LOJAENT 	)
				oNotaFis:AddCabec( "C9_SERIENF"	, cSerie 			)

				//Armazena itens a faturar
				If ValType( aNotas[ nFat ]:_Itens:_Item ) == "A"
					aItemFat := aNotas[ nFat ]:_Itens:_Item
				Else
					aItemFat := { aNotas[ nFat ]:_Itens:_Item }
				EndIf

				For nItFat := 1 To Len( aItemFat )
					//após a geração do pedido o indice é alterado
					SC6->( dbSetorder(1) ) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
					If SC6->( dbSeek( xFilial("SC6") + cPedido + aItemFat[ nItFat ]:_SEQ:Text + PadR( cProduto, TamSx3("C6_PRODUTO")[1] ) ) ) //aItemFat[ nItFat ]:_ID_Prod:Text
						//Armazena Itens
						oNotaFis:AddItem( "C9_PEDIDO"	, SC6->C6_NUM							)
						oNotaFis:AddItem( "C9_ITEM"		, SC6->C6_ITEM							)
						oNotaFis:AddItem( "C9_PRODUTO"	, SC6->C6_PRODUTO						)
						oNotaFis:AddItem( "C9_QTDLIB"	, Val( aItemFat[ nItFat ]:_Qtde:Text )	)
						oNotaFis:SetItem()
					Else
						lRetErro := .T.
						aAdd(aErro, {"ERRO"     , "Erro: " + "Produto: " + cProduto /*aItemFat[ nItFat ]:_ID_Prod:Text*/ + " Nao encontrado no pedido de vendas"})
					EndIf
				Next(nItFat)

				//Chama a gravacao da Nota Fiscal
				If oNotaFis:Gravacao(3)
					aAdd(aNF, {aNotas[ nFat ]:_ID_NF:Text, oNotaFis:GetNumero()})
				Else
					lRetErro := .T.
					aAdd(aErro, {"ERRO"     , "Erro: " + NoAcento(oNotaFis:GetMensagem())})
				EndIf
			Next(nFat)
		Else
			lRetErro := .T.
			aAdd(aErro, {"ERRO"     , "Erro: " + "Pedido: " + cPedido + " nao encontrado"})
		EndIf
	Else
		aAdd(aRetorno, {"NOTAS_FISCAIS", {"NOTA_FISCAL", {{"ID_NF", "0"}, {"ID_RET", "0"}}, {"PARCELAS", {"PARCELA", {{"ID_TIT", "0"}, {"ID_RET", "0"}}}} }})
	EndIf

	If Len(aNF) > 0
		aAdd(aRetorno, {"NOTAS_FISCAIS", {}})
		For nNF := 1 To Len(aNF)
			If nNF == 1
				aRetorno[Len(aRetorno)][2] := {"NOTA_FISCAL", {{"ID_NF", aNF[nNF][1]}, {"ID_RET", aNF[nNF][2]}}}
			Else
				aAdd(aRetorno[Len(aRetorno)][2], {"NOTA_FISCAL", {{"ID_NF", aNF[nNF][1]}, {"ID_RET", aNF[nNF][2]}}})
			EndIf

			If SF2->(dbSeek(xFilial("SF2") + aNF[nNF][2]))
				RecLock("SF2", .F.)
					SF2->F2_XCODEXT := aNF[nNF][1]
				SF2->(MsUnLock())
			EndIf

			//Busca Titulos gerados
			If SE1->(dbSeek(xFilial("SE1") + SC5->(C5_CLIENT + C5_LOJAENT + C5_ORIFAT) + aNF[Len(aNF)][2]))
				aAdd(aRetorno[Len(aRetorno)][2][Len(aRetorno[Len(aRetorno)][2])], {"PARCELAS", {}})
				nCountTit := 0

				While ! SE1->(EOF()) .AND. SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM) == xFilial("SE1") + SC5->(C5_CLIENT + C5_LOJAENT + C5_ORIFAT) + aNF[Len(aNF)][2]
					nCountTit ++

					If nCountTit == 1
						aRetorno[Len(aRetorno)][2][Len(aRetorno[Len(aRetorno)][2])][Len(aRetorno[Len(aRetorno)][2][Len(aRetorno[Len(aRetorno)][2])])][2] := {"PARCELA", {{"ID_TIT", aParcela[ nCountTit ]:_ID_TIT:Text}, {"ID_RET", SE1->(E1_NUM + E1_PARCELA)}}}
					Else
						aAdd(aRetorno[Len(aRetorno)][2][Len(aRetorno[Len(aRetorno)][2])][Len(aRetorno[Len(aRetorno)][2][Len(aRetorno[Len(aRetorno)][2])])][2], {"PARCELA", {{"ID_TIT", aParcela[ nCountTit ]:_ID_TIT:Text}, {"ID_RET", SE1->(E1_NUM + E1_PARCELA)}}})
					EndIf

					RecLock("SE1", .F.)
						SE1->E1_XCODEXT := aParcela[ nCountTit ]:_ID_TIT:Text
					SE1->(MsUnLock())

					SE1->(dbSkip())
				EndDo
			EndIf
		Next(nNF)
	Else
		aAdd(aRetorno, {"NOTAS_FISCAIS", {"NOTA_FISCAL", {{"ID_NF", "0"}, {"ID_RET", "0"}}, {"PARCELAS", {"PARCELA", {{"ID_TIT", "0"}, {"ID_RET", "0"}}}} }})

		lRetErro := .T.
	EndIf
Next(nX)
Return(lRetErro)

/*/{Protheus.doc} GeraPed
@description 	Verifica se pedido de venda ja existe
@author 		Amedeo D. Paoli Filho
@version		1.0
@return			Nil
@type 			Function
/*/
Static Function GeraPed( cFatura, cCliente, cLoja, cPedido )
Local cAliSC5 := GetNextAlias()
Local lRetorno := .F.

BeginSQL Alias cAliSC5
	SELECT C5_NUM
	FROM %Table:SC5%
	WHERE %NotDel%
	AND C5_FILIAL = %Exp:xFilial("SC5")%
	AND C5_PI = %Exp:cFatura%
	AND C5_CLIENTE = %Exp:cCliente%
	AND C5_LOJACLI = %Exp:cLoja%
EndSQL

If ( cAliSC5 )->( EOF() )
	lRetorno := .T.
Else
	cPedido := ( cAliSC5 )->C5_NUM
EndIf

( cAliSC5 )->( dbCloseArea() )
Return(lRetorno)

/*/{Protheus.doc} NoAcento
@description 	Remove acentos da String
@version		1.0
@return			Nil
@type 			Function
/*/
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
Next nX
Return(cString)