#Include 'Totvs.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   ³ M030INC    º Autor ³ Simone Santos         º Data ³ __/__/____ º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Empresa    ³ Sol Panamby                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ Ponto de entrada para o envio de email apos a inclusao no      º±±
±±º            ³ cadastro de cliente                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Modulo     ³ SIGACOM                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        ³ Ponto de Entrada                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros ³ Nil                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    ³ Nil                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Data       ³ Analista    ³Descricao da Alteracao                            º±±
±±º============³=============³==================================================º±±
±±º 24/11/2014 ³ Alexandre S ³ Reorganizacao do programa                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
User Function M030INC()
Local aArea := SA1->(GetArea())

If ParamIXB == 1
	If SM0->M0_CODIGO $ "75|80" .AND. SA1->A1_MSBLQL <> "1"
		U_ISA10001(INCLUI,ALTERA)
	EndIf
	If ! SM0->M0_CODIGO $ "A6|A7"
		WFCliente()
	EndIf
EndIf

RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao     ³ WFCliente  º Autor ³ Alexandre Soares Reis º Data ³ 15/06/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ Montagem de WorkFlow e envio de email para conferência         º±±
±±º            ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros ³ Nil                                                            º±±
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
Static Function WFCliente()
Local cMensagem := ""
Local cTitulo := "Cadastro de Cliente (inclusão)"
Local aSuperior := {}
Local aHeader := {}
Local aItens := {}
Local aMeio := {}
Local aInferior := Nil
Local aLegenda := Nil
Local aObserv := {}

aAdd( aSuperior, { "Empresa"      , SM0->(AllTrim(M0_CODIGO) + " - " + AllTrim(M0_NOME))                                               , .F., .F. } )
aAdd( aSuperior, { "Filial"       , SM0->(Alltrim(M0_CODFIL) + " - " + AllTrim(M0_FILIAL))                                             , .F., .F. } )
aAdd( aSuperior, { "Data / Hora"  , Transform( Date() , PesqPict( "SC8", "C8_EMISSAO" ) ) + " - " + Transform( Time() , "99:99:99" )   , .F., .F. } )
aAdd( aSuperior, { "Usuário"      , __cUserID + " - " + cUserName                                                                      , .F., .F. } )
aAdd( aSuperior, { ""             , "Este Cliente deverá ser revisado pelos deptos responsáveis antes de sua utilização no Sistema"    , .T., .F. } )

aAdd( aHeader, { RetTitle( "A1_COD"    ), "CENTER", "05%" } )
aAdd( aHeader, { RetTitle( "A1_LOJA"   ), "CENTER", "05%" } )
aAdd( aHeader, { RetTitle( "A1_NOME"   ), "CENTER", "15%" } )
aAdd( aHeader, { RetTitle( "A1_NREDUZ" ), "CENTER", "10%" } )
aAdd( aHeader, { RetTitle( "A1_CGC"    ), "CENTER", "10%" } )
aAdd( aHeader, { RetTitle( "A1_INSCR"  ), "CENTER", "10%" } )
aAdd( aHeader, { RetTitle( "A1_EST"    ), "CENTER", "05%" } )
aAdd( aHeader, { RetTitle( "A1_PESSOA" ), "CENTER", "05%" } )

aAdd( aItens,    {} )
aAdd( aItens[ Len( aItens ) ], { SA1->A1_COD                                                                                           , "LEFT", } )
aAdd( aItens[ Len( aItens ) ], { SA1->A1_LOJA                                                                                          , "LEFT", } )
aAdd( aItens[ Len( aItens ) ], { SA1->A1_NOME                                                                                          , "LEFT", } )
aAdd( aItens[ Len( aItens ) ], { SA1->A1_NREDUZ                                                                                        , "LEFT", } )
aAdd( aItens[ Len( aItens ) ], { AllTrim(Transform(SA1->A1_CGC,If(SA1->A1_PESSOA == "F","@R 999.999.999-99","@R 99.999.999/9999-99"))) , "LEFT", } )
aAdd( aItens[ Len( aItens ) ], { AllTrim(Transform(SA1->A1_INSCR,"@R 999.999.999.999"))                                                , "LEFT", } )
aAdd( aItens[ Len( aItens ) ], { SA1->A1_EST                                                                                           , "LEFT", } )
aAdd( aItens[ Len( aItens ) ], { If(SA1->A1_PESSOA == "F","Fisica","Juridica")                                                         , "LEFT", } )

aMeio := { aHeader, aItens }

aAdd( aObserv, { "Obs.: O Cadastro encontra-se bloqueado aguardando revisão da área resposável!" , .F., .T. } )

cMensagem := U_MontaWF( cTitulo, aSuperior, aMeio, aInferior, aLegenda, aObserv )
U_EnvEmail( {iEmail()}, cTitulo, cMensagem )
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao     ³ iEmail     º Autor ³                       º Data ³ __/__/____ º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ Funcao que determina para quais endereços de email serao       º±±
±±º            ³ enviados os avisos de inclusao                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros ³ Nil                                                            º±±
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
Static Function iEmail()
Local cTabela := "SA1"
Local cEmail := ""

SZH->(dbSetOrder(1))
SZH->(dbGoTop())
SZH->(dbSeek(xFilial("SZH") + cTabela))

While ! SZH->(EOF()) .AND. SZH->ZH_TABELA == cTabela
	cEmail += AllTrim(SZH->ZH_EMAIL) + ";"
	SZH->(dbSkip())
EndDo
Return(cEmail)