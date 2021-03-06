#include 'totvs.ch
#include 'rwmake.ch'
#include 'protheus.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������ͱ�
���Programa  �REL011CPO  �Autor  � Marcelo Joner      � Data � 16/11/2020 ���
��������������������������������������������������������������������������ͱ�
���Desc.     �Ponto de entrada executado na impress�o de Ct. Venda atrav�s���
���          �de integra��o com o Microsoft Word.                         ���
��������������������������������������������������������������������������ͱ�
���Uso       � Especifico RISA SA                                         ���
��������������������������������������������������������������������������ͱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function REL011CPO()

Local lRet      := .T.
Local aArea     := GetArea()
Local cDetKg    := ""
Local cDetSmb   := ""

//�������������������������������������
//�Comp�e variaveis com as informa��es�
//�������������������������������������
dbSelectArea("ZDP")
dbSelectArea("SB1")
SB1->(dbSetOrder(1))
SB1->(dbGoTop())
SB1->(dbSeek(xFilial("SB1") + ZDP->ZDP_PROD))
cDetKg  := ALLTRIM(TRANSFORM(NOROUND((ZDP->ZDP_VSACA / SB1->B1_GCKGSAC), 2), PESQPICT("ZDP", "ZDP_TOTLIQ")))
cDetSmb := IIF(ZDP->ZDP_MOED <= 1, "R$", "US$")

//���������������������������
//�Cria variaveis em mem�ria�
//���������������������������
OLE_SetDocumentVat(oWord,"%cDetKg"  , cDetKg)
OLE_SetDocumentVat(oWord,"%cDetSmb" , cDetSmb)

RestArea(aArea)

Return lRet
