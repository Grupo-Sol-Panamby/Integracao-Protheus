#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/*/{Protheus.doc} WSSOLPANAMBY
Web Service Sol Panamby (client)
@type CLASS

@author Alexandre Soares Reis
@since 17/05/2016
@version P11 R8
/*/

/* ===============================================================================
WSDL Location    http://192.168.9.248:8082/ws0101/SOLPANAMBY.apw?WSDL
Gerado em        05/24/16 16:15:28
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _GLJSILS/*_WSSOLPANAMBY*/ ; Return  // "dummy" function - Internal Use

/* -------------------------------------------------------------------------------
WSDL Service WSSOLPANAMBY
------------------------------------------------------------------------------- */

WSCLIENT WSSOLPANAMBY //DESCRIPTION "WEB SERVICE (CLIENT) SOL PANAMBY"
	WSMETHOD NEW DESCRIPTION "New"
	WSMETHOD INIT DESCRIPTION "Init"
	WSMETHOD RESET DESCRIPTION "Reset"
	WSMETHOD CLONE DESCRIPTION "Clone"
	WSMETHOD SEND_CLIENTE DESCRIPTION "Envia Cliente"
		WSDATA _URL     AS String
		WSDATA _HEADOUT AS Array of String
		WSDATA _COOKIES AS Array of String
		WSDATA cXML     AS string
		WSDATA cRetorno AS string
ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSSOLPANAMBY
	::Init()
	If ! FindFunction("XMLCHILDEX")
		UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150911 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
	EndIf
Return(Self)

WSMETHOD INIT WSCLIENT WSSOLPANAMBY
Return(Nil)

WSMETHOD RESET WSCLIENT WSSOLPANAMBY
	::cXML     := Nil
	::cRetorno := Nil
	::Init()
Return(Nil)

WSMETHOD CLONE WSCLIENT WSSOLPANAMBY
	Local oClone := WSSOLPANAMBY():New()
	oClone:_URL     := ::_URL
	oClone:cXML     := ::cXML
	oClone:cRetorno := ::cRetorno
Return(oClone)

WSMETHOD SEND_CLIENTE WSSEND cXML WSRECEIVE cRetorno WSCLIENT WSSOLPANAMBY
	Local cSoap := ""
	Local oXmlRet

	BEGIN WSMETHOD
	cSoap += '<SEND_CLIENTE xmlns="http://192.168.9.248:8082/">'
	cSoap += WSSoapValue("XML", ::cXML, cXML, "string", .F., .F., 0, NIL, .F.)
	cSoap += "</SEND_CLIENTE>"

	oXmlRet := SvcSoapCall(Self,cSoap,;
		"http://192.168.9.248:8082/SEND_CLIENTE",;
		"DOCUMENT","http://192.168.9.248:8082/",,"1.031217",;
		"http://192.168.9.248:8082/ws0101/SOLPANAMBY.apw")

	::Init()
	::cRetorno := WSAdvValue( oXmlRet,"_SEND_CLIENTERESPONSE:_SEND_CLIENTERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)
	END WSMETHOD

	oXmlRet := NIL
Return(.T.)