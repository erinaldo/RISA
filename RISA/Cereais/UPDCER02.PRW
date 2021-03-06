#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������`���������������������������ͻ��
���Programa  �UPDCER02  �Autor  �Marcelo Joner        � Data � 26/03/2018 ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada executado no compatibilizador U_UPDCEREAIS ���
���          �com o objetivo de determinar se deve atualizar as regras de ���
���          �obrigatoriedade do campo do Addon Gest�o de Cereais conforme���
���          �padr�o ou n�o.                                              ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Risa S/A                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function UPDCER02()

Local lAtualiza		:= .T.
Local cCamposGC		:= "ZD2_CCD\ZD3_CCD\ZDA_CCD"
Local cCampoUpd		:= ALLTRIM(PARAMIXB)

//���������������������������������������������������������������������������������������������������������
//�Caso o campo atual esteja entre os campos da lista, n�o atualiza defini��es de obrigatoriedade do mesmo�
//���������������������������������������������������������������������������������������������������������
If cCampoUpd $ cCamposGC .OR. "ZCB_ARG" $ cCampoUpd
	lAtualiza := .F.
EndIf

Return lAtualiza
