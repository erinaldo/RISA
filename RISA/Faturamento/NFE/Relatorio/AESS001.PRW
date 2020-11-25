#INCLUDE "RWMAKE.CH"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ AESS001 ³ Autor ³ Ismael Junior          ³ Data ³ 24/11/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Orcamento grafico buscando da SC5 e SC6					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para TROVATTO 								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Alteração ³ Toni Aguiar em 29/03/2016								  ³±±
±±³          ³ Não agregar IPI no total do pedidos de vendas, das TES     ³±±
±±³          ³ que possuam CFOPs 6109/6915/6916                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function AESS001()

LOCAL aMarked := {}
PRIVATE Exec    := .F.
PRIVATE cIndexName := ''
PRIVATE cIndexKey  := ''
PRIVATE cFilter    := ''
PRIVATE cNumOrc    := ''
PRIVATE cPerg      := "PEDVED"
lEnd     := .F.

If Funname() == 'MATA410'
	Pergunte(cPerg,.F.)
	cNumOrc		:= SC5->C5_NUM
Else
	If !Pergunte(cPerg,.T.)
	   Return
	Endif
	cNumOrc		:= MV_PAR01
Endif

//alert("alex")

RptStatus({ |lend| MontaRel()})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  MontaRel ³Autor ³ Ismael Junior         ³ Data ³ 24/11/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO PEDIDO DE VENDA MERCANTIL                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MontaRel()

//LOCAL oPrint
LOCAL n := 0
LOCAL aDadosEmp
LOCAL aDadosCli
LOCAL aDadosOrc
LOCAL i         := 1
LOCAL nRec      := 0
LOCAL _nVlrAbat := 0
LOCAL _nTotEnc  := 0
Local nVlAtraso := 0

Private _oFont       := TFont():New('Arial',,15,,.T.,,,,.F.,.F.)
Private oPrint

DO CASE
CASE LEN(ALLTRIM(SM0->M0_INSC)) == 8
   _Cie := Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"-"+Subs(SM0->M0_INSC,7,2)
CASE LEN(ALLTRIM(SM0->M0_INSC)) == 9
   _Cie := Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)
CASE LEN(ALLTRIM(SM0->M0_INSC)) == 12
   _Cie := Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)+"."+Subs(SM0->M0_INSC,10,3)
CASE LEN(ALLTRIM(SM0->M0_INSC)) == 14
   _Cie := Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)+"."+Subs(SM0->M0_INSC,10,3)+"-"+Subs(SM0->M0_INSC,13,2)
OTHERWISE
   _Cie := Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)
ENDCASE

aDadosEmp  := {SM0->M0_NOMECOM 															  ,; //[1]Nome da Empresa
				SM0->M0_ENDCOB                                           				  ,; //[2]Endereço
				AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
				"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
				"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
				"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+              ; //[6]
				Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
				Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
				"IE: "+_Cie 															   } //[7]I.E

oPrint:= TMSPrinter():New( "Pedido de Venda" )
oPrint:SetPortrait() // ou SetLandscape()
oPrint:StartPage()   // Inicia uma nova página
oPrint:SetpaperSize(9) // <==== AJUSTE PARA PAPEL a4

//Posiciona a SL1 (Orcamento)
//cNumOrc := '000003'//SC5->C5_NUM
//Alert(cNumOrc)

DbSelectArea("SC5")
DbSetOrder(1)
DbSeek(xFilial("SC5")+cNumOrc,.T.)

//Somente imprime pedido sem bloqueio de regra de desconto 

//IF SC5->C5_BLQ == "X" .OR. SC5->C5_BLQ == "Y" //Bloqueado X (Regra de Desconto) / Bloqueado Y (Regra Garantia)
IF SC5->C5_BLQ == "X" //Bloqueado X (Regra de Desconto)
//	If SC5->C5_BLQ == "X"
		MsgStop("Pedido não pode ser impresso. Pedido bloqueado por: [REGRA DE DESCONTO / COMERCIAL] ")
//	Else
//		MsgStop("Pedido não pode ser impresso. Pedido bloqueado por: [REGRA GARANTIA] ")
//	Endif

	Return
Endif

DbSelectArea("SX5")
DbSetOrder(1)
DbSeek(xFilial("SX5")+"DJ"+SC5->C5_XOPER)

DbSelectArea("DA0")
DbSetOrder(1)
DbSeek(xFilial("DA0")+SC5->C5_TABELA)

aRetBox := RetSx3Box( Posicione('SX3', 2, 'C5_TPFRETE', 'X3CBox()' ),,, Len(SC5->C5_TPFRETE) )
cTpFrete := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == SC5->C5_TPFRETE} ), 3 ])

DbSelectArea("SC5")

