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
		- 005 – Título Finenceiro (PARCELA)
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
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   ³ ISC50001   º Autor ³ Alexandre Soares Reis º Data ³ 29/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Empresa    ³ Sol Panamby                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ Integracao TOTVS Protheus vs Pulsar                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Modulo     ³ Integracao                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        ³ Integracao do estorno do pedido de venda                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros ³ nAction - N - 3 Excluir                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    ³ Nil                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Data       ³ Analista    ³Descricao da Alteracao                            º±±
±±º============³=============³==================================================º±±
±±º __/__/____ ³ ___________ ³                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
User Function ISC50001(nAction)
Local aDados := {}
Local cAction := ""
Local cDestino := ""
Local cIDProc := "003"
Local cProces := "Pedido de Venda"
Local lRet := .T.

Default nAction := 0

If SM0->M0_CODIGO == "70" //TVB CAMPINAS
	cDestino := "4"
ElseIf SM0->M0_CODIGO == "75" //TVB SAO VICENTE
	cDestino := "3"
ElseIf SM0->M0_CODIGO == "80" //NOVA BRASIL FM
	cDestino := "2"
EndIf

If nAction := 3
	cAction := "Exclusao"
EndIf

aAdd(aDados,{"ID_EMP"         ,cEmpAnt})                 //80 - RCC
aAdd(aDados,{"ID_FIL"         ,cFilAnt})                 //01 – SP | 02 – CAMPINAS | 03 – PE | 04 – DF | 05 – BA | 06 – RJ
aAdd(aDados,{"ID_PROC"        ,cIDProc})                 //005 – Título Finenceiro (PARCELA)
aAdd(aDados,{"PROCES"         ,cProces})                 //DESCRIÇÃO
aAdd(aDados,{"ID_TRANS"       ,PadR(nAction,1)})         //3 - Excluir | 6 – Imprimir
aAdd(aDados,{"TRANSAC"        ,cAction})                 //DESCRIÇÃO
aAdd(aDados,{"ID_ORI"         ,'1'})                     //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MÍDIA+
aAdd(aDados,{"ID_DES"         ,cDestino})                //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MÍDIA+
aAdd(aDados,{"ID_TIT"         ,SC5->C5_PI2})             //CODIGO NO SISTEMA INTEGRADO
aAdd(aDados,{"ID_RET"         ,SC5->C5_NUM})             //NUMERO DO PEDIDO DE VENDA
aAdd(aDados,{"DATA_PROCESSO"  ,SC5->C5_EMISSAO})         //DATA DA BAIXA / CANCELAMENTO / ESTORNO

cXML := fArToXML(aDados,"PARCELA","1.0","UTF-8",@nCount)

cQuery := "INSERT INTO [INTEGRACAO].[dbo].[XML]" + Chr(13) + Chr(10)
cQuery += "           ([ID_EMP]" + Chr(13) + Chr(10)
cQuery += "           ,[ID_FIL]" + Chr(13) + Chr(10)
cQuery += "           ,[ID_PROC]" + Chr(13) + Chr(10)
cQuery += "           ,[PROCES]" + Chr(13) + Chr(10)
cQuery += "           ,[ID_TRANS]" + Chr(13) + Chr(10)
cQuery += "           ,[TRANSAC]" + Chr(13) + Chr(10)
cQuery += "           ,[ID_ORI]" + Chr(13) + Chr(10)
cQuery += "           ,[ID_DES]" + Chr(13) + Chr(10)
cQuery += "           ,[ID_ENT]" + Chr(13) + Chr(10)
cQuery += "           ,[XML_ERP]" + Chr(13) + Chr(10)
cQuery += "           ,[DATEINT]" + Chr(13) + Chr(10)
cQuery += "           ,[TIMEINT]" + Chr(13) + Chr(10)
//cQuery += "           ,[ID_RET]" + Chr(13) + Chr(10)
//cQuery += "           ,[XML_RET]" + Chr(13) + Chr(10)
//cQuery += "           ,[DATERET]" + Chr(13) + Chr(10)
//cQuery += "           ,[TIMERET]" + Chr(13) + Chr(10)
//cQuery += "           ,[XML_ERR]" + Chr(13) + Chr(10)
cQuery += "           ,[STATUS])" + Chr(13) + Chr(10)
cQuery += "     VALUES" + Chr(13) + Chr(10)
cQuery += "           ('" + cEmpAnt + "' " + Chr(13) + Chr(10) //<ID_EMP, nchar(2),>
cQuery += "           ,'" + cFilAnt + "' " + Chr(13) + Chr(10) //<ID_FIL, nchar(2),>
cQuery += "           ,'" + cIDProc + "' " + Chr(13) + Chr(10) //<ID_PROC, nchar(3),>
cQuery += "           ,'" + cProces + "' " + Chr(13) + Chr(10) //<PROCES, nchar(10),>
cQuery += "           ,'" + PadR(nAction,1) + "' " + Chr(13) + Chr(10) //<ID_TRANS, nchar(1),>
cQuery += "           ,'" + cAction + "' " + Chr(13) + Chr(10) //<TRANSAC, nchar(10),>
cQuery += "           ,'" + '1' + "' " + Chr(13) + Chr(10) //<ID_ORI, nchar(1),>
cQuery += "           ,'" + cDestino + "' " + Chr(13) + Chr(10) //<ID_DES, nchar(1),>
cQuery += "           ,'" + SC5->C5_NUM + "' " + Chr(13) + Chr(10) //<ID_ENT, nchar(8),>
cQuery += "           ,'" + cXML + "' " + Chr(13) + Chr(10) //<XML_ERP, xml,>
cQuery += "           ,'" + DtoS(Date()) + "' " + Chr(13) + Chr(10) //<DATEINT, date,>
cQuery += "           ,'" + Time() + "' " + Chr(13) + Chr(10) //<TIMEINT, time(7),>
//cQuery += "           ,'" +  + "" + Chr(13) + Chr(10) //<ID_RET, int,>
//cQuery += "           ,'" +  + "" + Chr(13) + Chr(10) //<XML_RET, xml,>
//cQuery += "           ,'" +  + "" + Chr(13) + Chr(10) //<DATERET, date,>
//cQuery += "           ,'" +  +"" + Chr(13) + Chr(10) //<TIMERET, time(7),>
//cQuery += "           ,'" +  + "" + Chr(13) + Chr(10) //<XML_ERR, xml,>
cQuery += "           ," + '0' + ")" //<STATUS, nchar(1),>

If TCSQLExec(cQuery) < 0
	MsgStop("TCSQLError() " + TCSQLError())
	lRet := .F.
Else
//	RecLock("SC5",.F.)
//		SC5->C5_MSEXP := DtoS(Date())
//	SC5->(MsUnLock())
	lRet := .T.
EndIf
Return(lRet)