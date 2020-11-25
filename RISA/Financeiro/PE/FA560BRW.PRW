
#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#INCLUDE "topconn.ch"

User Function FA560BRW()

Local aButtons := ParamIxb[1]

Aadd(aButtons, {"Mov. Caixinha TMS", "U_TelCad()" ,0,4,Nil,.F.} )

Return(aButtons) 
 
User Function TelCad()
    PRIVATE aComboBo1       := {"01=Adiantamento","02=Diaria"} //Tipos de adiantamentos
    Private nComboBo1       := space(02)
    Private wtpadt			:= SPACE(01)        // Tipo de adiantamento
	Private wviagem			:= space(06) //
	Private wMotori			:= SPACE(06)		// 
	Private wVvlradt        := 0 //SPACE(14)

@ 000,000 to 270,500 dialog odlg9 title "Dados para o adiantamento"

	@ 012,010 say "Tipo de adiantamento"
	// get wDNunDi 		Picture "999999999999999" 	   size 070,10  //Valid
    @ 010,065 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS aComboBo1 SIZE 072, 010 OF odlg9 COLORS 0, 16777215 PIXEL 
	
    @ 032,010 say "Viagem "
	@ 030,065 get wViagem 		Picture "@!" 			       size 070,10 F3 "DTQ"

	@ 052,010 say "Motorista"
	@ 050,065 get wMotori    	Picture "@!" 			       size 070,10  F3 "DA4"

	@ 072,010 say "Vlr Adiantamento"
	@ 070,065 get wVvlradt 		Picture "@E 999,999,999.99"	   size 070,10

	@ 092,200 bmpbutton type 1 action fGraDadosAdt()

	Activate Dialog odlg9 Centered


Return


Static Function fGraDadosAdt()

Local _titadt   := {}
Local   _cquery     := ""
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
Local _codveic  := ""   
Local _existadt := 1
Local _existmot := 1
Local _existfor := 1
Local _existdes := 1
Local _exisvimo := 1
Local _existtit := 1
Private lMsErroAuto := .F.

If nComboBo1 = "01"
    // procuro o veiculo da viagem
     _cquery:=" SELECT * FROM "
     _cquery+=  retsqlname("DTR")+" DTR"
     _cquery+=" where DTR.D_E_L_E_T_ = ' ' "
     _cquery+=" AND DTR.DTR_VIAGEM = '"+wViagem+"'" 
     _cquery+=" AND DTR.DTR_FILIAL = '"+wMotori+"'"
     _cquery:=changequery(_cquery)			
     tcquery _cquery new alias "TMP2"
 	
     tmp2->(DbGoTop())

     Tmp2->(DbCloseArea()) 
        If Len(alltrim(wViagem)) > 0
            else
                msgalert("A viagem tem que ser informada neste tipo de adiantamento!!")
                Return         
        EndIf

    // procuro se existe o motorista x viagem informada
     _cquery:=" SELECT * FROM "
     _cquery+=  retsqlname("DUP")+" DUP"
     _cquery+=" where DUP.D_E_L_E_T_ = ' ' "
     _cquery+=" AND DUP.DUP_VIAGEM = '"+wViagem+"'" 
     _cquery+=" AND DUP.DUP_CODMOT = '"+wMotori+"'"      
     _cquery+=" AND DUP.DUP_FILIAL = '"+XFILIAL("DUP")+"'"
     _cquery:=changequery(_cquery)			
     tcquery _cquery new alias "TMP2"
 	
     tmp2->(DbGoTop())
            While tmp2->(!Eof())
                _exisvimo := 2        
                tmp2->(DbSkip())       
            end 
     Tmp2->(DbCloseArea()) 
             If _exisvimo = 1

                msgalert("A viagem x motorista informada nao existe!")
                Return         
        EndIf

     else
        wViagem := ""
