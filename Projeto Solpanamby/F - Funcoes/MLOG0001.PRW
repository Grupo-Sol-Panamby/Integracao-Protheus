#Include "Totvs.ch"

/*/{Protheus.doc} MLOG0001
@description	Tela com Log de integracoes (ERP x Pulsar)
@author			Amedeo D. Paoli Filho
@version		1.0
@return			Nil
@type			Function
/*/
User Function MLOG0001()
Local aArea := GetArea()
Local lRetorno := .T.

Private lBtnFil := .F.

While lRetorno
	lBtnFil := .F.
	lRetorno := TelaPar()

	If ! lBtnFil
		Exit
	EndIf
EndDo

RestArea( aArea )
Return(Nil)

/*/{Protheus.doc} TelaPar
@description	Tela de parametros LOGS de integracao
@author			Amedeo D. Paoli Filho
@version		1.0
@return			Nil
@type			Function
/*/
Static Function TelaPar()
Local aRet := {}
Local aParamBox := {}
Local lRetorno := .T.

Private cTitulo := "Monitor de Logs de Integração Protheus" + If(SM0->M0_CODIGO == "80", " vs Pulsar",If(SM0->M0_CODIGO == "75", " vs SCTV",""))
Private cCadastro := cTitulo

aAdd( aParamBox, { 1,"Data de Integração De"	,dDatabase,"","","","",0,.T. } )
aAdd( aParamBox, { 1,"Data de Integração Até"	,dDatabase,"","","","",0,.T. } )

aAdd( aParamBox, { 5,"Cliente"			,.T.,100,"",.F. } )
aAdd( aParamBox, { 5,"Faturamento"		,.T.,100,"",.F. } )
aAdd( aParamBox, { 5,"Pedido de Venda"	,.T.,100,"",.F. } )
aAdd( aParamBox, { 5,"Nota Fsical"		,.T.,100,"",.F. } )
aAdd( aParamBox, { 5,"Título Financeiro",.T.,100,"",.F. } )
aAdd( aParamBox, { 5,"Vendedor"			,.T.,100,"",.F. } )

If ParamBox( aParamBox,"",@aRet, { ||VldPar( aRet ) } )
	Monitor( aRet )
Else
	lRetorno := .F.
EndIf
Return(lRetorno)

/*/{Protheus.doc} VldPar
@description	Valida Parametros
@author			Amedeo D. Paoli Filho
@version		1.0
@return			Nil
@type			Function
/*/
Static Function VldPar( aRet )
Local lRetorno := .T.

If ! aRet[3] .AND. ! aRet[4] .AND. ! aRet[5] .AND. ! aRet[6]
	lRetorno := .F.
	Alert( "Pelo menos um processo deve ser selecionado, verifique" )
EndIf
Return(lRetorno)

/*/{Protheus.doc} Monitor
@description	Tela de Monitor de LOG
@author			Amedeo D. Paoli Filho
@version		1.0
@return			Nil
@type			Function
/*/
Static Function Monitor( aParam )
Local oFontLeg := TFont():New("Verdana",,012,,.T.,,,,,.F.,.F.)
Local oFontPan := TFont():New("Verdana",,012,,.T.,,,,,.F.,.F.)
Local bCarga := { || FwMsgRun( ,{|| RefBrowse( @aLbxLog, @oLbxLog, dDataDe, dDataAte, aFiltro ) }, , 'Atualizando dados, Por favor aguarde' ) }
Local bReproc := { || FwMsgRun( ,{|| U_fProcess( .F., Left(aLbxLog[oLbxLog:nAt,03],3), aLbxLog[oLbxLog:nAt,02] ) }, , 'Reprocessando dados, Por favor aguarde' ) }
Local aSize := MsAdvSize( .F. )
Local dDataDe := aParam[1]
Local dDataAte := aParam[2]
Local aFiltro := {}
Local aLbxLog := {}
Local oLbxLog := Nil
Local oDlg := Nil
Local oFWLayer := Nil
Local oWin1 := Nil
Local oWin2 := Nil