aDadosOrc    := {AllTrim(C5_NUM)		            	,;  // [1] Número do orcamento
		   		C5_EMISSAO                              ,;  // [2] Data da emissão do orcamento
   				C5_VEND1   		                        ,;  // [3] Vendedor
				C5_CLIENTE                              ,;  // [4] cliente
				C5_LOJACLI                              ,;  // [5] loja do cliente
			    C5_DESCONT                              ,;  // [6] total desconto
			    C5_NOTA                                 ,;  // [7] num documento
			    C5_SERIE                                ,;  // [8] serie documento
			    C5_FRETE								,;  // [9] valor do frete
			    C5_MENNOTA                              ,;	// [10] Observações
			    C5_PEDCLI                               ,;	// [11] Observações
			    C5_XOPER					            ,;	// [12] Tipo de Operação				
			    SX5->X5_DESCRI				            ,;	// [13] Descrição da Operação								
			    C5_TABELA+"-"+DA0->DA0_DESCRI	        ,;	// [14] Cod Tabela + Descrição Tabela
			    cTpFrete						        ,;	// [15] Tipo de Frete
			    C5_FRETE						         }	// [16] Valor do frete								

//Posiciona o SA1 (Cliente)
DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial()+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.T.)

aDadosCli   := {SUBSTR(SA1->A1_NOME,1,40)      		 																				,;  // [1]Razão Social
				   AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA           																	,;  // [2]Código
				   Iif(Len(AllTrim(SA1->A1_ENDCOB))<5,AllTrim(SA1->A1_END) + " " + AllTrim(SA1->A1_BAIRRO),AllTrim(SA1->A1_ENDCOB)) ,;  // [3]Endereço
				   AllTrim(SA1->A1_MUN )                            																,;  // [4]Cidade
				   SA1->A1_EST                                      																,;  // [5]Estado
				   SA1->A1_CEP                                      																,;  // [6]CEP
				   SA1->A1_CGC                                      																,;  // [7]CGC
				   SA1->A1_TEL                              																		,;  // [8]FONE
				   SA1->A1_EMAIL                             																		,;  // [9]EMAIL
				   SA1->A1_INSCR                             																		,;  // [10]IE
				   SA1->A1_CONTATO                             																		,;   // [11]CONTATO
				   SA1->A1_TIPO                             																		}   // [12]TIPO

dbSelectArea("SA3")
dbSetOrder(1)
dbSeek(xFilial("SA3")+SC5->C5_VEND1)
If Found()
   cNomVen  := A3_NREDUZ
Else
   cNomVen  := "  "
Endif

//   cNomArq  := " "

Impress(oPrint,aDadosEmp,aDadosOrc,aDadosCli)

oPrint:Preview()     // Visualiza antes de imprimir
//oPrint:setup()     // Escolher a impressora
//   oPrint:Print()   // Imprime direto na impressora default do APx

oPrint:End()     // Finaliza Objeto
ms_flush() // desativar impressora

Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  IMPRESS ³ Autor ³ Alisson Alessandro    ³ Data ³ 14/06/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO ORCAMENTO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosOrc,aDadosCli)

LOCAL cCGC := IIF(SA1->A1_PESSOA == "J",substr(SA1->A1_CGC,1,2) +"."+substr(SA1->A1_CGC,3,3) +"."+ substr(SA1->A1_CGC,6,3) +"/"+ substr(SA1->A1_CGC,9,4) +"-"+substr(SA1->A1_CGC,13,2),substr(SA1->A1_CGC,1,3) +"."+substr(SA1->A1_CGC,4,3) +"."+ substr(SA1->A1_CGC,7,3) +"-"+ substr(SA1->A1_CGC,10,2))
Local nVlTotal := 0
Local nValIpi  := 0
Local nQuante  := 0
Local lCliente := .T.
Local nTotPed  := 0
Local i
Local nRecuo

//Parâmetros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)

