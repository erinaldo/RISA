#INCLUDE "colors.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/

{Protheus.doc} CFGXFAT
                 
Funções genéricas

@author  Milton J.dos Santos	
@since   15/07/20
@version 1.0

/*/

// ValidReg - Validações das Consultas especifica
// Valida Registros na tabela SC5 e SC6 ( CAMPOS: C5_VEND1,C5_TABELA, C5_CONDPAG, C5_XOPER, C6_PRODUTO) 

User Function ValidReg()
Local bRetorno  := { || .T. }
Local aArea 	:= GetArea()
Local cCampo	:= ReadVar()
Local lRet      := .T.

If IsInCallStack('MATA410')
//  Para evitar imcompatilidade com outros modulos
    If l410Auto     // Ignora as regras se for um EXECAUTO
        Return( Eval( bRetorno ) )
    Endif
    If Empty( M->C5_XOPER )
        MsgStop("Obrigatorio o preenchimento do campo Tipo de Operacao!","Campo Obrigatorio")
        lRet := .F.
    Else
        If cCampo == 'M->C5_XOPER'
            If U_CampObr( cCampo )
                lRet := Iif(GetMV('FS_REGRATB',,.F.),ValOper(), .T. )
            Else
                lRet := .F.
            Endif
        Endif
    Endif
    If ! lRet
        bRetorno  := { || .F. }
        Return( Eval( bRetorno ) )
    Endif
    If GetMV('FS_REGRATB',,.F.) 
        If Alltrim(M->C5_XOPER) $ GetMV('FS_OPERVEN',,"01/02/04")
            Do Case 
                Case cCampo == 'M->C5_VEND1'
                    If U_CampObr( cCampo )
                        bRetorno 	:= { || Iif(GetMV('FS_REGRATB',,.F.),ValVend(),.T.) }
                    Endif
                Case cCampo == 'M->C5_TABELA'
                    If U_CampObr( cCampo )
                        bRetorno 	:= { || Iif(GetMV('FS_REGRATB',,.F.),ValTabP(),.T.) }
                    Endif
                Case cCampo == 'M->C5_CONDPAG'
                    If U_CampObr( cCampo )
                        bRetorno 	:= { || Iif(GetMV('FS_REGRATB',,.F.),ValCond(),.T.) }
                    Endif
                Case cCampo == 'M->C6_PRODUTO'
                    If U_CampObr( cCampo )
                       bRetorno 	:= { || Iif(GetMV('FS_REGRATB',,.F.),ValProd(),.T.) }
                    Endif
            EndCase
         Else
            bRetorno  := { || .T. }
        Endif
    Else
        bRetorno  := { || .T. }
    Endif
Endif

RestArea(aArea)

Return( Eval( bRetorno ) )

// ValOper - Valida operacoes do pedido de venda

Static Function ValOper()
Local lRet := .T.


lRet := ExistCPO("SX5","DJ" + M->C5_XOPER)

Return( lRet )

Static Function ValOperV()
Local lRet := .T.

If Type("l410Auto") == "U" .OR. l410Auto     // Ignora se não identificar a origem do cadastro ou se for um EXECAUTO
    Return(lRet)   
Endif

If ! U_USAREGRA()
    Return(lRet)   
Endif

If Empty(M->C5_XOPER)
    MsgStop("Campo de Operacao e Obrigatorio !")
ELSE
    If M->C5_XOPER $ GetMV('FS_OPERVEN',,"01/02/04")
        If EMPTY(M->C5_VEND1)
            MsgStop("Campo vendedor e Obrigatorio para operacao de venda !")
        Endif
        If EMPTY(M->C5_CONDPAG)
            MsgStop("Campo condicao de pagamento e Obrigatorio para operacao de venda !")
        Endif
    Else
        lRet := ExistCPO("SX5","DJ" + M->C5_XOPER)
    Endif
Endif

Return( lRet )

// ValVend - Regras de vendedor

Static Function ValVend()
Local lRet  := .T.
Local lSZA  := .F.
Local lSZB  := .F.
Local lSZC  := .F.
Local lSZE  := .F.

DbSelectArea("SZA")
DbSetOrder(1)
IF DbSeek( xFilial("SZA") + M->C5_VEND1 )
	lSZA    := .T.
EndIf
SZA->( DbCloseArea() )
DbSelectArea("SZB")
DbSetOrder(1)
IF DbSeek( xFilial("SZB") + M->C5_VEND1 )
	lSZB    := .T.
EndIf
SZB->( DbCloseArea() )
DbSelectArea("SZC")
DbSetOrder(1)
IF DbSeek( xFilial("SZC") + M->C5_VEND1 )
    lSZC    := .T.
EndIf
SZC->( DbCloseArea() )
DbSelectArea("SZE")
DbSetOrder(1)
IF DbSeek( xFilial("SZE") + M->C5_VEND1 + M->C5_XOPER )
	lSZE    := .T.
Else
    MsgStop("Vendedor nao autorizado para esta Operação.")
EndIf
SZE->( DbCloseArea() )

If !lSZA .OR. !lSZB .OR. !lSZC .OR. !lSZE
    lRet := .F.
    MsgStop("Vendedor nao possui Regras Cadastradas ou divergentes, falar com responsavel !")
EndIf

Return lRet

// ValTabP - Regras de Tabelas de Preco
// Filtra as tabelas do vendedor

Static Function ValTabP()
Local cQuery   := ""
Local cTabVend := GetNextAlias()
Local lRet     := .T.

If !Empty(M->C5_VEND1) .AND. !Empty(M->C5_CLIENTE) 

    cQuery := "SELECT * " 
    cQuery += " FROM "
    cQuery += "	    " + RetSQLName("SZA") + " SZA "
    cQuery += " WHERE SZA.D_E_L_E_T_ <> '*'"
    cQuery += "     AND SZA.ZA_FILIAL = '" + xFilial( "SZA" ) + "'" 
    cQuery += "     AND SZA.ZA_VEND = '" + M->C5_VEND1 + "' "
//    cQuery += "	    AND SZA.ZA_CODMUN+SZA.ZA_UF IN (SELECT SA1.A1_COD_MUN+SA1.A1_EST FROM " + RetSQLName("SA1") + " SA1 WHERE SA1.D_E_L_E_T_ <> '*' AND SA1.A1_COD + SA1.A1_LOJA = '" + M->C5_CLIENTE+M->C5_LOJACLI + "')"
    cQuery += "	    AND SZA.ZA_UF IN (SELECT SA1.A1_EST FROM " + RetSQLName("SA1") + " SA1 WHERE SA1.D_E_L_E_T_ <> '*' AND SA1.A1_COD + SA1.A1_LOJA = '" + M->C5_CLIENTE+M->C5_LOJACLI + "')"
    cQuery += "     AND SZA.ZA_TABELA = '" + M->C5_TABELA + "' "

    Memowrite('ValTabP.SQL',cQuery)

    ChangeQuery(cQuery)
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabVend,.F.,.T.)
    dbSelectArea(cTabVend)
    (cTabVend)->(dbGoTop())
    If (cTabVend)->( Eof() )
        lRet := .F.
    Endif
    (cTabVend )->( DbCloseArea() )
EndIf

If !lRet
    MsgStop("Tabela nao autorizada para este vendedor na regiao do cliente!","Bloqueio da tabela")
Endif

Return (lRet)

// ValCond - Regras de Condicao de Pagamento
// Filtra as condicoes de pagamento do vendedor do vendedor

Static Function ValCond()
Local lRet     := .F.
Local cQuery   := ""
Local cTabCond := GetNextAlias()

lRet := ValOperV()        // Valida Operacao de venda

If !EMPTY(M->C5_VEND1) .and. !EMPTY(M->C5_CONDPAG)

    cQuery := "SELECT * " 
    cQuery += " FROM "
    cQuery += "	    " + RetSQLName("SZB") + " SZB "
    cQuery += " WHERE SZB.D_E_L_E_T_ <> '*'"
    cQuery += "     AND SZB.ZB_FILIAL = '" + xFilial( "SZB" ) + "'" 
    cQuery += "     AND SZB.ZB_VEND = '" + M->C5_VEND1 + "' "
    cQuery += "     AND SZB.ZB_COND = '" + M->C5_CONDPAG + "' "

    Memowrite('ValidCond.SQL',cQuery)

	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabCond,.F.,.T.)
	dbSelectArea(cTabCond)
	(cTabCond)->(dbGoTop())
    If ! (cTabCond)->( Eof() )
        lRet := .T.
    EndIf
    (cTabCond )->( DbCloseArea() )
EndIf

If !lRet
    MsgStop("Condicao nao autorizada para este vendedor!")
Endif

Return (lRet)

// ValProd - Regras de Produtos
// Filtra os produtos do vendedor

Static Function ValProd()
Local aArea    := GetArea()
Local cQuery   := ""
Local cTabProd := GetNextAlias()
Local lRet     := .F.

lRet := ValOperV()

If !EMPTY(M->C5_VEND1) .AND. !EMPTY(M->C5_TABELA) .AND. !EMPTY(M->C6_PRODUTO) 

    cQuery := "SELECT DA1.DA1_CODPRO "
    cQuery += " FROM " + RetSQLName("DA1") + " DA1 "
    cQuery += "       INNER JOIN " + RetSQLName("SB1") + " SB1 ON SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = DA1.DA1_CODPRO "
    cQuery += "       INNER JOIN " + RetSQLName("SZC") + " SZC ON SZC.D_E_L_E_T_ <> '*' "
    cQuery += "       AND SB1.B1_GRUPO >= SZC.ZC_GRPROD AND SB1.B1_GRUPO <= SZC.ZC_GRPRODA "
    cQuery += "       AND SZC.ZC_VEND = '" + M->C5_VEND1 + "' "
    cQuery += " WHERE DA1.D_E_L_E_T_ <> '*' AND DA1.DA1_CODTAB = '" + M->C5_TABELA + "' AND DA1.DA1_CODPRO = '" + M->C6_PRODUTO + "' "

	Memowrite('ValProd.SQL',cQuery)

	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabProd,.F.,.T.)
	dbSelectArea(cTabProd)
    (cTabProd)->(dbGoTop())
    If (cTabProd)->( Eof() )
        lRet := .F.
    EndIf
    (cTabProd )->( DbCloseArea() )
EndIf

If !lRet
    MsgStop("Produto nao autorizado ou nao existe na tabela deste vendedor!")
Endif
RestArea(aArea)

Return (lRet)

// GatPromo - Regras de Produtos Promocionais
// Valida utilização dos produtos promocionais cadastrados

User Function GatPromo()
Local aArea    := GetArea()
//Local cRet     := "1"       // M->C6_XOFERTA 
Local lTemProm := .F.
Local nPreco   := M->C6_PRCVEN
Local nPosPreco:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_PRCVEN'})
Local nPosDescP:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_DESCONT'})
Local nPosDescV:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_VALDESC'})
Local nPosOfert:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_XOFERTA'})
Local cRet     := IIF(alltrim(aCols[n,nPosOfert])=="","1",aCols[n,nPosOfert])

//Local nPosComis:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_COMIS1'})

If ! GetMV('FS_REGRATB',,.F.) .OR. l410Auto 
    Return( cRet )
ENDIF

If !EMPTY(M->C6_PRODUTO)
   DbSelectArea("SZD")
    DbSetOrder(1)
    If DbSeek( xFilial("SZD") + M->C5_TABELA + SA1->A1_EST + M->C6_PRODUTO )
        IF SZD->ZD_DTVLD <= DATE()
            lTemProm := .T.
        EndIf
    EndIf
EndIf
If lTemProm
    nPreco:=SZD->ZD_VLRPROM
    If MsgYesNo("Deseja utilizar o preço promocional de R$" + TRANSFORM(nPreco,"@E 999,999.99") + " ?","PREÇO PROMOCIONAL")
        cRet := "2" 
        aCols[n,nPosPreco] := nPreco
        aCols[n,nPosDescP] := 0
        aCols[n,nPosDescV] := 0
        //aCols[n,nPosComis] := 0
    Endif
Endif

RestArea(aArea)

Return (cRet)

// ValDesC - Verifica limite de desconto e preço mínimo
// Valida o limite de desconto dos itens do pedido (C6_DESCONT ou C6_VALDESC)

User Function ValDesc(cValPer)
Local aArea     := GetArea()
Local lRet      := .F.
Local nPosPrd   := aScan( aHeader, {|x| x[2] == 'C6_PRODUTO'})
Local nPosDescP := aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_DESCONT'})
Local nPosPrcV  := aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_PRCVEN'})
Local cGRPPRD   := ''
Local cProduto  := acols[n,nPosPrd] 
Local nDesc     := Iif(cValPer == "P", M->C6_DESCONT, aCols[n,nPosDescP])
Local nPrcVen   := aCols[n,nPosPrcV]
//Local nCustoMrk := 0

If ! GetMV('FS_REGRATB',,.F.) .OR. l410Auto 
    Return( .T. )
ENDIF

lRet := ValOperV()

If lRet 
    If nDesc > 0
        If EMPTY( cProduto )
            MsgStop("FALTA CODIGO DO PRODUTO")
        Else
            DbSelectARea("SB1")
            SB1->( dbSetOrder(1) )
            If DbSEEK( xFilial("SB1") + cProduto ) 
                cGRPPRD := SB1->B1_GRUPO
                DbSelectARea("SZC")
                DbSetOrder(1)
                // validação de margem de desconto
                //IF DBSEEK( xFilial("SZC") + M->C5_VEND1 + cGRPPRD )
                IF DBSEEK( xFilial("SZC") + M->C5_VEND1 )
                    While !Eof() .and. M->C5_VEND1 == SZC->ZC_VEND

                        If cGRPPRD >= SZC->ZC_GRPROD .and. cGRPPRD <= SZC->ZC_GRPRODA
                            IF nDesc > SZC->ZC_DESMAX
                                MsgStop("Desconto acima do limite do vendedor ( " + Transform(SZC->ZC_DESMAX,"99%") + " ) !")
                                // Validação de Preço Mínimo.
                                lRet := U_ValPrcMin(nPrcVen) //nPrcVen já esta com o desconto aplicado. //,nDesc)
                            ELSEIF nDesc < SZC->ZC_DESMIN
                                MsgStop("Desconto abaixo do limite do vendedor ( " + Transform(SZC->ZC_DESMIN,"99%") + " ) !")
                            ELSE
                                lRet := .T.
                            ENDIF
                        Endif

                        DbSelectArea("SZC")
                        DbSkip()
                    Enddo
                Else
                    MsgStop("Vendedor nao autorizado para esse grupo de produtos")
                ENDIF
            ENDIF
        ENDIF
    EndIf
Endif
RestArea(aArea)
Return( lRet )

//Função para validação do preço minimo

User Function ValPrcMin( _nPrcVen ) //, _nDesc)
Local aArea     := GetArea()
Local lRet      := .F.
Local nPrcVen   := _nPrcVen //_nPrcVen - (_nPrcVen * _nDesc / 100 )
Local nCustoMrk := SB1->B1_CUSTD    // Preço Stand conforme orientacao do Silas

DbSelectARea("SB2")
DbSetOrder(1)
If DbSEEK( xFilial("SB2") + SB1->B1_COD ) 
    nCustoMrk := SB2->B2_CM1
    DbSelectARea("SBZ")
    DbSetOrder(1)
    If DbSEEK( xFilial("SBZ") + SB1->B1_COD )
        nCustoMrk := (SB2->B2_CM1 + ((SB2->B2_CM1*SBZ->BZ_MARKUP)/100))
    Else
        MsgStop("Sem percentual de MarkUp, sera utilizado custo STANDARD pra calcular o preco minimo de venda  !")
    EndIf
Else
    MsgStop("Nao foi possivel identificar o preco minimo de venda pela tabela SB2, sera utilizado a SB1 !")
EndIf

RestArea(aArea)
//   15,00  <  14,50
If nPrcVen < nCustoMrk
    MsgStop("O valor minimo de venda deve ser maior ou igual ao valor de custo + índice markup, sendo R$" + TRANSFORM(nCustoMrk,"@E 999,999.99") + " !")
ELSE
   lRet := .T.
Endif

Return( lRet )

// Libera edição dos campos C6_PRCVEN, C6_VALOR, C6_DESCONT, C6_VALDESC, C6_COMIS1 se C6_XOFERTA for igual a 1 ou 3
//1=Normal;2=Promocional;3=Acima do desconto  
User Function Oferta(cCampo)
Local lRet := .T.
Local nPosXofer:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_XOFERTA'})
Local nPosOper := aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_OPER'})

lRet := ( aCols[n][nPosXofer] == '1' .or. aCols[n][nPosXofer] == '3')

If ALLTRIM(cCampo) == "C6_PRCVEN"

    //se a operação não estiver contida no parametro o campo fica aberto para digitação
    If acols[n][nPosOper] $ GetMv("FS_OPERVEN")
        lRet := .F.
    Endif

Endif

Return( lRet)

// GatDesC - Gatilha os campos C6_XOFERTA e C6_XBLQ
// De acordo com o limite de desconto dos itens do pedido (C6_DESCONT ou C6_VALDESC)

User Function GatDesc()
Local nPosPrd  := aScan( aHeader, {|x| x[2] == 'C6_PRODUTO'})
Local nPosXofer:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_XOFERTA'})
Local nPosDescP:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_DESCONT'})
Local nPosXblq := aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_XBLQ'})
Local nPosComis:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_COMIS1'})
Local cGRPPRD  := ''
Local cProduto := acols[n,nPosPrd] 
Local cRet     := aCols[n,nPosXofer]
Local nDesc    := aCols[n,nPosDescP]
Local nComis   := aCols[n,nPosComis]

If ! GetMV('FS_REGRATB',,.F.) .OR. l410Auto 
    Return( cRet )
ENDIF

lRet := ValOperV()

If lRet 
    If nDesc > 0
        If EMPTY( cProduto )
            MsgStop("FALTA CODIGO DO PRODUTO")
        Else
            DbSelectARea("SB1")
            SB1->( dbSetOrder(1) )
            If DbSEEK( xFilial("SB1") + cProduto ) 
                cGRPPRD := SB1->B1_GRUPO
                DbSelectARea("SZC")
                DbSetOrder(1)
                //If DBSEEK( xFilial("SZC") + M->C5_VEND1 + cGRPPRD )
                If DBSEEK( xFilial("SZC") + M->C5_VEND1 )
                    While !Eof() .and. M->C5_VEND1 == SZC->ZC_VEND
                        If cGRPPRD >= SZC->ZC_GRPROD .and. CGRPPRD <= SZC->ZC_GRPRODA
                            If nDesc > SZC->ZC_DESMAX // .or. nDesc < SZC->ZC_DESMIN
                                aCols[n,nPosXofer] := '3' // Oferta passa a ser fora alçada de desconto.
                                aCols[n,nPosXblq ] := '1' // Bloqueio o pedido.
                                aCols[n,nPosComis] := SZC->ZC_COMIS
                                cRet := '3'
                            Endif
                        Endif
                        
                        DbSelectArea("SZC")
                        DbSkip()
                    Enddo
                ENDIF
            ENDIF
        ENDIF
    Else
        // Caso os campos C6_DESCONT ou C6_VALDESC estejam zerado volta o pedido para normal e desbloqueia o mesmo
        aCols[n,nPosXofer] := '1' // Volto a oferta para normal.
        aCols[n,nPosXblq ] := '2' // Desbloqueio o pedido.
        aCols[n,nPosComis] := nComis
        cRet := '1'
    EndIf
Endif
Return( cRet )

// ConsReg - Semaforo de Campos obrigatorios nas regras

User Function ConsReg()
Local bRetorno  := { || .F. }
Local aArea 	:= GetArea()
Local cCampo	:= ReadVar()
Local lRegra    := U_USAREGRA()

If lRegra
    IF Empty( M->C5_CLIENTE )
        MsgStop("Falta preencher o codigo do cliente","Campo obrigatorio")
        Return( Eval( bRetorno ) )
    ElseIf Empty( M->C5_XOPER )
        MsgStop("Falta preencher o campo de Tp.operacao","Campo obrigatorio")
        Return( Eval( bRetorno ) )
    ElseIf Empty( M->C6_TABELA )
        If Alltrim(M->C5_XOPER) $ GetMV('FS_OPERVEN',,"01/02/04")
            If Empty( M->C5_VEND1 )
                MsgStop("Falta preencher o campo de Vendedor. Verifique o tipo de operação!","Campo obrigatorio")
                Return( Eval( bRetorno ) )
            EndIf
        Endif
    ElseIf Empty( M->C6_PRODUTO )
        If Empty( M->C5_VEND1 )
            MsgStop("Falta preencher o campo de Vendedor","Campo obrigatorio")
            Return( Eval( bRetorno ) )
        ElseIf Empty( M->C5_TABELA )
            MsgStop("Falta preencher o tabela de preco","Campo obrigatorio")
            Return( Eval( bRetorno ) )
        Endif
    Endif
Endif

Do Case 
    Case cCampo == 'M->C5_TABELA'
        bRetorno 	:= { || Conpad1(,,,'DA0',,,.F.) }
    Case cCampo == 'M->C5_CONDPAG'
        bRetorno 	:= { || Conpad1(,,,'SE4',,,.F.) }
    Case cCampo == 'M->C6_PRODUTO'
        bRetorno 	:= { || Conpad1(,,,'SB1',,,.F.) }
EndCase

If IsInCallStack('MATA410')
    If lRegra .and. AllTrim( M->C5_XOPER ) $ GetMV('FS_OPERVEN',,"01/02/04")
        Do Case 
            Case cCampo == 'M->C5_TABELA'
                bRetorno 	:= { || Iif(GetMV('FS_REGRATB',,.F.),Conpad1(,,,'DA0X',,,.F.),Conpad1(,,,'DA0',,,.F.)) }
            Case cCampo == 'M->C5_CONDPAG'
                bRetorno 	:= { || Iif(GetMV('FS_REGRATB',,.F.),Conpad1(,,,'SE4X',,,.F.),Conpad1(,,,'SE4',,,.F.)) }
            Case cCampo == 'M->C6_PRODUTO'
                bRetorno 	:= { || Iif(GetMV('FS_REGRATB',,.F.),Conpad1(,,,'SB1X',,,.F.),Conpad1(,,,'SB1',,,.F.)) }
        EndCase
    Endif
Endif

RestArea(aArea)

Return( Eval( bRetorno ) )

User Function FiltraDA0()
Local cQuery
Local cSQL := "@DA0_CODTAB IN ('')" 
Local cTab := GetNextAlias()

If !Empty(M->C5_CLIENTE) .AND. !Empty(M->C5_VEND1)
    cQuery := "SELECT DA0.DA0_CODTAB" 
    cQuery += " FROM  " + RetSQLName("SZA") + " SZA "
    cQuery += "	    INNER JOIN " + RetSQLName("DA0") + " DA0 ON DA0.DA0_CODTAB = SZA.ZA_TABELA AND DA0.D_E_L_E_T_ <> '*'"
    cQuery += " WHERE   SZA.D_E_L_E_T_ <> '*'"
    cQuery += "     AND SZA.ZA_FILIAL = '" + xFilial( "SZA" ) + "'" 
    cQuery += "     AND SZA.ZA_VEND = '" + M->C5_VEND1 + "' "
//    cQuery += "	    AND SZA.ZA_CODMUN+SZA.ZA_UF IN (SELECT SA1.A1_COD_MUN+SA1.A1_EST FROM " + RetSQLName("SA1") + " SA1 WHERE SA1.D_E_L_E_T_ <> '*' AND SA1.A1_COD + SA1.A1_LOJA = '" + M->C5_CLIENTE+M->C5_LOJACLI + "')"
    cQuery += "	    AND SZA.ZA_UF IN (SELECT SA1.A1_EST FROM " + RetSQLName("SA1") + " SA1 WHERE SA1.D_E_L_E_T_ <> '*' AND SA1.A1_COD + SA1.A1_LOJA = '" + M->C5_CLIENTE+M->C5_LOJACLI + "')"

    Memowrite('FiltraDA0.SQL',cQuery)
    ChangeQuery(cQuery)
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.F.,.T.)
    dbSelectArea(cTab)
    (cTab)->(dbGoTop())
    If ! (cTab)->( Eof() )
        cSQL := "@DA0_CODTAB IN (" 
        While !(cTab)->( Eof() )
            cSQL += "'" + AllTrim((cTab)->DA0_CODTAB) + "',"
            (cTab)->( DbSkip() )
        EndDo
        cSQL := Substr(cSQL,1,len(cSQL)-1) + ")"
    Endif
    (cTab )->( DbCloseArea() )
EndIf

Return cSQL

User Function FiltraSE4()
Local cQuery:= ""
Local cSQL  := "@E4_CODIGO IN ('')" 
Local cTab  := GetNextAlias()

If !Empty(M->C5_VEND1)

    cQuery := "SELECT SE4.E4_CODIGO " 
    cQuery += " FROM "
    cQuery += "	    " + RetSQLName("SZB") + " SZB "
    cQuery += "	    INNER JOIN " + RetSQLName("SE4") + " SE4 ON SE4.E4_CODIGO = SZB.ZB_COND AND SE4.D_E_L_E_T_ <> '*'"
    cQuery += " WHERE SZB.D_E_L_E_T_ <> '*'"
    cQuery += "     AND SZB.ZB_FILIAL = '" + xFilial( "SZB" ) + "'" 
    cQuery += "     AND SZB.ZB_VEND = '" + M->C5_VEND1 + "' "

    Memowrite('FiltraSE4.SQL',cQuery)
    ChangeQuery(cQuery)
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.F.,.T.)
    dbSelectArea(cTab)
    (cTab)->(dbGoTop())
    If !(cTab)->( Eof() )
        cSQL := "@E4_CODIGO IN (" 
        While !(cTab)->( Eof() )
            cSQL += "'" + AllTrim((cTab)->E4_CODIGO) + "',"
            (cTab)->( DbSkip() )
        EndDo
        (cTab )->( DbCloseArea() )
        cSQL := Substr(cSQL,1,len(cSQL)-1) + ")"
    Endif
EndIf

Return cSQL

User Function FiltraSB1()
Local cQuery
Local cSQL  := "@B1_COD IN ('')" 
Local cTab  := GetNextAlias()

If !Empty(M->C5_TABELA) .AND. !Empty(M->C5_VEND1)

    cQuery := "SELECT DA1.DA1_CODPRO "
    cQuery += " FROM " + RetSQLName("DA1") + " DA1 "
    cQuery += "       INNER JOIN " + RetSQLName("SB1") + " SB1 ON SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = DA1.DA1_CODPRO "
    cQuery += "       INNER JOIN " + RetSQLName("SZC") + " SZC ON SZC.D_E_L_E_T_ <> '*' "
    cQuery += "       AND SB1.B1_GRUPO >= SZC.ZC_GRPROD AND SB1.B1_GRUPO <= SZC.ZC_GRPRODA "
    cQuery += "       AND SZC.ZC_VEND = '" + M->C5_VEND1 + "' "
    cQuery += " WHERE DA1.D_E_L_E_T_ <> '*' AND DA1.DA1_CODTAB = '" + M->C5_TABELA + "' "
    cQuery += " AND DA1.DA1_FILIAL = '"+xFilial("DA1")+"' "

    Memowrite('VerTab.SQL',cQuery)
    ChangeQuery(cQuery)
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.F.,.T.)
    dbSelectArea(cTab)
    (cTab)->(dbGoTop())
    If !(cTab)->( Eof() )
        cSQL  := "@B1_COD IN ("
        While !(cTab)->( Eof() )
            cSQL += "'" + AllTrim((cTab)->DA1_CODPRO) + "',"
            (cTab)->( DbSkip() )
        EndDo
        (cTab )->( DbCloseArea() )
        cSQL := Substr(cSQL,1,len(cSQL)-1) + ")"
    Endif

/*
    dbSelectArea("DA1")
    DA1->(dbGoTop())
    DA1->(dbSetOrder(1))
    DbSeek(xFilial("DA1")+M->C5_TABELA)
    cSQL  := "@B1_COD IN ("
    While !DA1->( Eof() ) .and. DA1->DA1_CODTAB == M->C5_TABELA
        cSQL += "'" + AllTrim(DA1->DA1_CODPRO) + "',"
        DA1->( DbSkip() )
    EndDo
    cSQL := Substr(cSQL,1,len(cSQL)-1) + ")"
*/

