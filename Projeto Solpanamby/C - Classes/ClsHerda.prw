#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

User Function ClsHerda()
Return Nil

/*==========================================================================
 Classe.......: uExecAuto
 Descricao....: Gravacao via Rotina Automatica: deve ser utilizada por
 				Heranca.
 Autor........: Amedeo D. Paoli Filho
 Parametros...: Nil
 Retorno......: Nil
==========================================================================*/
Class uExecAuto
	Data aCabec							//Dados do Cabecalho
	Data aItens							//Dados dos Itens
	Data aItemTemp						//Array temporario para o Item
	Data aTabelas						//Array com as Tabelas que devem ser abertas na Preparacao do Ambiente
	Data aValues						//Dados para Gravacao
	
	Data cEmpBkp						//Backup da Empresa Original
	Data cFilBkp						//Backup da Filial Original
	Data cEmpGrv						//Empresa para Gravacao
	Data cFileLog						//Nome do Arquivo para Gravacao de Log de Erro da Rotina Automatica
	Data cFilGrv						//Filial para Gravacao
	Data cMensagem						//Mensagem de Erro
	Data cPathLog						//Caminho para Gravacao do Arquivo de Log

	Data dEmissao						//Data da Inclusao ou Alteracao do Registro
	Data nTime							//Hora Inicio / Fim da Transacao
	Data cProcTOut						//Processos que estao no Time-Out
	Data nTimeOut						//Tempo do Time-Out	

	Data lExibeTela						//Define se deve exibir Tela com a Mensagem de Erro
	Data lGravaLog						//Define se deve gravar arquivo de log com a Mensagem de Erro

	Method New()						//Inializacao do Objeto
	Method AddValues(cCampo, xValor)	//Adiciona dados para Gravacao
	Method AddCabec(cCampo, xValor)		//Adicona dados ao Cabecalho
	Method AddItem(cCampo, xValor)		//Adiciona dados ao Item
	Method SetItem()					//Insere os dados do Item no Array dos Itens
	Method Gravacao(nOpcao)				//Gravacao via Rotina Automatica
	Method GetMensagem()				//Retorno das Mensagens de Erro
	Method SetEnv(nOpcao, cModulo)		//Prepara o Ambiente para Execucao da Rotina Automatica
EndClass

/*==========================================================================
 Metodo........: 	New
 Descricao.....: 	Inicializa o Objeto
 Parametros....:	Nil
==========================================================================*/
Method New() Class uExecAuto
	::aCabec		:= {}
	::aItens		:= {}
	::aItemTemp	 	:= {}
	::aTabelas		:= {}
	::aValues		:= {}

	::cEmpBkp		:= ""
	::cFilBkp		:= ""
	::cEmpGrv		:= ""
	::cFilGrv		:= ""
	::cMensagem		:= ""

	::nTime			:= ""
	::cProcTOut		:= SuperGetMV("SP_PROCTMO", NIL, "000")
	::nTimeOut		:= SuperGetMV("SP_INTTIMO", NIL, 99999999999)

	::cFileLog		:= "MATAXXX.LOG"
	::cPathLog		:= U_SPCAMGRV("L")

	::dEmissao		:= CtoD("  /  /  ")

	::lExibeTela	:= .F.
	::lGravaLog		:= .T.
Return Self

/*==========================================================================
 Metodo........: 	AddValues
 Descricao.....: 	Armazena os valores para gravacao
 Parametros....:	cCampo - Nome do Campo para Gravacao
 					xValor - Valor do Campo para Gravacao 
==========================================================================*/
Method AddValues(cCampo, xValor) Class uExecAuto
	Local nPosCpo	:= Ascan(::aValues, {|x| AllTrim(x[01]) == AllTrim(cCampo)})

	If AllTrim(cCampo) == "EMPRESA"
		::cEmpGrv := xValor
	Else
		If "_FILIAL" $ AllTrim(cCampo)
			::cFilGrv := xValor
		Else
			If nPosCpo == 0
				Aadd(::aValues, {cCampo		,xValor		,NIL})
			Else
				::aValues[nPosCpo][02] := xValor
			EndIf
		EndIf
	EndIf
Return Nil

