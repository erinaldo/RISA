#include 'totvs.ch
#include 'rwmake.ch'
#include 'protheus.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������ͱ�
���Programa  �CTS01DET   �Autor  � Marcelo Joner      � Data � 31/10/2020 ���
��������������������������������������������������������������������������ͱ�
���Desc.     �Ponto de entrada, executado antes da apresenta��o da interfa���
���          �ce das funcionalidades na rotina de Ct. Venda.              ���
��������������������������������������������������������������������������ͱ�
���Uso       � Gest�o de Cereais                                          ���
��������������������������������������������������������������������������ͱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CTS01DET()

Local lRet  := .T.

//�����������������������������������������������������
//�Verifica se existe Pesagem �nica para o Ct. Servi�o�
//�����������������������������������������������������
If ISINCALLSTACK("U_CTS001EXC") .AND. U_CXESP01(ZEG->ZEG_NUM)
    Help(NIL, NIL, "Aten��o", NIL, "Existem registros de Pesagem �nica para este Ct. Servi�o.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Para excluir o Ct. Servi�o, � necess�rio que n�o existam registros v�lidos de Pesagem �nica."})
    lRet := .F.
EndIf

Return lRet