Else
    cSQL := "" 
EndIf

Return cSQL

// CAMPO WHEN DA C5_CONDPG

User Function Feira() 
Local lRet := .T.
Local nPosPrd  := aScan( aHeader, {|x| x[2] == 'C6_PRODUTO'})
Local i

/*
IF DA0->( FieldPos("DA0_XFEIRA") ) > 0 
    IF ! Empty( M->C5_TABELA)
        IF ! Empty( POSICIONE("DA0",1, xFilial("DA0") + M->C5_TABELA,"DA0_CONDPG") )
            IF DA0->DA0_XFEIRA == "1"
                M->C5_CONDPAG := DA0->DA0_CONDPG
                lRet := .F.
            Endif
        Endif
    Endif
Endif
*/

//todas as condições de pagamento devem ser bloqueadas para alteração após a digitação da condição
//motivo: cálculo do acréscimo do preço
//obs.: não foi tratado o item deletado para evitar que o usuário delete a linha só para alterar 
//      a condição de pagamento e depois voltar o delete com o valor errado

If M->C5_TIPO == 'N' //executa essa trava somente para pedidos do tipo normal para compatibilização do GC - Gestão de cereais
    For i:= 1 to len(acols) 
        If !Empty(acols[1,nPosPrd]) //verifica se já foi digitado algum item 
            lRet := .F.
        Endif
    Next
