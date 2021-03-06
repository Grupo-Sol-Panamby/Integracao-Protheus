#include "APWEBSRV.CH"
#include "PROTHEUS.CH"
#include "TBICONN.CH"
#include "TBICODE.CH"
#include "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PESQCLI   �Autor  �Microsiga           � Data �  08/13/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSSERVICE PESQCLI DESCRIPTION "WS service - Pesquisa Cliente"
	WSMETHOD CONSULTA DESCRIPTION "Consulta cliente"
		WSDATA CGC AS STRING
		WSDATA RET AS STRING
ENDWSSERVICE

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PESQCLI   �Autor  �Microsiga           � Data �  08/13/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD CONSULTA WSRECEIVE CGC WSSEND RET WSSERVICE PESQCLI
	Local _cDescErro := ""
	Local _cCodSIG := AllTrim(::CGC)
	Local _nPos := 0
	Local _lErro := .F.
	Local _lInclui := .T.
	Local _aRetorno := {}
	Local _aCampos := {}
	Local _aArray := {}

	::Ret := ""

	DbSelectArea("SA1")
	DbSetOrder(3)
	If DbSeek(xFilial("SA1") + _cCodSIG)
		::Ret := SA1->A1_NOME
	Else
		_lErro := .T.
		_cDescErro := "Cliente nao encontrado no cadastro"
		::Ret := "Cliente nao encontrado no cadastro"
	EndIf

	If _lErro
		SetSoapFault("Atencao", _cDescErro)
		ConOut(_cDescErro)
		ConOut("Fim - Cliente/Inclui")
//		Return(.F.)
	EndIf
Return(.T.)