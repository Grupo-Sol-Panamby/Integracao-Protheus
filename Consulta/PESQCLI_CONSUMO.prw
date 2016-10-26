#INCLUDE 'PROTHEUS.CH'

USER FUNCTION PESQCLIC()
LOCAL oOBJ
LOCAL cResult		:= ""

//-----------------------------------------------------------------------
// Conecta ao WS
//-----------------------------------------------------------------------
oOBJ := WSPESQCLI():New()

oOBJ:cCGC := "55077598000109" //55.077.598/0001-09 //"12324885859"

//-----------------------------------------------------------------------
// Envio
//-----------------------------------------------------------------------
IF oOBJ:CONSULTA()
	cResult := oOBJ:cCONSULTARESULT

	ALERT( cResult )
ELSE
	ALERT( "Não foi possível conectar ao WSPESQCLI()" )
ENDIF

RETURN