Endif

Return lRet

// VALIDAÇÃO PARA USO NO CAMPO DA0_COND

User Function TabFeira( _cCond ) 
Local lRet := .T.

IF DA0->( FieldPos("DA0_XFEIRA") )> 0 
    IF M->DA0_XFEIRA == "1" .AND. EMPTY( _cCond )
        lRet := .F.
        MsgStop("Condicao de pagamento obrigatorio para tabela de feira !")
    Endif
Endif

Return lRet

// VALIDAÇÃO PARA USO NO CAMPO C5_CONDPAG

User Function PedFeira() 
Local lRet := .T.

IF ! EMPTY( M->C5_TABELA ) 
    IF DA0->( FieldPos("DA0_XFEIRA") ) > 0 
        IF DA0->DA0_XFEIRA == "1" 
            If  EMPTY( M->C5_TABELA )
                lRet := .F.
                MsgStop("Condicao de pagamento obrigatorio para tabela de feira !")
            Else
                M->C5_TABELA := DA0->DA0_CONDPG
            Endif
        Endif
    Endif
ENDIF

Return lRet

User Function GatComis()
Local nRet     := 0
Local cGRPPRD  := ''

If ! GetMV('FS_REGRATB',,.F.)
    Return( nRet )
ENDIF

If ! AllTrim( M->C5_XOPER ) $ GetMV('FS_OPERVEN',,"01/02/04")
    Return( nRet )
