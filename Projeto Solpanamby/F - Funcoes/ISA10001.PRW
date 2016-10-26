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
ฑฑบ Programa   ณ ISA10001   บ Autor ณ Alexandre Soares Reis บ Data ณ 07/06/2016 บฑฑ
ฑฑฬออออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบ Empresa    ณ Sol Panamby                                                    บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Descricao  ณ Integracao TOTVS Protheus vs Pulsar                            บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Modulo     ณ Integracao                                                     บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        ณ Integracao do cadastro de clientes                             บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros ณ INCLUI - L Indica inclusใo                                     บฑฑ
ฑฑบ            ณ ALTERA - L Indica altera็ใo                                    บฑฑ
ฑฑบ            ณ RETORNO - L Indica retorno                                     บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    ณ Nil                                                            บฑฑ
ฑฑฬออออออออออออุอออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Data       ณ Analista    ณDescricao da Alteracao                            บฑฑ
ฑฑบ============ณ=============ณ==================================================บฑฑ
ฑฑบ __/__/____ ณ ___________ ณ                                                  บฑฑ
ฑฑศออออออออออออฯอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
User Function ISA10001(lInclui,lAltera,lRetorno) //U_ISA10001(.F.,.F.,.T.)
Local aCliente := {}
Local aContatos := {}
Local aIntegra := {}
Local cAction := ""
Local cDestino := ""
Local cError := ""
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

If SM0->M0_CODIGO == "70" //TVB CAMPINAS
	cDestino := "4"
ElseIf SM0->M0_CODIGO == "75" //TVB SAO VICENTE
	cDestino := "3"
ElseIf SM0->M0_CODIGO == "80" //NOVA BRASIL FM
	cDestino := "2"
EndIf

