#include "rwmake.ch"
/*-----------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} FA080PE
Ponto de entrada no final da baixa do titulo a pagar manual, para tratar movimentação do caixinha do TMS, para titulos gerados no
caixiha do TMS.

@type    function
@author  TOTVS..
@since   Nov/2020
@version P12

@project MAN0000001_EF_001
@obs     Projeto RISA
-----------------------------------------------------------------------------------------------------------------------------------*/

User Function FA080PE()

Local aArea := GetArea()           
Local cCaixa:= ""

//Somente registros gerado pela rotina de caixinha do TMS.
If SE2->E2_PREFIXO == "CAR" .AND. Alltrim(SE2->E2_ORIGEM) == "SIGATMS" .AND. Alltrim(SE2->E2_TIPO) == "DP"

	cCaixa := RetCx() //Pego o codigo do caixinha baseado no fornecedor

	If !Empty(cCaixa)
		U_RIFINA01(SE5->E5_VALOR,cCaixa,SE5->E5_CLIFOR,SE5->E5_LOJA,SE2->E2_XVIAGEM,SE2->E2_XCODVEI)
	Else
		Aviso("Atencao","Fornecedor "+SE5->E5_CLIFOR+"-"+SE5->E5_LOJA+" não localizado no caixinha. Verifique!",{"Voltar"})
	EndIf

EndIf

RestArea(aArea)

Return()             

//Funcao para retornar o codigo do caixinha baseado no fornecedor
Static Function RetCx()

Local aArea := GetArea()
Local cRet 	:= ""
Local cAli 	:= GetNextAlias()

BeginSQL Alias cAli

	SELECT 
		ET_CODIGO,
		ET_FORNECE,
		ET_LOJA
	FROM %table:SET% ET
	WHERE ET_FILIAL = %xFilial:SET%
		AND ET.%NotDel%                           
		AND ET_FORNECE = %Exp:SE5->E5_CLIFOR%
		AND ET_LOJA = %Exp:SE5->E5_LOJA%

EndSQL

//	MemoWrite("\system\RFATA18A.SQL",GetLastQuery()[2])

If !EOF() .And. !BOF()
	If !Empty(Alltrim((cAli)->ET_CODIGO))
		cRet := Alltrim((cAli)->ET_CODIGO)
	EndIf
	(cAli)->(dbCloseArea())
Endif

RestArea(aArea)

Return(cRet) 
