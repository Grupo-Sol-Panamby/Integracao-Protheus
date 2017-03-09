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
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   ³ ISA10001   º Autor ³ Alexandre Soares Reis º Data ³ 07/06/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Empresa    ³ Sol Panamby                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ Integracao TOTVS Protheus vs Sistemas Legados das empresas de  º±±
±±º            ³ Comunicacao                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Modulo     ³ SIGAFAT                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        ³ Integracao do cadastro de clientes                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros ³ INCLUI - L - Inclusão                                          º±±
±±º            ³ ALTERA - L - Alteração                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    ³ lRet - L - .T. OK / .F. Erro                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Data       ³ Analista    ³Descricao da Alteracao                            º±±
±±º============³=============³==================================================º±±
±±º __/__/____ ³ ___________ ³                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
User Function ISA10001(lInclui,lAltera,cOpc,lRetorno,nID) //U_ISA10001(.F.,.F.,.T.)
Local aDados := {}
Local aContatos := {}
Local aIntegra := {}
Local cAction := ""
Local cDestino := ""
Local cError := ""
Local cIDProc := "001"
Local cProces := "Cliente"
Local cQuery := ""
Local cRetorno := ""
Local cWarning := ""
Local cXML := ""
Local lRet := .F.
Local nAction := 0
Local nX := 0
Local nCount := 0
Local oXML

Default lInclui := .F.
Default lAltera := .F.
Default cOpc := ""
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
	aIntegra := U_FQRYXML( SM0->M0_CODIGO, SM0->M0_CODFIL, "001", "5", , ,nID ) //RETORNO AGUARDANDO PROCESSAMENTO
