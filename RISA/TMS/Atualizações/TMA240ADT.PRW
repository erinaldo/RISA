#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "AUTODEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "topconn.ch"


User Function TMA240Adt()
Local lRet      := .T.
Local nOpcx     := ParamIXB[1]
Local nTotAdto  := ParamIXB[2]
Local nFrePag   := ParamIXB[3]
Local   _viagem     := dtq->dtq_viagem
Local   _cquery     := ""
Local   _adto       := {}
Local   _totaladt   := {}
Local   _uladto       := ""
Local   _ultotaladt  := 0  
Local   _codmot  
Local   _codformot  
Local   _cCaixa
Local   _numatu 
Local   _adtoseu
Local   _valor      := 0
Local _docadt   := {}
Local _docseu   := {}
Local nx        := 1
Local _difadt   := 0
Local _titadt   := {}
Local _coddes   := ""
Local _ljformot := ""
Local _nomfor   := ""
Local _numsx8   

 aRet := .T.
//ao clicar em salvar no complemento de viagens

// busco adiantamento 
     _cquery:=" SELECT"
     _cquery+=" DG_DOC ULTADT, DG_TOTAL TOTALADT "
     _cquery+=" FROM "
     _cquery+=  retsqlname("SDG")+" SDG"
     _cquery+=" where SDG.D_E_L_E_T_ = ' ' "
     _cquery+=" AND DG_VIAGEM = '"+_viagem+"'"
     _cquery+=" AND DG_ORIGEM = 'DTR'"
     _cquery+=" AND DG_STATUS = '3'"          
     _cquery+=" AND DG_CODDES = '000000000000001'"
     _cquery+=" AND DG_FILIAL = '"+XFILIAL("SDG")+"'"
     _cquery:=changequery(_cquery)			
     tcquery _cquery new alias "TMP2"

     tmp2->(DbGoTop())
    While tmp2->(!Eof())
        aadd(_adto,tmp2->ULTADT)
        aadd(_totaladt,tmp2->TOTALADT)
        _uladto       := tmp2->ULTADT
        _ultotaladt   := tmp2->TOTALADT + _ultotaladt

        tmp2->(DbSkip())       
    end
    _difadt := nTotAdto - _ultotaladt

     Tmp2->(DbCloseArea()) 
     

