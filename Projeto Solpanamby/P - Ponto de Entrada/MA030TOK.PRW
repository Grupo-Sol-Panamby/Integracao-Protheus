#Include 'Protheus.ch'

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
��� Programa   � MA030TOK   � Autor � Alexandre Soares Reis � Data � 24/11/2014 ���
�������������������������������������������������������������������������������͹��
��� Empresa    � Sol Panamby                                                    ���
�������������������������������������������������������������������������������͹��
��� Descricao  � Ponto de entrada no momento da validacao dos dados digitados   ���
���            � no cadastro de cliente                                         ���
�������������������������������������������������������������������������������͹��
��� Modulo     � SIGAFAT                                                        ���
�������������������������������������������������������������������������������͹��
��� Uso        � Ponto de Entrada                                               ���
�������������������������������������������������������������������������������͹��
��� Parametros � Nil                                                            ���
�������������������������������������������������������������������������������͹��
��� Retorno    � Nil                                                            ���
�������������������������������������������������������������������������������͹��
��� Data       � Analista    �Descricao da Alteracao                            ���
���============�=============�==================================================���
��� 19/10/2015 � Alexandre   � Inclusao de validacao A1_CODMUN2                 ���
���            �             �                                                  ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
User Function MA030TOK()
Local lRet := .T.

If Empty(M->A1_CGC)
	If M->A1_TIPO <> "X"
		Aviso("Atencao","O tipo de cliente selecionado exige o preenchimento do campo " + If(M->A1_PESSOA == "J","CNPJ","CPF"),{"Ok"})
		lRet := .F.
	EndIf
EndIf

If Empty(M->A1_COD_MUN)
	If M->A1_EST == "SP"
		Aviso("Atencao","O estado SP do cliente exige o preenchimento do campo Cod. Munic�pio",{"Ok"})
		lRet := .F.
	EndIf
EndIf

If Empty(M->A1_CODMUN2)
	If M->A1_EST == "SP"
		Aviso("Atencao","O estado SP do cliente exige o preenchimento do campo Cod. Mun. GIA",{"Ok"})
		lRet := .F.
	EndIf
EndIf

If SA1->A1_MSBLQL == M->A1_MSBLQL
	PutMV("PY_OPCBLQL","")
Else
	PutMV("PY_OPCBLQL",M->A1_MSBLQL)
EndIf
Return(lRet)