Endif

IF EMPTY( M->C5_VEND1 )
    MsgStop("FALTA CODIGO DO VENDEDOR")
Elseif EMPTY( M->C6_PRODUTO )
    MsgStop("FALTA CODIGO DO PRODUTO")
Else
    DBSELECTAREA('SB1')
    SB1->( dbSetOrder(1) )
    If DbSEEK( xFilial("SB1") + M->C6_PRODUTO ) 
        cGRPPRD := SB1->B1_GRUPO
        DBSELECTAREA('SZC')
        SZC->( dbSetOrder(1) )
        //If SZC->( DbSEEK( xFilial("SZC") + M->C5_VEND1 + cGRPPRD )) // ESTAVA BUSCANDO FILIAL SB1 MAS O MODO DE COMP É # DA SZC
        If SZC->( DbSEEK( xFilial("SZC") + M->C5_VEND1 )) // ESTAVA BUSCANDO FILIAL SB1 MAS O MODO DE COMP É # DA SZC
            While !Eof() .and. M->C5_VEND1 == SZC->ZC_VEND
                If cGRPPRD >= SZC->ZC_GRPROD .and. cGRPPRD <= SZC->ZC_GRPRODA
                    nRet := SZC->ZC_COMIS
                Endif
                DbSelectArea("SZC")
                DbSkip()
            Enddo
        Else
            MsgStop("Nao achou a regra!")
        ENDIF
    ELSE
        MsgStop("Nao achou o produto!")
    Endif