//busco motorista da viagem
     _cquery:=" SELECT"
     _cquery+=" DUP_CODMOT "
     _cquery+=" FROM "
     _cquery+=  retsqlname("DUP")+" DUP"
     _cquery+=" where DUP.D_E_L_E_T_ = ' ' "
     _cquery+=" AND DUP_VIAGEM = '"+_viagem+"'"
     _cquery+=" AND DUP_FILIAL = '"+XFILIAL("DUP")+"'"
     _cquery:=changequery(_cquery)			
     tcquery _cquery new alias "TMP2"

    tmp2->(DbGoTop())
    While tmp2->(!Eof())
        _codmot      := tmp2->DUP_CODMOT

        tmp2->(DbSkip())       
    end

    Tmp2->(DbCloseArea()) 



 //procuro os dados de fornecedor do motorista
     _cquery:=" SELECT * "
     //_cquery+=" sum(EU_VALOR) VALOR"
     _cquery+=" FROM "
     _cquery+=  retsqlname("DA4")+" DA4"
     _cquery+=" where DA4.D_E_L_E_T_ = ' ' "
     _cquery+=" AND DA4.DA4_COD = '"+_codmot+"'" 
     _cquery:=changequery(_cquery)			
     tcquery _cquery new alias "TMP2"
 	

    _codformot  :=   TMP2->DA4_FORNEC
    _ljformot   :=   TMP2->DA4_LOJA
    _nomfor     :=   TMP2->DA4_NOME
     Tmp2->(DbCloseArea()) 

     _cquery:=" SELECT"
     _cquery+=" MAX(EU_NUM) PROXNUM"
     _cquery+=" FROM "
     _cquery+=  retsqlname("SEU")+" SEU"
     _cquery+=" where SEU.D_E_L_E_T_ = ' ' "
     _cquery+=" AND SEU.EU_FILIAL = '"+XFILIAL("SEU")+"'"
     _cquery:=changequery(_cquery)			
     tcquery _cquery new alias "TMP2"

     tmp2->(DbGoTop())
     _numatu    := tmp2->PROXNUM
     ProxN      := SOMA1(tmp2->PROXNUM)
     Tmp2->(DbCloseArea()) 

    _adtoseu := Posicione("SEU",1,xFilial("SEU")+_numatu,'EU_HISTOR')

 //verifico se È estorno
     _cquery:=" SELECT * "
     //_cquery+=" sum(EU_VALOR) VALOR"
     _cquery+=" FROM "
     _cquery+=  retsqlname("SEU")+" SEU"
     _cquery+=" where SEU.D_E_L_E_T_ = ' ' "
     _cquery+=" AND SEU.EU_VIAGEM = '"+_viagem+"'"
     _cquery+=" AND SEU.EU_CODMOT = '"+_codmot+"'" 
     _cquery+=" AND SEU.EU_CODDES = '000000000000001'"      
     _cquery+=" AND SEU.EU_FILIAL = '"+XFILIAL("SEU")+"'"
     _cquery:=changequery(_cquery)			
     tcquery _cquery new alias "TMP2"
 	
     tmp2->(DbGoTop())
        While tmp2->(!Eof())
            aadd(_docadt,alltrim(tmp2->EU_HISTOR))
            aadd(_docseu,alltrim(tmp2->EU_NUM))

            tmp2->(DbSkip())       
        end         
   
     Tmp2->(DbCloseArea()) 


     _cquery:=" SELECT * "
     _cquery+=" FROM "
     _cquery+=  retsqlname("SDG")+" SDG"
     _cquery+=" where SDG.D_E_L_E_T_ = '*' "
     _cquery+=" AND DG_VIAGEM = '"+_viagem+"'"
     _cquery+=" AND DG_CODDES = '000000000000001'"
     _cquery+=" AND DG_FILIAL = '"+XFILIAL("SDG")+"'"
     _cquery:=changequery(_cquery)			
     tcquery _cquery new alias "TMP2"




        tmp2->(DbGoTop())
        While tmp2->(!Eof())
            For nx := 1 to len(_docadt)
                If alltrim(_docadt[nx]) = tmp2->DG_DOC
			        DbSelectArea("SEU")
			        DbSetOrder(1)
		            DbSeek(xFilial("SEU")+_docseu[nx])
                    _numsx8 :=  GetSX8NUM() 
                    ConfirmSX8()
                    If Found()
                        RecLock("SEU",.F.)
                        SEU->(dbDelete())
                        //msgalert(SEU->EU_NUM)
                        MsUnLock()
                    EndIf               
                EndIf
            Next nx
            tmp2->(DbSkip())       
        end

     Tmp2->(DbCloseArea())

    If alltrim(_uladto) = alltrim(_adtoseu)
        Return aRet   
    EndIf
  
    If _numatu = ProxN
        ProxN      := SOMA1(ProxN)  

    EndIf 

