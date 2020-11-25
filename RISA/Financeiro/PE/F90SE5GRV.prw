#INCLUDE "TOPCONN.CH" 
#INCLUDE "PROTHEUS.CH"

/*-----------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} F90SE5GRV
PE no final da baixa automatica (via bordero) do contas a pagar para tratar movimenta��o do caixinha do TMS, para titulos gerados no
caixiha do TMS.
O registro no SE2 ja est� posicionado.
Esse PE n�o espera retorno e ja est� com o E2 e E5 gravados

Essa funcao pode ser chamada tb de dentro do PE F430BXA, usado na baixa via cnab, pois nesse momento tb est� com o SE5 e SE2 posicionado.

@type    function
@author  TOTVS..
@since   Nov/2020
@version P12

@project MAN0000001_EF_001
@obs     Projeto
-----------------------------------------------------------------------------------------------------------------------------------*/

User Function F90SE5GRV()

Local aArea := GetArea()

U_FA080PE()

RestArea(aArea)

Return()
