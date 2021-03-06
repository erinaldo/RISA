#include 'totvs.ch
#include 'rwmake.ch'
#include 'protheus.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������ͱ�
���Programa  �REL063CPO  �Autor  � Marcelo Joner      � Data � 16/11/2020 ���
��������������������������������������������������������������������������ͱ�
���Desc.     �Ponto de entrada executado na impress�o de Fixa��o sob Ct.  ���
���          �Venda atrav�s de integra��o com o Microsoft Word.           ���
��������������������������������������������������������������������������ͱ�
���Uso       � Especifico RISA SA                                         ���
��������������������������������������������������������������������������ͱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function REL063CPO()

Local lRet      := .T.
Local aArea     := GetArea()
Local cDetFix   := ""
Local cDetSmb   := ""

//�������������������������������������
//�Comp�e variaveis com as informa��es�
//�������������������������������������
dbSelectArea("ZDP")
cDetFix  := ALLTRIM(TRANSFORM(NOROUND((ZDP->ZDP_QUANT - ZDU->ZDU_QUANT), 2), PESQPICT("ZDP", "ZDP_QUANT")))
cDetSmb := IIF(ZDU->ZDU_MOED <= 1, "R$", "US$")

//���������������������������
//�Cria variaveis em mem�ria�
//���������������������������
OLE_SetDocumentVat(oWord,"%cDetFix", cDetFix)
OLE_SetDocumentVat(oWord,"%cDetSmb", cDetSmb)

RestArea(aArea)

Return lRet
