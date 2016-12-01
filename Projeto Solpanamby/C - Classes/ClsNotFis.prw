#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

User Function ClsNotFis()
Return Nil

/*/{Protheus.doc} ClsNotFis (NFSaida)
@description	Classe para NF de Saida
@author 		Amedeo D. Paoli Filho
@version 		1.0
/*/
Class NFSaida From uExecAuto
	Data cCliente
	Data cLojaCli
	Data cNumero
	Data cNumNFS
	Data cSerNFS
	Data cPedido

	Method New()
	Method AddCabec(cCampo, xValor)
	Method VerSX6()
	Method VerSX5()
	Method Gravacao(nOpcao)
	Method GetNumero()
	Method GetSerie()
	Method LibPed()
EndClass

/*/{Protheus.doc} new
@Description	Metodo construtor
@author 		Amedeo D. Paoli Filho
@version 		1.0
/*/
Method New() Class NFSaida
	_Super:New()
	::aTabelas := {"SA1","SB1","SB2","SF4","SC5","SC6","SC9"}
	::cNumero := ""
	::cCliente := ""
	::cLojaCli := ""
	::cNumero := ""
	::cNumNFS := ""
	::cSerNFS := ""
	::cPedido := ""
Return Self

/*/{Protheus.doc} AddCabec
@Description	Metodo AddCabec
@author 		Amedeo D. Paoli Filho
@version 		1.0
/*/
Method AddCabec(cCampo, xValor) Class NFSaida
	If Alltrim(cCampo) == "C9_CLIENTE"
		::cCliente := xValor
	ElseIf Alltrim(cCampo) == "C9_LOJA"
		::cLojaCli := xValor
	ElseIf Alltrim(cCampo) == "C9_NFISCAL"
		::cNumNFS := xValor
	ElseIf Alltrim(cCampo) == "C9_SERIENF"
		::cSerNFS := xValor
	ElseIf Alltrim(cCampo) == "C9_PEDIDO"
		::cPedido := xValor
	EndIf
Return Nil

/*/{Protheus.doc} VerSX6
@Description	Metodo VerSX6
@author 		Amedeo D. Paoli Filho
@version 		1.0
/*/
Method VerSX6() Class NFSaida
	Local lRetorno := .T.
	Local lContinua := .T.
	Local nVezes := 0

	ConOut("Verificando Parametro SX6 (MV_NUMITEN)")

	If ( GetMv("MV_NUMITEN",.T.) )
		While ( lContinua .And. !SX6->(MsRLock()) )
			Inkey(1)
			nVezes++

			ConOut("Tentativa: " + Alltrim(Str(nVezes)) + " Sem Sucesso")

			If ( nVezes > 200 )
				lContinua := .F.
			EndIf
		EndDo
	Else
		lContinua := .F.
	EndIf

	If !lContinua
		lRetorno := .F.
	EndIf

	//Destrava Parametro
	If ( GetMv("MV_NUMITEN",.T.) )
		ConOut("Destravando SX6")
		SX6->(MsRUnLock())
	Else
		ConOut("Destravando SX6")
	EndIf
Return lRetorno

/*/{Protheus.doc} VerSX5
@Description	Metodo VerSX5
@author 		Amedeo D. Paoli Filho
@version 		1.0
/*/
Method VerSX5() Class NFSaida
	Local lRetorno := .T.
	Local lLocked := .F.
	Local cTabela := "01"
	Local nContador := 0

	ConOut("Verificando Numeração de NF, Série: " + ::cSerNFS)

	DbSelectArea( "SX5" )
	SX5->(DbSetOrder(1))

	If SX5->(MsSeek( xFilial("SX5") + cTabela + ::cSerNFS,.F.))
		While !lLocked .And. (++nContador < 200)
			ConOut("Tentando Reservar SX5, Tentativa: " + Alltrim(Str(nContador)) )

			If InTransact()
				lLocked := RecLock("SX5")
			Else
				lLocked := MsRLock()
			EndIf

			If !lLocked
				Inkey(1)
				ConOut("Tentativa: " + Alltrim(Str(nContador)) + " Sem Sucesso")
			Else
				ConOut("Tentativa: " + Alltrim(Str(nContador)) + " Com Sucesso")
			EndIf
		End
	Else
		lRetorno 	:= .F.
		::cMensagem	:= "Série: " + ::cSerNFS + " Não encontrada na Tabela SX5"
	EndIf

	If lRetorno
		If !lLocked
			lRetorno 	:= .F.
			::cMensagem	:= "Não foi possível reservar numeração de NF na tabela SX5, Contate Suporte"
		EndIf
	EndIf
