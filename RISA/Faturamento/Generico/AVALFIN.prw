#INCLUDE "TOTVS.CH" 

#DEFINE ENTER CHR(13)+CHR(10)

/*/

{Protheus.doc} AVALFIN
                 
Lista de Pedidos que necessitam de aprova豫o

@author  Milton J.dos Santos	
@since   01/09/20
@version 1.0

/*/

User Function AVALFIN()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Local aArea     := GetArea()
Local cCondicao := ""
Local aIndSC5   := {}
Local aCores 	:=	{	{ "Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)"	,	'ENABLE'		,	"Pedido em Aberto"			},;		
						{ "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)"		,	'DISABLE'		,	"Pedido Encerrado"			},;		
						{ "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)"	,	'BR_AMARELO'	,	"Pedido Liberado"			},;		
						{ "C5_BLQ == '1'"												,	'BR_AZUL'		,	"Pedido Bloquedo por regra"	},;		
						{ "C5_BLQ == '2'"												,	'BR_LARANJA'	,	"Pedido Bloquedo por verba"	}}		
/*
Local aCores    := {
					{"C5_BLQ == 'X' .AND. C5_XAVAL <> 'R'"    , "BR_BRANCO"   , "Pedido Bloqueado no Comercial"},
					{"C5_BLQ == 'X' .AND. C5_XAVAL == 'R'"    , "BR_PRETO"    , "Pedido Bloqueado no Comercial REPROVADO"},
					{"C5_BLQ == 'Y' .AND. C5_XAVALG <> 'R'"   , "BR_CINZA"    , "Pedido Bloqueado na Garantia"},
					{"C5_BLQ == 'Y' .AND. C5_XAVALG == 'R'"   , "BR_PINK"     , "Pedido Bloqueado na Garantia REPROVADO"}
					}
*/
If ExistBlock("MA410COR")
	aCoresNew	:= ExecBlock("MA410COR",.F.,.F.,aCores)
	aCores		:= aClone(aCoresNew)
Endif

If ( cPaisLoc $ "ARG|POR|EUA" )
	Private aArrayAE:={}
EndIf
Private cCadastro := OemToAnsi("Avaliacao da Garantia")		// STR0005   "Liberacao de Credito / Estoque"
Private aRotina := MenuDef()
	
If VerSenha(136) .And. VerSenha(137)
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿐XECUTAR CHAMADA DE FUNCAO p/ integracao com sistema de Distribuicao - NAO REMOVER �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	dbSelectArea("SC5")
	dbSetOrder(1)
// AURICELIO PEDIU PRA SEMPRE MOSTRAR TODOS OS PEDIDOS PARA NOVAMENTE BLOQUEA-LO
	//cCondicao := "C5_FILIAL =='"+xFilial("SC5")+"' .And. C5_BLQ == 'Y' "
	//cCondicao := "C5_FILIAL ==''"+xFilial("SC5")+"'"
	//!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ) -> legenda no MATA410 padr�o para pedidos encerrados

//Alterado por Emerson dia 14/10/2020 - troquei a regra do campo C5_NOTA pelo C5_LIBEROK
//quando um PV esta totalmente liberado j� gerou SC9 ent�o nao pode ser Reprovado por Garantia
//quando um PV esta faturado o C5_LIBEROK fica igual a Sim
//	cCondicao := "C5_FILIAL =='"+xFilial("SC5")+"' .And. Empty(C5_NOTA) .And. (C5_BLQ == 'Y' .or. C5_XAVALG <> '')"
	cCondicao := "C5_FILIAL =='"+xFilial("SC5")+"' .And. Empty(C5_LIBEROK) .And. (C5_BLQ == 'Y' .or. C5_XAVALG <> '')"

 	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴�	컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Endereca a funcao de BROWSE                                  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	dbSelectArea("SC5")
	If ( Eof() )
		HELP(" ",1,"RECNO")
	Else
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿝ealiza a filtragem somente na fun豫o de browse para permitir o usu�rio �
		//쿶ncluir filtros customizados na rotina                                  �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		mBrowse( 7, 4,20,74,"SC5",,,,,,aCores,,,,,,,,,,,,cCondicao) //,,"SC9->C9_BLEST+SC9->C9_BLCRED"
	EndIf
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿝estaura a integridade da rotina                                �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	dbSelectArea("SC5")
	RetIndex("SC5")
	dbClearFilter()
	aEval(aIndSC5,{|x| Ferase(x[1]+OrdBagExt())})