Private oBrush      := TBrush():New("",4),;
		oPen     	:= TPen():New(0,5,),;
		oFont05     := TFont():New('Arial',,5,,.F.,,,,,.F. ),;
      	oFont06     := TFont():New('Arial',06,06,,.F.,,,,.T.,.F.),;
		oFont07     := TFont():New('Arial',07,07,,.F.,,,,.T.,.F.),;
      	oFont08     := TFont():New('Arial',08,08,,.F.,,,,.T.,.F.),;
      	oFont08n    := TFont():New('Arial',08,08,,.T.,,,,.T.,.F.),;
      	oFont09     := TFont():New('Arial',09,09,,.T.,,,,.T.,.F.),;
      	oFont10     := TFont():New('Arial',10,10,,.F.,,,,.T.,.F.),;
      	oFont10n    := TFont():New('Arial',10,10,,.T.,,,,.T.,.F.),;
      	oFont10a    := TFont():New('Arial',,10,,.t.,,,,,.f. ),;
      	oFont11     := TFont():New('Arial',11,11,,.F.,,,,.T.,.F.),;
      	oFont11n    := TFont():New('Arial',11,11,,.T.,,,,.T.,.F.),;
      	oFont12     := TFont():New('Arial',12,12,,.T.,,,,.T.,.F.),;
      	oFont12n    := TFont():New('Arial',12,12,,.F.,,,,.T.,.F.),;
      	oFont12a    := TFont():New('Arial',12,12,,.T.,,,,.T.,.F.),;
      	oFont12x    := TFont():New('Arial',12,12,,.T.,,,,.T.,.T.,.T.),;		  //underline e itálico
      	oFont13     := TFont():New('Arial',13,13,,.T.,,,,.T.,.F.),;
      	oFont14     := TFont():New('Arial',14,14,,.T.,,,,.T.,.F.),;
      	oFont15     := TFont():New('Arial',15,15,,.T.,,,,.T.,.F.),;
      	oFont18     := TFont():New('Arial',18,18,,.T.,,,,.T.,.T.),;
      	oFont16     := TFont():New('Arial',16,16,,.T.,,,,.T.,.F.),;
      	oFont20     := TFont():New('Arial',20,20,,.F.,,,,.T.,.F.),;
      	oFont22     := TFont():New('Arial',22,22,,.T.,,,,.T.,.F.)

nLinha      := 50   		// Controla a linha por extenso
lPrintDesTab:= .f. 			// Imprime a Descricao da tabela (a cada nova pagina)
Private  _nQtdReg := 0      // Numero de registros para intruir a regua
Private _cNomecomp := ""
lCabec := .T.

_nomeuser := substr(cUsuario,7,15)
PswOrder(2)
If PswSeek(_nomeuser,.T.)
   aRetUser := PswRet(1)
   _cNomecomp := aRetUser[1,04]
Endif


DbSelectArea("SC6")
DbSetOrder(1)
If DbSeek(xFilial("SC6")+cNumOrc,.T.)
	MaFisEnd()
	MaFisIni(;
		IIF(lCliente,aDadosOrc[4],),;  // 1-Codigo Cliente/Fornecedor
		IIF(lCliente,aDadosOrc[5],),; // 2-Loja do Cliente/Fornecedor
		"C",;	       // 3-C:Cliente , F:Fornecedor
		"N",;          // 4-Tipo da NF
		IIF(lCliente,aDadosCli[12],),; // 5-Tipo do Cliente/Fornecedor
		,;             // 6-Relacao de Impostos que suportados no arquivo
		,;             // 7-Tipo de complemento
		,;             // 8-Permite Incluir Impostos no Rodape .T./.F.
		,;             // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
		,;             // 10-Nome da rotina que esta utilizando a funcao
		,;		       // 11-Tipo de documento
		,IIF(lCliente,,)) // 12-Codigo e Loja do Prospect
//		,IIF(lCliente,,SUS->(US_COD+US_LOJA))) // 12-Codigo e Loja do Prospect
Endif

nMedDesc:= nQtdItem := nTotBru := nTotDesc := nTotLiq := 0

