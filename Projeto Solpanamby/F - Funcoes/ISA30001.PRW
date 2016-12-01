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
		- 005 – Tํtulo Finenceiro (PARCELA)
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบ Programa   ณ ISA30001   บ Autor ณ Alexandre Soares Reis บ Data ณ 26/10/2016 บฑฑ
ฑฑฬออออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบ Empresa    ณ Sol Panamby                                                    บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Descricao  ณ Integracao TOTVS Protheus vs Pulsar                            บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Modulo     ณ Integracao                                                     บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        ณ Integracao do cadastro de vendedores                           บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros ณ INCLUI - L - Inclusใo                                          บฑฑ
ฑฑบ            ณ ALTERA - L - Altera็ใo                                         บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    ณ lRet - L - .T. OK / .F. Erro                                   บฑฑ
ฑฑฬออออออออออออุอออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Data       ณ Analista    ณDescricao da Alteracao                            บฑฑ
ฑฑบ============ณ=============ณ==================================================บฑฑ
ฑฑบ __/__/____ ณ ___________ ณ                                                  บฑฑ
ฑฑศออออออออออออฯอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
User Function ISA30001(lInclui,lAltera,lRetorno,nID)
Local aDados := {}
Local aIntegra := {}
Local cAction := ""
Local cDestino := ""
Local cError := ""
Local IDProc := "006"
Local Proces := "Vendedor"
Local cQuery := ""
Local cRetorno := ""
Local cWarning := ""
Local cXML := ""
Local lRet := .F.
Local nAction := 0
Local nX := 0
Local oXML
Private nCount := 0

Default lInclui := .F.
Default lAltera := .F.
Default lRetorno := .F.
Default nID := 0

If SM0->M0_CODIGO == "70" //TVB CAMPINAS
	cDestino := "4"
ElseIf SM0->M0_CODIGO == "75" //TVB SAO VICENTE
	cDestino := "3"
ElseIf SM0->M0_CODIGO == "80" //NOVA BRASIL FM
	cDestino := "2"
EndIf

