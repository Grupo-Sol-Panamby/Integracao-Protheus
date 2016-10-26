#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

 /* ===============================================================================
 WSDL Location    http://www.webservicex.net/ConvertComputer.asmx?wsdl
 Gerado em        08/19/10 10:42:26
 Observações      Código-Fonte gerado por ADVPL WSDL Client 1.090116
                  Alterações neste arquivo podem causar funcionamento incorreto
                  e serão perdidas caso o código-fonte seja gerado novamente.
 =============================================================================== */

User Function _WS ; Return  // "dummy" function - Internal Use
 /* -------------------------------------------------------------------------------
 WSDL Service WSComputerUnit
 ------------------------------------------------------------------------------- */
WSCLIENT WSComputerUnit

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ChangeComputerUnit

	WSDATA   _URL                      AS String
	WSDATA   nComputerValue            AS double
	WSDATA   oWSfromComputerUnit       AS ComputerUnit_Computers
	WSDATA   oWStoComputerUnit         AS ComputerUnit_Computers
	WSDATA   nChangeComputerUnitResult AS double

ENDWSCLIENT

 WSMETHOD NEW WSCLIENT WSComputerUnit
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.090818P-20100630] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSComputerUnit
	::oWSfromComputerUnit := ComputerUnit_COMPUTERS():New()
	::oWStoComputerUnit   := ComputerUnit_COMPUTERS():New()
Return

WSMETHOD RESET WSCLIENT WSComputerUnit
	::nComputerValue      := NIL
	::oWSfromComputerUnit := NIL
	::oWStoComputerUnit   := NIL
	::nChangeComputerUnitResult := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSComputerUnit
Local oClone := WSComputerUnit():New()
	oClone:_URL           := ::_URL
	oClone:nComputerValue := ::nComputerValue
	oClone:oWSfromComputerUnit :=  IIF(::oWSfromComputerUnit = NIL , NIL ,::oWSfromComputerUnit:Clone() )
	oClone:oWStoComputerUnit   :=  IIF(::oWStoComputerUnit = NIL , NIL ,::oWStoComputerUnit:Clone() )
	oClone:nChangeComputerUnitResult := ::nChangeComputerUnitResult
Return oClone

// WSDL Method ChangeComputerUnit of Service WSComputerUnit
WSMETHOD ChangeComputerUnit WSSEND nComputerValue,oWSfromComputerUnit,oWStoComputerUnit WSRECEIVE nChangeComputerUnitResult WSCLIENT WSComputerUnit
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ChangeComputerUnit xmlns="http://www.webserviceX.NET/">'
cSoap += WSSoapValue("ComputerValue", ::nComputerValue, nComputerValue , "double", .T. , .F., 0 , NIL, .F.)
cSoap += WSSoapValue("fromComputerUnit", ::oWSfromComputerUnit, oWSfromComputerUnit , "Computers", .T. , .F., 0 , NIL, .F.)
cSoap += WSSoapValue("toComputerUnit", ::oWStoComputerUnit, oWStoComputerUnit , "Computers", .T. , .F., 0 , NIL, .F.)
cSoap += "ChangeComputerUnit>"

oXmlRet := SvcSoapCall(Self,cSoap,"http://www.webserviceX.NET/ChangeComputerUnit","DOCUMENT","http://www.webserviceX.NET/",,,"http://192.168.9.248:8082/ConvertComputer.asmx")

::Init()
::nChangeComputerUnitResult :=  WSAdvValue( oXmlRet,"_CHANGECOMPUTERUNITRESPONSE:_CHANGECOMPUTERUNITRESULT:TEXT","double",NIL,NIL,NIL,NIL,NIL,NIL)

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Data Enumeration Computers
WSSTRUCT ComputerUnit_Computers
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ComputerUnit_Computers
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Bit" )
	aadd(::aValueList , "Byte" )
	aadd(::aValueList , "Kilobyte" )
	aadd(::aValueList , "Megabyte" )
	aadd(::aValueList , "Gigabyte" )
	aadd(::aValueList , "Terabyte" )
	aadd(::aValueList , "Petabyte" )
Return Self

WSMETHOD SOAPSEND WSCLIENT ComputerUnit_Computers
	Local cSoap := ""
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.)
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ComputerUnit_Computers
	::Value := NIL
	If oResponse = NIL ; Return ; Endif
	::Value :=  oResponse:TEXT
Return

WSMETHOD CLONE WSCLIENT ComputerUnit_Computers
	Local oClone := ComputerUnit_Computers():New()
	oClone:Value := ::Value
Return oClone