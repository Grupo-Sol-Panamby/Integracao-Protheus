#Include "Totvs.ch"

/*/{Protheus.doc} BINTXFUN
@description 	Rotinas genericas da integracao Protheus x Sistemas Legados das empresas de Comunica็ใo
@author 		Amedeo D. Paoli Filho
@since 			27/06/2016
@version		1.0
@return			Nil
@type 			Function
/*/
User Function BINTXFUN(); Return Nil
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
		- 005 – Tํtulo Financeiro (PARCELA)

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

/*/{Protheus.doc} FQRYXML
@description	Rotinas para retorno de Query em tabela de Integracao
@author			Amedeo D. Paoli Filho
@since			27/06/2016
@version		1.0
@return			Nil
@type			Function
/*/
User Function FQRYXML( cEmpCon, cFilCon, cProcess, cStatus, dDtDe, dDtAte, nID )
Local cTable := "% [INTEGRACAO].dbo.XML %"
Local cAliTmp := GetNextAlias()
Local aRetorno := {}
Local aRetAux := {}
Local cWhere := ""

Default cEmpCon := ""
Default cFilCon := ""
Default cStatus := ""
Default dDtDe := CtoD("")
Default dDtAte := CtoD("")
Default nID := 0

cWhere := "% "
cWhere += " ID_PROC = '" + cProcess + "' "

//Caso tenha busca por empresa
If ! Empty( cEmpCon )
	cWhere += " AND ID_EMP = '" + cEmpCon + "' "
EndIf

//Caso tenha busca por filial
If ! Empty( cFilCon )
	cWhere += " AND ID_FIL = '" + cFilCon + "' "
EndIf

//Caso tenha busca por Status
If ! Empty( cStatus )
	cWhere += " AND STATUS = '" + cStatus + "' "
EndIf

//Caso tenha busca por range da datas
If ! Empty( dDtDe ) .And. ! Empty( dDtAte )
	cWhere += " AND DATEINT BETWEEN '" + DtoS( dDtDe ) + "' AND '" + DtoS( dDtAte ) + "' "
EndIf

//Caso tenha busca por ID
If nID > 0
	cWhere += " AND ID = " + lTrim(Str(nID)) + " "
EndIf

cWhere += " %"

BeginSQL Alias cAliTmp
	SELECT	ID									AS 'ID'
	,		Convert( Varchar, ID_EMP )			AS 'ID_EMP'
	,		Convert( Varchar, ID_FIL )			AS 'ID_FIL'
	,		Convert( Varchar, ID_PROC )			AS 'ID_PROC'
	,		Convert( Varchar, PROCES )			AS 'PROCES'
	,		Convert( Varchar, ID_TRANS )		AS 'ID_TRANS'
	,		Convert( Varchar, TRANSAC )			AS 'TRANSAC'
	,		Convert( Varchar, ID_ORI )			AS 'ID_ORI'
	,		Convert( Varchar, ID_DES )			AS 'ID_DES'
	,		Convert( Varchar, ID_ENT )			AS 'ID_ENT'
	,		Convert( Varchar(8000), XML_ERP )	AS 'XML_ERP'
	,		DATEINT								AS 'DATEINT'
	,		TIMEINT								AS 'TIMEINT'
	,		ID_RET								AS 'ID_RET'
	,		Convert( Varchar(8000), XML_RET )	AS 'XML_RET'
	,		DATERET								AS 'DATERET'
	,		TIMERET								AS 'TIMERET'
	,		Convert( Varchar(8000), XML_ERR )	AS 'XML_ERR'
	,		Convert( Varchar, STATUS )			AS 'STATUS'
	FROM	%Exp:cTable%
	WHERE	%Exp:cWhere%
EndSQL

