#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������`���������������������������ͻ��
���Programa  �M460MARK  �Autor  �Marcelo Joner        � Data � 22/03/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada executado na marca��o de cargas\pedidos de ���
���          �venda para faturamento junto as rotinas de faturamento.     ���
���          �Utilizado para valida��es adicionais em torno do faturamento���
�������������������������������������������������������������������������͹��
���Uso       � Gest�o de Cereais                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function M460MARK()

Local lRet			:= .T.
Local aArea		:= GetArea()
Local cMarca		:= PARAMIXB[1]












//                                            ^
//                                            |
/*Implemente o ponto de entrada antes da chamada do Bloco de Fun��o do Gest�o de Cereais....*/
//************************************************************************************************************************************
//������������������������������������������������������������������������������������������������������������������������������������
//� Espec�fico para ser utilizado pelo Gest�o de Cereais 																						�
//������������������������������������������������������������������������������������������������������������������������������������
If lRet .AND. ExistBlock("xM460MARKB")
	lRet := ExecBlock("xM460MARKB", .F., .F., cMarca) 
EndIf

RestArea(aArea)

Return lRet