//Define o filtro
If aParam[03] //Cliente
	aAdd( aFiltro, "001" )
EndIf
If aParam[04] //Faturamento
	aAdd( aFiltro, "002" )
EndIf
If aParam[05] //Pedido de Venda
	aAdd( aFiltro, "003" )
EndIf
If aParam[06] //Nota Fiscal
	aAdd( aFiltro, "004" )
EndIf
If aParam[07] //Título Finenceiro (PARCELA)
	aAdd( aFiltro, "005" )
EndIf
If aParam[07] //Vendedor
	aAdd( aFiltro, "006" )
EndIf

DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],aSize[1] TO aSize[6],aSize[5] OF oMainWnd STYLE nOR( WS_VISIBLE,WS_POPUP ) PIXEL
	oDlg:lEscClose := .F.

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg,.F.)

	oFWLayer:AddCollumn("Col01",06,.T.)
	oFWLayer:AddCollumn("Col02",94,.T.)

	oFWLayer:AddWindow("Col01","Win01"	,"Açoes"	,100,.F.,.F.,/*bAction*/,/*cIDLine*/,/*bGotFocus*/)
	oFWLayer:AddWindow("Col02","Win02"	,cTitulo	,080,.F.,.F.,/*bAction*/,/*cIDLine*/,/*bGotFocus*/)
	oFWLayer:AddWindow("Col02","Win03"	,"Status"	,020,.T.,.F.,/*bAction*/,/*cIDLine*/,/*bGotFocus*/)

	oWin1 := oFWLayer:GetWinPanel('Col01','Win01')
	oWin2 := oFWLayer:GetWinPanel('Col02','Win02')
	oWin3 := oFWLayer:GetWinPanel('Col02','Win03')

	@ 000, 000 BTNBMP oBtnRefre	RESNAME "RELOAD"	SIZE 010, 040 OF oWin1 MESSAGE "Refresh"
	oBtnRefre:bAction := { || Eval( bCarga ) }
	oBtnRefre:Align := CONTROL_ALIGN_TOP

	@ 000, 000 BTNBMP oBtnVeroc	RESNAME "HISTORIC"	SIZE 010, 040 OF oWin1 MESSAGE "Ver Ocorrencias"
	oBtnVeroc:bAction := { || VisLog( oLbxLog ) }
	oBtnVeroc:Align := CONTROL_ALIGN_TOP

	@ 000, 000 BTNBMP oBtnFilt	RESNAME "FILTRO1"	SIZE 010, 040 OF oWin1 MESSAGE "Filtro Inicial"
	oBtnFilt:Align := CONTROL_ALIGN_TOP
	oBtnFilt:bAction := { || lBtnFil := .T., oDlg:End() }

	@ 000, 000 BTNBMP oBtnRepr	RESNAME "SduAppend"	SIZE 010, 040 OF oWin1 MESSAGE "Reprocessar integraçao"
	oBtnRepr:Align := CONTROL_ALIGN_TOP
	oBtnRepr:bAction := { || Eval( bReproc ), Eval( bCarga ) }

	@ 000, 000 BTNBMP oBtnSair	RESNAME "FINAL"		SIZE 010, 040 OF oWin1 MESSAGE "Sair"
	oBtnSair:Align := CONTROL_ALIGN_TOP
	oBtnSair:bAction := { || oDlg:End() }

	//ListBox
	@ 000, 000 LISTBOX oLbxLog Fields HEADER "","ID","Processo","Transação","Origem","Destino","Entidade","Data Int.","Hora Int.","Retorno","Data Fim","Hora Fim" SIZE 340, 219 OF oWin2 PIXEL ColSizes 20,20
	oLbxLog:Align := CONTROL_ALIGN_ALLCLIENT
	oLbxLog:nScrollType := 1
	Eval( bCarga )

	//Legendas
	//1 Coluna
	@ 002,006 BITMAP oBmp RESNAME "BR_AMARELO"	SIZE 16,16 NOBORDER OF oWin3 PIXEL
	TSay():New(002, 016, { || "Aguardando Processamento"			}	,oWin3,,oFontLeg,.F.,.F.,.F.,.T.,,,GetTextWidth(0,"Aguardando Processamento")	,15,.F.,.F.,.F.,.F.,.F.)

	@ 013,006 BITMAP oBmp RESNAME "BR_VERDE"	SIZE 16,16 NOBORDER OF oWin3 PIXEL
	TSay():New(013, 016, { || "Processado com Sucesso"				}	,oWin3,,oFontLeg,.F.,.F.,.F.,.T.,,,GetTextWidth(0,"Processado com Sucesso")		,15,.F.,.F.,.F.,.F.,.F.)

	@ 024,006 BITMAP oBmp RESNAME "BR_VERMELHO"	SIZE 16,16 NOBORDER OF oWin3 PIXEL
	TSay():New(024, 016, { || "Processado com Erro"					}	,oWin3,,oFontLeg,.F.,.F.,.F.,.T.,,,GetTextWidth(0,"Processado com Erro")		,15,.F.,.F.,.F.,.F.,.F.)

	//2 Coluna
	@ 002,106 BITMAP oBmp RESNAME "BR_LARANJA"	SIZE 16,16 NOBORDER OF oWin3 PIXEL
	TSay():New(002, 116, { || "Retorno aguardando processamento"	}	,oWin3,,oFontLeg,.F.,.F.,.F.,.T.,,,GetTextWidth(0,"Aguardando Processamento")	,15,.F.,.F.,.F.,.F.,.F.)

	@ 013,106 BITMAP oBmp RESNAME "BR_AZUL"		SIZE 16,16 NOBORDER OF oWin3 PIXEL
	TSay():New(013, 116, { || "Retorno processado com Sucesso"		}	,oWin3,,oFontLeg,.F.,.F.,.F.,.T.,,,GetTextWidth(0,"Processado com Sucesso")		,15,.F.,.F.,.F.,.F.,.F.)

	@ 024,106 BITMAP oBmp RESNAME "BR_MARROM"	SIZE 16,16 NOBORDER OF oWin3 PIXEL
	TSay():New(024, 116, { || "Retorno processado com Erro"			}	,oWin3,,oFontLeg,.F.,.F.,.F.,.T.,,,GetTextWidth(0,"Processado com Erro")		,15,.F.,.F.,.F.,.F.,.F.)