Else
	HELP(" ",1,"SEMPERM")
Endif
RestArea(aArea)
Return(.T.)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rograma  쿘enuDef   � Autor � Marco Bianchi         � Data �01/09/2006낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Utilizacao de menu Funcional                               낢�
굇�          �                                                            낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   쿌rray com opcoes da rotina.                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros쿛arametros do array a Rotina:                               낢�
굇�          �1. Nome a aparecer no cabecalho                             낢�
굇�          �2. Nome da Rotina associada                                 낢�
굇�          �3. Reservado                                                낢�
굇�          �4. Tipo de Transa뇙o a ser efetuada:                        낢�
굇�          �	  1 - Pesquisa e Posiciona em um Banco de Dados           낢�
굇�          �    2 - Simplesmente Mostra os Campos                       낢�
굇�          �    3 - Inclui registros no Bancos de Dados                 낢�
굇�          �    4 - Altera o registro corrente                          낢�
굇�          �    5 - Remove o registro corrente do Banco de Dados        낢�
굇�          �5. Nivel de acesso                                          낢�
굇�          �6. Habilita Menu Funcional                                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

Static Function MenuDef()
  
Private aRotina	:= {{"Avalia豫o", "U_AprGar"	, 0, 2, 0, .T.},;
               	    {"Pesquisar", "PesqBrw"		, 0, 1, 0, .F.},;
               	    {"Legenda"	, "A410Legend"	, 0, 8, 0, .F.}} 
               	    //{"Autom�tica", "U_A456LibAut", 0, 2, 0, .T.},;	// STR0003
Return(aRotina)

/*/

{Protheus.doc} APRGAR
                 
Tela de Aprova豫o comercial

@author  Milton J.dos Santos	
@since   22/07/20
@version 1.0

/*/

User Function APRGAR()
Local aArea     := GetArea()
Local cTitulo   := "Solicita豫o de Aprova豫o"
Local cNumPed   := SC5->C5_NUM // N�mero do Pedido
Local cNomCli 	:= AllTrim(SC5->C5_CLIENTE + " - " + POSICIONE('SA1', 1, xFilial('SA1') + SC5->C5_CLIENTE, 'A1_NOME')) // C�digo e Nome do Cliente
Local cDtPed    := DtoC(SC5->C5_EMISSAO) // Data do Pedido
Local cCondPG   := AllTrim(SC5->C5_CONDPAG + " - " + POSICIONE('SE4', 1, xFilial('SE4') + SC5->C5_CONDPAG, 'E4_DESCRI')) // C�digo e Descri豫o da condi豫o de Pagamento 
Local cNomVen	:= AllTrim(SC5->C5_VEND1 + " - " + POSICIONE('SA3', 1, xFilial('SA3') + SC5->C5_VEND1, 'A3_NOME')) // C�digo e Nome do Vendedor 
Local oButton1
Local oButton2
Local oButton3
Local oCondPG
Local oDtPed
Local oNomCli
Local oNomVen
Local oNumPed
Local oRed1
Local oBlue1
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local oSay10
Local oValTot
Static oDlgMain