Return lRetorno

/*/{Protheus.doc} Gravacao
@Description	Metodo Gravacao
@author 		Amedeo D. Paoli Filho
@version 		1.0
/*/
Method Gravacao(nOpcao) Class NFSaida
	Local dDataBackup := dDataBase
	Local cSeek := ""
	Local lRetorno := .T.
	Local nRegDAK := 0
	Local nPrcVen := 0
	Local aPvlNfs := {}

	Local lMostraCtb := .F.
	Local lAglutCtb := .F.
	Local lCtbOnLine := .F.
	Local lCtbCusto := .F.
	Local lReajuste := .F.
	Local lAtuSA7lECF := .F.

	Local nCalAcrs := 1
	Local nArredPrcLis := 1

	Local lRetorno := .T.
	Local lAddItem := .F.
	Local lEmitida := .F.
	Local nPosPed := 0
	Local nPosItem := 0
	Local nPosProd := 0
	Local nPosQtVd := 0
	Local nI := 0

	::SetEnv(1, "FAT")

	//Altera a Data da Gravacao
	If !Empty(::dEmissao)
		dDataBase := ::dEmissao
	EndIf

	//Chama liberacao do pedido
	::LibPed()

	// Controle de Transacao
	Begin Transaction
		If nOpcao == 3
			DbSelectarea("SD2")
			DbSelectarea("SD1")
			DbSelectarea("SD3")
			DbSelectArea("SC5")
			DbSelectArea("SC6")
			DbSelectArea("SC9")
			DbSelectArea("SE4")
			DbSelectArea("SB1")
			DbSelectArea("SB2")
			DbSelectArea("SF4")

			For nI := 1 To Len( ::aItens )
				nPosPed := Ascan( ::aItens[nI], {|x| x[01] == "C9_PEDIDO" })
				nPosItem := Ascan( ::aItens[nI], {|x| x[01] == "C9_ITEM" })
				nPosProd := Ascan( ::aItens[nI], {|x| x[01] == "C9_PRODUTO" })
				nPosQtVd := Ascan( ::aItens[nI], {|x| x[01] == "C9_QTDLIB" })

				If nPosPed > 0 .And. nPosItem > 0 .AND. nPosProd > 0 .AND. nPosQtVd > 0

					SC5->( DBSetOrder(1) )
					SC6->( DBSetOrder(1) )

					If SC5->( DbSeek( xFilial("SC5") + ::aItens[nI][nPosPed][02] ) )
						cSeek := xFilial("SC6") + ::aItens[nI][nPosPed][02] + ::aItens[nI][nPosItem][02]

						If SC6->( DbSeek( cSeek ) )
							While SC6->( !Eof() .AND. SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_ITEM == cSeek )

								// Posiciona na condicao de pagamento
								SE4->( DBSetOrder(1) )
								SE4->( DbSeek(xFilial("SE4") + SC5->C5_CONDPAG) )

								// Posiciona no produto
								SB1->( DBSetOrder(1) )
								SB1->( DbSeek(xFilial("SB1") + SC6->C6_PRODUTO) )

								// Posiciona no saldo em estoque
								SB2->( DBSetOrder(1) )
								SB2->( DbSeek(xFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL) )

								// Posiciona no TES
								SF4->( DBSetOrder(1) )
								SF4->( DbSeek(xFilial("SF4") + SC6->C6_TES) )

								lAddItem := .F.
								lEmitida := .F.

								SC9->( DBSetOrder(1) )

								If SC9->(DbSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM))
									While !SC9->(Eof()) .AND. SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_ITEM == SC9->C9_FILIAL + SC9->C9_PEDIDO + SC9->C9_ITEM
										If Empty(SC9->C9_NFISCAL)
											If Empty(SC9->C9_BLCRED) .AND. Empty(SC9->C9_BLEST) .AND. SC9->C9_QTDLIB == ::aItens[nI][nPosQtVd][02]
												nPrcVen := SC9->C9_PRCVEN

												If (SC5->C5_MOEDA <> 1)
													DbSelectArea("SM2")
													DbSetOrder(1)
													If DbSeek(DtoS(dDataBase))
														nPrcVen := SC9->C9_PRCVEN * SM2->M2_MOEDA2
													Else
														nPrcVen := xMoeda(nPrcVen, SC5->C5_MOEDA, 1, dDataBase)
													EndIf
												EndIf

												// Monta array para gerar a nota fiscal
												Aadd(aPvlNfs,	{;
																SC9->C9_PEDIDO,		SC9->C9_ITEM, 		SC9->C9_SEQUEN,		SC9->C9_QTDLIB,;
																nPrcVen,			SC9->C9_PRODUTO,	.F.,				SC9->(RecNo()),;
																SC5->(RecNo()),		SC6->(RecNo()),		SE4->(RecNo()),		SB1->(RecNo()),;
																SB2->(RecNo()),		SF4->(RecNo()),		SC6->C6_LOCAL,		nRegDAK,;
																SC9->C9_QTDLIB2;
																})

												lAddItem := .T.
												lEmitida := .F.
											Else
												::cMensagem += "Erro durante Geraçào da NF. Pedido com Bloqueios ou Quant. diferente da Liberada." + CRLF
												lRetorno := .F.
												nI := Len(::aItens)
											EndIf
										Else
											lEmitida := .T.
										EndIf

										SC9->( DbSkip() )
									End

									If lEmitida
										::cMensagem := "Nota fiscal Já Emitida Para Esse Pedido / Item"
										lRetorno := .F.
									ElseIf !lAddItem
										::cMensagem += " 01 - Liberação do Item " + ::aItens[nI][nPosItem][02] + " não encontrada."
										lRetorno := .F.
										nI := Len(::aItens)
									EndIf

								Else
									::cMensagem += " 02 - Liberação do Item " + ::aItens[nI][nPosItem][02] + " não encontrada."
									lRetorno := .F.
									nI := Len(::aItens)
								EndIf

								SC6->( DbSkip() )
							End
						Else
							::cMensagem := "Item " + ::aItens[nI][nPosItem][02] + " não encontrado."
							lRetorno := .F.
							nI := Len(::aItens)
						EndIf
					Else
						::cMensagem := "Pedido " + ::aItens[nI][nPosPed][02] + " não encontrado."
						lRetorno := .F.
					EndIf
				Else
					::cMensagem := "Os Campos Obrigatórios dos Itens não foram informados."
					lRetorno := .F.
					nI := Len(::aItens)
				EndIf
			Next nI

			//Verifica parametro de NF
			If lRetorno
				lRetorno := ::VerSX6()
			EndIf

			//Verifica se SX5 esta disponivel
			If lRetorno
				//lRetorno := ::VerSX5()
			EndIf

			If lRetorno
				If !Empty(aPvlNfs)
					::cNumero := MaPvlNFS(	aPvlNfs,		::cSerNFS,	lMostraCtb, lAglutCtb,;
											lCtbOnLine,		lCtbCusto,	lReajuste,	nCalAcrs,;
											nArredPrcLis,	lAtuSA7lECF)

					If Empty(::cNumero)
						::cMensagem := "Erro durante a Preparação da Nota Fiscal de Saída."
						lRetorno := .F.
					EndIf
				Else
					::cMensagem += CRLF + "Erro durante a Preparação da Nota Fiscal de Saída."
					lRetorno := .F.
				EndIf
			EndIf
		EndIf

		If !lRetorno
			DisarmTransaction()
		EndIf

	//Encerra a Transacao
	End Transaction

	::SetEnv(2, "FAT")