Endif

Return( nRet )

User Function SC6Oper
Local lRet := .T.

//retirado por Alex Rodrigues - 04/11/2020
//se o campo estiver bloqueado não consegue dar enter para trazer a TES, farei o bloqueio via gatilho 
//   para não deixar colocar o tipo de operação diferente que está no cabeçalho
//lRet := ! GetMV('FS_REGRATB',,.F.)

Return( lRet )

User Function BlocPed()
Local aArea     := GetArea()
Local nLinha    := 0
Local nPosXBLQ  := aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_XBLQ'  })
Local nPosTOT   := aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_VALOR' })
Local cBloq     := ""
Local lEmailOK  := .F.
Local nTotal    := 0

//Somente bloqueia pedidos de vendas que são operação de venda
If !M->C5_XOPER $ GetMV('FS_OPERVEN',,"01/02/04")
    Return
Endif

If Type("l410Auto") == "U" .OR. l410Auto     //  Ignora se não identificar a origem do cadastro ou se for um EXECAUTO
    Return    
Endif

For nLinha := 1 TO Len(aCols) //Varre os itens do Pedido para saber se deve bloquear por Regra de Desconto (gatilho preenche o campo C6_XBLQ)
    nTotal += aCols[nLinha,nPosTOT]
    If aCols[nLinha,nPosXBLQ] == "1"
        cBloq   := "X"
    EndIf
Next

If Empty( cBloq ) //cBloq verifica a Regra de Preços e Descontos - quando vazio passa para Bloqueio em Garantia
    If M->C5_TIPO == "N"
        If nTotal > GetMV('FS_VLRGAR',,0)
            cBloq     := "Y"
        Endif
    Endif
Endif

dbSelectArea("SC5")
RecLock("SC5",.F.)

If cBloq == "X"
    MsgAlert("Bloqueio Comercial !","Bloqueio de Pedido")
    If M->C5_XAPROVA == "N"
        lEmailOK := U_WFBlqVen()
    Else
        If MsgYesNo("E-mail Já enviado anteriormente, deseja enviar novamente?","Envio de Email de Aprovação")
            lEmailOK := U_WFBlqVen()
        Endif
    EndIf
EndIf
If lEmailOK
    SC5->C5_XAPROVA := "S"
    MsgInfo("E-mail de Solicitação de Aprovação Enviado Com Sucesso!")
EndIf

SC5->C5_BLQ := cBloq

//Limpa variáveis de aprovações anteriores visto que pode ser uma alteração de pedido e vai gerar novo bloqueio
SC5->C5_XDTAVAL := CTOD("")
SC5->C5_XAVAL   := ""
SC5->C5_XDTAVG  := CTOD("")
SC5->C5_XAVALG  := ""

MsUnlock()

RestArea(aArea)

Return

User Function CampObr( _cCampo )
Local lRet   := .T.
Local aLista := {}
Local aCampos:= {}
Local i      := 0

aAdd( aLista, { "1","C5_XOPER"    ,"Tipo de Operacao"}  )
aAdd( aLista, { "2","C5_CLIENTE"  ,"Cliente"         }  )
aAdd( aLista, { "3","C5_VEND1"    ,"Vendedor"        }  )
aAdd( aLista, { "4","C5_TABELA"   ,"Tabela de Preco" }  )
aAdd( aLista, { "5","C6_PRODUTO"  ,"Produto"         }  )

Do Case 
    Case _cCampo == "M->C5_XOPER"
        aCampos := {"1"}
    Case _cCampo == "M->C5_VEND1"
        aCampos := {"1","2","3"}
    Case _cCampo == "M->C5_CONDPAG"
        aCampos := {"1","3"}
    Case _cCampo == 'M->C5_TABELA'
        aCampos := {"1","2","3","4"}
    Case _cCampo == 'M->C6_PRODUTO'
        aCampos := {"1","2","3","4","5"}
EndCase

For i := 1 to Len( aCampos )
    nPos := aScan( aLista, {|x| x[1] == aCampos[i] })
    cCampo := "M->" + aLista[ nPos ][2]
    If Empty( &cCampo )
        MsgStop("Este campo necessita da informacao do " + aLista[nPos,3] + " !","Bloqueio de campo")
        lRet := .F.
    Endif
Next

Return( lRet )

// Validacao de campos para Regras de Precos e descontos
User Function CMPREGRA
Local lRet := .T.
Local nLinha    := 0

// Ignora se não identificar a origem do cadastro ou se for um EXECAUTO
If Type("l410Auto") == "U" .OR. l410Auto     
    Return(lRet)   
Endif

// Nao valida as regras se for uma EXCLUSAO ..
IF ! ALTERA .AND. ! INCLUI
    Return(lRet)   
Endif

// Condicoes que nao validam as regras de precos e descontos 
If ! U_USAREGRA()
    Return(lRet)   
Endif

If Empty(M->C5_XOPER)
    MsgStop("Campo de Operacao e Obrigatorio !")
    lRet := .F.
EndIf

If lRet 
    If M->C5_XOPER $ GetMV('FS_OPERVEN',,"01/02/04")
        If ! GetMV('FS_REGRATB',,.F.)
            MsgAlert("Operacao nao permitida para esta filial !")
            lRet := .F. 
        Endif
        If lRet 
            If EMPTY(M->C5_VEND1)
                MsgStop("Campo vendedor e Obrigatorio para operacao de venda !")
                lRet := .F.
            Endif
            If EMPTY(M->C5_CONDPAG)
                MsgStop("Campo condicao de pagamento e Obrigatorio para operacao de venda !")
                lRet := .F.
            Endif
            If EMPTY(M->C5_TABELA)
                MsgStop("Campo Tabela de Preco e Obrigatorio para operacao de venda !")
                lRet := .F.
            Endif
        Endif
    Endif
Endif

