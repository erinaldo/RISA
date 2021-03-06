#include 'totvs.ch
#include 'rwmake.ch'
#include 'protheus.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������ͱ�
���Programa  �CXESP01    �Autor  � Marcelo Joner      � Data � 31/10/2020 ���
��������������������������������������������������������������������������ͱ�
���Desc.     �Fun��o respons�vel por verificar � exist�ncia de Pesagem    ���
���          ��nica para o contrato informado por par�metro.              ���
��������������������������������������������������������������������������ͱ�
���Uso       � Gest�o de Cereais                                          ���
��������������������������������������������������������������������������ͱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CXESP01(cNumCt)

Local lRet			:= .F.
Local cQuery		:= ""
Local cAliasTMP		:= GetNextAlias()

Default cNumCt		:= ""

//����������������������������������������������������������������
//�Executa regras, caso tenha sido informado o n�mero do contrato�
//����������������������������������������������������������������
If !EMPTY(cNumCt)

    //�������������������������������������������������������������
    //�Ajusta o n�mero do contrato ao tamanho do campo de consulta�
    //�������������������������������������������������������������
    cNumCt := PADR(cNumCt, TAMSX3("Z01_DOCUME")[1])

	//����������������������������������������������������
	//�Composi��o da consulta SQL de an�lise de Romaneios�
	//����������������������������������������������������
	cQuery := "SELECT COUNT(*) REGISTROS						" + CRLF
	cQuery += "FROM " + RetSQLName("Z01") + " Z01				" + CRLF
	cQuery += "WHERE Z01.Z01_DOCUME  = '" + cNumCt + "'			" + CRLF
	cQuery += "  AND Z01.Z01_STATUS <> '4'						" + CRLF
	cQuery += "  AND Z01.D_E_L_E_T_ <> '*'						" + CRLF
	
	If Select(cAliasTMP) > 0
		(cAliasTMP)->(dbCloseArea())
	EndIf

	dBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTMP, .F., .T.)

	lRet := (cAliasTMP)->REGISTROS > 0

	If Select(cAliasTMP) > 0
		(cAliasTMP)->(dbCloseArea())
	EndIf
EndIf

Return lRet