//	If Empty(aIntegra)
//		aIntegra := U_FQRYXML( SM0->M0_CODIGO, SM0->M0_CODFIL, "001", "1", , ,nID ) //PROCESSADO COM SUCESSO
//	EndIf
	If ! Empty(aIntegra)
		For nX := 1 To Len(aIntegra)
			oXML := XmlParser( aIntegra[nX][15], "_", @cError, @cWarning )
			If Empty(cError) .OR. Empty(cWarning)
				If ValType( oXML:_CLIENTE ) <> "U"
					SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
					If ! Empty(oXML:_CLIENTE:_ID_RET:Text) .OR. ! Empty(aIntegra[nX][14])
						If SA1->( dbSeek( xFilial("SA1") + aIntegra[nX][10] ) )
							RecLock("SA1",.F.)
								If ! Empty(oXML:_CLIENTE:_ID_RET:Text)
									SA1->A1_XCODEXT := Trim(oXML:_CLIENTE:_ID_RET:Text)
								Else
									SA1->A1_XCODEXT := Trim(aIntegra[nX][14])
								EndIf
							SA1->(MsUnLock())

							cQuery := "UPDATE [INTEGRACAO].[dbo].[XML]" + Chr(13) + Chr(10)
							cQuery += "   SET [STATUS] = '6'" + Chr(13) + Chr(10)
							cQuery += "WHERE [ID] = " + lTrim(Str(aIntegra[nX][1])) + ""

							If TCSQLExec(cQuery) < 0
								ConOut( "TCSQLError() " + TCSQLError() )
								lRet := .F.
							Else
								RecLock("SA1",.F.)
									SA1->A1_MSEXP := ""
								SA1->(MsUnLock())

								lRet := .T.
							EndIf
						EndIf
					Else
						cError := "Retorno inválido ou não informado."
						cWarning := "Código do cliente inválido ou não informado. Favor verificar no sistema integrado se a integração foi concluída com sucesso."
						aAdd(aErro,{"ID_EMP"   ,aIntegra[nX][2]})  //80 - RCC
						aAdd(aErro,{"ID_FIL"   ,aIntegra[nX][3]})  //01 – SP | 02 – CAMPINAS | 03 – PE | 04 – DF | 05 – BA | 06 – RJ
						aAdd(aErro,{"ID_PROC"  ,aIntegra[nX][4]})  //001 – CLIENTE
						aAdd(aErro,{"PROCES"   ,aIntegra[nX][5]})  //DESCRIÇÃO
						aAdd(aErro,{"ID_TRANS" ,aIntegra[nX][6]})  //1 – INCLUIR | 2 – ALTERAR | 3 – EXCLUIR
						aAdd(aErro,{"TRANSAC"  ,aIntegra[nX][7]})  //DESCRIÇÃO
						aAdd(aErro,{"ID_ORI"   ,aIntegra[nX][8]})  //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MÍDIA+
						aAdd(aErro,{"ID_DES"   ,aIntegra[nX][9]})  //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MÍDIA+
						aAdd(aErro,{"ID_ENT"   ,aIntegra[nX][10]}) //CODIGO E LOJA CLIENTE
						aAdd(aErro,{"COD_EXT"  ,aIntegra[nX][11]}) //CODIGO NO SISTEMA INTEGRADO
						aAdd(aErro,{"ERRO"     ,"Erro: " + cError + "  -  Aviso: " + cWarning})

						cXML += U_fArToXML(aErro, "ERRO", "1.0", "UTF-8", @nCount)

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
					lRet := .F.
					aAdd(aErro, {"ERRO"     , "Erro: " + "XML DE CLIENTE COM FORMATO INVALIDO"})
				EndIf
			Else
				aAdd(aErro,{"ID_EMP"   ,aIntegra[nX][2]})  //80 - RCC
				aAdd(aErro,{"ID_FIL"   ,aIntegra[nX][3]})  //01 – SP | 02 – CAMPINAS | 03 – PE | 04 – DF | 05 – BA | 06 – RJ
				aAdd(aErro,{"ID_PROC"  ,aIntegra[nX][4]})  //001 – CLIENTE
				aAdd(aErro,{"PROCES"   ,aIntegra[nX][5]})  //DESCRIÇÃO
				aAdd(aErro,{"ID_TRANS" ,aIntegra[nX][6]})  //1 – INCLUIR | 2 – ALTERAR | 3 – EXCLUIR
				aAdd(aErro,{"TRANSAC"  ,aIntegra[nX][7]})  //DESCRIÇÃO
				aAdd(aErro,{"ID_ORI"   ,aIntegra[nX][8]})  //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MÍDIA+
				aAdd(aErro,{"ID_DES"   ,aIntegra[nX][9]})  //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MÍDIA+
				aAdd(aErro,{"ID_ENT"   ,aIntegra[nX][10]}) //CODIGO E LOJA CLIENTE
				aAdd(aErro,{"COD_EXT"  ,aIntegra[nX][11]}) //CODIGO NO SISTEMA INTEGRADO
				aAdd(aErro,{"ERRO"     ,"Erro: " + cError + "  -  Aviso: " + cWarning})

				cXML += U_fArToXML(aErro, "ERRO", "1.0", "UTF-8", @nCount)

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
	If Empty(cOpc)
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
	ElseIf cOpc == "1"
		nAction := 4
		cAction := "Bloquear"
		cOpc := ""
	ElseIf cOpc == "2"
		nAction := 5
		cAction := "Desbloquear"
		cOpc := ""
	EndIf

	aAdd(aDados,{"ID_EMP"         ,cEmpAnt})                 //80 - RCC
	aAdd(aDados,{"ID_FIL"         ,cFilAnt})                 //01 – SP | 02 – CAMPINAS | 03 – PE | 04 – DF | 05 – BA | 06 – RJ
	aAdd(aDados,{"ID_PROC"        ,cIDProc})                 //001 – CLIENTE
	aAdd(aDados,{"PROCES"         ,cProces})                 //DESCRIÇÃO
	aAdd(aDados,{"ID_TRANS"       ,PadR(nAction,1)})         //1 – INCLUIR | 2 – ALTERAR | 3 – EXCLUIR
	aAdd(aDados,{"TRANSAC"        ,cAction})                 //DESCRIÇÃO
	aAdd(aDados,{"ID_ORI"         ,'1'})                     //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MÍDIA+
	aAdd(aDados,{"ID_DES"         ,cDestino})                //1 - PROTHEUS | 2 - PULSAR | 3 - SCTV | 4 - MÍDIA+
	aAdd(aDados,{"ID_ENT"         ,SA1->(A1_COD + A1_LOJA)}) //CODIGO E LOJA DO CLIENTE
	aAdd(aDados,{"COD_EXT"        ,SA1->A1_XCODEXT})         //CODIGO NO SISTEMA INTEGRADO
	aAdd(aDados,{"RAZAO_SOCIAL"   ,SA1->A1_NOME})            //RAZÃO SOCIAL
	aAdd(aDados,{"NOME_FANTASIA"  ,SA1->A1_NREDUZ})          //NOME FANTASIA
	aAdd(aDados,{"CNPJ"           ,SA1->A1_CGC})             //CNPJ
	aAdd(aDados,{"PESSOA"         ,SA1->A1_PESSOA})          //PESSOA (F - FISICA | J - JURIDICA)
	aAdd(aDados,{"TIPO"           ,SA1->A1_TIPO})            //TIPO (F - CONSUNIDOR FINAL | L - PRODUTOR RURAL | R - REVENDEDOR | S - SOLIDARIO | X - EXPORTACAO)
	aAdd(aDados,{"TIPO_PESSOA"    ,SA1->A1_TPESSOA})         //TIPO PESSOA (CI - COMERCIO/INDUSTRIA | PF - PESSOA FISICA | OS - PRESTACAO DE SERVICO | EP - EMPRESA PUBLICA)
	aAdd(aDados,{"TIPO_CLIENTE"   ,SA1->A1_XTPCLI})          //TIPO CLIENTE (1 - CLIENTE | 2 - AGENCIA | 3 - AMBOS)
	aAdd(aDados,{"GRUPO"          ,SA1->A1_GRPCLI})          //GRUPO CLIENTE (01 - AGENCIA | 02 - BANCO PRIVADO | 03 - CARTORIO | 04 - CLIENTE | 05 - GOV EST | 06 - GOV FED | 07 - GOV MUN | 08 - GOV MISTO | 09 - INTERCOMPANY | 10 - SHOPPING | 11 - PARTIDO POLITICO)
	aAdd(aDados,{"BLOQUEADO"      ,SA1->A1_MSBLQL})          //BLOQUEADO (1 - SIM | 2 - NAO)
	aAdd(aDados,{"INS_ESTAD"      ,SA1->A1_INSCR})           //INS. ESTAD
	aAdd(aDados,{"INS_MUNICIP"    ,SA1->A1_INSCRM})          //INS. MUNICIP
	aAdd(aDados,{"ENDERECO"       ,SA1->A1_END})             //ENDEREÇO
	aAdd(aDados,{"BAIRRO"         ,SA1->A1_BAIRRO})          //BAIRRO
	aAdd(aDados,{"COMPLEMENTO"    ,SA1->A1_COMPLEM})         //COMPLEMENTO
	aAdd(aDados,{"CIDADE"         ,{{"CODIGO"   ,SA1->A1_COD_MUN},;
	                                {"DESCRICAO",SA1->A1_MUN}    ,;
	                                {"UF"       ,SA1->A1_ESTADO} };
	            })                                           //CD. MUNICIPIO,MUNICIPIO,UF
	aAdd(aDados,{"CEP"            ,SA1->A1_CEP})             //CEP
	aAdd(aDados,{"ENDERECO_COBRANCA"    ,SA1->A1_ENDCOB})    //ENDEREÇO
	aAdd(aDados,{"BAIRRO_COBRANCA"      ,SA1->A1_BAIRROC})   //BAIRRO
	aAdd(aDados,{"COMPLEMENTO_COBRANCA" ,SA1->A1_COMPLEM})   //COMPLEMENTO
	aAdd(aDados,{"CIDADE_COBRANCA"      ,{{"CODIGO"   ,"0"    },;
	                                      {"DESCRICAO",SA1->A1_MUNC},;
	                                      {"UF"       ,SA1->A1_ESTC}};
	            })                                           //CD. MUNICIPIO,MUNICIPIO,UF
	aAdd(aDados,{"CEP_COBRANCA"   ,SA1->A1_CEPC})            //CEP
	aAdd(aDados,{"DDD"            ,SA1->A1_DDD})             //DDD
	aAdd(aDados,{"TELEFONE"       ,SA1->A1_TEL})             //TELEFONE
	aAdd(aDados,{"EMAIL"          ,SA1->A1_EMAIL})           //E-MAIL
	aAdd(aDados,{"SITE"           ,SA1->A1_HPAGE})           //HOME PAGE

	aContatos := fContatos(SA1->(A1_COD + A1_LOJA))
	aAdd(aDados,{"CONTATOS"})
	If Len(aContatos) > 0
		For nX := 1 To Len(aContatos)
			aAdd(aDados[Len(aDados)],{"CONTATO", {{"ID_CONTATO"      ,aContatos[nX][01]},;
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
		aAdd(aDados[Len(aDados)],{"CONTATO", {{"ID_CONTATO"      ,""},;
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

	aAdd(aDados,{"SEGMENTO"       ,SA1->A1_XCATAN})          //SEGMENTO
	aAdd(aDados,{"CLASSIF_RF"     ,SA1->A1_CLASSRF})         //CLASSIF RF
	aAdd(aDados,{"AGLUTINA_FAT"   ,SA1->A1_AGLFAT})          //AGLUTINA FAT
	aAdd(aDados,{"GERA_BOLETO"    ,SA1->A1_GERBOL})          //GERA BOLETO
	aAdd(aDados,{"COMPROV_INSERC" ,SA1->A1_COMPINS})         //COMP. INSERC
	aAdd(aDados,{"GERA_CARTA"     ,SA1->A1_CART299})         //GERA CARTA
	aAdd(aDados,{"TIPO_NEGOCIACAO","0"})                     //
	aAdd(aDados,{"PORCENTAGEM"    ,"0"})                     //
	aAdd(aDados,{"DATA_ABERTURA"  ,CtoD("")})                //

	cXML := U_fArToXML(aDados, "CLIENTE", "1.0", "UTF-8", @nCount)

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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao     ³ fContatos  º Autor ³ Alexandre Soares Reis º Data ³ 12/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ Função responsável por retornar um Array com a lista de        º±±
±±º            ³ contatos do cliente informado                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros ³ cChave - C - SA1->(A1_CODIGO+A1_LOJA)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    ³ aRet - A - Array com os contatos                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Data       ³ Analista    ³Descricao da Alteracao                            º±±
±±º============³=============³==================================================º±±
±±º __/__/____ ³ ___________ ³                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
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