If lRetorno
	aIntegra := U_INTPQRY( SM0->M0_CODIGO, SM0->M0_CODFIL, "001", "5" ) //RETORNO AGUARDANDO PROCESSAMENTO
	If Empty(aIntegra)
		aIntegra := U_INTPQRY( SM0->M0_CODIGO, SM0->M0_CODFIL, "001", "1" ) //PROCESSADO COM SUCESSO
	EndIf
	If ! Empty(aIntegra)
		For nX := 1 To Len(aIntegra)
			oXML := XmlParser( aIntegra[nX][15], "_", @cError, @cWarning )
			If Empty(cError) .OR. Empty(cWarning)
				SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
				If ( Type("oXML:_CLIENTE:_ID_RET:Text") == "C" .AND. ! Empty(oXML:_CLIENTE:_ID_RET:Text) ) .OR. ! Empty(aIntegra[nX][14])
					If SA1->( dbSeek( xFilial("SA1") + aIntegra[nX][10] ) )
						RecLock("SA1",.F.)
							If Type("oXML:_CLIENTE:_ID_RET:Text") == "C"
								SA1->A1_XCODEXT := oXML:_CLIENTE:_ID_RET:Text
							Else
								SA1->A1_XCODEXT := aIntegra[nX][14]
							EndIf
						SA1->(MsUnLock())

						cQuery := "UPDATE [INTEGRACAO].[dbo].[XML]" + Chr(13) + Chr(10)
						cQuery += "   SET [STATUS] = 6" + Chr(13) + Chr(10)
						cQuery += "WHERE [ID] = " + Str(aIntegra[nX][1],1) + ""

						If TCSQLExec(cQuery) < 0
							ConOut( "TCSQLError() " + TCSQLError() )
							lRet := .F.
						Else
							RecLock("SA1",.F.)
								SA1->A1_MSEXP := CtoD("")
							SA1->(MsUnLock())

							lRet := .T.
						EndIf
					EndIf
				Else
					cError := "Retorno invแlido ou nใo informado."
					cWarning := "C๓digo do cliente invแlido ou nใo informado. Favor verificar no sistema integrado se a integra็ใo foi concluํda com sucesso."
					aAdd(aErro,{"ID_EMP"   ,aIntegra[nX][2]})  //80 - RCC
					aAdd(aErro,{"ID_FIL"   ,aIntegra[nX][3]})  //01 – SP | 02 – CAMPINAS | 03 – PE | 04 – DF | 05 – BA | 06 – RJ
					aAdd(aErro,{"ID_PROC"  ,aIntegra[nX][4]})  //001 – CLIENTE
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
					cQuery += "   SET [STATUS] = 7, XML_ERR = '" + cXML + "'" + Chr(13) + Chr(10)
					cQuery += "WHERE [ID] = " + Str(aIntegra[nX][1],1) + ""

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
				aAdd(aErro,{"ID_PROC"  ,aIntegra[nX][4]})  //001 – CLIENTE
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
				cQuery += "   SET [STATUS] = 7, XML_ERR = '" + cXML + "'" + Chr(13) + Chr(10)
				cQuery += "WHERE [ID] = " + Str(aIntegra[nX][1],1) + ""

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

	aAdd(aCliente,{"ID_EMP"         ,cEmpAnt})                 //80 - RCC
	aAdd(aCliente,{"ID_FIL"         ,cFilAnt})                 //01 – SP | 02 – CAMPINAS | 03 – PE | 04 – DF | 05 – BA | 06 – RJ
	aAdd(aCliente,{"ID_PROC"        ,"001"})                   //001 – CLIENTE
	aAdd(aCliente,{"PROCES"         ,"Cliente"})               //DESCRIวรO
	aAdd(aCliente,{"ID_TRANS"       ,PadR(nAction,1)})         //1 – INCLUIR | 2 – ALTERAR | 3 – EXCLUIR
	aAdd(aCliente,{"TRANSAC"        ,cAction})                 //DESCRIวรO
	aAdd(aCliente,{"ID_ORI"         ,'1'})                     //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MอDIA+
	aAdd(aCliente,{"ID_DES"         ,cDestino})                //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MอDIA+
	aAdd(aCliente,{"ID_ENT"         ,SA1->(A1_COD + A1_LOJA)}) //CODIGO E LOJA DO CLIENTE
	aAdd(aCliente,{"COD_EXT"        ,SA1->A1_XCODEXT})         //CODIGO NO SISTEMA INTEGRADO
	aAdd(aCliente,{"RAZAO_SOCIAL"   ,SA1->A1_NOME})            //RAZรO SOCIAL
	aAdd(aCliente,{"NOME_FANTASIA"  ,SA1->A1_NREDUZ})          //NOME FANTASIA
	aAdd(aCliente,{"CNPJ"           ,SA1->A1_CGC})             //CNPJ
	aAdd(aCliente,{"PESSOA"         ,SA1->A1_PESSOA})          //PESSOA (F - FISICA | J - JURIDICA)
	aAdd(aCliente,{"TIPO"           ,SA1->A1_TIPO})            //TIPO (F - CONSUNIDOR FINAL | L - PRODUTOR RURAL | R - REVENDEDOR | S - SOLIDARIO | X - EXPORTACAO)
	aAdd(aCliente,{"TIPO_PESSOA"    ,SA1->A1_TPESSOA})         //TIPO PESSOA (CI - COMERCIO/INDUSTRIA | PF - PESSOA FISICA | OS - PRESTACAO DE SERVICO | EP - EMPRESA PUBLICA)
	aAdd(aCliente,{"TIPO_CLIENTE"   ,SA1->A1_XTPCLI})          //TIPO CLIENTE (1 - CLIENTE | 2 - AGENCIA | 3 - AMBOS)
	aAdd(aCliente,{"GRUPO"          ,SA1->A1_GRPCLI})          //GRUPO CLIENTE (0 - JURIDICA | 1 - FISICA | 2 - GOV FEDERAL | 3 - GOV ESTADUAL | 4 - (GOV MUNICIPAL)PREFEITURA | 5 - PARTIDO POLITICO)
	aAdd(aCliente,{"BLOQUEADO"      ,SA1->A1_MSBLQL})          //BLOQUEADO (1 - SIM | 2 - NAO)
	aAdd(aCliente,{"INS_ESTAD"      ,SA1->A1_INSCR})           //INS. ESTAD
	aAdd(aCliente,{"INS_MUNICIP"    ,SA1->A1_INSCRM})          //INS. MUNICIP
	aAdd(aCliente,{"ENDERECO"       ,SA1->A1_END})             //ENDEREวO
	aAdd(aCliente,{"BAIRRO"         ,SA1->A1_BAIRRO})          //BAIRRO
	aAdd(aCliente,{"COMPLEMENTO"    ,SA1->A1_COMPLEM})         //COMPLEMENTO
	aAdd(aCliente,{"CIDADE"         ,{{"CODIGO"   ,SA1->A1_COD_MUN},;
	                                  {"DESCRICAO",SA1->A1_MUN}    ,;
	                                  {"UF"       ,SA1->A1_ESTADO} };
	              })                                           //CD. MUNICIPIO,MUNICIPIO,UF
	aAdd(aCliente,{"CEP"            ,SA1->A1_CEP})             //CEP
	aAdd(aCliente,{"ENDERECO_COBRANCA"    ,SA1->A1_ENDCOB})    //ENDEREวO
	aAdd(aCliente,{"BAIRRO_COBRANCA"      ,SA1->A1_BAIRROC})   //BAIRRO
	aAdd(aCliente,{"COMPLEMENTO_COBRANCA" ,SA1->A1_COMPLEM})   //COMPLEMENTO
	aAdd(aCliente,{"CIDADE_COBRANCA"      ,{{"CODIGO"   ,"0"    },;
	                                        {"DESCRICAO",SA1->A1_MUNC},;
	                                        {"UF"       ,SA1->A1_ESTC}};
	              })                                           //CD. MUNICIPIO,MUNICIPIO,UF
	aAdd(aCliente,{"CEP_COBRANCA"   ,SA1->A1_CEPC})            //CEP
	aAdd(aCliente,{"DDD"            ,SA1->A1_DDD})             //DDD
	aAdd(aCliente,{"TELEFONE"       ,SA1->A1_TEL})             //TELEFONE
	aAdd(aCliente,{"EMAIL"          ,SA1->A1_EMAIL})           //E-MAIL
	aAdd(aCliente,{"SITE"           ,SA1->A1_HPAGE})           //HOME PAGE

	aContatos := fContatos(SA1->(A1_COD + A1_LOJA))
	aAdd(aCliente,{"CONTATOS"})
	If Len(aContatos) > 0
		For nX := 1 To Len(aContatos)
			aAdd(aCliente[Len(aCliente)],{"CONTATO", {{"ID_CONTATO"      ,aContatos[nX][01]},;
			                                          {"NOME"            ,aContatos[nX][02]},;
			                                          {"DDD"             ,aContatos[nX][03]},;
			                                          {"TEL_RESIDENCIAL" ,aContatos[nX][04]},;
			                                          {"CELULAR"         ,aContatos[nX][05]},;
			                                          {"TEL_COMERCIAL01" ,aContatos[nX][06]},;
			                                          {"TEL_COMERCIAL02" ,aContatos[nX][07]},;
			                                          {"EMAIL"           ,aContatos[nX][08]},;
			                                          {"ANIVERSARIO"     ,aContatos[nX][09]}};
			                             })
		Next(nX)
	Else
		aAdd(aCliente[Len(aCliente)],{"CONTATO", {{"ID_CONTATO"      ,""},;
		                                          {"NOME"            ,""},;
		                                          {"DDD"             ,""},;
		                                          {"TEL_RESIDENCIAL" ,""},;
		                                          {"CELULAR"         ,""},;
		                                          {"TEL_COMERCIAL01" ,""},;
		                                          {"TEL_COMERCIAL02" ,""},;
		                                          {"EMAIL"           ,""},;
		                                          {"ANIVERSARIO"     ,""}};
		                             })
	EndIf

	aAdd(aCliente,{"SEGMENTO"       ,SA1->A1_XCATAN})          //SEGMENTO
	aAdd(aCliente,{"CLASSIF_RF"     ,SA1->A1_CLASSRF})         //CLASSIF RF
	aAdd(aCliente,{"AGLUTINA_FAT"   ,SA1->A1_AGLFAT})          //AGLUTINA FAT
	aAdd(aCliente,{"GERA_BOLETO"    ,SA1->A1_GERBOL})          //GERA BOLETO
	aAdd(aCliente,{"COMPROV_INSERC" ,SA1->A1_COMPINS})         //COMP. INSERC
	aAdd(aCliente,{"GERA_CARTA"     ,SA1->A1_CART299})         //GERA CARTA
	aAdd(aCliente,{"TIPO_NEGOCIACAO","0"})                     //
	aAdd(aCliente,{"PORCENTAGEM"    ,"0"})                     //
	aAdd(aCliente,{"DATA_ABERTURA"  ,CtoD("")})                //

	cXML := fArToXML(aCliente,"CLIENTE","1.0","UTF-8",@nCount)

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
	cQuery += "           ,'" + '001' + "' " + Chr(13) + Chr(10) //<ID_PROC, nchar(3),>
	cQuery += "           ,'" + 'Cliente' + "' " + Chr(13) + Chr(10) //<PROCES, nchar(10),>
	cQuery += "           ,'" + PadR(nAction,1) + "' " + Chr(13) + Chr(10) //<ID_TRANS, nchar(1),>
	cQuery += "           ,'" + cAction + "' " + Chr(13) + Chr(10) //<TRANSAC, nchar(10),>
	cQuery += "           ,'" + '1' + "' " + Chr(13) + Chr(10) //<ID_ORI, nchar(1),>
	cQuery += "           ,'" + cDestino + "' " + Chr(13) + Chr(10) //<ID_DES, nchar(1),>
	cQuery += "           ,'" + SA1->(A1_COD + A1_LOJA) + "' " + Chr(13) + Chr(10) //<ID_ENT, nchar(8),>
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
		RecLock("SA1",.F.)
			SA1->A1_MSEXP := DtoS(Date())
		SA1->(MsUnLock())
		lRet := .T.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบ Funcao     ณ fContatos  บ Autor ณ Alexandre Soares Reis บ Data ณ 12/09/2016 บฑฑ
ฑฑฬออออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบ Descricao  ณ Fun็ใo responsแvel por retornar um Array com a lista de        บฑฑ
ฑฑบ            ณ contatos do cliente informado                                  บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros ณ cChave - C - SA1->(A1_CODIGO+A1_LOJA)                          บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    ณ aRet - A - Array com os contatos                               บฑฑ
ฑฑฬออออออออออออุอออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Data       ณ Analista    ณDescricao da Alteracao                            บฑฑ
ฑฑบ============ณ=============ณ==================================================บฑฑ
ฑฑบ __/__/____ ณ ___________ ณ                                                  บฑฑ
ฑฑศออออออออออออฯอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function fContatos(cChave)
Local aRet := {}
Local _cAlias := "WRK"
Local cEntidade := "SA1"
Default cChave := ""

BeginSQL Alias _cAlias
%NoParser%
	SELECT U5_CODCONT, U5_CONTAT, U5_DDD, U5_FONE, U5_CELULAR, U5_FCOM1, U5_FCOM2, U5_EMAIL, U5_NIVER
	FROM %Table:AC8% AS AC8
	LEFT JOIN %Table:SU5% AS SU5 ON SU5.%NotDel% AND U5_FILIAL = %XFilial:SU5% AND U5_CODCONT = AC8_CODCON
	WHERE AC8.%NotDel%
	  AND AC8_FILIAL = %XFilial:AC8%
	  AND AC8_ENTIDA = %Exp:cEntidade%
	  AND AC8.AC8_CODENT = %Exp:cChave%
	ORDER BY AC8_CODCON
EndSQL

While ! (_cAlias)->(EOF())
	aAdd(aRet,{(_cAlias)->U5_CODCONT, (_cAlias)->U5_CONTAT, (_cAlias)->U5_DDD, (_cAlias)->U5_FONE, (_cAlias)->U5_CELULAR, (_cAlias)->U5_FCOM1, (_cAlias)->U5_FCOM2, (_cAlias)->U5_EMAIL, (_cAlias)->U5_NIVER})
	(_cAlias)->(dbSkip())
EndDo

If Select(_cAlias) > 0
	(_cAlias)->(dbCloseArea())
EndIf
Return(aRet)

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