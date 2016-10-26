#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/*/{Protheus.doc} SOLPANAMBY
Web Service Sol Panamby (server)
@type CLASS

@author Alexandre Soares Reis
@since 17/05/2016
@version P11 R8
/*/
WSSERVICE SOLPANAMBY DESCRIPTION "WEB SERVICE SOL PANAMBY"
	WSMETHOD SEND_CLIENTE DESCRIPTION "ENVIA CLIENTE"
	WSMETHOD RECE_CONTRATO DESCRIPTION "RECEBE CONTRATO"
	WSMETHOD RECE_EXECUCAO DESCRIPTION "RECEBE EXECUÇÃO"
	WSMETHOD RECE_FATURAMENTO DESCRIPTION "RECEBE FATURAMENTO"
ENDWSSERVICE

WSMETHOD SEND_CLIENTE WSRECEIVE XML WSSEND Retorno WSSERVICE SOLPANAMBY
	Local cXML := ::XML
	Local cRetorno := ::Retorno

	ConOut("Inicio recebimento XML Cliente")
	ConOut(cXML)
	cRetorno := cXML
	cRetorno += CHR(13) + CHR(10)
	cRetorno += "XML recebindo com sucesso"
	ConOut(cRetorno)

	::Retorno := cRetorno
Return(.T.)

WSMETHOD RECE_CONTRATO WSRECEIVE XML WSSEND Retorno WSSERVICE SOLPANAMBY
	Local cXML := ::XML
	Local cRetorno := ::Retorno

//	ConOut("Inicio recebimento XML Contrato")
//	ConOut(cXML)
//	cRetorno := cXML
//	cRetorno += CHR(13) + CHR(10)
//	cRetorno += "XML recebindo com sucesso"
//	ConOut(cRetorno)

	U_IGCO0001(cXML,1)

	::Retorno := cRetorno
Return(.T.)

WSMETHOD RECE_EXECUCAO WSRECEIVE XML WSSEND Retorno WSSERVICE SOLPANAMBY
	Local cXML := ::XML
	Local cRetorno := ::Retorno

	ConOut("Inicio recebimento XML Execução")
	ConOut(cXML)
	cRetorno := cXML
	cRetorno += CHR(13) + CHR(10)
	cRetorno += "XML recebindo com sucesso"
	ConOut(cRetorno)

	U_IGCO0001(cXML,2)

	::Retorno := cRetorno
Return(.T.)

WSMETHOD RECE_FATURAMENTO WSRECEIVE XML WSSEND Retorno WSSERVICE SOLPANAMBY
	Local cXML := ::XML
	Local cRetorno := ::Retorno

	ConOut("Inicio recebimento XML Faturamento")
	ConOut(cXML)
	cRetorno := cXML
	cRetorno += CHR(13) + CHR(10)
	cRetorno += "XML recebindo com sucesso"
	ConOut(cRetorno)

	U_IGCO0001(cXML,3)

	::Retorno := cRetorno
Return(.T.)