Private sMoeda		:= MV_SIMB1
Private nValTotG	:= 0
Private aWBrowse1	:= {} 
Private nTotalPed   := 0
Private cValTot 	:= "" //sMoeda+" "+TRANSFORM(nValTotG, "@E 999.999,99")
Private cJust 		:= ""
Private oJust
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿗eds utilizados para as legendas das rotinas�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
//Private oGreen   	:= LoadBitmap( GetResources(), "BR_VERDE")
Private oRed    	:= LoadBitmap( GetResources(), "BR_VERMELHO")
//Private oBlack	:= LoadBitmap( GetResources(), "BR_PRETO")
//Private oYellow	:= LoadBitmap( GetResources(), "BR_AMARELO")
//Private oBrown	:= LoadBitmap( GetResources(), "BR_MARROM")
Private oBlue		:= LoadBitmap( GetResources(), "BR_AZUL")
//Private oOrange	:= LoadBitmap( GetResources(), "BR_LARANJA")
//Private oViolet	:= LoadBitmap( GetResources(), "BR_VIOLETA")
//Private oPink		:= LoadBitmap( GetResources(), "BR_PINK")
//Private oGray		:= LoadBitmap( GetResources(), "BR_CINZA")

DEFINE MSDIALOG oDlgMain TITLE cTitulo  OF oMainWnd PIXEL FROM 040,040 TO 430,1200 COLORS 0, 12632256
DEFINE FONT oFont1	NAME "Mono AS"	SIZE 10, 18
DEFINE FONT oFont2	NAME "Mono AS"	SIZE 11, 19
DEFINE FONT oBold   NAME "Arial"	SIZE 0, -12 BOLD
DEFINE FONT oBold2  NAME "Arial"	SIZE 0, -40 BOLD

TGroup():New(029,008,91,571,,oDlgMain,,,.T.)

@ 007, 009 SAY   oSay1   PROMPT "Pedido"                 SIZE 043, 007 PIXEL OF oDlgMain FONT oBold COLORS 0, 12632256
@ 015, 008 MSGET oNumPed VAR    cNumPed                  SIZE 043, 010 PIXEL OF oDlgMain When .F.   COLORS 0, 16777215
@ 007, 050 SAY   oSay2   PROMPT "Cliente"                SIZE 154, 007 PIXEL OF oDlgMain FONT oBold COLORS 0, 12632256
@ 015, 050 MSGET oNomCli VAR    cNomCli                  SIZE 154, 010 PIXEL OF oDlgMain When .F.   COLORS 0, 16777215
@ 007, 203 SAY   oSay3   PROMPT "Data do Pedido"         SIZE 062, 007 PIXEL OF oDlgMain FONT oBold COLORS 0, 12632256
@ 015, 203 MSGET oDtPed  VAR    cDtPed PICTURE "@!"      SIZE 062, 010 PIXEL OF oDlgMain When .F.   COLORS 0, 16777215
@ 007, 264 SAY   oSay4   PROMPT "Condi豫o do Pagamento"  SIZE 094, 007 PIXEL OF oDlgMain FONT oBold COLORS 0, 12632256
@ 015, 264 MSGET oCondPG VAR    cCondPG                  SIZE 094, 010 PIXEL OF oDlgMain When .F.   COLORS 0, 16777215
@ 006, 357 SAY   oSay5   PROMPT "Vendedor"               SIZE 106, 007 PIXEL OF oDlgMain FONT oBold COLORS 0, 12632256
@ 015, 357 MSGET oNomVen VAR    cNomVen                  SIZE 106, 010 PIXEL OF oDlgMain When .F.   COLORS 0, 16777215
@ 006, 462 SAY   oSay6   PROMPT "Valor Total"            SIZE 110, 007 PIXEL OF oDlgMain FONT oBold COLORS 0, 12632256
@ 015, 462 MSGET oValTot VAR    cValTot					 SIZE 110, 010 PIXEL OF oDlgMain When .F.   COLORS 0, 16777215
@ 100, 012 SAY   oSay7   PROMPT "JUSTIFICATIVA"          SIZE 045, 007 PIXEL OF oDlgMain FONT oBold COLORS 0, 12632256 
@ 108, 008 GET   oJust   VAR    cJust                    SIZE 560, 066 PIXEL OF oDlgMain MULTILINE  COLORS 0, 16777215 HSCROLL 
@ 096, 285 SAY   oSay10  PROMPT "Legenda:"               SIZE 025, 007 PIXEL OF oDlgMain FONT oBold COLORS 0, 12632256 
//@ 094, 414 MSGET oRed1   VAR    oRed                     SIZE 015, 010 PIXEL OF oDlgMain READONLY   COLORS 0, 12632256  
@ 094, 314 BITMAP oRed1 RESNAME "BR_VERMELHO" 			 SIZE 16,16 NOBORDER OF oDlgMain PIXEL
@ 095, 325 SAY   oSay8   PROMPT "Com Bloqueio Garantia" SIZE 110, 007 PIXEL OF oDlgMain FONT oBold COLORS 0, 12632256 
//@ 094, 410 MSGET oBlue1  VAR    oBlue                    SIZE 015, 010 PIXEL OF oDlgMain READONLY   COLORS 0, 12632256  
@ 094, 410 BITMAP oBlue1 RESNAME "BR_AZUL" SIZE 16,16 NOBORDER OF oDlgMain PIXEL
@ 095, 420 SAY   oSay9   PROMPT "Sem Bloqueio Garantia" SIZE 110, 007 PIXEL OF oDlgMain FONT oBold COLORS 0, 12632256 


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// GRID 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