While SC6->C6_NUM == cNumOrc

	If lCabec

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Titulo do Relatorio³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SC6->C6_TES == '506'
				oPrint:Say(nLinha+040,800,OemToAnsi('PEDIDO DE ASSITÊNCIA')+ aDadosOrc[11],oFont20)
		Elseif SC6->C6_TES $ "507/508"
				oPrint:Say(nLinha+040,800,OemToAnsi('PEDIDO DE BONIFICAÇÃO')+ aDadosOrc[11],oFont20)
		Else
				oPrint:Say(nLinha+040,800,OemToAnsi('PEDIDO DE VENDA')+ aDadosOrc[11],oFont20)
		Endif

		nLinha += 150

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime o cabecalho da empresa. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box(nLinha,0050,nLinha+220,2300)
		cBitMap := GetSrvProfString("Startpath","")+"DANFE01.bmp"
		oPrint:SayBitmap(nLinha+10,070,cBitMap,500,200)			// Imprime logo da Empresa: comprimento X altura

		oPrint:Say(nLinha+10,600,AllTrim(Upper(aDadosEmp[1])),oFont12)
		oPrint:Say(nLinha+50,600,AllTrim(aDadosEmp[2]),oFont11)
		oPrint:Say(nLinha+90,600,AllTrim(aDadosEmp[3]),oFont11)
		oPrint:Say(nLinha+130,600,aDadosEmp[6]+" "+aDadosEmp[7],oFont11)
		oPrint:Say(nLinha+170,600,AllTrim(aDadosEmp[5]),oFont12)

		// imprime dados vendedor e orcamento no cabeçalho
		oPrint:Say(nLinha+010,1620,"No. Pedido: "					,oFont10a)
		oPrint:Say(nLinha+010,1850,aDadosOrc[1]						,oFont10a)
		oPrint:Say(nLinha+050,1620,"Vendedor..: "					,oFont10a)
		oPrint:Say(nLinha+050,1850,cNomVen							,oFont10a)
		oPrint:Say(nLinha+090,1620,"Emissão...: "					,oFont10a)
		oPrint:Say(nLinha+090,1850,DTOC(aDadosOrc[2])				,oFont10a)
		oPrint:Say(nLinha+130,1620,"Operação..: "					,oFont10a)
		oPrint:Say(nLinha+130,1850,aDadosOrc[12]+"-"+aDadosOrc[13]	,oFont10a)

		//ÚÄÄÄÄÄÄÄÄÄÄ¿
		//³Cliente   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÙ

		nLinha += 245 // 395

		oPrint:Box(nLinha,050,nLinha+220,2300)
		oPrint:Say(nLinha+15,0070,OemToAnsi('Cliente   :'),oFont12)
		oPrint:Say(nLinha+15,0450,AllTrim(aDadosCli[1]) + ' - ('+AllTrim(aDadosCli[2])+') - '+cCGC,oFont13)
		oPrint:Say(nLinha+065,0070,OemToAnsi('Endereço:'),oFont12)
		oPrint:Say(nLinha+065,0450,Alltrim(aDadosCli[3]),oFont11)
		oPrint:Say(nLinha+065,1750,OemToAnsi('IE:'),oFont12)
		oPrint:Say(nLinha+065,1930,aDadosCli[10],oFont11)
		oPrint:Say(nLinha+115,0070,OemToAnsi('Município/U.F.:'),oFont12)
		oPrint:Say(nLinha+115,0450,AllTrim(aDadosCli[4])+'/'+AllTrim(aDadosCli[5]),oFont11)
		oPrint:Say(nLinha+115,1150,OemToAnsi('Cep:'),oFont12)
		oPrint:Say(nLinha+115,1320,TransForm(aDadosCli[6],'@R 99.999-999'),oFont11)
		oPrint:Say(nLinha+165,0070,OemToAnsi('Fone:'),oFont12)
		oPrint:Say(nLinha+165,0450,ALLTRIM(aDadosCli[8]),oFont11)
		oPrint:Say(nLinha+165,1150,OemToAnsi('Email:'),oFont12)
		oPrint:Say(nLinha+165,1320,ALLTRIM(aDadosCli[9]),oFont11)
		oPrint:Say(nLinha+165,1750,OemToAnsi('Contato:'),oFont12)
		oPrint:Say(nLinha+165,1930,ALLTRIM(aDadosCli[11]),oFont11)   

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³PRODUTOS      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		nLinha += 250  // 645

		// box do titulo
		oPrint:Box(nLinha,050,nLinha+65,2300)
		oPrint:Say(nLinha+5,0900,OemToAnsi('ITENS DO PEDIDO'),oFont16)

		//sem os descontos
		oPrint:Say(nLinha+75,0070,'Item',oFont10a)
		oPrint:Say(nLinha+75,0170,'Descrição',oFont10a)
		//oPrint:Say(nLinha+75,1450,'NCM',oFont10a)
		oPrint:Say(nLinha+75,1000,'Qtde',oFont10a)
		oPrint:Say(nLinha+75,1150,'UM',oFont10a)
		oPrint:Say(nLinha+75,1250,'Vlr.Unit.Tab.',oFont10a)
		oPrint:Say(nLinha+75,1450,'% Desc.',oFont10a)
		oPrint:Say(nLinha+75,1650,'Vlr.Desc.',oFont10a)
		oPrint:Say(nLinha+75,1850,'Vlr.Unit.Li.',oFont10a)	
		oPrint:Say(nLinha+75,2050,'$',oFont10a)	
		oPrint:Say(nLinha+75,2150,'Vlr.Total',oFont10a)

		nLinha += 125

		lCabec := .F.
	Endif

	cUn 		:= POSICIONE("SB1",1,XFILIAL("SB1")+SC6->C6_PRODUTO,"B1_UM")
	cEspecif    := POSICIONE("SB1",1,XFILIAL("SB1")+SC6->C6_PRODUTO,"B1_ESPECIF")
	cDescAd 	:= POSICIONE("SB5",1,XFILIAL("SB5")+SC6->C6_PRODUTO,"B5_CEME")
	cDescProd 	:= alltrim(SC6->C6_PRODUTO)+"-"+alltrim(SC6->C6_DESCRI)+AllTrim(cDescAd)