ACTIVATE MSDIALOG oDlg CENTERED
Return(Nil)

/*/{Protheus.doc} RefBrowse
@description	Carga / Refresh na listbox de logs
@author			Amedeo D. Paoli Filho
@version		1.0
@return			Nil
@type			Function
/*/
Static Function RefBrowse( aLbxLog, oLbxLog, dDataDe, dDataAte, aFiltro )
Local oLegenda := LoadBitmap( GetResources(), "BR_CINZA")
Local cProces := ""
Local cTransa := ""
Local cOrigem := ""
Local aRetAux := {}
Local aLbxLog := {}
Local lVazio := .T.
Local nX := 0
Local nY := 0

//Chama funcao de retorno de Query
For nX := 1 To Len( aFiltro )
	aRetAux := U_FQRYXML( cEmpAnt, cFilAnt, aFiltro[nX], Nil, dDataDe, dDataAte, Nil )

	If Len( aRetAux ) > 0
		lVazio := .F.

		For nY := 1 To Len( aRetAux )
			//Status
			If Alltrim( aRetAux[nY][19] ) == "0"
				oLegenda := LoadBitmap( GetResources(), "BR_AMARELO" )
			ElseIf Alltrim( aRetAux[nY][19] ) == "1"
				oLegenda := LoadBitmap( GetResources(), "BR_VERDE" )
			ElseIf Alltrim( aRetAux[nY][19] ) == "2"
				oLegenda := LoadBitmap( GetResources(), "BR_VERMELHO" )
			ElseIf Alltrim( aRetAux[nY][19] ) == "5"
				oLegenda := LoadBitmap( GetResources(), "BR_LARANJA" )
			ElseIf Alltrim( aRetAux[nY][19] ) == "6"
				oLegenda := LoadBitmap( GetResources(), "BR_AZUL" )
			ElseIf Alltrim( aRetAux[nY][19] ) == "7"
				oLegenda := LoadBitmap( GetResources(), "BR_MARROM" )
			Else
				oLegenda := LoadBitmap( GetResources(), "BR_CINZA" )
			EndIf

			//Processo
			If Alltrim( aRetAux[nY][04] ) == "001"
				cProces := "001 - Cliente"
			ElseIf Alltrim( aRetAux[nY][04] ) == "002"
				cProces := "002 - Faturamento"
			ElseIf Alltrim( aRetAux[nY][04] ) == "003"
				cProces := "003 - Pedido de Venda"
			ElseIf Alltrim( aRetAux[nY][04] ) == "004"
				cProces := "004 - Nota Fiscal"
			ElseIf Alltrim( aRetAux[nY][04] ) == "005"
				cProces := "005 - Título Financeiro"
			ElseIf Alltrim( aRetAux[nY][04] ) == "006"
				cProces := "006 - Vendedor"
			EndIf

			//Transacao
			If Alltrim( aRetAux[nY][06] ) == "1"
				cTransa := "1 - Inclusão"
			ElseIf Alltrim( aRetAux[nY][06] ) == "2"
				cTransa := "2 - Alteração"
			ElseIf Alltrim( aRetAux[nY][06] ) == "3"
				cTransa := "3 - Exclusão"
			ElseIf Alltrim( aRetAux[nY][06] ) == "4"
				cTransa := "4 - Bloqueio"
			ElseIf Alltrim( aRetAux[nY][06] ) == "5"
				cTransa := "5 - Desbloqueio"
			ElseIf Alltrim( aRetAux[nY][06] ) == "6"
				cTransa := "6 - Imprimissão"
			ElseIf Alltrim( aRetAux[nY][06] ) == "7"
				cTransa := "7 - Baixa"
			ElseIf Alltrim( aRetAux[nY][06] ) == "8"
				cTransa := "8 - Cancelamento"
			EndIf

			//Origem
			If Alltrim( aRetAux[nY][08] ) == "1"
				cOrigem := "1 - Protheus"
			ElseIf Alltrim( aRetAux[nY][08] ) == "2"
				cOrigem := "2 - Pulsar"
			ElseIf Alltrim( aRetAux[nY][08] ) == "3"
				cOrigem := "3 - SCTV"
			ElseIf Alltrim( aRetAux[nY][08] ) == "4"
				cOrigem := "4 - Mídia+"
			EndIf

			//Origem
			If Alltrim( aRetAux[nY][09] ) == "1"
				cDestino := "1 - Protheus"
			ElseIf Alltrim( aRetAux[nY][09] ) == "2"
				cDestino := "2 - Pulsar"
			ElseIf Alltrim( aRetAux[nY][09] ) == "3"
				cDestino := "3 - SCTV"
			ElseIf Alltrim( aRetAux[nY][09] ) == "4"
				cDestino := "4 - Mídia+"
			EndIf

			aAdd( aLbxLog, {oLegenda,;										//[19] - Legenda
							aRetAux[nY][01],;								//[01] - ID
							cProces,;										//[04] - Processo
							cTransa,;										//[06] - Transacao
							cOrigem,;										//[08] - Origem
							cDestino,;										//[09] - Destino
							aRetAux[nY][10],;								//[10] - Entidade
							StoD( StrTran( aRetAux[nY][12], "-","" ) ),;	//[12] - Data da Integracao
							SubStr( aRetAux[nY][13], 1, 8 ),;				//[13] - Hora da Integracao
							aRetAux[nY][14],;								//[14] - Retorno
							StoD( StrTran( aRetAux[nY][16], "-","" ) ),;	//[16] - Data Fim
							SubStr( aRetAux[nY][17], 1, 8 ),;				//[17] - Hora Fim
							aRetAux[nY][11],;								//[11] - XML Enviado
							aRetAux[nY][15],;								//[15] - XML Retornado
							aRetAux[nY][18];								//[18] - XML Erro
						   })
		Next( nY )
	EndIf