fWBrowse1()

@ 179, 443 BUTTON oButton1 PROMPT "Aprovar"   SIZE 037, 012 OF oDlgMain ACTION (IIF(Decisao( '2' ),oDlgMain:End(),)) PIXEL
@ 179, 487 BUTTON oButton2 PROMPT "Reprovar"  SIZE 037, 012 OF oDlgMain ACTION (IIF(Decisao( '1' ),oDlgMain:End(),)) PIXEL
@ 179, 531 BUTTON oButton3 PROMPT "Abandonar" SIZE 037, 012 OF oDlgMain ACTION (oDlgMain:End()) 					 PIXEL

ACTIVATE MSDIALOG oDlgMain  CENTERED
RestArea(aArea)
RETURN

//------------------------------------------------
Static Function fWBrowse1()
//------------------------------------------------
	Local aArea     := GetArea()
	Local aDados	:= {}
	Local oWBrowse1

	aDados := DADOSGAR() // Busca dados do pedido para aprova豫o

	If Empty(aDados)
		Alert( "Nao encontrou saldo a faturar !")
		Return
	Endif

	aWBrowse1 := aDados[1]
	nValTotG  := aDados[2]
	cValTot   := sMoeda+" "+AllTrim(TRANSFORM(nValTotG, "@E 999,999.99"))

    @ 029, 009 LISTBOX oWBrowse1 Fields HEADER "STATUS","CODIGO","DESCRICAO","QTDE","PRECO TABELA","MINIMO ACEITAVEL","UNIT핾IO","TOTAL","DESCONTO","% DESCONTO","% MARGEM","VALOR MARGEM","DESCONTO MINIMO","DESCONTO MAXIMO","GRUPO PRODUTO" SIZE 561, 062 OF oDlgMain PIXEL ColSizes 50,50
    oWBrowse1:SetArray(aWBrowse1)
    oWBrowse1:bLine := {|| {;
      aWBrowse1[oWBrowse1:nAt,1],;
      aWBrowse1[oWBrowse1:nAt,2],;
      aWBrowse1[oWBrowse1:nAt,3],;
      aWBrowse1[oWBrowse1:nAt,4],;
      aWBrowse1[oWBrowse1:nAt,5],;
      aWBrowse1[oWBrowse1:nAt,6],;
      aWBrowse1[oWBrowse1:nAt,7],;
      aWBrowse1[oWBrowse1:nAt,8],;
      aWBrowse1[oWBrowse1:nAt,9],;
      aWBrowse1[oWBrowse1:nAt,10],;
      aWBrowse1[oWBrowse1:nAt,11],;
      aWBrowse1[oWBrowse1:nAt,12],;
      aWBrowse1[oWBrowse1:nAt,13],;
      aWBrowse1[oWBrowse1:nAt,14],;
      aWBrowse1[oWBrowse1:nAt,15];
    }}
    // DoubleClick event
    //oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],oWBrowse1:DrawSelect()}
RestArea(aArea)
Return

Static Function Decisao( cApro )
Local aArea := GetArea()
Local lRet  := .F.
Local cUsr  := Alltrim(Substr(cUsuario,7,13))