/*==========================================================================
 Metodo........: 	AddCabec
 Descricao.....: 	Armazena os Valores do Cabecalho do para gravacao.
 Parametros....:	cCampo - Nome do Campo para Gravacao
 					xValor - Valor do Campo para Gravacao 
==========================================================================*/
Method AddCabec(cCampo, xValor) Class uExecAuto
	Local nPosCpo := Ascan(::aCabec, {|x| x[01] == cCampo})		//Posicao do Campo no Array

	If AllTrim(cCampo) == "EMPRESA"
		::cEmpGrv := xValor
	Else
		If "_FILIAL" $ AllTrim(cCampo)
			::cFilGrv	:= xValor
		Else
			If nPosCpo == 0
				Aadd(::aCabec, {cCampo, xValor, NIL})
			Else
				::aCabec[nPosCpo][02] := xValor
			EndIf
		EndIf
	EndIf
Return Nil

/*==========================================================================
 Metodo........: 	AddItem
 Descricao.....: 	Armazena os Valores do Item para gravacao.
 Parametros....:	cCampo - Nome do Campo para Gravacao
 					xValor - Valor do Campo para Gravacao 
==========================================================================*/
Method AddItem(cCampo, xValor) Class uExecAuto
	Local nPosCpo := Ascan(::aItemTemp, {|x| x[01] == cCampo})

	If !AllTrim(cCampo) == "EMPRESA"
		If nPosCpo == 0
			Aadd(::aItemTemp, {cCampo, xValor, NIL})
		Else
			::aItemTemp[nPosCpo][02] := xValor
		EndIf
	EndIf
Return Nil

/*==========================================================================
 Metodo........: 	SetItem
 Descricao.....: 	Armazena os Valores do Item e Reinicializa o Array Temporario.
 Parametros....:	cCampo - Nome do Campo para Gravacao
 					xValor - Valor do Campo para Gravacao 
==========================================================================*/
Method SetItem() Class uExecAuto
	If Len(::aItemTemp) > 0
		Aadd(::aItens, ::aItemTemp)
		::aItemTemp := {}
	EndIf
Return Nil

/*==========================================================================
 Metodo.......: SetEnv
 Descricao....: Prepara o Ambiente para Gravacao na Empresa correta.
 Parametros...: nOpcao -> 1 = Prepara / 2 = Restaura 
==========================================================================*/
Method SetEnv(nOpcao, cModulo, lTroca) Class uExecAuto
	Local	nTamEmp		:= Len(::cEmpGrv)

	Default cModulo 	:= "FAT"
	Default lTroca		:= .F.
	
	If nTamEmp > 2
		::cEmpGrv := Substr(::cEmpGrv, 1, 2)
	EndIf

	If nOpcao == 1
		If !Empty(::cEmpGrv) .AND. !Empty(::cFilGrv)
			::cEmpBkp := cEmpAnt
			::cFilBkp := cFilAnt
			
			If (::cEmpGrv <> ::cEmpBkp .OR. ::cFilGrv <> ::cFilBkp) .Or. lTroca
				RpcClearEnv()
				RPCSetType(3)
				RpcSetEnv(::cEmpGrv, ::cFilGrv, NIL, NIL, cModulo, NIL, ::aTabelas)
			EndIf
		EndIf
	
		::lExibeTela	:= SuperGetMV("SP_SHOWERR", NIL, .F.)
		::lGravaLog		:= SuperGetMV("SP_GRVLOG", NIL, .T.)

	Else
		If !Empty(::cEmpBkp) .AND. !Empty(::cFilBkp)
			If ::cEmpBkp <> cEmpAnt .OR. ::cFilBkp <> cFilAnt
				RpcClearEnv()
				RPCSetType(3)
				RpcSetEnv(::cEmpBkp, ::cFilBkp, NIL, NIL, cModulo, NIL, ::aTabelas)
			EndIf
		EndIf
	EndIf

Return Nil

/*==========================================================================
 Metodo........: 	GetMensagem
 Descricao.....: 	Retorna a Mensagem de Erro do ExecAuto
 Parametros....:	Nil
==========================================================================*/
Method GetMensagem() Class uExecAuto
Return ::cMensagem