Next( nX )

If lVazio
	aAdd( aLbxLog, { oLegenda, "","","","","","","","","","","","","","" } )
EndIf

oLbxLog:SetArray( aLbxLog )
oLbxLog:bLine := {|| {aLbxLog[oLbxLog:nAt,01],;
					  aLbxLog[oLbxLog:nAt,02],;
					  aLbxLog[oLbxLog:nAt,03],;
					  aLbxLog[oLbxLog:nAt,04],;
					  aLbxLog[oLbxLog:nAt,05],;
					  aLbxLog[oLbxLog:nAt,06],;
					  aLbxLog[oLbxLog:nAt,07],;
					  aLbxLog[oLbxLog:nAt,08],;
					  aLbxLog[oLbxLog:nAt,09],;
					  aLbxLog[oLbxLog:nAt,10],;
					  aLbxLog[oLbxLog:nAt,11],;
					  aLbxLog[oLbxLog:nAt,12]}}
oLbxLog:Refresh()
Return(Nil)

/*/{Protheus.doc} VisLog
@description	Visualiza Log da transacao
@author			Amedeo D. Paoli Filho
@version		1.0
@return			Nil
@type			Function
/*/
Static Function VisLog( oLbxLog )
Local cMEnvio := oLbxLog:aArray[ oLbxLog:nAT ][ 13 ]
Local cMRet := oLbxLog:aArray[ oLbxLog:nAT ][ 14 ]
Local cMErro := oLbxLog:aArray[ oLbxLog:nAT ][ 15 ]
Local oBtnSair := Nil
Local oPanelBot := Nil
Local oDlgVis := Nil

