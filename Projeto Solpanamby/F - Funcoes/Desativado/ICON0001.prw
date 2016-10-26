#Include "Totvs.ch"

/*/{Protheus.doc} ICON0001
@description 	Integracao de Contratos
@author 		Alexandre Soares Reis / Amedeo D. Paoli Filho
@since 			27/06/2016
@version		1.0
@return			Nil
@type 			Function
/*/
User Function ICON0001( lSched )
Local aIntegra 	:= U_INTPQRY( Nil, Nil, "002", '0' )
Local lIntegra 	:= .T.
Local cErroInt 	:= ""
Local cError 	:= ""
Local cWarning 	:= ""

Local aProduto	:= {}
Local aGrade	:= {}

Local nValTot	:= 0
Local nItem		:= 0
Local nX 		:= 0

Private oXml 	:= Nil

Default lSched	:= .F.

If ! Empty(aIntegra)
	For nX := 1 To Len( aIntegra )

		oXml := XmlParser( aIntegra[nX][10], "_", @cError, @cWarning )

		If Empty(cError)
			/* **** VALIDAÇÕES **** */
			/* **** CLIENTE ZCK **** */
			ZCK->(dbSetOrder(1)) //CK_FILIAL+\CK_CODIGO
			If ! ZCK->( dbSeek( xFilial("ZCK") + oXML:_CONTRATO:_TIPO_AV:Text ) )
				lIntegra := .F.
				cErroInt += "Tipo de AV TIPO_AV: " + oXML:_CONTRATO:_TIPO_AV:Text + " não cadastrado no Protheus." + Chr(13) + Chr(10)
				ConOut( "Tipo de AV TIPO_AV: " + oXML:_CONTRATO:_TIPO_AV:Text + " não cadastrado no Protheus." )
			EndIf
			/* **** CLIENTE SA1 **** */
			SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
			If ! SA1->( dbSeek( xFilial("SA1") + oXML:_CONTRATO:_CLIENTE:_ID_ENT:Text ) )
				lIntegra := .F.
				cErroInt += "Cliente ID_ENT: " + oXML:_CONTRATO:_CLIENTE:_ID_ENT:Text + " - ID_ERP: " + oXML:_CONTRATO:_CLIENTE:_ID_ERP:Text + " não cadastrado no Protheus." + Chr(13) + Chr(10)
				ConOut( "Cliente ID_ENT: " + oXML:_CONTRATO:_CLIENTE:_ID_ENT:Text + " - ID_ERP: " + oXML:_CONTRATO:_CLIENTE:_ID_ERP:Text + " não cadastrado no Protheus." )
			EndIf
			/* **** AGENCIA SA1 **** */
			If ! SA1->( dbSeek( xFilial("SA1") + oXML:_CONTRATO:_AGENCIA:_ID_ENT:Text ) )
				lIntegra := .F.
				cErroInt += "Agencia ID_ENT: " + oXML:_CONTRATO:_AGENCIA:_ID_ENT:Text + " - ID_ERP: " + oXML:_CONTRATO:_AGENCIA:_ID_ERP:Text + " não cadastrado no Protheus." + Chr(13) + Chr(10)
				ConOut( "Agencia ID_ENT: " + oXML:_CONTRATO:_AGENCIA:_ID_ENT:Text + " - ID_ERP: " + oXML:_CONTRATO:_AGENCIA:_ID_ERP:Text + " não cadastrado no Protheus." )
			EndIf
			/* **** ORIGEM FATURAMENTO SZ1 **** */
			SZ1->(dbSetOrder(1)) //Z1_FILIAL+Z1_COD
			If ! SZ1->( dbSeek( xFilial("SZ1") + oXML:_CONTRATO:_ORIGEM_FATURAMENTO:Text ) )
				lIntegra := .F.
				cErroInt += "Origem Faturamento ORIGEM_FATURAMENTO: " + oXML:_CONTRATO:_AGENCIA:_ORIGEM_FATURAMENTO:Text + " não cadastrado no Protheus." + Chr(13) + Chr(10)
				ConOut( "Origem Faturamento ORIGEM_FATURAMENTO: " + oXML:_CONTRATO:_AGENCIA:_ORIGEM_FATURAMENTO:Text + " não cadastrado no Protheus." )
			EndIf

			/* **** CENTRO DE CUSTO CTT **** */
			CTT->(dbSetOrder(1)) //CTT_FILIAL+CTT_CUSTO
			If ! CTT->( dbSeek( xFilial("CTT") + oXML:_CONTRATO:_CENTRO_CUSTO:Text ) )
				lIntegra := .F.
				cErroInt += "Centro de Custo CENTRO_CUSTO: " + oXML:_CONTRATO:_AGENCIA:_CENTRO_CUSTO:Text + " não cadastrado no Protheus." + Chr(13) + Chr(10)
				ConOut( "Centro de Custo CENTRO_CUSTO: " + oXML:_CONTRATO:_AGENCIA:_CENTRO_CUSTO:Text + " não cadastrado no Protheus." )
			EndIf

			/* **** CONDIÇÃO DE PAGAMENTO SE4 **** */
			SE4->(dbSetOrder(1)) //E4_FILIAL+E4_CODIGO
			If ! SE4->( dbSeek( xFilial("SE4") + oXML:_CONTRATO:_COND_PAGTO:Text ) )
				lIntegra := .F.
				cErroInt += "Codição de Pagamento COND_PAGTO: " + oXML:_CONTRATO:_AGENCIA:_COND_PAGTO:Text + " não cadastrado no Protheus." + Chr(13) + Chr(10)
				ConOut( "Codição de Pagamento COND_PAGTO: " + oXML:_CONTRATO:_AGENCIA:_COND_PAGTO:Text + " não cadastrado no Protheus." )
			EndIf

			/* **** CATEGORIA ANUNCIANTE ZCN **** */
			ZCN->(dbSetOrder(1)) //ZCN_FILIAL+ZCN_CODIGO
			If ! ZCN->( dbSeek( xFilial("ZCN") + oXML:_CONTRATO:_CATEGORIA_ANUNCIANTE:Text ) )
				lIntegra := .F.
				cErroInt += "Categoria do Anunciante CATEGORIA_ANUNCIANTE: " + oXML:_CONTRATO:_AGENCIA:_CATEGORIA_ANUNCIANTE:Text + " não cadastrado no Protheus." + Chr(13) + Chr(10)
				ConOut( "Categoria do Anunciante CATEGORIA_ANUNCIANTE: " + oXML:_CONTRATO:_AGENCIA:_CATEGORIA_ANUNCIANTE:Text + " não cadastrado no Protheus." )
			EndIf

			/* **** VENDEDOR SA3 **** */
			SA3->(dbSetOrder(1)) //A3_FILIAL+A3_COD
			If ! SE4->( dbSeek( xFilial("SE4") + oXML:_CONTRATO:_VENDEDOR:_ID_ENT:Text ) )
				lIntegra := .F.
				cErroInt += "Vendedor VENDEDOR: " + oXML:_CONTRATO:_VENDEDOR:_ID_ENT:Text + " não cadastrado no Protheus." + Chr(13) + Chr(10)
				ConOut( "Vendedor VENDEDOR: " + oXML:_CONTRATO:_VENDEDOR:_ID_ENT:Text + " não cadastrado no Protheus." )
			EndIf

			//Reposiciona Cliente
			SA1->( dbSeek( xFilial("SA1") + oXML:_CONTRATO:_AGENCIA:_ID_ENT:Text ) )

			/* **** CONTRATOS ZCA|ZCB **** */