If lRetorno
	aIntegra := U_INTPQRY( SM0->M0_CODIGO, SM0->M0_CODFIL, "006", "5", , ,nID ) //RETORNO AGUARDANDO PROCESSAMENTO
	If Empty(aIntegra)
		aIntegra := U_INTPQRY( SM0->M0_CODIGO, SM0->M0_CODFIL, "006", "1", , ,nID ) //PROCESSADO COM SUCESSO
	EndIf
	If ! Empty(aIntegra)
		For nX := 1 To Len(aIntegra)
			oXML := XmlParser( aIntegra[nX][15], "_", @cError, @cWarning )
			If Empty(cError) .OR. Empty(cWarning)
				SA3->(dbSetOrder(1)) //A3_FILIAL+A3_COD
				If ! Empty(oXML:_VENDEDOR:_ID_RET:Text) .OR. ! Empty(aIntegra[nX][14])
					If SA3->( dbSeek( xFilial("SA3") + aIntegra[nX][10] ) )
						RecLock("SA3",.F.)
							If ! Empty(oXML:_VENDEDOR:_ID_RET:Text)
								SA3->A3_XCODEXT := Trim(oXML:_VENDEDOR:_ID_RET:Text)
							Else
								SA3->A3_XCODEXT := Trim(aIntegra[nX][14])
							EndIf
						SA3->(MsUnLock())

						cQuery := "UPDATE [INTEGRACAO].[dbo].[XML]" + Chr(13) + Chr(10)
						cQuery += "   SET [STATUS] = '6'" + Chr(13) + Chr(10)
						cQuery += "WHERE [ID] = " + lTrim(Str(aIntegra[nX][1])) + ""

						If TCSQLExec(cQuery) < 0
							ConOut( "TCSQLError() " + TCSQLError() )
							lRet := .F.
						Else
							RecLock("SA3",.F.)
								SA3->A3_MSEXP := ""
							SA3->(MsUnLock())

							lRet := .T.
						EndIf
					EndIf
				Else
					cError := "Retorno invแlido ou nใo informado."
					cWarning := "C๓digo do vendedor invแlido ou nใo informado. Favor verificar no sistema integrado se a integra็ใo foi concluํda com sucesso."
					aAdd(aErro,{"ID_EMP"   ,aIntegra[nX][2]})  //80 - RCC
					aAdd(aErro,{"ID_FIL"   ,aIntegra[nX][3]})  //01 – SP | 02 – CAMPINAS | 03 – PE | 04 – DF | 05 – BA | 06 – RJ
					aAdd(aErro,{"ID_PROC"  ,aIntegra[nX][4]})  //006 – VENDEDOR
					aAdd(aErro,{"PROCES"   ,aIntegra[nX][5]})  //DESCRIวรO
					aAdd(aErro,{"ID_TRANS" ,aIntegra[nX][6]})  //1 – INCLUIR | 2 – ALTERAR | 3 – EXCLUIR
					aAdd(aErro,{"TRANSAC"  ,aIntegra[nX][7]})  //DESCRIวรO
					aAdd(aErro,{"ID_ORI"   ,aIntegra[nX][8]})  //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MอDIA+
					aAdd(aErro,{"ID_DES"   ,aIntegra[nX][9]})  //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MอDIA+
					aAdd(aErro,{"ID_ENT"   ,aIntegra[nX][10]}) //CODIGO E LOJA CLIENTE
					aAdd(aErro,{"COD_EXT"  ,aIntegra[nX][11]}) //CODIGO NO SISTEMA INTEGRADO
					aAdd(aErro,{"ERRO"     ,"Erro: " + cError + "  -  Aviso: " + cWarning})

					cXML += fArToXML(aErro,"ERRO","1.0","UTF-8",@nCount)

					cQuery := "UPDATE [INTEGRACAO].[dbo].[XML]" + Chr(13) + Chr(10)
					cQuery += "   SET [STATUS] = '7', XML_ERR = '" + cXML + "'" + Chr(13) + Chr(10)
					cQuery += "WHERE [ID] = " + lTrim(Str(aIntegra[nX][1])) + ""

					If TCSQLExec(cQuery) < 0
						ConOut( "TCSQLError() " + TCSQLError() )
						lRet := .F.
					Else
						ConOut( "Erro: " + cError + "  -  Aviso: " + cWarning )
						lRet := .F.
					EndIf
				EndIf
			Else
				aAdd(aErro,{"ID_EMP"   ,aIntegra[nX][2]})  //80 - RCC
				aAdd(aErro,{"ID_FIL"   ,aIntegra[nX][3]})  //01 – SP | 02 – CAMPINAS | 03 – PE | 04 – DF | 05 – BA | 06 – RJ
				aAdd(aErro,{"ID_PROC"  ,aIntegra[nX][4]})  //006 – VENDEDOR
				aAdd(aErro,{"PROCES"   ,aIntegra[nX][5]})  //DESCRIวรO
				aAdd(aErro,{"ID_TRANS" ,aIntegra[nX][6]})  //1 – INCLUIR | 2 – ALTERAR | 3 – EXCLUIR
				aAdd(aErro,{"TRANSAC"  ,aIntegra[nX][7]})  //DESCRIวรO
				aAdd(aErro,{"ID_ORI"   ,aIntegra[nX][8]})  //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MอDIA+
				aAdd(aErro,{"ID_DES"   ,aIntegra[nX][9]})  //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MอDIA+
				aAdd(aErro,{"ID_ENT"   ,aIntegra[nX][10]}) //CODIGO E LOJA CLIENTE
				aAdd(aErro,{"COD_EXT"  ,aIntegra[nX][11]}) //CODIGO NO SISTEMA INTEGRADO
				aAdd(aErro,{"ERRO"     ,"Erro: " + cError + "  -  Aviso: " + cWarning})

				cXML += fArToXML(aErro,"ERRO","1.0","UTF-8",@nCount)

				cQuery := "UPDATE [INTEGRACAO].[dbo].[XML]" + Chr(13) + Chr(10)
				cQuery += "   SET [STATUS] = '7', XML_ERR = '" + cXML + "'" + Chr(13) + Chr(10)
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
Else
	If lInclui
		nAction := 1
		cAction := "Inclusao"
	ElseIf lAltera
		nAction := 2
		cAction := "Alteracao"
	Else
		nAction := 3
		cAction := "Exclusao"
	EndIf

	aAdd(aDados,{"ID_EMP"         ,cEmpAnt})                 //80 - RCC
	aAdd(aDados,{"ID_FIL"         ,cFilAnt})                 //01 – SP | 02 – CAMPINAS | 03 – PE | 04 – DF | 05 – BA | 06 – RJ
	aAdd(aDados,{"ID_PROC"        ,cIDProc})                 //006 – VENDEDOR
	aAdd(aDados,{"PROCES"         ,cProces})                 //DESCRIวรO
	aAdd(aDados,{"ID_TRANS"       ,PadR(nAction,1)})         //1 – INCLUIR | 2 – ALTERAR | 3 – EXCLUIR
	aAdd(aDados,{"TRANSAC"        ,cAction})                 //DESCRIวรO
	aAdd(aDados,{"ID_ORI"         ,'1'})                     //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MอDIA+
	aAdd(aDados,{"ID_DES"         ,cDestino})                //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MอDIA+
	aAdd(aDados,{"ID_ENT"         ,SA3->A3_COD})             //CODIGO DO VENDEDOR
	aAdd(aDados,{"COD_EXT"        ,SA3->A3_XCODEXT})         //CODIGO NO SISTEMA INTEGRADO
	aAdd(aDados,{"RAZAO_SOCIAL"   ,SA3->A3_NOME})            //RAZรO SOCIAL
	aAdd(aDados,{"NOME_FANTASIA"  ,SA3->A3_NREDUZ})          //NOME FANTASIA
	aAdd(aDados,{"CNPJ"           ,SA3->A3_CGC})             //CNPJ
	aAdd(aDados,{"TIPO"           ,SA3->A3_TIPO})            //TIPO (I - INTERNO | E - EXTERNO)
	aAdd(aDados,{"TIPO_COMISSAO"  ,SA3->A3_TIPOCOM})         //TIPO COMISSAO (1 - META | 2 - ALวADA | 3 - NORMAL)
	aAdd(aDados,{"PERC_COMISSAO"  ,SA3->A3_COMIS})           //PERCENTUAL COMISSAO
	aAdd(aDados,{"PERC_COMIS_GE"  ,SA3->A3_SCOMIS})          //PERCENTUAL COMISSAO GERENTE
	aAdd(aDados,{"PERC_COMIS_SA"  ,SA3->A3_COMIS1})          //PERCENTUAL COMISSAO SEM AGENCIA
	aAdd(aDados,{"PERC_COMIS_CA"  ,SA3->A3_COMIS2})          //PERCENTUAL COMISSAO COM AGENCIA
	aAdd(aDados,{"FUNCAO"         ,SA3->A3_FUNCAO})          //FUNCAO EXERCIDA (D - DIRETOR | G - GERENTE GERAL | S - SUPERVISOR | R - REPRESENTANTE | V - VENDEDOR)
	aAdd(aDados,{"TIPO_VENDA"     ,SA3->A3_TIPVEND})         //TIPO DE VENDA (1 - COOPERATIVA | 2 - FUNCIONมRIO | 3 - CORRETORA)
