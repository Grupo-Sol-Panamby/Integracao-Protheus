#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPDSA1X
Fun��o de update de dicion�rios para compatibiliza��o

@author TOTVS Protheus
@since  03/11/16
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDSA1X( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZA��O DE DICION�RIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como fun��o fazer  a atualiza��o  dos dicion�rios do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja n�o podem haver outros"
Local   cDesc3    := "usu�rios  ou  jobs utilizando  o sistema.  � EXTREMAMENTE recomendav�l  que  se  fa�a um"
Local   cDesc4    := "BACKUP  dos DICION�RIOS  e da  BASE DE DADOS antes desta atualiza��o, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualiza��o dos dicion�rios ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualiza��o Realizada.", "UPDSA1X" )
				Else
					MsgStop( "Atualiza��o n�o Realizada.", "UPDSA1X" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualiza��o Conclu�da." )
				Else
					Final( "Atualiza��o n�o Realizada." )
				EndIf
			EndIf

		Else
			MsgStop( "Atualiza��o n�o Realizada.", "UPDSA1X" )

		EndIf

	Else
		MsgStop( "Atualiza��o n�o Realizada.", "UPDSA1X" )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Fun��o de processamento da grava��o dos arquivos

@author TOTVS Protheus
@since  03/11/16
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// S� adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.T.) )
				MsgStop( "Atualiza��o da empresa " + aRecnoSM0[nI][2] + " n�o efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZA��O DOS DICION�RIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora �nicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Vers�o.............: " + GetVersao(.T.) )
			AutoGrLog( " Usu�rio TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usu�rio da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Esta��o............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conex�o............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicion�rio SX3
			//------------------------------------
			FSAtuSX3()

			oProcess:IncRegua1( "Dicion�rio de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/�ndices" )

			// Altera��o f�sica dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualiza��o da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicion�rio e da tabela.", "ATEN��O" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualiza��o da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//------------------------------------
			// Atualiza o dicion�rio SX9
			//------------------------------------
			oProcess:IncRegua1( "Dicion�rio de relacionamentos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX9()

			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuHlp()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualiza��o concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Fun��o de processamento da grava��o do SX3 - Campos

@author TOTVS Protheus
@since  03/11/16
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local nI        := 0
Local nJ        := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

AutoGrLog( "�nicio da Atualiza��o" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )

//
// --- ATEN��O ---
// Coloque .F. na 2a. posi��o de cada elemento do array, para os dados do SX3
// que n�o ser�o atualizados quando o campo j� existir.
//

//
// Campos Tabela SA1
//
/*
aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ '30'																	, .T. }, ; //X3_ORDEM
	{ 'A1_ENDCOB'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 160																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'End.Cobranca'														, .T. }, ; //X3_TITULO
	{ 'Dir.Cobranza'														, .T. }, ; //X3_TITSPA
	{ 'Collec.Addr.'														, .T. }, ; //X3_TITENG
	{ 'End.de cobr. do cliente'												, .T. }, ; //X3_DESCRIC
	{ 'Dir. de cobr. del cliente'											, .T. }, ; //X3_DESCSPA
	{ 'Custm.Collec.Address'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(255) + Chr(255) + Chr(236) + Chr(128) + Chr(128) + ;
	Chr(139) + Chr(240) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(135) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ '�'																	, .T. }, ; //X3_OBRIGAT
	{ 'Vazio().Or.texto()'													, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '2'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ '31'																	, .T. }, ; //X3_ORDEM
	{ 'A1_XCOMPLE'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 50																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Complem. Cob'														, .T. }, ; //X3_TITULO
	{ 'Complem. Cob'														, .T. }, ; //X3_TITSPA
	{ 'Complem. Cob'														, .T. }, ; //X3_TITENG
	{ 'Complem. ender. cobranca'											, .T. }, ; //X3_DESCRIC
	{ 'Complem. ender. cobranca'											, .T. }, ; //X3_DESCSPA
	{ 'Complem. ender. cobranca'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '2'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ '32'																	, .T. }, ; //X3_ORDEM
	{ 'A1_BAIRROC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 40																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Bairro Cobr'															, .T. }, ; //X3_TITULO
	{ 'Barrio Cob'															, .T. }, ; //X3_TITSPA
	{ 'Coll. Distr.'														, .T. }, ; //X3_TITENG
	{ 'Bairro de Cobranca'													, .T. }, ; //X3_DESCRIC
	{ 'Barrio del Cobranza'													, .T. }, ; //X3_DESCSPA
	{ 'District for collection'												, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ '�'																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '2'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME
*/
aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ 'M0'																	, .T. }, ; //X3_ORDEM
	{ 'A1_GRPCLI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Grupo Client'														, .T. }, ; //X3_TITULO
	{ 'Grupo Client'														, .T. }, ; //X3_TITSPA
	{ 'Grupo Client'														, .T. }, ; //X3_TITENG
	{ 'Grupo de Clientes'													, .T. }, ; //X3_DESCRIC
	{ 'Grupo de Clientes'													, .T. }, ; //X3_DESCSPA
	{ 'Grupo de Clientes'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ '�'																	, .T. }, ; //X3_OBRIGAT
	{ 'Pertence("01/02/03/04/05/06/07/08/09/10/11")'							, .T. }, ; //X3_VLDUSER
	{ '01=AGENCIA;02=BANCO PRIVADO;03=CARTORIO;04=CLIENTE;05=GOV EST;06=GOV FED;07=GOV MUN;08=GOV MISTO;09=INTERCOMPANY;10=SHOPPING;11=PARTIDO POLITICO', .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME


//
// Atualizando dicion�rio
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq][1]+x[nPosOrd][1]+x[nPosCpo][1] < y[nPosArq][1]+y[nPosOrd][1]+y[nPosCpo][1] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG][1] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG][1] ) )
			If aSX3[nI][nPosTam][1] <> SXG->XG_SIZE
				aSX3[nI][nPosTam][1] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " N�O atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq][1] $ cAlias )
		cAlias += aSX3[nI][nPosArq][1] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq][1] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo][1], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq][1] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq][1]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ][1] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo][1] )

	Else

		//
		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		//
		If !Empty( SX3->X3_GRPSXG ) .AND. SX3->X3_GRPSXG <> aSX3[nI][nPosSXG][1]
			SXG->( dbSetOrder( 1 ) )
			If SXG->( MSSeek( SX3->X3_GRPSXG ) )
				If aSX3[nI][nPosTam][1] <> SXG->XG_SIZE
					aSX3[nI][nPosTam][1] := SXG->XG_SIZE
					AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " N�O atualizado e foi mantido em [" + ;
					AllTrim( Str( SXG->XG_SIZE ) ) + "]"+ CRLF + ;
					"   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF )
				EndIf
			EndIf
		EndIf

		//
		// Verifica todos os campos
		//
		For nJ := 1 To Len( aSX3[nI] )

			If aSX3[nI][nJ][2]
				cX3Campo := AllTrim( aEstrut[nJ][1] )
				cX3Dado  := SX3->( FieldGet( aEstrut[nJ][2] ) )

				If  aEstrut[nJ][2] > 0 .AND. ;
					PadR( StrTran( AllToChar( cX3Dado ), " ", "" ), 250 ) <> ;
					PadR( StrTran( AllToChar( aSX3[nI][nJ][1] ), " ", "" ), 250 ) .AND. ;
					!cX3Campo  == "X3_ORDEM"

					AutoGrLog( "Alterado campo " + aSX3[nI][nPosCpo][1] + CRLF + ;
					"   " + PadR( cX3Campo, 10 ) + " de [" + AllToChar( cX3Dado ) + "]" + CRLF + ;
					"            para [" + AllToChar( aSX3[nI][nJ][1] )           + "]" + CRLF )

					RecLock( "SX3", .F. )
					FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ][1] )
					MsUnLock()
				EndIf
			EndIf
		Next

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualiza��o" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX9
Fun��o de processamento da grava��o do SX9 - Relacionamento

