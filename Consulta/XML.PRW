#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

Function u_TesteXml()
Local aLivros := {}
Local aXml := {}
Local cError := ''
Local cModelo := ''
Local cXml := ''
Local cWarning := ''
Local nL := 0
Local nTotL := 0
Local nXmlStatus := 0
Local oXml

// Defino dados dos livros a catalogar
aadd(aLivros,{"000001","Livro Teste"   ,"John Doe"   ,"10/05/2001"})
aadd(aLivros,{"000002","Livro Ficticeo","Mary Brahms","15/05/2001"})

// Crio modelo ( apenas estrutura ) em String
cModelo += '<?xml version="1.0"?>'
cModelo += '<MeuDoc>'
cModelo += '<Livro>'
cModelo += '<Id></Id>'
cModelo += '<Titulo></Titulo>'
cModelo += '<Autor></Autor>'
cModelo += '<Data></Data>'
cModelo += '</Livro>'
cModelo += '</MeuDoc>'

// Crio o Objeto XML , definindo o Livro como Array
CREATE oXML XMLSTRING cModelo SETASARRAY _MeuDoc:_Livro
nXmlStatus := XMLError()

If nXmlStatus == XERROR_SUCCESS
	// Caso nao houve nenhum tipo de erro de criação do Objeto
	// Calcula o total de Livros e percorre os elementos do array
	// para criar os nodes dos livros no XML.
	nTotL := len(aLivros)
	For nL := 1 to nTotL
		If nL > 1
			// Apenas acrescento nodes novos caso já tenha realizado a
			// primeira volta do looping , que irá atribuir os valores
			// do primeiro livro ao node já existente no objeto Xml
			ADDNODE oXml:_MeuDoc:_Livro NODE '_Livro' ON oXML
		Endif
		// Atriblui os dados do livro no objeto Xml
		oXml:_MeuDoc:_Livro[nL]:_Id:TEXT := aLivros[nL][1]
		oXml:_MeuDoc:_Livro[nL]:_Titulo:TEXT := aLivros[nL][2]
		oXml:_MeuDoc:_Livro[nL]:_Autor:TEXT := aLivros[nL][3]
		oXml:_MeuDoc:_Livro[nL]:_Data:TEXT := aLivros[nL][4]
	Next
	// Ao fim do processo , gera a string XML correspondente ao Objeto
	SAVE oXml XMLSTRING cXml
	// Sava XML em arquivo na pasta root
	SAVE oXml XMLFILE "\teste.xml"
	//Abre o arquivo gerado
	oXml := XmlParserFile("\teste.xml", "_", @cError, @cWarning )
	If Empty(cError) .OR. Empty(cWarning)
		If ValType(oXml:_MeuDoc) == "O"
			// Transforma em array um objeto (nó) da estrutura do XML
			If XmlNode2Arr(oXml:_MeuDoc, "_MeuDoc")
				// Realiza uma copia do mesmo para um array
				aXml := aClone(oXml:_MeuDoc)
			EndIf
		EndIf
	Else
		alert("Erro: " + cError + "  -  Aviso: " + cWarning )
	EndIf
	// Mostra o XML criado na Tela , usando a função MsgStop
	MsgStop(cXml)
Else
	MsgStop("Erro (" + Str(nXmlStatus,3) + ") na criação do XML.")
Endif
Return