//	aAdd(aDados,{"BLOQUEADO"      ,SA3->A3_MSBLQL})          //BLOQUEADO (1 - SIM | 2 - NAO)
	aAdd(aDados,{"INS_ESTAD"      ,SA3->A3_INSCR})           //INS. ESTAD
	aAdd(aDados,{"INS_MUNICIP"    ,SA3->A3_INSCRM})          //INS. MUNICIP
	aAdd(aDados,{"ENDERECO"       ,SA3->A3_END})             //ENDEREวO
	aAdd(aDados,{"BAIRRO"         ,SA3->A3_BAIRRO})          //BAIRRO
	aAdd(aDados,{"CIDADE"         ,{{"CODIGO"   ,"0"        },;
	                                {"DESCRICAO",SA3->A3_MUN},;
	                                {"UF"       ,SA3->A3_EST}};
	            })                                           //CD. MUNICIPIO,MUNICIPIO,UF
	aAdd(aDados,{"CEP"            ,SA3->A3_CEP})             //CEP
	aAdd(aDados,{"DDD"            ,SA3->A3_DDDTEL})          //DDD
	aAdd(aDados,{"TELEFONE"       ,SA3->A3_TEL})             //TELEFONE
	aAdd(aDados,{"CELULAR"        ,SA3->A3_CEL})             //CELULAR
	aAdd(aDados,{"EMAIL"          ,SA3->A3_EMAIL})           //E-MAIL
	aAdd(aDados,{"SITE"           ,SA3->A3_HPAGE})           //HOME PAGE

	cXML := fArToXML(aDados,"VENDEDOR","1.0","UTF-8",@nCount)

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
//	cQuery += "           ,[ID_RET]" + Chr(13) + Chr(10)
//	cQuery += "           ,[XML_RET]" + Chr(13) + Chr(10)
//	cQuery += "           ,[DATERET]" + Chr(13) + Chr(10)
//	cQuery += "           ,[TIMERET]" + Chr(13) + Chr(10)
//	cQuery += "           ,[XML_ERR]" + Chr(13) + Chr(10)
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
	cQuery += "           ,'" + SA3->A3_COD + "' " + Chr(13) + Chr(10) //<ID_ENT, nchar(8),>
	cQuery += "           ,'" + cXML + "' " + Chr(13) + Chr(10) //<XML_ERP, xml,>
	cQuery += "           ,'" + DtoS(Date()) + "' " + Chr(13) + Chr(10) //<DATEINT, date,>
	cQuery += "           ,'" + Time() + "' " + Chr(13) + Chr(10) //<TIMEINT, time(7),>