RECLOCK('SC5',.F.)
If cApro == "2"
	SC5->C5_XUSUG	:= __cUserID
	SC5->C5_XDTAVG	:= DATE()
	SC5->C5_XOBSG	:= Alltrim(SC5->C5_XOBSG)+DTOC(DATE())+" �s "+Time()+" hs"+" - "+"Aprovado por: "+cUsr+" - "+cJust+CHR(10)+CHR(13)
	SC5->C5_XAVALG	:= "A"
  	SC5->C5_BLQ		:=  Iif( cApro == "2","","Y") 

  	MsgInfo("Pedido " + SC5->C5_NUM + " Aprovado com Sucesso !")
	lRet := Iif( SC5->C5_BLQ <> "Y",.T.,.F.) 
Else
	SC5->C5_XDTAVG	:= DATE()
	SC5->C5_XOBSG	:= Alltrim(SC5->C5_XOBSG)+DTOC(DATE())+" �s "+Time()+" hs"+" - "+"*REPROVADO* por: "+cUsr+" - "+cJust+CHR(10)+CHR(13)
	SC5->C5_XAVALG	:= "R"
  	SC5->C5_BLQ		:=  Iif( cApro == "2","","Y") 

	MsgInfo("Pedido " + SC5->C5_NUM + " Reprovado !")
	lRet := .T.
EndIF
SC5->(MSUNLOCK())
RestArea(aArea)
Return(lRet)

