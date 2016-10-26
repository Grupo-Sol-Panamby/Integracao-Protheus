#INCLUDE 'PROTHEUS.CH'

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
��� Programa   � MA040DIN   � Autor � Alexandre Soares Reis � Data � 26/10/2016 ���
�������������������������������������������������������������������������������͹��
��� Empresa    � Sol Panamby                                                    ���
�������������������������������������������������������������������������������͹��
��� Descricao  � Ponto de entrada apos a inclusao no cadastro de vendedor       ���
�������������������������������������������������������������������������������͹��
��� Modulo     � SIGACOM                                                        ���
�������������������������������������������������������������������������������͹��
��� Uso        � Ponto de Entrada                                               ���
�������������������������������������������������������������������������������͹��
��� Parametros � Nil                                                            ���
�������������������������������������������������������������������������������͹��
��� Retorno    � Nil                                                            ���
�������������������������������������������������������������������������������͹��
��� Data       � Analista    �Descricao da Alteracao                            ���
���============�=============�==================================================���
��� __/__/____ � ___________ �                                                  ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
User Function MA040DIN()
Local aAreaSA3 := SA3->(GetArea())

If SM0->M0_CODIGO $ "75|80" .AND. SA3->A3_MSBLQL <> "1"
	U_ISA30001(INCLUI,ALTERA)
EndIf

RestArea(aAreaSA3)
Return(Nil)