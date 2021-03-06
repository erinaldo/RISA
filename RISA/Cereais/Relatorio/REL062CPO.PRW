#include 'totvs.ch
#include 'rwmake.ch'
#include 'protheus.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������ͱ�
���Programa  �REL062CPO  �Autor  � Marcelo Joner      � Data � 16/11/2020 ���
��������������������������������������������������������������������������ͱ�
���Desc.     �Ponto de entrada executado na impress�o de Fixa��o sob Ct.  ���
���          �Compra atrav�s de integra��o com o Microsoft Word.          ���
��������������������������������������������������������������������������ͱ�
���Uso       � Especifico RISA SA                                         ���
��������������������������������������������������������������������������ͱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function REL062CPO()

Local lRet      := .T.
Local aArea     := GetArea()
Local cDetFix   := ""
Local cDetSmb   := ""

//�������������������������������������
//�Comp�e variaveis com as informa��es�
//�������������������������������������
dbSelectArea("ZDA")
cDetFix  := ALLTRIM(TRANSFORM(NOROUND((ZDA->ZDA_QUANT - ZDH->ZDH_QUANT), 2), PESQPICT("ZDA", "ZDA_QUANT")))
cDetSmb := IIF(ZDH->ZDH_MOEDA <= 1, "R$", "US$")

//���������������������������
//�Cria variaveis em mem�ria�
//���������������������������
OLE_SetDocumentVat(oWord,"%cDetFix", cDetFix)
OLE_SetDocumentVat(oWord,"%cDetSmb", cDetSmb)

RestArea(aArea)

Return lRet