//			ZCA->(RecLock("ZCA",.T.))
//				ZCA->ZCA_FILIAL := xFilial("ZCA")
//				ZCA->ZCA_CODAV 	:= GetNumSX8("ZCA")
//				ZCA->ZCA_REVISA := oXML:_CONTRATO:_REVISAO:Text
//				ZCA->ZCA_TIPOAV := oXML:_CONTRATO:_TIPO_AV:Text
//				ZCA->ZCA_CODPR 	:= oXML:_CONTRATO:_CODIGO_PRACA:Text
//				ZCA->ZCA_CLIENT := SA1->A1_COD
//				ZCA->ZCA_LOJA 	:= SA1->A1_LOJA
//				ZCA->ZCA_NOMCLI := SA1->A1_NOME
//				ZCA->ZCA_NOMFAN := SA1->A1_NREDUZ
//				ZCA->ZCA_TABPRC := oXML:_CONTRATO:_TABELA_PRECO:Text
//				ZCA->ZCA_FATDIR := oXML:_CONTRATO:_FATURA_DIRETO:Text
//				ZCA->ZCA_NPICLI := oXML:_CONTRATO:_PI_CLIENTE:Text
//				ZCA->ZCA_AGNCIA	:= SA1->A1_COD
//				ZCA->ZCA_LOJAAG	:= SA1->A1_LOJA
//				ZCA->ZCA_NOMAGE	:= SA1->A1_NOME
//				ZCA->ZCA_NOMFA2	:= SA1->A1_NREDUZ
//				ZCA->ZCA_ORIFAT	:= oXML:_CONTRATO:_ORIGEM_FATURAMENTO:Text
//				ZCA->ZCA_DESORF	:= SZ1->Z1_DESCRI
//				ZCA->ZCA_CC 	:= oXML:_CONTRATO:_CENTRO_CUSTO:Text
//				ZCA->ZCA_DESCCC	:= CTT->CTT_DESC01
//				ZCA->ZCA_CONDPG	:= oXML:_CONTRATO:_COND_PAGTO:Text
//				ZCA->ZCA_DESCPG := SE4->E4_DESCRI
//				ZCA->ZCA_CAMP 	:= oXML:_CONTRATO:_CAMPANHA:Text
//				ZCA->ZCA_MODFAT := oXML:_CONTRATO:_MODO_FATURAMENTO:Text
//				ZCA->ZCA_CATEG 	:= oXML:_CONTRATO:_CATEGORIA_ANUNCIANTE:Text
//				ZCA->ZCA_DESCAT := ZCN->ZCN_DESCRI
//				ZCA->ZCA_VEND 	:= oXML:_CONTRATO:_VENDEDOR:_ID_ENT:Text
//				ZCA->ZCA_COMVD1 := SA3->A3_COMIS
//				ZCA->ZCA_DESVEN := SA3->A3_NOME
//				ZCA->ZCA_DATA 	:= oXML:_CONTRATO:_DATA_DIGITACAO:Text
//				ZCA->ZCA_CUIDAD := oXML:_CONTRATO:_AOS_CUIDADOS:Text
//				ZCA->ZCA_MENS01 := oXML:_CONTRATO:_MENSAGEM:Text
//				ZCA->ZCA_AGLFAT := oXML:_CONTRATO:_AGLUTINA_FATURAMENTO:Text
//				ZCA->ZCA_GCARTA := oXML:_CONTRATO:_GERA_CARTA:Text
//				ZCA->ZCA_GBOLET := oXML:_CONTRATO:_GERA_BOLETO:Text
//				ZCA->ZCA_GCOMPR := oXML:_CONTRATO:_GERA_COMPROVANTE:Text
//				ZCA->ZCA_ENMAIL := oXML:_CONTRATO:_ENVIA_EMAIL:Text
//				ZCA->ZCA_STATUS := oXML:_CONTRATO:_STATUS:Text
//				ZCA->ZCA_PATROC := oXML:_CONTRATO:_PATROCINIO:Text
//				/* **** FALTA CRIAR O CAMPO NA BASE **** */
////					ZCA->ZCA_XCODEX := oXML:_CONTRATO:_ID_ENT:Text
//			ZCA->(MsUnLock())
//
//			ZCB->(RecLock("ZCB",.T.))
//				ZCB->ZCB_FILIAL	:= xFilial("ZCB")
//				ZCB->ZCB_CODAV 	:= ZCA->ZCA_CODAV
//				ZCB->ZCB_REVISA	:= oXML:_CONTRATO:_REVISAO:Text
//				ZCB->ZCB_NRNUM 	:= nItem ++
//				ZCB->ZCB_CODPR 	:= oXML:_CONTRATO:_CODIGO_PRACA:Text
//				ZCB->ZCB_PRODUT	:= oXML:_CONTRATO:_ITENS:_ITEM:_PRODUTO:Text
//				ZCB->ZCB_VALUNI := oXML:_CONTRATO:_ITENS:_ITEM:_VALOR_UNITARIO:Text
//				ZCB->ZCB_QTTVEI := oXML:_CONTRATO:_ITENS:_ITEM:_QUATIDADE_INSERCOES:Text
//				ZCB->ZCB_VALDES := oXML:_CONTRATO:_ITENS:_ITEM:_VALOR_DESCONTO:Text
//				ZCB->ZCB_VALTOT := oXML:_CONTRATO:_ITENS:_ITEM:_VALOR_TOTAL:Text
//				ZCB->ZCB_PORDES := oXML:_CONTRATO:_ITENS:_ITEM:_PERCENTUAL_DESCONTO:Text
//				ZCB->ZCB_TIPOAN := oXML:_CONTRATO:_ITENS:_ITEM:_TIPO_ANUNCIO:Text
//				ZCB->ZCB_DETERM := oXML:_CONTRATO:_ITENS:_ITEM:_DETERMINADO:Text
//			ZCB->(MsUnLock())
//
//			//Gravacao da ZCE
//			ZCE->(RecLock("ZCE",.T.))
//				ZCE->ZCE_FILIAL	:= xFilial("ZCE")
//				ZCE->ZCE_CODPI	:=
//				ZCE->ZCE_REVISA	:=
//				ZCE->ZCE_NRITEM	:=
//				ZCE->ZCE_CODPR	:=
//				ZCE->ZCE_TPANUN	:=
//				ZCE->ZCE_QTDSEG	:=
//				ZCE->ZCE_QTINS	:=
//				ZCE->ZCE_TOTANU	:=
//				ZCE->ZCE_DTEXIB	:=
//				ZCE->ZCE_CODGR	:=
//				ZCE->ZCE_CUSUNI	:=
//				ZCE->ZCE_PORDES	:=
//				ZCE->ZCE_VALTOT	:=
//				ZCE->ZCE_OBSMAT	:=
//				ZCE->ZCE_STATUS	:=
//				ZCE->ZCE_LEGEND	:=
//				ZCE->ZCE_NMIDIA	:=
//				ZCE->ZCE_AVPAI	:=
//				ZCE->ZCE_ITMPAI	:=
//				ZCE->ZCE_BONIF	:=
//			ZCE->(MsUnLock())
//
//			//Gravacao da ZCC
//			ZCC->(RecLock("ZCC",.T.))
//				ZCC->ZCC_FILIAL	:= xFilial("ZCC")
//				ZCC->ZCC_CODPI	:= ZCA->ZCA_CODAV
//				ZCC->ZCC_REVISA	:= ZCA->ZCA_REVISA
//				ZCC->ZCC_CODAV	:= ZCA->ZCA_CODAV
//				ZCC->ZCC_DATA	:= ZCA->ZCA_DATA
//				ZCC->ZCC_DESCRI	:= ""
//				ZCC->ZCC_NRPI	:= ZCA->ZCA_NPICLI
//				ZCC->ZCC_CODCLI	:= ZCA->ZCA_CLIENT
//				ZCC->ZCC_LOJA	:= ZCA->ZCA_LOJA
//				ZCC->ZCC_NOMCLI	:= ZCA->ZCA_NOMCLI
//				ZCC->ZCC_NOMFA1	:= ZCA->ZCA_NOMFAN
//				ZCC->ZCC_AGENCI	:= ZCA->ZCA_AGNCIA
//				ZCC->ZCC_LOJAAG	:= ZCA->ZCA_LOJAAG
//				ZCC->ZCC_NOMEAG	:= ZCA->ZCA_NOMAGE
//				ZCC->ZCC_NOMFA2	:= ZCA->ZCA_NOMFA2
//				ZCC->ZCC_CAMP	:= ZCA->ZCA_CAMP
//				ZCC->ZCC_SOLIC	:= ""
//				ZCC->ZCC_CONDPG	:= ZCA->ZCA_CONDPG
//				ZCC->ZCC_DESPGT	:= ZCA->ZCA_DESCPG
//				ZCC->ZCC_VALTOT	:= nValTot
//				ZCC->ZCC_INTEGR	:= ""
//				ZCC->ZCC_STATUS	:= ZCA->ZCA_STATUS
//				ZCC->ZCC_MSEXP	:= Date()
//			ZCC->(MsUnLock())

		Else
			ConOut( "Erro: " + cError + "  -  Aviso: " + cWarning )
		EndIf
	Next(nX)

EndIf

Return(Nil)