Return lRetorno

/*/{Protheus.doc} GetSerie
@Description	Metodo GetSerie
@author 		Amedeo D. Paoli Filho
@version 		1.0
/*/
Method GetSerie() Class NFSaida
Return ::cSerNFS

/*/{Protheus.doc} GetNumero
@Description	Metodo GetNumero
@author 		Amedeo D. Paoli Filho
@version 		1.0
/*/
Method GetNumero() Class NFSaida
Return ::cNumero

/*/{Protheus.doc} LibPed
@Description	Metodo LibPed
@author 		Amedeo D. Paoli Filho
@version 		1.0
/*/
Method LibPed() Class NFSaida
	Local aAreaAt := GetArea()
	Local nPosItem := 0
	Local nPosQtVd := 0
	Local nPosPed := 0
	Local nPosPro := 0
	Local nQtdLib := 0

	Local lCredito := .F.
	Local lEstoque := .F.

	Local lLiber := .F.
	Local lFatur := .F.
	Local lRejeit := .F.

	Local nX := 0

	DbSelectarea("SC9")
	SC9->( DbSetorder(1) )	//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

	DbSelectarea("SC6")
	SC6->( DbSetorder(1) )	//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	//Faz o estorno dos itens para fazer nova liberacao
	DbSelectarea("SC5")
	SC5->( DbSetorder(1) )
	If SC5->( DbSeek( xFilial("SC5") + ::cPedido ) )
		DbSelectarea("SC6")
		SC6->( DbSetorder(1) )

		If SC6->( DbSeek( xFilial("SC6") + ::cPedido ) )
			While !SC6->( Eof() ) .And.	SC6->C6_FILIAL == xFilial("SC6") .And.;
										SC6->C6_NUM == ::cPedido

				DbSelectarea("SC9")
				SC9->(DbSetorder(1))

				If SC9->( DbSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM ) )
					While !SC9->( Eof() ) .And.	SC9->C9_FILIAL == xFilial("SC9") .And.;
												SC9->C9_PEDIDO == SC6->C6_NUM .And.;
												SC9->C9_ITEM == SC6->C6_ITEM

						lFatur	:= SC9->C9_BLCRED == "10" .And. SC9->C9_BLEST == "10"

						//Faz o Estorno por Item caso nao tenha sido faturado
						If !lFatur
							RecLock( "SC6", .F. )
								MaAvalSC6( "SC6", 4, "SC5" )
							SC6->( MsUnlock() )
						EndIf

						SC9->( DbSkip() )
					End
				Else
					MsgAlert( "PV / Item: " + SC6->C6_NUM + " / " + SC6->C6_ITEM + " sem liberação, nao será estornado" )
				EndIf

				SC6->( DbSkip() )
			End
			//Atualiza campos de Bloqueio
			SC6->( MaLiberOk( { ::cPedido } ) )
		EndIf
	EndIf

	//Faz a liberacao do pedido
	For nX := 1 To Len( ::aItens )
		nPosPed := Ascan( ::aItens[nX], { |x| x[01] == "C9_PEDIDO"	})
		nPosItem := Ascan( ::aItens[nX], { |x| x[01] == "C9_ITEM"	})
		nPosQtVd := Ascan( ::aItens[nX], { |x| x[01] == "C9_QTDLIB"	})
		nPosPro := Ascan( ::aItens[nX], { |x| x[01] == "C9_PRODUTO"	})

		If nPosPed > 0 .And. nPosItem > 0 .And. nPosQtVd > 0
			If SC6->( DbSeek(xFilial("SC6") + ::aItens[nX][nPosPed][02] + ::aItens[nX][nPosItem][02] + ::aItens[nX][nPosPro][02]) )

				//Caso nao encontre SC9, forca a liberacao
				If !SC9->( DbSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM ) )
					nQtdLib	:= ::aItens[nX][nPosQtVd][02]

					//Faz a Liberacao por Item
					RecLock("SC6")
						Begin Transaction
							nQtdLib := MaLibDoFat( SC6->( RecNo() ), nQtdLib, @lCredito, @lEstoque, .T., .T., .T., .F., Nil, Nil, Nil, Nil, Nil, Nil, 0 )
						End Transaction
					MsUnlock()
				EndIf

				//Verifica liberacao
				If SC9->( DbSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM ) )
					While !SC9->( Eof() ) .And.	SC9->C9_FILIAL == xFilial("SC9") .And.;
												SC9->C9_PEDIDO == SC6->C6_NUM .And.;
												SC9->C9_ITEM == SC6->C6_ITEM

						lLiber := Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLEST)
						lFatur := SC9->C9_BLCRED == "10" .And. SC9->C9_BLEST == "10"
						lRejeit := SC9->C9_BLCRED == "09"

						//Forcao liberacao de credito e estoque conforme definido com Alexandre (T.I.)
						If !lLiber .And. !lFatur .And. !lRejeit
							a450Grava(1, .T., .T., .F.)
						EndIf
					End
				EndIf
			EndIf
		EndIf
	Next nX

	RestArea( aAreaAt )
Return Nil