DEFINE MSDIALOG oDlgVis TITLE "LOG - Visualização" FROM 000, 000 TO 400, 800 COLORS 0, 16777215 PIXEL
	//Grupos
	@ 005, 002 GROUP oGrpEnv	TO 175, 132 PROMPT " XML Envio "	OF oDlgVis COLOR 0, 16777215 PIXEL
	@ 005, 135 GROUP oGrpRet	TO 175, 265 PROMPT " XML Retorno "	OF oDlgVis COLOR 0, 16777215 PIXEL
	@ 005, 268 GROUP oGrpErro	TO 175, 398 PROMPT " XML Erro "		OF oDlgVis COLOR 0, 16777215 PIXEL

	@ 015, 007 GET oMEnvio	VAR cMEnvio	OF oDlgVis MULTILINE SIZE 120, 155 COLORS 0, 16777215 HSCROLL READONLY PIXEL
	@ 015, 140 GET oMRet	VAR cMRet	OF oDlgVis MULTILINE SIZE 120, 155 COLORS 0, 16777215 HSCROLL READONLY PIXEL
	@ 015, 272 GET oMErro	VAR cMErro	OF oDlgVis MULTILINE SIZE 120, 155 COLORS 0, 16777215 HSCROLL READONLY PIXEL

	@ 180, 000 MSPANEL oPanelBot SIZE 400, 020 OF oDlgVis COLORS 0, 16777215 RAISED
	oPanelBot:Align 	:= CONTROL_ALIGN_BOTTOM

	@ 001, 001 BTNBMP oBtnSair RESNAME "FINAL" SIZE 050, 038 OF oPanelBot MESSAGE "Sair"
	oBtnSair:Align		:= CONTROL_ALIGN_LEFT
	oBtnSair:bAction	:= { || oDlgVis:End() }
ACTIVATE MSDIALOG oDlgVis CENTERED
Return(Nil)