If ! ( cAliTmp )->( EOF() )
	While ! ( cAliTmp )->( EOF() )
		//Dimensiona Array Temporario
		aRetAux := Array( 19 )

		//Atribui resultado da Query em Array
		aRetAux[01] := ( cAliTmp )->ID
		aRetAux[02] := ( cAliTmp )->ID_EMP
		aRetAux[03] := ( cAliTmp )->ID_FIL
		aRetAux[04] := ( cAliTmp )->ID_PROC
		aRetAux[05] := ( cAliTmp )->PROCES
		aRetAux[06] := ( cAliTmp )->ID_TRANS
		aRetAux[07] := ( cAliTmp )->TRANSAC
		aRetAux[08] := ( cAliTmp )->ID_ORI
		aRetAux[09] := ( cAliTmp )->ID_DES
		aRetAux[10] := ( cAliTmp )->ID_ENT
		aRetAux[11] := ( cAliTmp )->XML_ERP
		aRetAux[12] := ( cAliTmp )->DATEINT
		aRetAux[13] := ( cAliTmp )->TIMEINT
		aRetAux[14] := ( cAliTmp )->ID_RET
		aRetAux[15] := ( cAliTmp )->XML_RET
		aRetAux[16] := ( cAliTmp )->DATERET
		aRetAux[17] := ( cAliTmp )->TIMERET
		aRetAux[18] := ( cAliTmp )->XML_ERR
		aRetAux[19] := ( cAliTmp )->STATUS

		//Atribui Retorno ao Array
		aAdd( aRetorno, aRetAux )

		( cAliTmp )->( dbSkip() )
	End
EndIf
Return(aRetorno)

/*/{Protheus.doc} SPCAMGRV
@description	Verifica diretorios de gravacoes (Logs)
@author			Amedeo D. Paoli Filho
@since			30/06/2016
@version		1.0
@return			Nil
@type			Function
/*/
/*
User Function SPCAMGRV(cTipo)
Local cPath := AllTrim( SuperGetMV("SP_PATHARQ", Nil, "\LOG_PULSAR\" ) )
Local cLogWS := IIF( IsSrvUnix(), "LOGEXEC/", "LOGEXEC\" )
Local cLogExec := IIF( IsSrvUnix(), "ROTINAS/", "ROTINAS\" )
Local cRetorno := ""

Default cTipo := "L"

If ! IsSrvUnix()
	If Right( cPath, 1 ) <> "\"
		cPath += "\"
	EndIf
Else
	If Right( cPath, 1 ) <> "/"
		cPath += "/"
	EndIf
EndIf

//Diretorio Principal
If ! ExistDir( cPath )
	MakeDir( cPath )
EndIf

//Logs do WS
If ! ExistDir( cPath + cLogWS )
	MakeDir( cPath + cLogWS )
EndIf

//Log Rotinas
If ! ExistDir( cPath + cLogExec )
	MakeDir( cPath + cLogExec )
EndIf

//Logs
If cTipo == "L"
	cRetorno := cPath + cLogWS
//Rotina
ElseIf cTipo == "R"
	cRetorno := cPath + cLogExec
EndIf
Return(cRetorno)
*/
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
User Function fArToXML(aXML, cTagPai, cVersion, cEncoding, nCount)
Local cRet := ""
Local nX := 0

Default aXML := {}
Default cTagPai := ""
Default cVersion := "1.0"
Default cEncoding := "UTF-8"

nCount ++
For nX := 1 To Len(aXML)
	If ValType(aXML[nX]) == "C"
		cRet += '<' + cTagPai + '>' + Chr(13) + Chr(10)
		cRet += U_fArToXML(aXML[2], aXML[1], "", "", @nCount)
		cRet += '</' + cTagPai + '>' + If(nCount > 1, Chr(13) + Chr(10), '')
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
			cRet += U_fArToXML(aXML[nX][2], aXML[nX][1], "", "", @nCount)
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
			cRet += '</' + cTagPai + '>' + If(nCount > 1, Chr(13) + Chr(10), '')
		EndIf
	EndIf
Next(nX)
nCount--
Return(cRet)