//	cQuery += "           ,'" +  + "" + Chr(13) + Chr(10) //<ID_RET, int,>
//	cQuery += "           ,'" +  + "" + Chr(13) + Chr(10) //<XML_RET, xml,>
//	cQuery += "           ,'" +  + "" + Chr(13) + Chr(10) //<DATERET, date,>
//	cQuery += "           ,'" +  +"" + Chr(13) + Chr(10) //<TIMERET, time(7),>
//	cQuery += "           ,'" +  + "" + Chr(13) + Chr(10) //<XML_ERR, xml,>
	cQuery += "           ," + '0' + ")" //<STATUS, nchar(1),>

	If TCSQLExec(cQuery) < 0
		MsgStop("TCSQLError() " + TCSQLError())
		lRet := .F.
	Else
		RecLock("SA3",.F.)
			SA3->A3_MSEXP := DtoS(Date())
		SA3->(MsUnLock())
		lRet := .T.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบ Funcao     ณ fArToXML   บ Autor ณ Alexandre Soares Reis บ Data ณ 07/06/2016 บฑฑ
ฑฑฬออออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบ Descricao  ณ Fun็ใo responsแvel por converter um Array para XML com op็ใo   บฑฑ
ฑฑบ            ณ de chamada recursiva                                           บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros ณ aXML       - A - Arry com os dados do XML                      บฑฑ
ฑฑบ            ณ cTagPai    - S - Nome da TAG PAI                               บฑฑ
ฑฑบ            ณ cVersion   - S - Versใo do XML                                 บฑฑ
ฑฑบ            ณ cEncoding  - S - Tipo de codifica็ใo utilizada                 บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    ณ cRet - C - String do XML                                       บฑฑ
ฑฑฬออออออออออออุอออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Data       ณ Analista    ณDescricao da Alteracao                            บฑฑ
ฑฑบ============ณ=============ณ==================================================บฑฑ
ฑฑบ __/__/____ ณ ___________ ณ                                                  บฑฑ
ฑฑศออออออออออออฯอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function fArToXML(aXML,cTagPai,cVersion,cEncoding,nCount)
Local cRet := ""
Local nX := 0

Default aXML := {}
Default cTagPai := ""
Default cVersion := "1.0"
Default cEncoding := "UTF-8"
//Default lRecursiva := .F. //IsInCallStack("fArToXML")

nCount ++
For nX := 1 To Len(aXML)
	If ValType(aXML[nX]) == "C"
		cRet += '<' + cTagPai + '>' + Chr(13) + Chr(10)
		cRet += fArToXML(aXML[2],aXML[1],"","",@nCount)
		cRet += '</' + cTagPai + '>' + If(nCount > 1,Chr(13) + Chr(10),'')
		Exit
	Else
		If nX == 1
			If nCount == 1
				cRet += '<?xml version="' + cVersion + '" encoding="' + cEncoding + '" ?>' + Chr(13) + Chr(10)
			EndIf
			cRet += '<' + cTagPai + '>' + Chr(13) + Chr(10)
		EndIf

		If ValType(aXML[nX][2]) != "A"
			cRet += '<' + aXML[nX][1] + '>'
		EndIf
		If ValType(aXML[nX][2]) == "A"
			cRet += fArToXML(aXML[nX][2],aXML[nX][1],"","",@nCount)
		ElseIf ValType(aXML[nX][2]) == "C"
			cRet += '<![CDATA[' + AllTrim(aXML[nX][2]) + ']]>'
		ElseIf ValType(aXML[nX][2]) == "D"
			cRet += '<![CDATA[' + DtoC(aXML[nX][2]) + ']]>'
		ElseIf ValType(aXML[nX][2]) == "L"
			cRet += '<![CDATA[' + If(aXML[nX][2], "true", "false") + ']]>'
		ElseIf ValType(aXML[nX][2]) == "N"
			cRet += '<![CDATA[' + AllTrim(Str(aXML[nX][2])) + ']]>'
		Else
			cRet += ''
		EndIf
		If ValType(aXML[nX][2]) != "A"
			cRet += '</' + aXML[nX][1] + '>' + Chr(13) + Chr(10)
		EndIf

		If nX == Len(aXML)
			cRet += '</' + cTagPai + '>' + If(nCount > 1,Chr(13) + Chr(10),'')
		EndIf
	EndIf
Next(nX)
nCount--
Return(cRet)