//	cDescProd   := cDescAd + cEspecif
	nTamDesc    := 50

	//sem os descontos
	oPrint:Say(nLinha,0070,SC6->C6_ITEM											,oFont08)
	oPrint:Say(nLinha,0170,Substr(cDescProd,1,ntamDesc)							,oFont08)
	oPrint:Say(nLinha,1080,TransForm(SC6->C6_QTDVEN,'@E 999,999.99')			,oFont08,,,,1)
	oPrint:Say(nLinha,1150,SC6->C6_UM											,oFont08)		
	oPrint:Say(nLinha,1400,TransForm(SC6->C6_PRUNIT,'@E 999,999.9999')			,oFont08,,,,1)	    
	oPrint:Say(nLinha,1550,TransForm(SC6->C6_DESCONT,'@E 999,999,999.99')		,oFont08,,,,1)		// % desconto
	nMedDesc += SC6->C6_DESCONT
	nQtdItem ++
	oPrint:Say(nLinha,1760,TransForm(SC6->C6_VALDESC,'@E 999,999,999.99')		,oFont08,,,,1)		// valor do desconto
	oPrint:Say(nLinha,1960,TransForm(SC6->C6_PRCVEN,'@E 999,999.9999')			,oFont08,,,,1)
	oPrint:Say(nLinha,2050,SC6->C6_MOEDPV										,oFont08)			//Moeda	    
	oPrint:Say(nLinha,2280,TransForm(SC6->C6_VALOR,'@E 999,999,999.99')			,oFont08,,,,1)

	//imprime a 2a linha do produto
	If !Empty(Substr(cEspecif,1,180))
		oPrint:Say(nLinha+050,0170,Substr(cDescAd,1,180)						,oFont08)	
		nLinha+=50
	Endif

	MaFisAdd(;
		SC6->C6_PRODUTO,; // 1-Codigo do Produto ( Obrigatorio )
		SC6->C6_TES,;    // 2-Codigo do TES ( Opcional )
		SC6->C6_QTDVEN,; // 3-Quantidade ( Obrigatorio )
		SC6->C6_PRCVEN,; // 4-Preco Unitario ( Obrigatorio )
		0,;               // 5-Valor do Desconto ( Opcional )
		"",;              // 6-Numero da NF Original ( Devolucao/Benef )
		"",;              // 7-Serie da NF Original ( Devolucao/Benef )
		0,;               // 8-RecNo da NF Original no arq SD1/SD2
		0,;               // 9-Valor do Frete do Item ( Opcional )
		0,;               // 10-Valor da Despesa do item ( Opcional )
		0,;               // 11-Valor do Seguro do item ( Opcional )
		0,;               // 12-Valor do Frete Autonomo ( Opcional )
		SC6->C6_VALOR,;  // 13-Valor da Mercadoria ( Obrigatorio )
		0,;               // 14-Valor da Embalagem ( Opiconal )
		0,;               // 15-RecNo do SB1
		0)                // 16-RecNo do SF4
	
	MaFisRet(,"IT_TOTAL"  )

	nLinha += 050
	nVlTotal += SC6->C6_VALOR
	nTotDesc += SC6->C6_VALDESC
	nIpi := POSICIONE("SB1",1,XFILIAL("SB1")+SC6->C6_PRODUTO,"B1_IPI")

	//-- Toni Aguiar - TOTVS SIGA SERVICE em 29/03/2016
	//-- Só desstaca o IPI, caso não seja uma venda de serviço ou venda para zona franca - CF 6109
	//-- If Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_ISS")<>"N" .And. Alltrim(Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_CF"))<>"6109"
	If !Alltrim(Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_CF"))$"6109/6915/6916"
		nValIpi += SC6->C6_VALOR * nIpi /100
	Endif

	nQuante += SC6->C6_QTDVEN

	If nLinha >= 3100
		nLinha += 050
		oPrint:Say(nLinha,0100,"Continua...",oFont12)
		oPrint:EndPage()
		oPrint:StartPage()
		nLinha := 050
		lCabec := .T.
	EndIf

	DbSkip()
Enddo

nMedDesc := nMedDesc / nQtdItem

/*
	aTotais[1] := TransForm(MaFisRet(,"NF_VALIPI" ),"@E 999,999,999.99")
	aTotais[2] := TransForm(MaFisRet(,"NF_VALICM" ),"@E 999,999,999.99")
	aTotais[3] := TransForm(MaFisRet(,"NF_VALSOL" ),"@E 999,999,999.99")
	aTotais[4] := TransForm(MaFisRet(,"NF_TOTAL"  ),"@E 999,999,999.99")
*/

nTotPed := MaFisRet(,"NF_TOTAL")
nvalicms2 := MaFisRet(,"NF_VALICM")
ntotsnf := MaFisRet(,"NF_TOTAL")
MaFisEnd()

oPrint:Say(nLinha+075,0500,"TOTAL QUANTIDADES",oFont10n)
oPrint:Say(nLinha+075,1065,TransForm(nQuante,'@E 999,999.99'),oFont10,,,,1)

// box fechando os produtos depois da impressao de todos
oPrint:Box(700,050,nLinha+150,2300)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TOTAIS      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nLinha += 150

// box dos totais
oPrint:Box(nLinha,050,nLinha+125,2300)

nIcmsDispen := (nValIpi+nVlTotal)-nTotPed
//nIcmsDispen := (aDadosOrc[9]+nValIpi+nVlTotal)-nTotPed

oPrint:Say(nLinha+005,0070,"Sub.Total:     "+TransForm(nVlTotal+nTotDesc,'@E 999,999,999.99')							,oFont10n)
oPrint:Say(nLinha+005,0660,"Desconto Comercial: "+TransForm(aDadosOrc[6]+nTotDesc,'@E 999,999,999.99')					,oFont10n)
oPrint:Say(nLinha+005,1310,"Icms Dispens.: "+TransForm(nIcmsDispen,'@E 999,999.99')										,oFont10n)	

oPrint:Say(nLinha+075,0070,"Val IPI: "+TransForm(nValIpi,'@E 999,999.99')												,oFont10n)
oPrint:Say(nLinha+075,0660,"Outras Despesas: "+TransForm(SC5->C5_DESPESA+SC5->C5_SEGURO,'@E 999,999.99')				,oFont10n)
oPrint:Say(nLinha+075,1310,"Valor do Frete:"+TransForm(aDadosOrc[9],'@E 999,999.99')									,oFont10n) //linha com o valor do frete - incluido 27/11/2012
oPrint:Say(nLinha+075,1800,"TOTAL PEDIDO: "+TransForm(aDadosOrc[9]+nValIpi+nVlTotal-nIcmsDispen,'@E 999,999,999.99')	,oFont10n)

_vlrBruto := nVlTotal+aDadosOrc[9]-nIcmsDispen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³COND. DE PAGAMENTO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinha += 125

// box da cond. pgto
oPrint:Box(nLinha,0050,nLinha+65,1000)
oPrint:Say(nLinha+5,0070,OemToAnsi('CONDIÇÕES DE PAGAMENTO'),oFont16)

// Buscando as formas de pagamento informadas no orçamento
dbSelectArea("SE4")
DbSetOrder(1)
DbSeek(xFilial("SE4")+SC5->C5_CONDPAG,.T.)
oPrint:Say(nLinha+100,0090,"Código: "+SC5->C5_CONDPAG+" - "+SE4->E4_DESCRI,oFont10)
//oPrint:Say(nLinha+100,0390,SE4->E4_DESCRI,oFont10)
//oPrint:Say(nLinha+100,0690,SE4->E4_FORMA,oFont10)
nLinha += 50
oPrint:Say(nLinha+100,0090,"Datas de Vencimentos"	,oFont10n)
oPrint:Say(nLinha+100,0480,"Vl. Programado"			,oFont10n)
nLinha += 50
nRecuo := 30

oPrint:Say(nLinha-000,1320,"PEDIDO SUJEITO A APROVAÇÃO DE CRÉDITO"	,oFont12x)

//Array com a condição de pagamento.
aFin := condicao(_vlrBruto,SC5->C5_CONDPAG,0,ddatabase) // retorno do array {vencimento, valor}

For i:=1 to len(aFin)
	oPrint:Say(nLinha+100,0090,DTOC(aFin[i,1])							,oFont10n) //vencimento
	oPrint:Say(nLinha+100,0480,Transform(aFin[i,2],'@E 999,999,999.99')	,oFont10n) //valor
	nLinha += 50
	nRecuo += 50
Next

// box fechando cond. pgto
oPrint:Box(nLinha-nRecuo,050,nLinha+100,1000)
nLinha += 50

// box condições do fornecimento
oPrint:Box(nLinha+060,0050,nLinha+160,2300) //enquadrando o nome condições de fornecimento
oPrint:Say(nLinha+085,0070,OemToAnsi('CONDIÇÕES DE FORNECIMENTO'),oFont16)
nLinha += 080

//Condições do fornecimento - Coluna 01
oPrint:Box(nLinha+090,0050,nLinha+380,2300)
//oFont10,,,,1) 0 - Padrão- Alinhado à esquerda.1 - Alinhado à direita.2 - Centraliza o texto.
oPrint:Say(nLinha+110,0080,OemToAnsi('Prazo de Pagamento: ')		,oFont10n)
oPrint:Say(nLinha+110,0490,SC5->C5_CONDPAG+" - "+SE4->E4_DESCRI		,oFont10)
oPrint:Say(nLinha+160,0080,OemToAnsi('Validade da Proposta:')		,oFont10n)
oPrint:Say(nLinha+160,0490,DTOC(SC5->C5_XVLDPRO)					,oFont10)
oPrint:Say(nLinha+210,0080,OemToAnsi('Moeda: ')						,oFont10n)
cDesMoeda := IIF(SC5->C5_MOEDA == 1, "REAL","DOLAR")
oPrint:Say(nLinha+210,0490,STRZERO(SC5->C5_MOEDA,2)+"-"+cDesMoeda	,oFont10)
oPrint:Say(nLinha+260,0080,OemToAnsi('Tipo Cobrança.......: ')		,oFont10n)
oPrint:Say(nLinha+260,0490,SC5->C5_XTIPCOB							,oFont10)

//Condições do fornecimento - Coluna 02
oPrint:Say(nLinha+110,0950,OemToAnsi('Tabela..............: ')		,oFont10n)
oPrint:Say(nLinha+110,1320,aDadosOrc[14]							,oFont10)
oPrint:Say(nLinha+160,0950,OemToAnsi('Desconto.........: ')			,oFont10n)
oPrint:Say(nLinha+160,1320,Transform(nMedDesc, "@E 99.99")+'%'		,oFont10) //cálculo da média de desconto em todos os itens do pedido
oPrint:Say(nLinha+210,0950,OemToAnsi('Início Entrega...: ')			,oFont10n)
oPrint:Say(nLinha+210,1320,DTOC(SC5->C5_XINIENT)					,oFont10)
oPrint:Say(nLinha+260,0950,OemToAnsi('Limite Entrega...: ')			,oFont10n)
oPrint:Say(nLinha+260,1320,DTOC(SC5->C5_XLIMENT)					,oFont10)
oPrint:Say(nLinha+310,0950,OemToAnsi('Condições Entrega: ')			,oFont10n)
oPrint:Say(nLinha+310,1320,SC5->C5_XCONENT							,oFont10)

//Condições do fornecimento - Coluna 03

aRetBox := RetSx3Box( Posicione('SX3', 2, 'C5_XTPVLFR', 'X3CBox()' ),,, Len(SC5->C5_XTPVLFR) )
cTpVlFr := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == SC5->C5_XTPVLFR} ), 3 ])
nVlInfF := 0