//somo o que j· foi adiantado e faÁo a diferenÁa

    _cquery:=" SELECT"
     _cquery+=" sum(EU_VALOR) VALOR"
     _cquery+=" FROM "
     _cquery+=  retsqlname("SEU")+" SEU"
     _cquery+=" where SEU.D_E_L_E_T_ = ' ' "
     _cquery+=" AND SEU.EU_VIAGEM = '"+_viagem+"'" 
     _cquery+=" AND SEU.EU_CODDES = '000000000000001'"      
     _cquery+=" AND SEU.EU_FILIAL = '"+XFILIAL("SEU")+"'"
     _cquery:=changequery(_cquery)			
     tcquery _cquery new alias "TMP2"
 	
     tmp2->(DbGoTop())
     _valor    := tmp2->VALOR
     Tmp2->(DbCloseArea()) 
   // _totaladt := _totaladt - _valor

    //msgalert(_valor)
    dbSelectArea("SET")
    dbSetOrder(1)  // filial + caixa
    SET->(DbGoTop())
    While SET->(!Eof())
        If _codformot = SET->ET_FORNECE
			RecLock("SET",.F.)
            REPLACE ET_SALDO 	WITH ET_SALDO + _difadt
            REPLACE ET_VALOR    WITH ET_SALDO
            If ET_VALOR > ET_LIMREP
                REPLACE ET_LIMREP    WITH ET_VALOR
            EndIf 

			Replace ET_SITUAC   With "0"
			Replace ET_SEQCXA   With SOMA1(ET_SEQCXA)
			Replace ET_SALANT   With ET_SALDO
			REPLACE ET_NRREND	WITH SOMA1(ET_NRREND)
			REPLACE ET_ULTREP	WITH dDataBase
			MsUnLock()
            _cCaixa   		:= SET->ET_CODIGO
        EndIf

        SET->(DbSkip())       
    end

 
    dbSelectArea("SEU")
    dbSetOrder(1)  // filial + caixa

    RecLock("SEU",.T.)
	Replace EU_FILIAL  	With xFilial("SEU")
	Replace EU_NUM     	With ProxN    // Numero sequencial/semaforo (x3_relacao)
	Replace EU_CAIXA   	With _cCaixa
	Replace EU_DTDIGIT 	With dDataBase
	Replace EU_TIPO    	With "01"
	Replace EU_FILORI   With xFilial("SEU")
	Replace EU_SLDADIA 	With _difadt
	Replace EU_EMISSAO 	With dDataBase
    Replace EU_SEQCXA  	With SET->ET_SEQCXA
	Replace EU_NRREND   With SET->ET_NRREND
	Replace EU_VALOR   	With _difadt
	Replace EU_HISTOR	With _uladto
 	Replace EU_VIAGEM	With _viagem
	Replace EU_CODDES	With "000000000000001"
	Replace EU_CODMOT	With _codmot
    Replace EU_MOEDA    With 1           
    Replace EU_STATUS   With "01"
    Replace EU_CAIXA    With _cCaixa


    

//ao clicar em salvar o adiantamento

	_titadt := {{"E2_FILIAL"   , xFilial("SE2")    , NIL },;
	{ "E2_PREFIXO"  , "CAR"             , NIL },;
	{ "E2_NUM"      , _uladto, NIL },;
	{ "E2_TIPO"     , "DP"     , NIL },;
	{ "E2_NATUREZ"  , "24002"   , NIL },;
	{ "E2_FORNECE"  , _codformot  , NIL },;
	{ "E2_LOJA"  	, _ljformot     , NIL },;
	{ "E2_NOMFOR"   , _nomfor   , NIL },;
	{ "E2_EMISSAO"  , dDataBase  , NIL },;
	{ "E2_VENCTO"   , dDataBase + 10  , NIL },;
	{ "E2_VENCORI"  , dDataBase + 10   , NIL },;
	{ "E2_DEBITO"   , "5010201007"   , NIL },;
	{ "E2_CREDIT"   , "2010101002"   , NIL },;
	{ "E2_RATEIO"   , "N"   , NIL },;
	{ "E2_ORIGEM"   , "SIGATMS"         , NIL },;
	{ "E2_VLCRUZ"   , _difadt   , NIL },;
	{ "E2_SALDO"    , _difadt    , NIL },;
	{ "E2_VALOR"    , _difadt    , NIL },;
	{ "E2_HIST"     , "Viagem " + _viagem    , NIL } } // GRAVAR HISTORICO NO TITULO FINANCEIRO POR KYONE CHAMADO 005922
	
	
	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, _titadt,, 3)  // 3 - Inclusao, 4 - Altera√ßao, 5 - Exclusao
	
	If lMsErroAuto
		MostraErro()
    EndIf    
Return lRet 