EndIf        

        
        aRet := .T.
        //Busco o proximo numero nos titulos a pagar
            _cquery:=" SELECT"
            _cquery+=" MAX(E2_NUM) PROXNUM"
            _cquery+=" FROM "
            _cquery+=  retsqlname("SE2")+" SE2"
            _cquery+=" where SE2.D_E_L_E_T_ = ' ' "
            _cquery+=" AND SE2.E2_FILIAL = '"+XFILIAL("SE2")+"'"
            _cquery+=" AND SE2.E2_PREFIXO = 'CAR'"
            _cquery:=changequery(_cquery)			
            tcquery _cquery new alias "TMP2"

            tmp2->(DbGoTop())
            While tmp2->(!Eof())
                _numatu    := SOMA1(tmp2->PROXNUM)
                _existadt := 2        
                tmp2->(DbSkip())       
            end     
            If _existadt = 1 
                _numatu := "000000001"  
            EndIf      
            Tmp2->(DbCloseArea()) 


 


        //procuro os dados de fornecedor do motorista
            _cquery:=" SELECT * "
            //_cquery+=" sum(EU_VALOR) VALOR"
            _cquery+=" FROM "
            _cquery+=  retsqlname("DA4")+" DA4"
            _cquery+=" where DA4.D_E_L_E_T_ = ' ' "
            _cquery+=" AND DA4.DA4_COD = '"+wMotori+"'" 
            _cquery:=changequery(_cquery)			
            tcquery _cquery new alias "TMP2"
            

            While tmp2->(!Eof())
                _codformot  :=   TMP2->DA4_FORNEC
                _ljformot   :=   TMP2->DA4_LOJA
                _nomfor     :=   TMP2->DA4_NOME
                _existfor   := 2
                tmp2->(DbSkip())       
            end
            Tmp2->(DbCloseArea()) 
            If _existfor = 1 .and. Len(alltrim(_codformot)) = 0
                lRet    := .F.
                msgalert("O motorista nao esta cadastrado como fornecedor, o adiantamento nao sera incluido!!")
                Return lRet    
            EndIf

      //Busco se existe algum titulo em aberto para o motorista
            _cquery:=" SELECT * FROM "
            _cquery+=  retsqlname("SE2")+" SE2"
            _cquery+=" where SE2.D_E_L_E_T_ = ' ' "
            _cquery+=" AND SE2.E2_FILIAL = '"+XFILIAL("SE2")+"'"
            _cquery+=" AND SE2.E2_PREFIXO = 'CAR'"
            _cquery+=" AND SE2.E2_FORNECE = '"+_codformot+"'"
            _cquery+=" AND SE2.E2_SALDO > '0'"            
            _cquery:=changequery(_cquery)			
            tcquery _cquery new alias "TMP2"

            tmp2->(DbGoTop())
            While tmp2->(!Eof())
                If  MsgYesNo("Este motorista possui titulo em aberto - "+tmp2->E2_NUM+" deseja incluir mais um?","Confirmação")
                    else
                     return()
                EndIf                    
                tmp2->(DbSkip())       
            end     
    
            Tmp2->(DbCloseArea()) 


        //ao clicar em salvar o adiantamento

            _titadt := {{"E2_FILIAL"   , xFilial("SE2")    , NIL },;
            { "E2_PREFIXO"  , "CAR"             , NIL },;
            { "E2_NUM"      , _numatu, NIL },;
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
            { "E2_VLCRUZ"   , wVvlradt   , NIL },;
            { "E2_SALDO"    , wVvlradt    , NIL },;
            { "E2_VALOR"    , wVvlradt    , NIL },;
            { "E2_XVIAGEM"  , wViagem    , NIL },;
            { "E2_XCODVEIC" , _codveic    , NIL },;            
            { "E2_HIST"     , "Titulo Caixinha TMS", NIL } } 
            
            
            MsExecAuto( { |x,y,z| FINA050(x,y,z)}, _titadt,, 3)  // 3 - Inclusao, 4 - AlteraÃ§ao, 5 - Exclusao
            
            If lMsErroAuto
                MostraErro()
            EndIf 
  oDlg9:End()
  msgalert("Titulo incluido com sucesso!!")     