IF SC5->C5_XTPVLFR $ "2/3" //1 - POR TONELADA || 2 - VALOR || 3 - FROTA
	nVlInfF := aDadosOrc[16]
Else
	DbSelectArea("GXS")
	DbSetOrder(1)
	DbSeek(xFilial("GXS")+SC5->C5_XCODRE)

	If GXS->GXS_XTIPOF == "1"  //1 - FRETE PESO || 2 - CARGA FECHADA
		nVlInfF := GXS->GXS_FRTPES
	Else
		Alert("Conflito: Informado por tonelada no pedido e não existe frete por peso na requisição do frete","GFE|TMS")
	Endif

Endif

oPrint:Say(nLinha+160,1580,OemToAnsi('Tipo Frete....: ')			,oFont10n)
oPrint:Say(nLinha+160,1890,aDadosOrc[15]							,oFont10)
oPrint:Say(nLinha+210,1580,OemToAnsi('Tp Valor Frete: ')			,oFont10n)
oPrint:Say(nLinha+210,1890,cTpVlFr									,oFont10)
oPrint:Say(nLinha+260,1580,OemToAnsi('Valor de Frete: ')			,oFont10n)
oPrint:Say(nLinha+260,1890,Transform(nVlInfF,'@E 999,999,999.99')	,oFont10)

