#Include 'Totvs.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   ³ MA410DEL   º Autor ³ Alexandre Soares Reis º Data ³ 30/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Empresa    ³ Sol Panamby                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ O ponto de entrada apos a exclusao do pedido de venda          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Modulo     ³ SIGAFAT                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        ³ Ponto de Entrada                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros ³ Nil                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    ³ Nil                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Data       ³ Analista    ³Descricao da Alteracao                            º±±
±±º============³=============³==================================================º±±
±±º __/__/____ ³             ³                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
User Function MA410DEL(aPedido)
Local aArea := SC5->(GetArea())
Local cSQL += ""
Local cRevisa := "00"

// Exclui vinculos com Pedido Aglutinador
If SM0->M0_CODIGO $ "10|20|25|26|28"
	//Apaga referencia ao Pedido Aglutinador
	cSQL += "BEGIN TRANSACTION" + Chr(10) + Chr(13)
	cSQL += "GO" + Chr(10) + Chr(13)
	cSQL += "UPDATE " + RetSqlName("SC5") + " SET C5_PED_AGL = '      ',C5_NOTA = '      ' " + Chr(10) + Chr(13)
	cSQL += "WHERE C5_PED_AGL = '" + SC5->C5_NUM + "' AND C5_FILIAL = '" + SC5->C5_FILIAL + "' " + Chr(10) + Chr(13)
	cSQL += "UPDATE " + RetSqlName("SC6") + " SET C6_PED_AGL = '      ',C6_NOTA = '      ' " + Chr(10) + Chr(13)
	cSQL += "WHERE C6_PED_AGL = '" + SC5->C5_NUM + "' AND C6_FILIAL = '" + SC5->C5_FILIAL + "' " + Chr(10) + Chr(13)
	cSQL += "UPDATE " + RetSqlName("SC9") + " SET C9_NUMLOTE = '      ',D_E_L_E_T_ = ' ' " + Chr(10) + Chr(13)
	cSQL += "WHERE C9_NUMLOTE = '" + SC5->C5_NUM + "' AND C9_FILIAL = '" + SC5->C5_FILIAL + "' " + Chr(10) + Chr(13)
	cSQL += "COMMIT TRANSACTION"

	If TCSQLExec(cSQL) < 0
		Alert(TCSQLError())
	EndIf
EndIf


If SM0->M0_CODIGO $ "10|80"
	ZCO->(DbsetOrder(1)) //ZCO_FILIAL+ZCO_PEDIDO+ZCO_PRODUT+ZCO_ITEMAV
	ZCA->(dbSetOrder(1)) //ZCA_FILIAL+ZCA_CODAV+ZCA_REVISA
	ZCB->(dbSetOrder(1)) //ZCB_FILIAL+ZCB_CODAV+ZCB_REVISA+ZCB_NRNUM

	If ZCO->(dbSeek(xFilial("ZCO") + M->C5_NUM))
		While ! ZCO->(EOF()) .AND. ZCO->ZCO_PEDIDO == M->C5_NUM
			If ZCA->(dbSeek(xFilial("ZCA") + ZCO->ZCO_CODIAV))
				While ! ZCA->(EOF()) .AND. ZCA->ZCA_CODAV == ZCO->ZCO_CODIAV
					cRevisa := ZCA->ZCA_REVISA
					ZCA->(dbSkip())
				EndDo
			EndIf

			ZCA->(dbSkip(-1))
			If ZCB->(dbSeek(xFilial("ZCB") + ZCO->ZCO_CODIAV + cRevisa + ZCO->ZCO_ITEMAV))
				RecLock("ZCB",.F.)
					ZCB->ZCB_QTEMPV := ZCB->ZCB_QTEMPV - ZCO->ZCO_QTDVEN
					ZCB->ZCB_SLDFAT := ZCB->ZCB_SLDFAT - ZCO->ZCO_QTDVEN
				ZCB->(MsUnLock())
			EndIf

			RecLock("ZCO",.F.)
				ZCO->(dbDelete())
			ZCO->(MsUnLock())

			ZCO->(dbSkip())
		EndDo

		U_APGCMPZCL(M->C5_NUM)
	EndIf
EndIf

If SM0->M0_CODIGO $ "75|80"
	U_ISC50001(3) //3 - Excluir
EndIf

RestArea(aArea)
Return(Nil)