Static Function DADOSGAR()
Local aArea     := GetArea()
Local cQuery    := ""
Local cAliasTRB := GetNextAlias()
Local aDados	:= {}
Local nValTot	:= 0
Local sMoeda	:= MV_SIMB1

	cQuery := " SELECT DISTINCT "										+ ENTER
	cQuery += " SC6.C6_XOFERTA AS RB_XOFERTA, " 						+ ENTER
	cQuery += " SC6.C6_PRODUTO AS RB_PRODUTO, " 						+ ENTER
	cQuery += " SC6.C6_DESCRI  AS RB_DESCRI, "							+ ENTER
	cQuery += " SC6.C6_QTDVEN  AS RB_QTDVEN, "							+ ENTER
	cQuery += " DA1.DA1_PRCVEN AS RB_PRCVENT, " 						+ ENTER
	cQuery += " ISNULL((SB2.B2_CM1 + ((SB2.B2_CM1*SBZ.BZ_MARKUP)/100)),0) AS RB_PREMIN, " + ENTER
	cQuery += " SC6.C6_PRCVEN  AS RB_PRCVEN, "							+ ENTER
	cQuery += " SC6.C6_VALOR   AS RB_VALOR, "							+ ENTER
	cQuery += " SC6.C6_VALDESC AS RB_VALDESC, " 						+ ENTER
	cQuery += " SC6.C6_DESCONT AS RB_DESCONT, " 						+ ENTER
	cQuery += " (SC6.C6_DESCONT-SZC.ZC_DESMAX) AS RB_MARGEMP, " 		+ ENTER
	cQuery += " (SC6.C6_VALOR*(SC6.C6_DESCONT-SZC.ZC_DESMAX)/100) AS RB_MARGEMV, " + ENTER
	cQuery += " SZC.ZC_DESMIN AS RB_DESMIN, "							+ ENTER
	cQuery += " SZC.ZC_DESMAX AS RB_DESMAX, "							+ ENTER
	cQuery += " CONCAT(SB1.B1_GRUPO,' - ',SBM.BM_DESC) AS RB_GRUPO "	+ ENTER
	cQuery += " FROM " + RetSQLName("SC6") + " SC6 "					+ ENTER
	cQuery += " INNER JOIN " + RetSQLName("SC5") + " SC5 ON SC5.D_E_L_E_T_ <> '*' AND SC5.C5_FILIAL = '"+xFilial("SC5")+ "' AND SC5.C5_NUM = SC6.C6_NUM " + ENTER
	cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON SB1.D_E_L_E_T_ <> '*' AND SB1.B1_FILIAL = '"+xFilial("SB1")+ "' AND SB1.B1_COD = SC6.C6_PRODUTO "	+ ENTER
	cQuery += " LEFT  JOIN " + RetSQLName("DA1") + " DA1 ON DA1.D_E_L_E_T_ <> '*' AND DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND DA1.DA1_CODPRO = SC6.C6_PRODUTO AND DA1_CODTAB = SC5.C5_TABELA " + ENTER
	cQuery += " LEFT  JOIN " + RetSQLName("SB2") + " SB2 ON SB2.D_E_L_E_T_ <> '*' AND SB2.B2_FILIAL = '"+xFilial("SB2")+ "' AND SB2.B2_COD = SC6.C6_PRODUTO AND SB2.B2_LOCAL = SC6.C6_LOCAL "	+ ENTER
	cQuery += " LEFT  JOIN " + RetSQLName("SBZ") + " SBZ ON SBZ.D_E_L_E_T_ <> '*' AND SBZ.BZ_FILIAL = '"+xFilial("SBZ")+ "' AND SBZ.BZ_COD = SC6.C6_PRODUTO "	+ ENTER
	cQuery += " LEFT  JOIN " + RetSQLName("SZC") + " SZC ON SZC.D_E_L_E_T_ <> '*' AND SZC.ZC_FILIAL = '"+xFilial("SZC")+ "' AND SC5.C5_VEND1 = SZC.ZC_VEND AND SZC.ZC_GRPROD = SB1.B1_GRUPO " + ENTER
	cQuery += " LEFT  JOIN " + RetSQLName("SBM") + " SBM ON SBM.D_E_L_E_T_ <> '*' AND SBM.BM_FILIAL = '"+xFilial("SBM")+ "' AND SBM.BM_GRUPO = SZC.ZC_GRPROD " + ENTER
	cQuery += " WHERE "													+ ENTER
	cQuery += " SC6.D_E_L_E_T_ <> '*' "									+ ENTER
	cQuery += " AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "			+ ENTER
	cQuery += " AND SC6.C6_NUM = '" + AllTrim(SC5->C5_NUM) + "' "		+ ENTER

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.F.,.T.)
	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop())
	While !(cAliasTRB)->( Eof() )
		
	    Aadd(aDados,{IIF((cAliasTRB)->RB_XOFERTA == '3', oRed, oBlue),;
		                AllTrim((cAliasTRB)->RB_PRODUTO),;
		                AllTrim((cAliasTRB)->RB_DESCRI),;
		                        (cAliasTRB)->RB_QTDVEN,;
		                        sMoeda+" "+AllTrim(TRANSFORM((cAliasTRB)->RB_PRCVENT, "@E 999,999.99")),;
		                        sMoeda+" "+AllTrim(TRANSFORM((cAliasTRB)->RB_PREMIN, "@E 999,999.99")),;
		                        sMoeda+" "+AllTrim(TRANSFORM((cAliasTRB)->RB_PRCVEN, "@E 999,999.99")),;
		                        sMoeda+" "+AllTrim(TRANSFORM((cAliasTRB)->RB_VALOR, "@E 999,999,999.99")),;
		                        sMoeda+" "+AllTrim(TRANSFORM((cAliasTRB)->RB_VALDESC, "@E 999,999,999.99")),;
		                        STR((cAliasTRB)->RB_DESCONT)+"%",;
		                        STR((cAliasTRB)->RB_MARGEMP)+"%",;
		                        sMoeda+" "+AllTrim(TRANSFORM((cAliasTRB)->RB_MARGEMV, "@E 999,999.99")),;
		                        STR((cAliasTRB)->RB_DESMIN)+"%",;
		                        STR((cAliasTRB)->RB_DESMAX)+"%",;
		                AllTrim((cAliasTRB)->RB_GRUPO)})
		nValTot += (cAliasTRB)->RB_VALOR
	    (cAliasTRB)->( DbSkip() )
	EndDo
	(cAliasTRB )->( DbCloseArea() )
	RestArea(aArea)

Return({aDados,nValTot})