For nLinha := 1 TO Len(aCols) //Vare os itens do Pedido para saber se deve bloquear por Regra de Desconto (gatilho preenche o campo C6_XBLQ)
    aCols[nLinha,aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_QTDLIB'  })] := 0
Next

Return( lRet )

// Chamadas de Outros Modulos que nao devem utilizar as regras de precos e descontos
User Function USAREGRA()
Local lRet  := .T.

// Ignora se não identificar a origem do cadastro ou se for um EXECAUTO
If !(IsInCallStack("U_MTASF2")) //PE rotina de faturamento (documento de saida)
    If Type("l410Auto") == "U" .OR. l410Auto 
        lRet := .F.   
    Endif
EndIf

If       IsInCallStack("VEIXA018")      ;   // VEICULOS       - Função que não obriga o preenchimento de campos
    .OR. IsInCallStack("OFIXA100")      ;   // OFICINA        - Função que não obriga o preenchimento de campos
    .OR. IsInCallStack("OFIXA011")      ;   // OFICINA BALCAO - Função que não obriga o preenchimento de campos
    .OR. IsInCallStack("GCSC5BRW")      ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("MOV01ADEV")     ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("AUT001NFS")     ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("AUT004NFS")     ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("AUT004DOCS")    ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("AUT005DOCS")    ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("CTS01GRDEV")    ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("CTV01NFEXP")    ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("U_CTV01NFMAN")  ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("CTC01ENFGH")    ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("CTC01ENFF7")    ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("CTS01BENPR")    ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("CTT01GERPV")    ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("CTT01EXCPV")    ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("CTT001SWCT")    ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("CTV01NFCMP")    ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("MONTADOCDEV")   ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("AUT001EXCDOCS") ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("AUT004EXCDOCS") ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("AUT005EXCDOCS") ;   // P.E. Gestao de Cereais
    .OR. IsInCallStack("MONTADOCSAIDA") ;    // P.E. Gestao de Cereais 
    .OR. IsInCallStack("VEIXX001") ;        // VEICULOS       - Função que não obriga o preenchimento de campos
    .OR. IsInCallStack("U_IMPCTE01")        // Importação do CTE
    lRet := .F.
Endif

Return( lRet )

//Ajusta menu Pedido de VEndas
//Ponto de entrada MA410MNU
//Ajustado por Emerson Natali
User Function CFGXMNUPV()

//Rotina de preparação Documento de Saida ("Ma410PvNfs")
aRotina[ascan(arotina,{|x| alltrim(x[2]) == "Ma410PvNfs"}),2] := "u_CFGXBLOQ()"
aAdd(aRotina, {"Imprimir Pedido",'U_AESS001()',0,7,0,NIL})

Return()

//Nao permite acessar rotina se pedido bloqueado
//Chamado por CFGXMNUPV
//Ajustado por Emerson Natali
User Function CFGXBLOQ()

If SC5->C5_BLQ == "Y" //Bloqueado em Garantia
    MsgStop("Pedido Bloqueado em Garantia")
ElseIf SC5->C5_BLQ == "X" //Bloqueado Regras de Preços e Descontos
    MsgStop("Pedido Bloqueado por Regras de Preços e Descontos")
Else
    Ma410PvNfs()
EndIf

Return

//Grava informações na tabela CD6 (campo Codigo da ANP) para quando produto Combustivel
//Ponto de entrada SF2460I
//Ajustado Emerson Natali
User Function GRVCD6COMB()

IF SF2->F2_TIPO == 'N' .AND. SB1->B1_GRUPO $ GETMV("MV_COMBUS")
    DbSelectArea("CD6")
    CD6->( DbSetOrder(1) )  // Chave: CD6_FILIAL + CD6_TPMOV + CD6_SERIE + CD6_DOC + CD6_CLIFOR + CD6_LOJA + CD6_ITEM + CD6_COD + CD6_PLACA  + CD6_TANQUE  
    DbSelectArea("SB1")
    SB1->( DbSetOrder(1) )  // Chave: B1_FILIAL + B1_COD
    DbSelectArea("C0G")
    C0G->( DbSetOrder(7) )  // Chave: C0G_FILIAL + C0G_CODIGO
    DbSelectArea("SD2")
    SD2->( DbSetOrder(3) )  // Chave: D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA 
 
    If SF2->( DBSEEK( xFilial("SD2") + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) )
        Do While SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) == SF2->( XFILIAL("SD2") + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
            DbSelectArea("SB1")
            IF DbSeek( xFilial("SB1") + SD2->D2_COD )
                DbSelectArea("C0G")
                If DbSeek( xFilial("C0G") + SB1->B1_XCODANP )
                    DbSelectArea("CD6")
                    If DbSeek( SD2->D2_FILIAL + "S" + SD2->D2_SERIE + SD2->D2_DOC + SF2->F2_CLIENTE + SF2->F2_LOJA + SD2->D2_ITEM  )
                        Reclock("CD6",.F.)
                    Else
                        RecLock("CD6",.T.)
                        CD6_FILIAL  := xFilial("CD6")
                        CD6_TPMOV   := "S"
                        CD6_DOC     := SD2->D2_DOC          // NUMERO DA NF
                        CD6_TRANSP  := SF2->F2_TRANSP       // TRANSPORTADORA
                        CD6_SERIE   := SD2->D2_SERIE        // NUMERO DE SERIE DA NF
                        CD6_CLIFOR  := SD2->D2_CLIENTE      // CODIGO DO CLIENTE
                        CD6_LOJA    := SD2->D2_LOJA         // LOJA DO CLIENTE
                        CD6_ITEM    := SD2->D2_ITEM         // SEQUENCIA DO ITEM
                        CD6_COD     := SD2->D2_COD          // CODIGO DO PRODUTO
                        CD6_UFCONS  := SF2->F2_EST          // UNIDADE FEDERATIVA DO CONSUMIDOR
                    Endif
                    CD6_CODANP  :=  C0G->C0G_CODIGO         // CODIGO ANP
                    CD6_DESANP  :=  C0G->C0G_DESCRI         // DESCRICAO ANP
                    CD6->( MsUnLock() )
                Endif
            Endif
            DbSelectArea("SD2")
            SD2->(DbSkip())
        ENDDO
    Endif
    CD6->( DbCloseArea() )
Endif

Return

//Grava informações do motorista na SF2 para impressão em DANFE atraves do PE da Nota
//Dados Transportador
//Ponto de entrada SF2460I
//Conteudo usado em PE01NFESEFAZ
//Ajustado Emerson Natali
User Function GRVMOTORIS()

Local cTitulo   := "Dados do Transportador"

Private cCodTrans   := Space( TamSX3("A4_COD")[1] )   // Código Transportadora (SA4) //carregar conteudo do SC5 OU tabela Z01
Private cNomTrans   := Space( TamSX3("A4_NOME")[1] )  // Nome da Transportadora (SA4) //pesquisar SA4 trazer o conteudo
Private cCNPJTrans  := Space( TamSX3("A4_CGC")[1] )  // CNPJ da Transportadora (SA4)
Private cEndTrans   := Space( TamSX3("A4_END")[1] )  // Endereço da Transportadora (SA4)

Private cVeic   := Space( TamSX3("DA4_NOME")[1] )  // Veiculo

Private cPlaca   := Space( TamSX3("DA4_NOME")[1] )  // Placa veiculo
Private cUFVei   := Space( TamSX3("DA4_NOME")[1] )  // Placa veiculo

Private cMotor  := Space( TamSX3("DA4_COD")[1] )   // Código do Motorista
Private cNmMotor:= Space( TamSX3("DA4_NOME")[1] )  // Nome do Veículo
Private cCPFMotor:= Space( TamSX3("DA4_NOME")[1] )  // CPF do Motorista
Private cRGMotor:= Space( TamSX3("DA4_NOME")[1] )  // RG do Motorista

Private cEspecie:= Space( TamSX3("F2_ESPECI1")[1] )  // Especie
Private cMarca:= Space( TamSX3("DA4_NOME")[1] )  // Marca
Private cVolume:= 0 //TamSX3("F2_VOLUME1")[1]  // Volume
Private cPesoB:= 0 //TamSX3("F2_PBRUTO")[1]    // Peso Bruto
Private cPesoL:= 0 //TamSX3("F2_PLIQUI")[1]    // Peso Liquido

//Conforme orientação Joabe - Totvs - Pegar os dados do Z01 posicionado

If IsInCallStack("U_AAGRA001")         // Pesagem Unica - Romaneio
    
    //alert('entrou: '+Z01->Z01_TRANSP+"- numero romaneio: "+Z01->Z01_NUM )

    cCodTrans   := Z01->Z01_TRANSP          // Código Transportadora (SA4) //carregar conteudo do SC5 OU tabela Z01

    DbSelectArea("SA4")
    DbSetOrder(1)
    If DbSeek( xFILIAL("SA4") + cCodTrans )
        cNomTrans   := SA4->A4_NOME         // Nome da Transportadora (SA4) //pesquisar SA4 trazer o conteudo
        cCNPJTrans  := SA4->A4_CGC          // CNPJ da Transportadora (SA4)
        cEndTrans   := SA4->A4_END          // Endereço da Transportadora (SA4)
    Endif

    cVeic   := Z01->Z01_VEICUL                   // Veiculo

    DbSelectArea("DA3")
    DbSetOrder(1)
    If DbSeek( xFILIAL("DA3") + cVeic )
        cPlaca := DA3->DA3_PLACA            // Placa do Veiculo
        cUFVei := DA3->DA3_ESTPLA           // UF da Placa
    Endi

    cMotor  := Z01->Z01_MOTORI                   // Código do Motorista

    DbSelectArea("DA4")
    DbSetOrder(1)
    If DbSeek( xFILIAL("DA4") + cMotor )
        cNmMotor := DA4->DA4_NOME           // Nome do Motorista
        cCPFMotor := DA4->DA4_CGC           //CPF/ GNPJ
        cRGMotor := ""                      //DA4->DA4_CGC
    Endif

//    cEspecie:= Space( TamSX3("F2_ESPECI1")[1] )  // Especie
//    cMarca:= Space( TamSX3("DA4_NOME")[1] )  // Marca
//    cVolume:= 0 //TamSX3("F2_VOLUME1")[1]  // Volume

    cPesoB:= Z01->Z01_PBRUTO                 // Peso Bruto
    cPesoL:= Z01->Z01_PBRUTO-Z01->Z01_PTARA  // Peso Liquido

Endif

SX3->(DBSETORDER(2))
SX3->(DBSEEK("F2_PBRUTO"))
cPicPeso := alltrim(X3Picture(SX3->X3_CAMPO))

SX3->(DBSETORDER(2))
SX3->(DBSEEK("F2_VOLUME1"))
cPicVol := alltrim(X3Picture(SX3->X3_CAMPO))

DEFINE MSDIALOG oDlg TITLE cTitulo  OF oMainWnd PIXEL FROM 040,040 TO 430,1200

@ 020, 009 SAY   oSay3    PROMPT "Cod.Transp"      SIZE 043, 007 PIXEL OF oDlg
@ 018, 040 MSGET oCodTrans   VAR    cCodTrans      SIZE 043, 010 PIXEL OF oDlg When .T.   F3 "SA4" VALID ValMotor( "SA4",cCodTrans )
@ 018, 100 MSGET oNomTrans  VAR    cNomTrans       SIZE 080, 010 PIXEL OF oDlg When .F.
@ 020, 250 SAY   oSay3    PROMPT "CNPJ/CPF.:"      SIZE 043, 007 PIXEL OF oDlg
@ 018, 300 MSGET oCNPJTrans  VAR    cCNPJTrans       SIZE 080, 010 PIXEL OF oDlg When .F.

@ 040, 009 SAY   oSay3    PROMPT "End.Trans.:"      SIZE 043, 007 PIXEL OF oDlg
@ 038, 040 MSGET oEndTrans  VAR    cEndTrans       SIZE 080, 010 PIXEL OF oDlg When .F.

@ 060, 009 SAY   oSay3    PROMPT "Veiculo"      SIZE 043, 007 PIXEL OF oDlg
@ 058, 040 MSGET oVeic  VAR    cVeic       SIZE 080, 010 PIXEL OF oDlg When .T.   F3 "DA3" VALID ValMotor( "DA3",cVeic )
@ 060, 130 SAY   oSay3    PROMPT "Placa"      SIZE 043, 007 PIXEL OF oDlg
@ 058, 155 MSGET oPlaca  VAR    cPlaca       SIZE 080, 010 PIXEL OF oDlg When .F.
@ 060, 250 SAY   oSay3    PROMPT "UF Veiculo :"      SIZE 043, 007 PIXEL OF oDlg
@ 058, 290 MSGET oUFVei  VAR    cUFVei       SIZE 080, 010 PIXEL OF oDlg When .F.

@ 080, 009 SAY   oSay3    PROMPT "Motorista"      SIZE 043, 007 PIXEL OF oDlg
@ 078, 040 MSGET oMotor   VAR    cMotor           SIZE 043, 010 PIXEL OF oDlg When .T.   F3 "DA4" VALID ValMotor( "DA4",cMotor )
@ 078, 100 MSGET oNMMtor  VAR    cNMMotor         SIZE 080, 010 PIXEL OF oDlg When .F.
@ 080, 220 SAY   oSay3    PROMPT "CPF Mot.:"      SIZE 043, 007 PIXEL OF oDlg
@ 078, 250 MSGET oCPFMotor  VAR    cCPFMotor       SIZE 080, 010 PIXEL OF oDlg When .F.
@ 080, 350 SAY   oSay3    PROMPT "RG Mot.:"      SIZE 043, 007 PIXEL OF oDlg
@ 078, 400 MSGET oRGMotor  VAR    cRGMotor       SIZE 080, 010 PIXEL OF oDlg When .F.

@ 110, 009 SAY   oSay3    PROMPT "Especie"      SIZE 043, 007 PIXEL OF oDlg
@ 108, 040 MSGET oEspecie  VAR    cEspecie       SIZE 080, 010 PIXEL OF oDlg When .T.
@ 110, 130 SAY   oSay3    PROMPT "Marca"      SIZE 043, 007 PIXEL OF oDlg
@ 108, 155 MSGET oMarca  VAR    cMarca       SIZE 080, 010 PIXEL OF oDlg When .T.
@ 110, 250 SAY   oSay3    PROMPT "Volume"      SIZE 043, 007 PIXEL OF oDlg
@ 108, 290 MSGET oVolume  VAR    cVolume       SIZE 080, 010 PIXEL OF oDlg When .T. PICTURE cPicVol

@ 130, 009 SAY   oSay3    PROMPT "Peso Bruto"      SIZE 043, 007 PIXEL OF oDlg
@ 128, 040 MSGET oPesoB  VAR    cPesoB       SIZE 080, 010 PIXEL OF oDlg When .T. PICTURE cPicPeso
@ 130, 130 SAY   oSay3    PROMPT "Peso Liquido"      SIZE 043, 007 PIXEL OF oDlg
@ 128, 180 MSGET oPesoL  VAR    cPesoL       SIZE 080, 010 PIXEL OF oDlg When .T. PICTURE cPicPeso

@ 179, 531 BUTTON oButton1 PROMPT "Confirma"      SIZE 037, 012 OF oDlg ACTION (GravaMot(),oDlg:End()) PIXEL

ACTIVATE MSDIALOG oDlg  CENTERED

Return

//Rotina para gravar os dados na Tabela SF2
//essas informações serão usadas na impressão da DANFE atraves do PE - PE01NFESEFAZ
Static Function GravaMot
/*
cCodTrans           // Código Transportadora (SA4)
cNomTrans           // Nome da Transportadora (SA4)
cCNPJTrans          // CNPJ da Transportadora (SA4)
cEndTrans           // Endereço da Transportadora (SA4)

cVeic               //Codigo do Veiculo
cPlaca              // Placa veiculo
cUFVei              // UF veiculo

cMotor              // Código do Motorista
cNmMotor            // Nome do Veículo
cCPFMotor           // CPF do Motorista
cRGMotor            // RG do Motorista
cEspecie            // Especie
cMarca              // Marca
cVolume             // Volume
cPesoB              // Peso Bruto
cPesoL              // Peso Liquido
*/

Local cCompl := ""

cCompl := "Marca:"+alltrim(cMarca)+" Placa:" + alltrim(cPlaca) + " UF Veiculo:" + alltrim(cUFVei)
cCompl += " Motorista:"+alltrim(cNmMotor) + " CNPJ/CPF:" + alltrim(cCPFMotor) + " RG:" + alltrim(cRGMotor)

If RecLock("SF2",.F.)
    SF2->F2_TRANSP  := cCodTrans        //Transportadora
    SF2->F2_VEICUL1 := cVeic            //Veiculo DA3
    SF2->F2_ESPECI1 := cEspecie         //Especie 
    SF2->F2_VOLUME1 := cVolume          //Volume
    SF2->F2_PLIQUI  := cPesoL           //Peso Liquido
    SF2->F2_PBRUTO  := cPesoB           //Peso Bruto
    SF2->F2_MENN2   := If(Empty(ALLTRIM(F2_MENN2)),alltrim(cCompl) , ALLTRIM(F2_MENN2) +" "+ alltrim(cCompl)) //complemento - dados do Motorista - não tem campos na DANFE imprimir no complemento
    SF2->(MsUnLock())
EndIf

Return

// Valida Codigo do motorista
Static Function ValMotor( _cAlias, _cCodigo )
Local lRet := .F.

Default _cAlias := Nil

If _cAlias = "SA4" //Transportadora
    DbSelectArea("SA4")
    DbSetOrder(1)
    If DbSeek( xFILIAL("SA4") + _cCodigo )
        cNomTrans  := SA4->A4_NOME  // Nome da Transportadora
        cCNPJTrans := SA4->A4_CGC  // CNPJ da Transportadora
        cEndTrans  := SA4->A4_END  // Endereço da Transportadora
        lRet     := .T.
    Endif
ElseIf _cAlias = "DA4" //Transportadora
    DbSelectArea("DA4")
    DbSetOrder(1)
    If DbSeek( xFILIAL("DA4") + _cCodigo )
        cNmMotor := DA4->DA4_NOME  // Nome do Motorista
        cCPFMotor := DA4->DA4_CGC //CPF/ GNPJ
        cRGMotor := ""//DA4->DA4_CGC
        lRet     := .T.
    Endif
ElseIf _cAlias = "DA3" //Veiculo
    DbSelectArea("DA3")
    DbSetOrder(1)
    If DbSeek( xFILIAL("DA3") + _cCodigo )
        cPlaca := DA3->DA3_PLACA  // Placa do Veiculo
        cUFVei := DA3->DA3_ESTPLA // UF da Placa
        lRet     := .T.
    Endi
EndIf

Return( lRet )

//Impressao do Boleto atraves da DANFE
//Chamado no final da DANFEII e DANFEIII
User Function ImpBoleto(mv_par01, mv_par02, mv_par03,mv_par04)  // parametro - NOTA DE | NOTA ATE | SERIE | TP.OPERAÇÃO (E-1/S-2)

Local aArea	:= GetArea()

If mv_par04 == 2 //Somente para Nota de Saida
	If cFilAnt $ SuperGetMV("FS_BOLFIL ",.T.,"")
        cAliasSF2 := GetNextAlias()
 		BeginSql Alias cAliasSF2
			SELECT *
			FROM %Table:SF2% SF2
                INNER JOIN %Table:SE1% SE1 ON SE1.D_E_L_E_T_ = '' 
                AND SE1.E1_FILIAL = SF2.F2_FILIAL 
                AND SE1.E1_PREFIXO = SF2.F2_SERIE 
                AND SE1.E1_NUM = SF2.F2_DOC
			WHERE
			SF2.F2_FILIAL = %Exp:cFilAnt% AND
			SF2.F2_SERIE = %Exp:mv_par03% AND 
			SF2.F2_DOC BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
            SF2.F2_CHVNFE <> '' AND 
            SF2.%NotDel%
			ORDER BY SF2.F2_SERIE, SF2.F2_DOC
		EndSql

        If (cAliasSF2)->(!Eof())
            If MsgYesNo("Deseja imprimir o Boleto Bancário ?","Boleto")
                While (cAliasSF2)->(!Eof())
                    aParam := {.T., (cAliasSF2)->(F2_DOC), mv_par02, mv_par03} // parametro - .t. (DANFE no multibol) | Nota de | Nota ate | serie 
                    ExecBlock( "MULTIBOL", .F., .F.,aParam) //Impressão do Boleto
                    (cAliasSF2)->(DbSkip())
                EndDo
            EndIf
        Endif
	EndIf
EndIf

RestArea(aArea)
Return

// GatPrcVen - Calculo do preço de venda com acréscimo conforme condição de pagamento
// Autor: Alex Rodrigues - 28/10/2020

User Function GatPrcVen(cRet)

Local aArea    := GetArea()
Local nPosPreco:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_PRUNIT'})
//Local nPosPreco:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_PRCVEN'})
Local nPosDescP:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_DESCONT'})
//Local nPosDescV:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_VALDESC'})
Local nPosOfert:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_XOFERTA'})
Local nPosCodPr:= aScan( aHeader, {|x| Alltrim(x[2]) == 'C6_PRODUTO'})
Local nPreco   := aCols[n,nPosPreco]
Local nPrcTab  := 0
Local nPrecoJ  := 0
Local aFin     := {}
Local dUltData := ddatabase
Local cScan    := ""
Local i        := 0
Local nValDesc := 0
Local aAreaDA1 := DA1->(GetArea())
Local nTaxa    := GetMV('FS_TAXAJUR',,"1")

//cRet
//1 ou Nulo - retorna preço de venda
//2         - retorna o valor do desconto
//3         - preço de tabela com acréscimo

Default cRet := Nil


If ! GetMV('FS_REGRATB',,.F.) .OR. l410Auto 
    Return( nPreco )
ENDIF

//estava no gatilho antes assim
//IIF(M->C6_XOFERTA=="2",SZD->ZD_VLRPROM,M->C6_PRCVEN)

//Pega o preço promocional se tiver preço promocional
If aCols[n,nPosOfert] == "2"
    nPreco := SZD->ZD_VLRPROM
Endif

//Array com a condição de pagamento
aFin := condicao(nPreco,M->C5_CONDPAG,0,DDATABASE) // retorno do array {vencimento, valor}

IF Len(aFin) == 0 // se array está vazio é porque a condição de pagamento é do tipo específica

    If Empty(M->C5_DATA1)
        Alert("Condição de pagamento do tipo 9, sem preencher data de vencimento no cabeçalho do pedido. Favor verificar ... ")
    Endif

    //***** Pode ser usado por % ou po 9 - valor ..

    cScan := "1"
    nDup:= 0
    While ( !Empty(cScan) )

    	If SC5->(FieldPos("C5_DATA"+cScan))>0
            If !Empty(&("M->C5_DATA"+cScan))
                dUltData := &("M->C5_DATA"+cScan)
            Endif
            //Alert("condição de pagamento específica % ou valor -> "+DTOC(&("M->C5_DATA"+cScan)))
        Else
            cScan := ""
        Endif

        cScan := Soma1(cScan,1)

    EndDo

Else
        For i:=1 to len(aFin)
            dUltData := aFin[i,1] 
            //Alert("Condição normal -> "+DTOC(aFin[i,1]))
        Next
ENDIF

If nPreco > 0 

    DbSelectArea("DA1")
    DbSetOrder(1) //Filial+Tabela+Produto+IndLot+Item
    DbSeek(xFilial("DA1")+M->C5_TABELA+aCols[n,nPosCodPr])

    nPrcTab := DA1->DA1_PRCVEN
    
    If DA1->DA1_MOEDA <> M->C5_MOEDA
        If DA1->DA1_MOEDA = 2 .and. M->C5_MOEDA = 1
            nPrcTab := nPrcTab * SM2->M2_MOEDA2
        EndIf    
    EndIf
    
    nJuros := int((dUltData-dDataBase)/30) * nTaxa
    nPrecoJ := nPrcTab + (nPrcTab * nJuros / 100) //aplica acréscimo
    nValDesc := (nPrecoJ*aCols[n,nPosDescP]/100)
    nPreco := nPrecoJ - nValDesc //aplica desconto
//Else
//    MsgInfo("Produto sem preço")
Endif

RestArea(aArea)
RestArea(aAreaDa1)

If cRet == '2' //valor do desconto
    nRet := nValDesc
ElseIf cRet == '3'  // preço de tabela com acréscimo.
    nRet := nPrecoJ
Else
    nRet := nPreco
ENDIF

Return (nRet)