nLinha += 280

// box dados p/ depósito - quadro 01
oPrint:Box(nLinha+100,0050,nLinha+480,0600)
oPrint:Say(nLinha+130,0080,OemToAnsi('Dados para depósito')		,oFont14)
oPrint:Say(nLinha+180,0080,OemToAnsi('Banco do Brasil')			,oFont14)	
oPrint:Say(nLinha+230,0080,OemToAnsi('AG.: 0895-8')				,oFont14)		
oPrint:Say(nLinha+280,0080,OemToAnsi('C/C: 3493-2')				,oFont14)			
oPrint:Say(nLinha+330,0080,OemToAnsi('Cod. Identificador: ')	,oFont14)			
oPrint:Say(nLinha+380,0080,OemToAnsi('CPF Depositante.')		,oFont14)				

// box dados p/ depósito - quadro 02
oPrint:Box(nLinha+100,0600,nLinha+480,1650)
//oFont10,,,,1) 0 - Padrão- Alinhado à esquerda.1 - Alinhado à direita.2 - Centraliza o texto.
oPrint:Say(nLinha+130,1125,OemToAnsi('Após vencimento, acréscimo de 3% de multa mais 1,8% de juros ao mês.')		,oFont08n,,,,2) //centralizado
oPrint:Say(nLinha+180,1125,OemToAnsi('Nos casos em que o pagamento for realizado por meio de cheque a entrega')		,oFont08,,,,2)	
oPrint:Say(nLinha+230,1125,OemToAnsi('do produto está condicionada a compensação bancária do mesmo.')				,oFont08,,,,2)		
oPrint:Say(nLinha+280,1125,OemToAnsi('Na hipótese de desistência da compra dos produtos pelo comprador, este')		,oFont08,,,,2)			
oPrint:Say(nLinha+330,1125,OemToAnsi('fica sujeito ao pagamento de uma multa não compensatória de 15% (quinze')		,oFont08,,,,2)			
oPrint:Say(nLinha+380,1125,OemToAnsi('por cento) sobre o valor deste pedido, sem prejuízo da vendedora cobrar')		,oFont08,,,,2)				
oPrint:Say(nLinha+430,1125,OemToAnsi('perdas e danos diretos devidamente comprovados.')								,oFont08,,,,2)				

