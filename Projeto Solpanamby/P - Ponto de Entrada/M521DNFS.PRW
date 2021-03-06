#Include 'Totvs.ch'

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
��� Programa   � M521DNFS   � Autor � Alexandre Soares Reis � Data � 29/11/2016 ���
�������������������������������������������������������������������������������͹��
��� Empresa    � Sol Panamby                                                    ���
�������������������������������������������������������������������������������͹��
��� Descricao  � O ponto de entrada executado apos o estorno da nota fiscal     ���
�������������������������������������������������������������������������������͹��
��� Modulo     � SIGAFIN                                                        ���
�������������������������������������������������������������������������������͹��
��� Uso        � Ponto de Entrada                                               ���
�������������������������������������������������������������������������������͹��
��� Parametros � aPedido - A - Pedido de Venda                               ���
�������������������������������������������������������������������������������͹��
��� Retorno    � Nil                                                            ���
�������������������������������������������������������������������������������͹��
��� Data       � Analista    �Descricao da Alteracao                            ���
���============�=============�==================================================���
��� __/__/____ �             �                                                  ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
User Function M521DNFS(aPedido)
Local aArea := SF1->(GetArea())
Local lIntregCom := SuperGetMv('PY_INT001',.T.,.F.) //Parametro respons�vel por ligar a integra��o do faturamento com os sistemas legados das empresas de comunica��o

If SM0->M0_CODIGO $ "75|80"
	If lIntregCom .AND. ! Empty(SF1->F1_XCODEXT)
		U_ISF10001(3) //3 - Excluir / 6 � Impimir
	EndIf
EndIf

RestArea(aArea)
Return(Nil)