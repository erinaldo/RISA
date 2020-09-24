#INCLUDE "TOTVS.CH"

/*/

{Protheus.doc} MT410TOK
                 
Ponto de Entrada

@author  Milton J.dos Santos	
@since   15/07/20
@version 1.0

/*/

User Function MT410TOK()
Local lRet   := .T.

// Verifica os campos obrigatorios para regra de precos e descontos
If  lRet
	If ExistBlock("CMPREGRA")
		lRet := ExecBlock( "CMPREGRA", .F., .F.)
	EndIf
EndIf

//*************************************************************************************************************************************
/*Implemente o ponto de entrada antes da chamada do Bloco de Fun��o do Gest�o de Cereais....*/
//*************************************************************************************************************************************
//�������������������������������������������������������������������������������������������������������������������������������������
//� Espec�fico para ser utilizado pelo Gest�o de Cereais 																			  �
//�������������������������������������������������������������������������������������������������������������������������������������
If lRet
	If ExistBlock("xMT40TOK")
		lRet := ExecBlock( "xMT40TOK", .F., .F.)
	EndIf
EndIf

Return( lRet )

