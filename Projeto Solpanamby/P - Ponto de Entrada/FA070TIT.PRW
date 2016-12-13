#Include 'Totvs.ch'

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa   ≥ FA070TIT   ∫ Autor ≥                       ∫ Data ≥ __/__/____ ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Empresa    ≥ Sol Panamby                                                    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao  ≥ O ponto de entrada executado apos a confirmacao da baixa do    ∫±±
±±∫            ≥ contas a receber                                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Modulo     ≥ SIGAFIN                                                        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Uso        ≥ Ponto de Entrada                                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Parametros ≥ nParciais - N -                                                ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Retorno    ≥ lRet - L - .T. realiza a baixa / .F. nao realiza a baixa       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Data       ≥ Analista    ≥Descricao da Alteracao                            ∫±±
±±∫============≥=============≥==================================================∫±±
±±∫ 28/11/2016 ≥ Alexandre S ≥ Reorganizacao do programa                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
User Function FA070TIT(nParciais)
Local aArea := Getarea()
Local _dAno := ""
Local _dMes := ""
Local lIntregCom := SuperGetMv('PY_INT001',.T.,.F.) //Parametro respons·vel por ligar a integraÁ„o do faturamento com os sistemas legados das empresas de comunicaÁ„o
Local lRet := .T.
Local lZZZ := .F.
Local nAcresc := 0
Local nTitAtu := 0

chist070 := SE1->E1_HIST

If SM0->M0_CODIGO $ "75|80"
	If lIntregCom .AND. ! Empty(SE1->E1_XCODEXT)
		U_ISE10001(7) //3 - Excluir / 7 ñ Baixar / 8 - Cancelar
	EndIf

//rodar· somente para a empresa Acqua e Titulos gerados pelo GEI e com valor reajustavel  30/01/13
//atualizaÁ„o do campo Acrescimo para o valor da data do pagamento, quando foi pago com data retoroativa
ElseIf SM0->M0_CODIGO == "C1" .AND. SE1->E1_TIPO == "BOL" .AND. AllTrim(SE1->E1_TPVLR) == "R"
	//Baixa dentro do mÍs de Vencimento. se o vencto = FEV e pgto = FEV. considero o acrescimo da data de vencimento
	If dBaixa >= FirstDate( SE1->E1_VENCREA ) .AND. dBaixa <= LastDate( SE1->E1_VENCREA )
		_dAno := SubStr(DtoS(SE1->E1_VENCREA),1,4)
		_dMes := SubStr(DtoS(SE1->E1_VENCREA),5,2)

		// localizar na ZZZ o acrescimo do mes correto
		If ZZZ->(dbSeek(xFilial("ZZZ") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA) + _dAno + _dMes, .F.))
			RecLock("SE1",.F.)
				SE1->E1_ACRESC := ZZZ->ZZZ_ACRESC
				nAcresc := ZZZ->ZZZ_ACRESC
				nTitAtu := ZZZ->ZZZ_TITATU
			SE1->(Msunlock())
			lZZZ := .T.
		EndIf
	// Baixa no mÍs posterior ao Mes do Vencimento.  se o vencimento = FEV e pagamento = MAR. considero o acrescimo da data pagamento
	ElseIf dBaixa > LastDate( SE1->E1_VENCREA )
		_dAno := SubStr(DtoS(dBaixa),1,4)
		_dMes := SubStr(DtoS(dBaixa),5,2)

		// localizar na ZZZ o acrescimo do mes correto
		If ZZZ->(dbSeek(xFilial("ZZZ") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA) + _dAno + _dMes, .F.))
			RecLock("SE1",.F.)
				SE1->E1_ACRESC := ZZZ->ZZZ_ACRESC
				nAcresc := ZZZ->ZZZ_ACRESC
				nTitAtu := ZZZ->ZZZ_TITATU
			SE1->(Msunlock())
			lZZZ := .T.
		EndIf
	// Baixa no m s anterior ao m s de Vencimento.   se o vencimento = FEV e pagamento = JAN. considero o acrescimo da data vencimento
	ElseIf dBaixa < FirstDate( SE1->E1_VENCREA )
		_dAno := SubStr(DtoS(SE1->E1_VENCREA),1,4)
		_dMes := SubStr(DtoS(SE1->E1_VENCREA),5,2)

		// localizar na ZZZ o acrescimo do mes correto
		If ZZZ->(dbSeek(xFilial("ZZZ")+ SE1->(E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA) + _dAno + _dMes, .F.))
			RecLock("SE1",.F.)
				SE1->E1_ACRESC := ZZZ->ZZZ_ACRESC
				nAcresc := ZZZ->ZZZ_ACRESC
				nTitAtu := ZZZ->ZZZ_TITATU
			SE1->(Msunlock())
			lZZZ := .T.
		EndIf
	EndIf

	If lZZZ
		While ! ZZZ->(EOF()) .AND. SE1->E1_PREFIXO == ZZZ->ZZZ_PREFIX  .AND. SE1->E1_NUM ==ZZZ->ZZZ_NUM .AND. SE1->E1_PARCELA == ZZZ->ZZZ_PARCEL
			RecLock("ZZZ",.F.)
				ZZZ->ZZZ_ACRESC := nAcresc
				ZZZ->ZZZ_TITATU := nTitAtu
			ZZZ->(Msunlock())
			ZZZ->(DBSKIP())
		EndDo
	EndIf
EndIf

RestArea(aArea)
Return(lRet)