/*

// busco adiantamento 
     _cquery:=" SELECT"
     _cquery+=" DG_DOC ULTADT, DG_TOTAL TOTALADT "
     _cquery+=" FROM "
     _cquery+=  retsqlname("SDG")+" SDG"
     _cquery+=" where SDG.D_E_L_E_T_ = ' ' "
     _cquery+=" AND DG_VIAGEM = '"+_viagem+"'"
     _cquery+=" AND DG_ORIGEM = 'SDG'"
     _cquery+=" AND DG_STATUS = '1'"          
     _cquery+=" AND DG_CODDES = '000000000000003'"
     _cquery+=" AND DG_FILIAL = '"+XFILIAL("SDG")+"'"
     _cquery:=changequery(_cquery)			
     tcquery _cquery new alias "TMP2"

     tmp2->(DbGoTop())
    While tmp2->(!Eof())
        ' 
                aadd(_adto,tmp2->ULTADT)
                aadd(_totaladt,tmp2->TOTALADT)
                _uladto       := tmp2->ULTADT
                _ultotaladt   := tmp2->TOTALADT + _ultotaladt
                _existadt     := 2
                
        
                _existdes := 2
                
        tmp2->(DbSkip())       
    end
    If _existadt = 1 .and. _existdes = 1
        _uladto := "000000001"  
    EndIf 
    If _existadt = 1 .and. _existdes = 2
        lRet    := .F.
        
        Return lRet 
    EndIf 
  
    _difadt := nTotAdto - _ultotaladt
    msgalert(aCols[3])
    msgalert(GdFieldGet(DG_TOTAL))
 msgalert(nTotAdto)
 msgalert(_ultotaladt)

    IF _difadt = 0
    nTotAdto
    EndIf
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
        _existmot    := 2
        tmp2->(DbSkip())       
    end

    Tmp2->(DbCloseArea()) 
    If _existmot = 1
        lRet    := .F.
        msgalert("Nao existe motorista cadastrado para esta viagem, o adiantamento nao sera incluido!!")
        Return lRet    
    EndIf



 //procuro os dados de fornecedor do motorista
     _cquery:=" SELECT * "
     //_cquery+=" sum(EU_VALOR) VALOR"
     _cquery+=" FROM "
     _cquery+=  retsqlname("DA4")+" DA4"
     _cquery+=" where DA4.D_E_L_E_T_ = ' ' "
     _cquery+=" AND DA4.DA4_COD = '"+_codmot+"'" 
     _cquery:=changequery(_cquery)			
     tcquery _cquery new alias "TMP2"
 	

    While tmp2->(!Eof())
        _codformot  :=   TMP2->DA4_FORNEC
        _ljformot   :=   TMP2->DA4_LOJA
        _nomfor     :=   TMP2->DA4_NOME
        _existfor   := 2
        tmp2->(DbSkip())       
    end
     Tmp2->(DbCloseArea()) 
    If _existfor = 1
        lRet    := .F.
        msgalert("O motorista nao esta cadastrado como fornecedor, o adiantamento nao sera incluido!!")
        Return lRet    
    EndIf



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

 //verifico se é estorno
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
     _cquery+=" AND DG_CODDES = '000000000000003'"
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

//somo o que já foi adiantado e faço a diferença

    _cquery:=" SELECT"
     _cquery+=" sum(EU_VALOR) VALOR"
     _cquery+=" FROM "
     _cquery+=  retsqlname("SEU")+" SEU"
     _cquery+=" where SEU.D_E_L_E_T_ = ' ' "
     _cquery+=" AND SEU.EU_VIAGEM = '"+_viagem+"'" 
     _cquery+=" AND SEU.EU_CODDES = '000000000000003'"      
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
	Replace EU_TIPO    	With "10"
	Replace EU_FILORI   With xFilial("SEU")
	Replace EU_SLDADIA 	With _difadt
	Replace EU_EMISSAO 	With dDataBase
    Replace EU_SEQCXA  	With SET->ET_SEQCXA
	Replace EU_NRREND   With SET->ET_NRREND
	Replace EU_VALOR   	With _difadt
	Replace EU_HISTOR	With _uladto
 	Replace EU_VIAGEM	With _viagem
	Replace EU_CODDES	With "000000000000003"
	Replace EU_CODMOT	With _codmot
    Replace EU_MOEDA    With 1           
    Replace EU_STATUS   With "01"
    Replace EU_CAIXA    With _cCaixa


    

   */
Return
