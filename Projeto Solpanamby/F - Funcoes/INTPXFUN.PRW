#Include "Totvs.ch"

/*/{Protheus.doc} INTPXFUN
@description 	Rotinas genericas da integracao Pulsar x Protheus
@author 		Amedeo D. Paoli Filho
@since 			27/06/2016
@version		1.0
@return			Nil
@type 			Function
/*/
User Function INTPXFUN(); Return Nil
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

/*/{Protheus.doc} INTPQRY
@description	Rotinas para retorno de Query em tabela de Integracao
@author			Amedeo D. Paoli Filho
@since			27/06/2016
@version		1.0
@return			Nil
@type			Function
/*/
User Function INTPQRY( cEmpCon, cFilCon, cProcess, cStatus, dDtDe, dDtAte, nID )
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

If !( cAliTmp )->( Eof() )
	While !( cAliTmp )->( Eof() )
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

		( cAliTmp )->( DbSkip() )
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
User Function SPCAMGRV(cTipo)
Local cPath := Alltrim( SuperGetMV("SP_PATHARQ", Nil, "\LOG_PULSAR\" ) )
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