// box dados p/ depósito - quadro 03 .
oPrint:Box(nLinha+100,1650,nLinha+480,2300)
oPrint:Say(nLinha+130,1660,OemToAnsi('Caro cliente,											')	,oFont07)
oPrint:Say(nLinha+160,1660,OemToAnsi('Para que seja possível agilizarmos seu atendimento, 	')	,oFont07)	
oPrint:Say(nLinha+190,1660,OemToAnsi('é importante que seja efetuado o agendamento prévio 	')	,oFont07)		
oPrint:Say(nLinha+220,1660,OemToAnsi('de cada embarque.										')	,oFont07)
oPrint:Say(nLinha+250,1660,OemToAnsi('O agendamento deverá ser enviado ao e-mail: 			')	,oFont07)			
oPrint:Say(nLinha+300,1660,OemToAnsi('comercial@risa.com, com as informações abaixo:		')	,oFont07)			
oPrint:Say(nLinha+330,1660,OemToAnsi('- Data do embarque:									')	,oFont07)				
oPrint:Say(nLinha+360,1660,OemToAnsi('- Nome do Motorista:									')	,oFont07)				
oPrint:Say(nLinha+390,1660,OemToAnsi('- Placa do Veículo:									')	,oFont07)					
oPrint:Say(nLinha+420,1660,OemToAnsi('- No. Pedido:											')	,oFont07)						
oPrint:Say(nLinha+450,1660,OemToAnsi('- Produto a ser embarcado:							')	,oFont07)							

//Quebra a página
If nLinha > 2500
	oPrint:Say(nLinha+600,0910,OemToAnsi('Continua...'),oFont12)
	oPrint:EndPage() // Finaliza a página
	oPrint:StartPage()
	nLinha := -500
Endif

// box observações gerais.
oPrint:Say(nLinha+500,0910,OemToAnsi('OBSERVAÇÕES GERAIS'),oFont16)
oPrint:Box(nLinha+580,0050,nLinha+0900,2300)
oPrint:Say(nLinha+600,0080,MEMOLINE(SC5->C5_OBS,100,1)					,oFont10)
oPrint:Say(nLinha+650,0080,MEMOLINE(SC5->C5_OBS,100,2)					,oFont10)
oPrint:Say(nLinha+700,0080,MEMOLINE(SC5->C5_OBS,100,3)					,oFont10)
oPrint:Say(nLinha+750,0080,MEMOLINE(SC5->C5_OBS,100,4)					,oFont10)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ASSINATURA   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nLinha += 1000
oPrint:Say(nLinha,0070,OemToAnsi('ASS. Cliente:'),oFont12)
oPrint:Say(nLinha,0350,'__________________________________',oFont12n)

oPrint:Say(nLinha,1170,OemToAnsi('ASS. Representante:'),oFont12)
oPrint:Say(nLinha,1550,'_______________________________',oFont12n)
oPrint:Say(nLinha+50,1550,AllTrim(aDadosEmp[1]),oFont08)


// box RODAPÉ
nLinha += 150
//oPrint:Say(nLinha,0100,"OBS: ",oFont12)
/*
		nCol := Len(Alltrim(aDadosOrc[10]))
		If nCol > 140
		oPrint:Say(nLinha+050,0100,Substr(aDadosOrc[10],1,140),oFont10)
		nLinha+=50
		oPrint:Say(nLinha+050,0100,Substr(aDadosOrc[10],141),oFont10)
		Else
		oPrint:Say(nLinha+050,0100,aDadosOrc[10],oFont10)
		Endif
*/
//oPrint:Say(nLinha+100,0100,"Data de Solicitação: "+DTOC(SC5->C5_DTSOLIC),oFont10)

//	oPrint:Say(nLinha+100,0100,aDadosOrc[13]                              ,oFont10)
//	oPrint:Say(nLinha+150,0100,aDadosOrc[14]                              ,oFont10)

//_i:=0
//_i+=If(!Empty(aDadosOrc[10]), 50, 0)
//nLinha += 200+_i

oPrint:Say(nLinha,0100," NÃO É  VALIDO COMO DOCUMENTO FISCAL   " 	    	,oFont12)
//oPrint:Say(nLinha,1350,"ORÇAMENTO VALIDO ATÉ :"    							,oFont12)
//oPrint:Say(nLinha,1950, DTOC(aDadosOrc[2] + 3) 	  	         				,oFont15)
oPrint:Say(nLinha+050,0100," EXIJA SEMPRE  O DOCUMENTO FISCAL	   " 	    ,oFont10)

oPrint:EndPage() // Finaliza a página

Return Nil
