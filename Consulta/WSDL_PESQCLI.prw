#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8088/ws/PESQCLI.apw?WSDL
Gerado em        03/26/16 10:44:38
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _CJQZJRV ; Return  // "dummy" function - Internal Use

/* -------------------------------------------------------------------------------
WSDL Service WSPESQCLI
------------------------------------------------------------------------------- */
WSCLIENT WSPESQCLI //DESCRIPTION "WS client - Pesquisa Cliente"
	WSMETHOD NEW DESCRIPTION "New"
	WSMETHOD INIT DESCRIPTION "Init"
	WSMETHOD RESET DESCRIPTION "Reset"
	WSMETHOD CLONE DESCRIPTION "Clone"
	WSMETHOD CONSULTA DESCRIPTION "Consulta Cliente"
		WSDATA _URL            AS String
		WSDATA _HEADOUT        AS Array Of String
		WSDATA _COOKIES        AS Array Of String
		WSDATA cCGC            AS string
		WSDATA cCONSULTARESULT AS string
ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSPESQCLI
	::Init()
	If ! FindFunction("XMLCHILDEX")
		UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150911 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
	EndIf
Return(Self)

WSMETHOD INIT WSCLIENT WSPESQCLI
Return(Nil)

WSMETHOD RESET WSCLIENT WSPESQCLI
	::cCGC            := NIL
	::cCONSULTARESULT := NIL
	::Init()
Return(Nil)

WSMETHOD CLONE WSCLIENT WSPESQCLI
	Local oClone := WSPESQCLI():New()
	oClone:_URL            := ::_URL
	oClone:cCGC            := ::cCGC
	oClone:cCONSULTARESULT := ::cCONSULTARESULT
Return(oClone)

// WSDL Method CONSULTA of Service WSPESQCLI
WSMETHOD CONSULTA WSSEND cCGC WSRECEIVE cCONSULTARESULT WSCLIENT WSPESQCLI
	Local cSoap := ""
	Local oXmlRet

	BEGIN WSMETHOD
	cSoap += '<CONSULTA xmlns="http://192.168.9.248:8082/">'
	cSoap += WSSoapValue("CGC", ::cCGC, cCGC , "string", .T. , .F., 0 , NIL, .F.)
	cSoap += "</CONSULTA>"

	oXmlRet := SvcSoapCall(	Self,cSoap,;
		"http://192.168.9.248:8082/CONSULTA",;
		"DOCUMENT","http://192.168.9.248:8082/",,"1.031217",;
		"http://192.168.9.248:8082/ws0101/PESQCLI.apw")

	::Init()
	::cCONSULTARESULT := WSAdvValue( oXmlRet,"_CONSULTARESPONSE:_CONSULTARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
	END WSMETHOD

	oXmlRet := NIL
Return(.T.)