@author TOTVS Protheus
@since  03/11/16
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX9()
Local aEstrut   := {}
Local aSX9      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX9->X9_DOM )

AutoGrLog( "�nicio da Atualiza��o" + " SX9" + CRLF )

aEstrut := { "X9_DOM"    , "X9_IDENT"  , "X9_CDOM"   , "X9_EXPDOM" , "X9_EXPCDOM", "X9_PROPRI" , "X9_LIGDOM" , ;
             "X9_LIGCDOM", "X9_CONDSQL", "X9_USEFIL" , "X9_VINFIL" , "X9_CHVFOR" , "X9_ENABLE" }


//
// Dom�nio ACY
//
aAdd( aSX9, { ;
	'ACY'																	, ; //X9_DOM
	'006'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'ACY_GRPVEN'															, ; //X9_EXPDOM
	'A1_GRPVEN'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio CC1
//
aAdd( aSX9, { ;
	'CC1'																	, ; //X9_DOM
	'003'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'CC1_CODIGO'															, ; //X9_EXPDOM
	'A1_VINCULO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio CC2
//
aAdd( aSX9, { ;
	'CC2'																	, ; //X9_DOM
	'004'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'CC2_CODMUN'															, ; //X9_EXPDOM
	'A1_COD_MUN'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio CT1
//
aAdd( aSX9, { ;
	'CT1'																	, ; //X9_DOM
	'040'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'CT1_CONTA'																, ; //X9_EXPDOM
	'A1_CONTA'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio DA0
//
aAdd( aSX9, { ;
	'DA0'																	, ; //X9_DOM
	'005'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'DA0_CODTAB'															, ; //X9_EXPDOM
	'A1_TABELA'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio DUY
//
aAdd( aSX9, { ;
	'DUY'																	, ; //X9_DOM
	'005'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'DUY_GRPVEN'															, ; //X9_EXPDOM
	'A1_CDRDES'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio JA2
//
aAdd( aSX9, { ;
	'JA2'																	, ; //X9_DOM
	'009'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'JA2_NUMRA'																, ; //X9_EXPDOM
	'A1_NUMRA'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio SA1
//
aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'006'																	, ; //X9_IDENT
	'AA3'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AA3_CODFAB+AA3_LOJAFA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'130'																	, ; //X9_IDENT
	'AA4'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AA4_CODFAB+AA4_LOJAFA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'032'																	, ; //X9_IDENT
	'AAH'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AAH_CODCLI+AAH_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'139'																	, ; //X9_IDENT
	'AAJ'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AAJ_CODCLI+AAJ_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'033'																	, ; //X9_IDENT
	'AAK'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AAK_CODFAB+AAK_LOJAFA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'143'																	, ; //X9_IDENT
	'AAL'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AAL_CODFAB+AAL_LOJAFA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'198'																	, ; //X9_IDENT
	'AAM'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AAM_CODCLI+AAM_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'030'																	, ; //X9_IDENT
	'AB1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AB1_CODCLI+AB1_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'100'																	, ; //X9_IDENT
	'AB2'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AB2_CODFAB+AB2_LOJAFA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'200'																	, ; //X9_IDENT
	'AB3'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AB3_CODCLI+AB3_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'003'																	, ; //X9_IDENT
	'AB4'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AB4_CODFAB+AB4_LOJAFA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'201'																	, ; //X9_IDENT
	'AB6'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AB6_CODCLI+AB6_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'140'																	, ; //X9_IDENT
	'AB7'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AB7_CODFAB+AB7_LOJAFA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'088'																	, ; //X9_IDENT
	'AB8'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AB8_CODCLI+AB8_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'004'																	, ; //X9_IDENT
	'AB9'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AB9_CODCLI+AB9_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'089'																	, ; //X9_IDENT
	'ABA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ABA_CODFAB+ABA_LOJAFA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'055'																	, ; //X9_IDENT
	'ABD'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ABD_CODFAB+ABD_LOJAFA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'246'																	, ; //X9_IDENT
	'ABE'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ABE_CODFAB+ABE_LOJAFA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'245'																	, ; //X9_IDENT
	'ABH'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ABH_CODCLI+ABH_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'045'																	, ; //X9_IDENT
	'ABK'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ABK_CODCLI+ABK_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'117'																	, ; //X9_IDENT
	'ABV'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ABV_CODCLI+ABV_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'252'																	, ; //X9_IDENT
	'ACF'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ACF_CLIENT+ACF_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'129'																	, ; //X9_IDENT
	'ACI'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ACI_CHAVE'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#ACI_ENTIDA='SA1'"														, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'251'																	, ; //X9_IDENT
	'ACK'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ACK_CODCLI+ACK_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'181'																	, ; //X9_IDENT
	'ACO'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ACO_CODCLI+ACO_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'248'																	, ; //X9_IDENT
	'ACQ'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ACQ_CODCLI+ACQ_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'044'																	, ; //X9_IDENT
	'ACS'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ACS_CODCLI+ACS_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'086'																	, ; //X9_IDENT
	'ACW'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ACW_CODCLI+ACW_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'240'																	, ; //X9_IDENT
	'AD5'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AD5_CODCLI+AD5_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'001'																	, ; //X9_IDENT
	'AD7'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AD7_CODCLI+AD7_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'063'																	, ; //X9_IDENT
	'AD8'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AD8_CODCLI+AD8_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'N'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'087'																	, ; //X9_IDENT
	'ADA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ADA_CODCLI+ADA_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'124'																	, ; //X9_IDENT
	'AF1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AF1_CLIENT+AF1_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'102'																	, ; //X9_IDENT
	'AF8'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AF8_CLIENT+AF8_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'171'																	, ; //X9_IDENT
	'AFP'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AFP_CLIENT+AFP_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'159'																	, ; //X9_IDENT
	'AGW'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AGW_CLIENT+AGW_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'081'																	, ; //X9_IDENT
	'AI1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AI1_CODCLI+AI1_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'123'																	, ; //X9_IDENT
	'AI4'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AI4_CODCLI+AI4_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'157'																	, ; //X9_IDENT
	'AIH'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AIH_CODCLI+AIH_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'N'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'107'																	, ; //X9_IDENT
	'AJH'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AJH_CLIENT+AJH_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'188'																	, ; //X9_IDENT
	'B44'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'B44_CODCLI+B44_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'046'																	, ; //X9_IDENT
	'B76'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'B76_CODCLI+B76_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'161'																	, ; //X9_IDENT
	'CC1'																	, ; //X9_CDOM
	'A1_VINCULO'															, ; //X9_EXPDOM
	'CC1_CODIGO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'010'																	, ; //X9_IDENT
	'CD2'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'CD2_CODCLI+CD2_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'009'																	, ; //X9_IDENT
	'CDA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'CDA_CLIFOR+CDA_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#CDA_TPMOVI='S'"														, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'203'																	, ; //X9_IDENT
	'CN8'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'CN8_CLIENT+CN8_LOJACL'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'020'																	, ; //X9_IDENT
	'CN9'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'CN9_CLIENT+CN9_LOJACL'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'108'																	, ; //X9_IDENT
	'CND'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'CND_CLIENT+CND_LOJACL'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'202'																	, ; //X9_IDENT
	'CNT'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'CNT_CLIENT+CNT_LOJACL'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'160'																	, ; //X9_IDENT
	'CNX'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'CNX_CLIENT+CNX_LOJACL'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'007'																	, ; //X9_IDENT
	'DA7'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'DA7_CLIENT+DA7_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'142'																	, ; //X9_IDENT
	'DAD'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'DAD_CODCLI+DAD_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'008'																	, ; //X9_IDENT
	'DAF'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'DAF_CODCLI+DAF_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'031'																	, ; //X9_IDENT
	'DAH'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'DAH_CODCLI+DAH_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'050'																	, ; //X9_IDENT
	'DCK'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'DCK_CODCLI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'110'																	, ; //X9_IDENT
	'DE5'																	, ; //X9_CDOM
	'A1_CGC'																, ; //X9_EXPDOM
	'DE5_CGCREM'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'210'																	, ; //X9_IDENT
	'DX8'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'DX8_CLIENT+DX8_LJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'158'																	, ; //X9_IDENT
	'DXN'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'DXN_CLIENT+DXN_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'133'																	, ; //X9_IDENT
	'DXP'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'DXP_CLIENT+DXP_LJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'235'																	, ; //X9_IDENT
	'DXS'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'DXS_CLIENT+DXS_LJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'116'																	, ; //X9_IDENT
	'DYA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'DYA_CLIDES+DYA_LOJDES'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'013'																	, ; //X9_IDENT
	'DYF'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'DYF_CLIDES'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'N'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'053'																	, ; //X9_IDENT
	'EE1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EE1_CODCLI+EE1_CLLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'058'																	, ; //X9_IDENT
	'EE7'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EE7_IMPORT+EE7_IMLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'223'																	, ; //X9_IDENT
	'EEC'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EEC_IMPORT+EEC_IMLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'043'																	, ; //X9_IDENT
	'EEN'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EEN_IMPORT+EEN_IMLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'047'																	, ; //X9_IDENT
	'EEQ'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EEQ_IMPORT+EEQ_IMLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'105'																	, ; //X9_IDENT
	'EF1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EF1_CLIENT+EF1_CLLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'226'																	, ; //X9_IDENT
	'EFA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EFA_CLIENT+EFA_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'014'																	, ; //X9_IDENT
	'EJW'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EJW_IMPORT+EJW_LOJIMP'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'N'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'N'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'254'																	, ; //X9_IDENT
	'EJY'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EJY_IMPORT+EJY_LOJIMP'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'N'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'253'																	, ; //X9_IDENT
	'ELA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ELA_IMPORT+ELA_LOJIMP'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'137'																	, ; //X9_IDENT
	'ELB'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'ELB_IMPORT+ELB_LOJIMP'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'222'																	, ; //X9_IDENT
	'EXH'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EXH_CODCLI+EXH_CLLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'037'																	, ; //X9_IDENT
	'EXJ'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EXJ_COD+EXJ_LOJA'														, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'170'																	, ; //X9_IDENT
	'FI2'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'FI2_CODCLI+FI2_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#FI2_CARTEI='1'"														, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'211'																	, ; //X9_IDENT
	'FJ4'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'FJ4_CLIENT+FJ4_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'077'																	, ; //X9_IDENT
	'JA2'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'JA2_CLIENT+JA2_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'182'																	, ; //X9_IDENT
	'JC5'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'JC5_CLIENT+JC5_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'184'																	, ; //X9_IDENT
	'JMM'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'JMM_CLIENT+JMM_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'173'																	, ; //X9_IDENT
	'JMN'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'JMN_CLIENT+JMN_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'038'																	, ; //X9_IDENT
	'JMO'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'JMO_CLIENT+JMO_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'165'																	, ; //X9_IDENT
	'MA6'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'MA6_CODCLI+MA6_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	''																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'166'																	, ; //X9_IDENT
	'MA7'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'MA7_CODCLI+MA7_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	''																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'064'																	, ; //X9_IDENT
	'MA8'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'MA8_CODCLI+MA8_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	''																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'065'																	, ; //X9_IDENT
	'MA9'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'MA9_CODCLI+MA9_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	''																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'034'																	, ; //X9_IDENT
	'MAA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'MAA_CODCLI+MAA_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	''																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'204'																	, ; //X9_IDENT
	'MAB'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'MAB_CODCLI+MAB_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	''																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'205'																	, ; //X9_IDENT
	'MAC'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'MAC_CODCLI+MAC_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	''																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'167'																	, ; //X9_IDENT
	'MAE'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'MAE_CODCLI+MAE_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	''																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'035'																	, ; //X9_IDENT
	'MAG'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'MAG_CODCLI+MAG_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	''																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'206'																	, ; //X9_IDENT
	'MAH'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'MAH_CODCLI+MAH_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	''																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'207'																	, ; //X9_IDENT
	'MAI'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'MAI_CODCLI+MAI_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	''																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'168'																	, ; //X9_IDENT
	'MAK'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'MAK_CODCLI+MAK_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	''																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'011'																	, ; //X9_IDENT
	'MB1'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'MB1_CLIENT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'193'																	, ; //X9_IDENT
	'MDD'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'MDD_CLIV+MDD_LJCLIV'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'151'																	, ; //X9_IDENT
	'MEI'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'MEI_CODCLI+MEI_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'054'																	, ; //X9_IDENT
	'N01'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'N01_PROPRI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'070'																	, ; //X9_IDENT
	'N04'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'N04_CODCLI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'071'																	, ; //X9_IDENT
	'N05'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'N05_PROPRI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'019'																	, ; //X9_IDENT
	'N0E'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'N0E_CODCLI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'072'																	, ; //X9_IDENT
	'N43'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'N43_CODCON'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'076'																	, ; //X9_IDENT
	'N45'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'N45_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	''																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'094'																	, ; //X9_IDENT
	'NPA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NPA_CODCLI+NPA_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'131'																	, ; //X9_IDENT
	'NPG'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NPG_CLIORI+NPG_LOJORI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'227'																	, ; //X9_IDENT
	'NSZ'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NSZ_CCLIEN+NSZ_LCLIEN'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'185'																	, ; //X9_IDENT
	'NT0'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NT0_CCLIEN+NT0_CLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'232'																	, ; //X9_IDENT
	'NT9'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NT9_CEMPCL+NT9_LOJACL'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'018'																	, ; //X9_IDENT
	'NTB'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NTB_CCLIEN+NTB_LOJACL'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'192'																	, ; //X9_IDENT
	'NTP'																	, ; //X9_CDOM
	'A1_FILIAL+A1_COD+A1_LOJA'												, ; //X9_EXPDOM
	'NTP_FILIAL+NTP_CCLIEN+NTP_CLOJA'										, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'017'																	, ; //X9_IDENT
	'NU0'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NU0_CCLIEN+NU0_CLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'197'																	, ; //X9_IDENT
	'NU8'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'NU8_CCLIEN'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'015'																	, ; //X9_IDENT
	'NU9'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NU9_CCLIEN+NU9_CLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'121'																	, ; //X9_IDENT
	'NUA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NUA_CCLIEN+NUA_CLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'196'																	, ; //X9_IDENT
	'NUB'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NUB_CCLIEN+NUB_CLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'016'																	, ; //X9_IDENT
	'NUC'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NUC_CCLIEN+NUC_CLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'195'																	, ; //X9_IDENT
	'NUD'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NUD_CCLIEN+NUD_CLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'138'																	, ; //X9_IDENT
	'NUH'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NUH_COD+NUH_LOJA'														, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'028'																	, ; //X9_IDENT
	'NUQ'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NUQ_CCLIEN+NUQ_LCLIEN'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'119'																	, ; //X9_IDENT
	'NUT'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NUT_CCLIEN+NUT_CLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'120'																	, ; //X9_IDENT
	'NV6'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NV6_CCLIEN+NV6_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'122'																	, ; //X9_IDENT
	'NVE'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NVE_CCLIEN+NVE_LCLIEN'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'115'																	, ; //X9_IDENT
	'NVV'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NVV_CCLIEN+NVV_CLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'098'																	, ; //X9_IDENT
	'NVW'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NVW_CCLIEN+NVW_CLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'241'																	, ; //X9_IDENT
	'NW2'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NW2_CCLIEN+NW2_CLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'118'																	, ; //X9_IDENT
	'NWG'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NWG_CCLIEN+NWG_LCLIEN'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'213'																	, ; //X9_IDENT
	'NWO'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NWO_CCLIEN+NWO_CLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'097'																	, ; //X9_IDENT
	'NWZ'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NWZ_CCLIEN+NWZ_CLOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'190'																	, ; //X9_IDENT
	'NXG'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NXG_CLIPG+NXG_LOJAPG'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'136'																	, ; //X9_IDENT
	'NXP'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'NXP_CLIPG+NXP_LOJAPG'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'062'																	, ; //X9_IDENT
	'QF6'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'QF6_CLIENT+QF6_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'126'																	, ; //X9_IDENT
	'QK1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'QK1_CODCLI+QK1_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'249'																	, ; //X9_IDENT
	'QM2'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'QM2_CLIE+QM2_LOJA'														, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'049'																	, ; //X9_IDENT
	'QMZ'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'QMZ_CLIENT+QMZ_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'186'																	, ; //X9_IDENT
	'QPK'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'QPK_CLIENT+QPK_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'026'																	, ; //X9_IDENT
	'QPR'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'QPR_CLIENT+QPR_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'029'																	, ; //X9_IDENT
	'QQ4'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'QQ4_CLIENT+QQ4_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	''																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'048'																	, ; //X9_IDENT
	'QQ7'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'QQ7_CLIENT+QQ7_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'099'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'A1_CLIFAT'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'052'																	, ; //X9_IDENT
	'SA7'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'A7_CLIENTE+A7_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'005'																	, ; //X9_IDENT
	'SAA'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'AA_CLIENTE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'085'																	, ; //X9_IDENT
	'SAB'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AB_CLIENTE+AB_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'238'																	, ; //X9_IDENT
	'SAO'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'AO_CLIENTE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'057'																	, ; //X9_IDENT
	'SAR'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'AR_CODCLI+AR_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'042'																	, ; //X9_IDENT
	'SC5'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'C5_CLIENTE+C5_LOJACLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#C5_TIPO   <>'D' AND #C5_TIPO   <>'B'"									, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'237'																	, ; //X9_IDENT
	'SCA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'CA_CLIENTE+CA_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'125'																	, ; //X9_IDENT
	'SCB'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'CB_CLIENTE+CB_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'079'																	, ; //X9_IDENT
	'SCJ'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'CJ_CLIENTE+CJ_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'056'																	, ; //X9_IDENT
	'SCK'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'CK_CLIENTE+CK_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'236'																	, ; //X9_IDENT
	'SD0'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'D0_CLIENTE+D0_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'078'																	, ; //X9_IDENT
	'SD1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'D1_FORNECE+D1_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#D1_TIPO   ='D' OR #D1_TIPO   ='B'"									, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'244'																	, ; //X9_IDENT
	'SD2'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'D2_CLIENTE+D2_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#D2_TIPO   <>'D' AND #D2_TIPO   <>'B'"									, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'228'																	, ; //X9_IDENT
	'SD6'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'D6_CLIENT2+D6_LOJ2'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'084'																	, ; //X9_IDENT
	'SDA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'DA_CLIFOR+DA_LOJA'														, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#DA_ORIGEM ='SD2'"														, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'061'																	, ; //X9_IDENT
	'SDH'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'DH_CLIENTE+DH_LOJACLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'091'																	, ; //X9_IDENT
	'SE1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'E1_CLIENTE+E1_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'002'																	, ; //X9_IDENT
	'SE3'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'E3_CODCLI+E3_LOJA'														, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'128'																	, ; //X9_IDENT
	'SE6'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'E6_CLIENTE+E6_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'147'																	, ; //X9_IDENT
	'SEL'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EL_CLIENTE+EL_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'092'																	, ; //X9_IDENT
	'SEM'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EM_CLIENTE+EM_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'027'																	, ; //X9_IDENT
	'SEU'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EU_CLIENTE+EU_LOJACLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'083'																	, ; //X9_IDENT
	'SEX'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'EX_CODCLI+EX_LOJA'														, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'041'																	, ; //X9_IDENT
	'SF1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'F1_FORNECE+F1_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#F1_TIPO   ='D' OR #F1_TIPO   ='B'"									, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'146'																	, ; //X9_IDENT
	'SF2'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'F2_CLIENTE+F2_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#F2_TIPO   <>'D' AND #F2_TIPO   <>'B'"									, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'250'																	, ; //X9_IDENT
	'SF9'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'F9_CLIENTE+F9_LOJACLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'183'																	, ; //X9_IDENT
	'SFE'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'FE_CLIENTE+FE_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'145'																	, ; //X9_IDENT
	'SFM'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'FM_CLIENTE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'040'																	, ; //X9_IDENT
	'SJ3'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'J3_CLIENTE+J3_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'215'																	, ; //X9_IDENT
	'SK1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'K1_CLIENTE+K1_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'039'																	, ; //X9_IDENT
	'SL1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'L1_CLIENT+L1_LOJENT'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'247'																	, ; //X9_IDENT
	'SLM'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'LM_CLIENTE+LM_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'144'																	, ; //X9_IDENT
	'SLQ'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'LQ_CLIENTE+LQ_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'189'																	, ; //X9_IDENT
	'SS2'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'S2_CLIFAT'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'149'																	, ; //X9_IDENT
	'ST9'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'T9_CLIENTE+T9_LOJACLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'082'																	, ; //X9_IDENT
	'SU6'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'U6_CODENT'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#U6_ENTIDA ='SA1'"														, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'199'																	, ; //X9_IDENT
	'SUA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'UA_CLIENTE+UA_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'093'																	, ; //X9_IDENT
	'SUC'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'UC_CHAVE'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#UC_ENTIDAD='SA1'"														, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'127'																	, ; //X9_IDENT
	'SUS'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'US_CODCLI+US_LOJACLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'073'																	, ; //X9_IDENT
	'SW2'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'W2_CLIENTE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'221'																	, ; //X9_IDENT
	'TM0'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'TM0_CLIENT+TM0_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'074'																	, ; //X9_IDENT
	'TMW'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'TMW_CLIDE'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'214'																	, ; //X9_IDENT
	'TO0'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'TO0_CLIENT+TO0_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'012'																	, ; //X9_IDENT
	'TON'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'TON_CLIENT+TON_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'106'																	, ; //X9_IDENT
	'TOZ'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'TOZ_CLIENT+TOZ_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'169'																	, ; //X9_IDENT
	'VAO'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VAO_CODCLI+VAO_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'152'																	, ; //X9_IDENT
	'VAZ'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VAZ_CODCLI+VAZ_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'021'																	, ; //X9_IDENT
	'VC1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VC1_CODCLI+VC1_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'172'																	, ; //X9_IDENT
	'VC2'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VC2_CODCLI+VC2_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'208'																	, ; //X9_IDENT
	'VC3'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VC3_CODCLI+VC3_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'066'																	, ; //X9_IDENT
	'VC4'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VC4_CODCLI+VC4_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VC4_CODCLI<>'      ' OR #VC4_LOJA  <>'  '"							, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'209'																	, ; //X9_IDENT
	'VC6'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VC6_CODCLI+VC6_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'067'																	, ; //X9_IDENT
	'VCC'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VCC_CODCLI+VCC_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'022'																	, ; //X9_IDENT
	'VCF'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VCF_CODCLI+VCF_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VCF_CODCLI<>'      ' OR #VCF_LOJCLI<>'  '"							, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'231'																	, ; //X9_IDENT
	'VDL'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VDL_CODCLI+VDL_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'191'																	, ; //X9_IDENT
	'VDN'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VDN_CODCLI+VDN_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'068'																	, ; //X9_IDENT
	'VE6'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VE6_CODCLI+VE6_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VE6_CODCLI<>'      ' OR #VE6_LOJCLI<>'  '"							, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'024'																	, ; //X9_IDENT
	'VEM'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VEM_CODCLI+VEM_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'212'																	, ; //X9_IDENT
	'VF2'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VF2_CODCLI+VF2_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'175'																	, ; //X9_IDENT
	'VFA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VFA_CODCLI+VFA_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'103'																	, ; //X9_IDENT
	'VFB'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VFB_CODCLI+VFB_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VFB_CODCLI<>'      ' OR #VFB_LOJA  <>'  '"							, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'104'																	, ; //X9_IDENT
	'VFC'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VFC_CODCLI+VFC_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'023'																	, ; //X9_IDENT
	'VFD'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VFD_CODCLI+VFD_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'219'																	, ; //X9_IDENT
	'VG8'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VG8_CODCLI+VG8_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VG8_CODCLI<>'      ' OR #VG8_LOJA  <>'  '"							, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'220'																	, ; //X9_IDENT
	'VGA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VGA_CODCLI+VGA_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VGA_CODCLI<>'      ' OR #VGA_LOJA  <>'  '"							, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'234'																	, ; //X9_IDENT
	'VIL'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VIL_COD+VIL_LOJA'														, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'180'																	, ; //X9_IDENT
	'VO1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VO1_PROVEI+VO1_LOJPRO'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VO1_PROVEI<>'      ' OR #VO1_LOJPRO<>'  '"							, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'233'																	, ; //X9_IDENT
	'VO4'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VO4_FATPAR+VO4_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'174'																	, ; //X9_IDENT
	'VOG'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VOG_CODCLI+VOG_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VOG_CODCLI<>'      ' OR #VOG_LOJA  <>'  '"							, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'134'																	, ; //X9_IDENT
	'VOI'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VOI_CLIFAT+VOI_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'036'																	, ; //X9_IDENT
	'VP1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VP1_CODCLI+VP1_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'216'																	, ; //X9_IDENT
	'VP2'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VP2_CODCLI+VP2_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'217'																	, ; //X9_IDENT
	'VP4'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VP4_CODCLI+VP4_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'109'																	, ; //X9_IDENT
	'VS1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VS1_CLIFAT+VS1_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'218'																	, ; //X9_IDENT
	'VS6'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VS6_CODCLI+VS6_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VS6_CODCLI<>'      ' OR #VS6_LOJA  <>'  '"							, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'156'																	, ; //X9_IDENT
	'VSA'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VSA_CODCLI+VSA_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'176'																	, ; //X9_IDENT
	'VSO'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VSO_PROVEI+VSO_LOJPRO'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VSO_PROVEI<>'      ' OR #VSO_LOJPRO<>'  '"							, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'150'																	, ; //X9_IDENT
	'VV0'																	, ; //X9_CDOM
	'A1_COD'																, ; //X9_EXPDOM
	'VV0_CODAVA'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'153'																	, ; //X9_IDENT
	'VV1'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VV1_PROANT+VV1_LJPANT'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'025'																	, ; //X9_IDENT
	'VV4'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VV4_CODCLI+VV4_LOJCLI'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'164'																	, ; //X9_IDENT
	'VV9'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VV9_CODCLI+VV9_LOJA'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VV9_CODCLI<>'      ' OR #VV9_LOJA  <>'  '"							, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SA1'																	, ; //X9_DOM
	'163'																	, ; //X9_IDENT
	'VVD'																	, ; //X9_CDOM
	'A1_COD+A1_LOJA'														, ; //X9_EXPDOM
	'VVD_CODCLI+VVD_LOJACL'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VVD_CODCLI<>'      ' OR #VVD_LOJACL<>'  '"							, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio SA3
//
aAdd( aSX9, { ;
	'SA3'																	, ; //X9_DOM
	'017'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'A3_COD'																, ; //X9_EXPDOM
	'A1_VEND'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio SA4
//
aAdd( aSX9, { ;
	'SA4'																	, ; //X9_DOM
	'004'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'A4_COD'																, ; //X9_EXPDOM
	'A1_TRANSP'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio SE4
//
aAdd( aSX9, { ;
	'SE4'																	, ; //X9_DOM
	'021'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'E4_CODIGO'																, ; //X9_EXPDOM
	'A1_COND'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio SED
//
aAdd( aSX9, { ;
	'SED'																	, ; //X9_DOM
	'002'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'ED_CODIGO'																, ; //X9_EXPDOM
	'A1_NATUREZ'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio SM4
//
aAdd( aSX9, { ;
	'SM4'																	, ; //X9_DOM
	'007'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'M4_CODIGO'																, ; //X9_EXPDOM
	'A1_MENSAGE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio SRA
//
aAdd( aSX9, { ;
	'SRA'																	, ; //X9_DOM
	'067'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'RA_MAT'																, ; //X9_EXPDOM
	'A1_MATFUN'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio SX5
//
aAdd( aSX9, { ;
	'SX5'																	, ; //X9_DOM
	'215'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'X5_TABELA+X5_CHAVE'													, ; //X9_EXPDOM
	"'12'+A1_EST"															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio SY5
//
aAdd( aSX9, { ;
	'SY5'																	, ; //X9_DOM
	'008'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'Y5_COD'																, ; //X9_EXPDOM
	'A1_CODAGE'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio SY6
//
aAdd( aSX9, { ;
	'SY6'																	, ; //X9_DOM
	'002'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'Y6_COD'																, ; //X9_EXPDOM
	'A1_CONDPAG'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio SYA
//
aAdd( aSX9, { ;
	'SYA'																	, ; //X9_DOM
	'007'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'YA_CODGI'																, ; //X9_EXPDOM
	'A1_PAIS'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Dom�nio SYR
//
aAdd( aSX9, { ;
	'SYR'																	, ; //X9_DOM
	'015'																	, ; //X9_IDENT
	'SA1'																	, ; //X9_CDOM
	'YR_DESTINO'															, ; //X9_EXPDOM
	'A1_DEST_1'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Atualizando dicion�rio
//
oProcess:SetRegua2( Len( aSX9 ) )

dbSelectArea( "SX9" )
dbSetOrder( 2 )

For nI := 1 To Len( aSX9 )

	If !SX9->( dbSeek( PadR( aSX9[nI][3], nTamSeek ) + PadR( aSX9[nI][1], nTamSeek ) ) )

		If !( aSX9[nI][1]+aSX9[nI][3] $ cAlias )
			cAlias += aSX9[nI][1]+aSX9[nI][3] + "/"
		EndIf

		RecLock( "SX9", .T. )
		For nJ := 1 To Len( aSX9[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX9[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

		AutoGrLog( "Foi inclu�do o relacionamento " + aSX9[nI][1] + "/" + aSX9[nI][3] )

		oProcess:IncRegua2( "Atualizando Arquivos (SX9)..." )

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualiza��o" + " SX9" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp
Fun��o de processamento da grava��o dos Helps de Campos

@author TOTVS Protheus
@since  03/11/16
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "�nicio da Atualiza��o" + " " + "Helps de Campos" + CRLF )


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela SA1
//
aHlpPor := {}
aAdd( aHlpPor, 'Endere�o de cobran�a do cliente.' )

PutHelp( "PA1_ENDCOB ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ENDCOB" )

aHlpPor := {}
aAdd( aHlpPor, 'Complemento do endere�o de cobran�a' )

PutHelp( "PA1_XCOMPLE", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XCOMPLE" )

aHlpPor := {}
aAdd( aHlpPor, 'Bairro de cobran�a' )

PutHelp( "PA1_BAIRROC", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_BAIRROC" )

AutoGrLog( CRLF + "Final da Atualiza��o" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )

Return {}


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Fun��o gen�rica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as sele��es feitas.
             Se n�o for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Par�metro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta s� com Empresas
// 3 - Monta s� com Filiais de uma Empresa
//
// Par�metro  aMarcadas
// Vetor com Empresas/Filiais pr� marcadas
//
// Par�metro  cEmpSel
// Empresa que ser� usada para montar sele��o
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.T.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para M�ltiplas Sele��es de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualiza��o"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "M�scara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Sele��o" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "m�scara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "m�scara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), oDlg:End()  ) ;
Message "Confirma a sele��o e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplica��o" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Fun��o auxiliar para marcar/desmarcar todos os �tens do ListBox ativo

@param lMarca  Cont�udo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Fun��o auxiliar para inverter a sele��o do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Fun��o auxiliar que monta o retorno com as sele��es

@param aRet    Array que ter� o retorno das sele��es (� alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Fun��o para marcar/desmarcar usando m�scaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a m�scara (???)
@param lMarDes  Marca a ser atribu�da .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Fun��o auxiliar para verificar se est�o todos marcados ou n�o

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Fun��o de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  03/11/16
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "N�o foi poss�vel a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATEN��O" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Fun��o de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  03/11/16
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibi��o maxima do LOG alcan�ado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
