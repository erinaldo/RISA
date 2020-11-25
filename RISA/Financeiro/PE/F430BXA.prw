#INCLUDE "TOPCONN.CH" 
#INCLUDE "PROTHEUS.CH"

/*-----------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} F430BXA
PE na baixa via cnab do contas a pagar para tratar movimentação do caixinha do TMS, para titulos gerados no
caixiha do TMS.
Esse PE não espera retorno e ja está com o E2 e E5 gravados

@type    function
@author  TOTVS..
@since   Nov/2020
@version P12

@project MAN0000001_EF_001
@obs     Projeto
-----------------------------------------------------------------------------------------------------------------------------------*/

User Function F430BXA()

Local aArea := GetArea()

U_FA080PE()

RestArea(aArea)

Return()