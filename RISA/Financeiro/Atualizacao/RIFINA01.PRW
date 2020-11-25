#include "rwmake.ch"
/*-----------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} RIFINA01
Funcao utlizado nos pontos de entrada:

F90SE5GRV - Baixa automática via borderô
F300SE5 - Baixa via SISPAG
F430BXA - Baixa via cnab
FA080PE - Baixa manual.

para movimentação de tabelas do caixinha, relacionados a registros gerados pela customização de geracao de titulos da rotina de caixinha do TMS.

@type    function
@author  TOTVS..
@since   Nov/2020
@version P12

@project MAN0000001_EF_001
@obs     Projeto RISA
-----------------------------------------------------------------------------------------------------------------------------------*/
User Function RIFINA01(nVlrBx,cCaixa,cFornece,cLoja,cViagem,cVei)

Local aArea  	:= GetArea()
Local aAreaSET  := SET->(GetArea())
Local aAreaSEU  := SEU->(GetArea()) 
Local aAreaSDG  := SDG->(GetArea())    
Local cProxN	:= ""
Local nSalAnt	:= 0   
Local cCodMot	:= ""
Local cDoc		:= ""

If nVlrBx > 0

	//Atualização na tabela SET - Caixinha
	dbSelectArea("SET")
	dbSetOrder(1)
	If dbSeek(xFilial("SET")+cCaixa)
		nSalAnt := SET->ET_SALDO
		RecLock("SET",.F.)
			REPLACE ET_SALDO    WITH ET_SALDO + nVlrBx
			REPLACE ET_VALOR    WITH nVlrBx
			REPLACE ET_LIMREP   WITH Iif(ET_SALDO > ET_LIMREP,ET_SALDO,ET_LIMREP)
			//Replace ET_SITUAC   With "0"
			//Replace ET_SEQCXA   With SOMA1(ET_SEQCXA) //Sequencia Ultimo Fecham. 
			Replace ET_SALANT   With nSalAnt
			//REPLACE ET_NRREND   WITH SOMA1(ET_NRREND) //Numero de rendicao       
			REPLACE ET_ULTREP   WITH dDataBase //Data da Ultima Reposicao 
		MsUnLock()
		
		//Inclusão na tabela SEU - Movimentos do caixinha
		dbSelectArea("SEU")
		dbSetOrder(1)		                                                                                                       

		cCodMot := RetMot(cFornece,cLoja) //Pego o codigo do motorista baseado no fornecedor
		cProxN  := GetSx8Num("SEU","EU_NUM") // Numero sequencial/semaforo (x3_relacao)
		ConfirmSX8()

		RecLock("SEU",.T.)
			Replace EU_FILIAL   With xFilial("SEU")
			Replace EU_NUM      With cProxN    
			Replace EU_CAIXA    With cCaixa 
			Replace EU_DTDIGIT  With dDataBase
			Replace EU_TIPO     With "10"
			Replace EU_FILORI   With xFilial("SEU")
			Replace EU_SLDADIA  With nVlrBx
			Replace EU_EMISSAO  With dDataBase
			Replace EU_SEQCXA   With SET->ET_SEQCXA
			Replace EU_NRREND   With SET->ET_NRREND
			Replace EU_VALOR    With nVlrBx
			Replace EU_HISTOR   With "Adiantamento TMS"
			Replace EU_VIAGEM   With cViagem
			Replace EU_CODVEI   With cVei
			Replace EU_CODDES   With "000000000000003"
			Replace EU_CODMOT   With cCodMot
			Replace EU_MOEDA    With 1           
			Replace EU_STATUS   With "01"
		MsUnLock()
			
		//Inclusão na tabela SDG - Movimento de Custo Transporte 
		//So gerar SDG se tiver viagem e veiculo
		If !Empty(cViagem) .and. !Empty(cVei)
		
			cDoc := RetDoc()//Retorna o ultimo numero da filial mais 1
			dbSelectArea("SDG")
			dbSetOrder(1)		                                                                                                       
	        
			RecLock("SDG",.T.)	
				Replace DG_FILIAL 	With xFilial("SDG")
				Replace DG_ITEM 	With "01"
				Replace DG_DOC 		With cDoc
				Replace DG_EMISSAO 	With dDataBase
				Replace DG_CODDES 	With "000000000000003"
				Replace DG_CODVEI 	With cVei
				Replace DG_FILORI 	With xFilial("SDG")
				Replace DG_VIAGEM 	With cViagem
				Replace DG_TOTAL 	With nVlrBx
				Replace DG_ORIGEM 	With "SDG"
				Replace DG_STATUS 	With "1"
				Replace DG_VALCOB 	With nVlrBx
				Replace DG_DATVENC 	With dDataBase
				Replace DG_NUMSEQ 	With SOMA1(DG_NUMSEQ) 
				Replace DG_CODFOR 	With cFornece
				Replace DG_LOJFOR 	With cLoja
			MsUnLock()
        
		EndIf
		
	EndIf

EndIF

RestArea(aAreaSET)
RestArea(aAreaSEU) 
RestArea(aAreaSDG)
RestArea(aArea)

Return()                                    

//Funcao para retornar o codigo do motorista baseado no fornecedor
Static Function RetMot(cFornece,cLoja)

Local aArea := GetArea()
Local cRet 	:= ""
Local cAli 	:= GetNextAlias()

BeginSQL Alias cAli

	SELECT 
		DA4_COD,
		DA4_FORNEC,
		DA4_LOJA
	FROM %table:DA4% DA4
	WHERE DA4_FILIAL = %xFilial:DA4%
		AND DA4.%NotDel%                           
		AND DA4_FORNEC = %Exp:cFornece%
		AND DA4_LOJA = %Exp:cLoja%

EndSQL

//	MemoWrite("\system\RFATA18A.SQL",GetLastQuery()[2])

If !EOF() .And. !BOF()
	If !Empty(Alltrim((cAli)->DA4_COD))
		cRet := Alltrim((cAli)->DA4_COD)
	EndIf
	(cAli)->(dbCloseArea())
Endif

RestArea(aArea)

Return(cRet) 


//Funcao para retornar o ultimo documento da filial corrente da SDG
Static Function RetDoc()

Local aArea := GetArea()
Local cRet 	:= "000000001"
Local cAli 	:= GetNextAlias()

BeginSQL Alias cAli

	SELECT 
		ISNULL(MAX(DG_DOC),'') AS DOC
	FROM %table:SDG% SDG
	WHERE DG_FILIAL = %xFilial:SDG%
		AND SDG.%NotDel%                           

EndSQL

//	MemoWrite("\system\RFATA18A.SQL",GetLastQuery()[2])

If !EOF() .And. !BOF()
	If !Empty(Alltrim((cAli)->DOC))
		cRet := Soma1((cAli)->DOC)
	EndIf
	(cAli)->(dbCloseArea())
Endif

RestArea(aArea)

Return(cRet) 
