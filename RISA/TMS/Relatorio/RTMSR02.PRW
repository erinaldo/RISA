#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "FWPrintSetup.ch"


#DEFINE CRLF Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ RTMSR02  ³ Autor ³ Fabio Costa        ³ Data ³ 08/07/2014  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ IMPRESSAO COLETA TMS    									   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R943C001		                                         	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//|DT5 - Solicitação de Coleta
//|DT6 - Documento de Transporte
//|DUD - Movimento de Viagem
//|DUE - Cadastro de Solicitantes
//|DUL - Endereços Solicitantes
//|DUM - Itens da Solicitação de Coleta
//|DTQ - Viagem de Coleta


User Function RTMSR02()
	
	Local _aArea 	 := GetArea()
	
	Local _aAreaDT5  := DT5->(GetArea()) //Coleta
	Local _aAreaDUM  := DUM->(GetArea()) //Itens da Coleta
	Local _aAreaDUD  := DUD->(GetArea()) //Movimento de Viagem
	
	Local lOk		 := .F.
	Local lRet	     := .F.
	Local cPerg      := "RTMR02" //"R943C001"
	
	If !IsInCallStack( 'TMSA460' )
		//AjustaSX1(cPerg)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica as perguntas selecionadas                             ³
		//³--------------------------------------------------------------- ³
		//³ mv_par01	// Coleta Inicial                                  ³
		//³ mv_par02	// Coleta Final    	                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If Pergunte(cPerg,.T.)
			lOk := .T.
		EndIf
	Else
		Pergunte(cPerg,.F.)
		mv_par01 := DT5->DT5_DOC
		mv_par02 := DT5->DT5_DOC
		lOk := .T.
	EndIf
	
	If !lOk
		Return Nil
	Else
		Processa( {|lEnd|lRet := R4305QRY()}, "","Filtrando as Informações ...", .F. )
	EndIf
	
	If lRet
		Processa( {|lEnd| R4305IMP()}, "","Imprimindo, Aguarde ...", .F. )
	Else
		Aviso("AVISO","Não há dados para impressão!!!",{"Verifique"})
	EndIf
	
	// FECHA AREA DE TRABALHO DAS QUERYS
	If Select("COLQRY") > 0
		COLQRY->(DbCloseArea())
	EndIf
	
	RestArea(_aAreaDT5)
	RestArea(_aAreaDUM)
	RestArea(_aArea)
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ R4305QRY ³ AUTOR ³ Fabio Costa           ³ DATA ³ 28.05.13   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Tela Seleção do Arquivo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ 43-SIGATMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R4305QRY()
	
	Local cQuery 	:= ''
	Local lQry		:= .F.
	
	ProcRegua(20)
	
	If Select("COLQRY") > 0
		COLQRY->(DbCloseArea())
	EndIf
	
	cQuery := " SELECT DISTINCT DT5.DT5_FILORI, DT5.DT5_NUMSOL, DT5.DT5_DATSOL, DT5.DT5_HORSOL, DT5.DT5_SEQEND, DT5.DT5_CODOBS, " + CRLF
	cQuery += " DT5.DT5_DDD, DT5.DT5_TEL, DT5.DT5_CODSOL, DT5.DT5_DATPRV, DT5.DT5_HORPRV, DT5.DT5_FILDOC, DT5.DT5_DOC, DT5.DT5_SERIE, " + CRLF
	cQuery += " DUE.DUE_NOME, DUE.DUE_END, DUE.DUE_BAIRRO, DUE.DUE_MUN, DUE.DUE_EST, DUE.DUE_CEP, DUE.DUE_CGC, DUE.DUE_INSCR,  " + CRLF
	cQuery += " DUE.DUE_CONTAT, DUE.DUE_PONREF, DUE.DUE_CDRSOL, DUE.DUE_CODCLI, DUE.DUE_LOJCLI, " + CRLF
	cQuery += " DTR.DTR_FILORI, DTR.DTR_VIAGEM, DTR.DTR_CODVEI, DTR.DTR_CODRB1, DTR.DTR_CODRB2, DTR.DTR_CODRB3, " + CRLF
	cQuery += " DA4.DA4_NOME, DA4.DA4_RG, SC5.C5_FILIAL, SC5.C5_NUM, DF1.DF1_XCODRE, DF1.DF1_XCDVEI,DF1.DF1_XRBQ1, DF1.DF1_XRBQ2,DF1.DF1_XRBQ3, DF1.DF1_XCDMOT" + CRLF
	cQuery += "	FROM "
	cQuery += 		RetSqlName("DT5") + " DT5 " +CRLF
	cQuery += " INNER JOIN " + RetSqlName("DUE") + " DUE ON DUE.DUE_FILIAL = '"+xFilial("DUE")+"'  AND DUE.DUE_CODSOL = DT5.DT5_CODSOL " +CRLF
	cQuery += "              AND DUE.D_E_L_E_T_ = '' " +CRLF
	cQuery += " INNER JOIN " + RetSqlName("DUD") + " DUD ON DUD.DUD_FILIAL = '"+xFilial("DUD")+"' AND DUD.DUD_FILDOC = DT5.DT5_FILDOC " +CRLF
	cQuery += "                 AND DUD.DUD_DOC = DT5.DT5_DOC AND DUD.DUD_SERIE = DT5.DT5_SERIE AND DUD.D_E_L_E_T_ = '' " +CRLF
	cQuery += " LEFT OUTER JOIN "+RetSqlName("DTQ")+" DTQ ON DTQ.DTQ_FILIAL = '"+xFilial("DTQ")+"' AND DTQ.DTQ_FILORI = DUD.DUD_FILORI " +CRLF
	cQuery += "                 AND DTQ.DTQ_VIAGEM = DUD.DUD_VIAGEM AND DTQ.D_E_L_E_T_ = '' " +CRLF
	cQuery += " LEFT OUTER JOIN "+RetSqlName("DTR")+" DTR ON DTR.DTR_FILIAL = '"+xFilial("DTR")+"' AND DTR.DTR_FILORI = DUD.DUD_FILORI  " +CRLF
	cQuery += "                 AND DTR.DTR_VIAGEM = DUD.DUD_VIAGEM AND DTR.D_E_L_E_T_ = '' " +CRLF
	cQuery += " LEFT OUTER JOIN "+RetSqlName("DUP")+" DUP ON DUP.DUP_FILIAL = '" + xFilial("DUP") + "' AND DUP.DUP_FILORI = DUD.DUD_FILORI  " +CRLF
	cQuery += "                 AND DUP.DUP_VIAGEM = DUD.DUD_VIAGEM AND DUP.D_E_L_E_T_ = '' " +CRLF
	cQuery += " LEFT OUTER JOIN "+RetSqlName("DA4")+" DA4 ON DA4.DA4_FILIAL = '" + xFilial("DA4") + "' AND  DA4.DA4_COD = DUP.DUP_CODMOT " +CRLF
	cQuery += "                 AND DA4.D_E_L_E_T_ = '' " +CRLF
	cQuery += " LEFT OUTER JOIN "+RetSqlName("DF1")+" DF1 ON DF1.DF1_FILIAL = '" + xFilial("DF1") + "' AND  DF1.DF1_FILDOC = DT5.DT5_FILDOC " +CRLF
	cQuery += "                 AND  DF1.DF1_DOC = DT5.DT5_DOC AND  DF1.DF1_SERIE = DT5.DT5_SERIE   AND DF1.D_E_L_E_T_ = '' " +CRLF
	cQuery += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 ON SC5.C5_XCODRE = DF1.DF1_XCODRE AND DF1.DF1_XCODRE <> '' " +CRLF
	cQuery += "                 AND SC5.D_E_L_E_T_ = '' " +CRLF
	cQuery += " WHERE DT5.D_E_L_E_T_ = ''   " +CRLF
	cQuery += " AND DT5.DT5_FILORI = '"+cFilAnt+"' " +CRLF ////TBETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +CRLF
	cQuery += " AND DT5.DT5_NUMSOL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
	
	ConOut(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"COLQRY")
	
	If !COLQRY->(Eof())
		lQry := .T.
	EndIf
	
Return lQry

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ F43R004IMP ³ AUTOR ³ Fabio Costa         ³ DATA ³ 22.05.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Processamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ 43-SIGATMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R4305IMP()
	
	/*******************************************************\
	Fontes disponivies no objeto de impressão TFont
	cFntName == "courier new"
	cFntName == "arial"
	cFntName == "arial black"
	cFntName == "times new roman"
	cFntName == "fw microsiga"
	cFntName == "andale mono"
	cFntName == "Courier New"  --> Fonte padrão Courier New
	\*******************************************************/
	
	Private oFatura
	//Private oBrush1 	:= TBrush():New( , CLR_GREEN)
	Private oBrush1 	:= TBrush():New( , RGB(86,98,36),,)
	Private oBrush2 	:= TBrush():New( , RGB(247,247,247),,)
	Private oBrush3 	:= TBrush():New( , RGB(255,255,223),,)
	Private oFont06  	:= TFont():New("Times New Roman",,06,,.F.,,,,,.F.,.F.)// 3
	Private oFont06N 	:= TFont():New("Times New Roman",,06,,.T.,,,,,.F.,.F.)// 2
	Private oFont08  	:= TFont():New("Times New Roman",,08,,.F.,,,,,.F.,.F.)// 4
	Private oFont08N 	:= TFont():New("Arial",,08,,.T.,,,,,.F.,.F.)// 5
	Private oFont09  	:= TFont():New("Arial",,09,,.F.,,,,,.F.,.F.)// 7
	Private oFont09N 	:= TFont():New("Arial",,09,,.T.,,,,,.F.,.F.)// 6
	Private oFont10  	:= TFont():New("Arial",,10,,.F.,,,,,.F.,.F.)// 8
	Private oFont10N 	:= TFont():New("Arial",,10,,.T.,,,,,.F.,.F.)// 8
	Private oFont10A	:= TFont():New("Arial Black",,10,,.F.,,,,,.F.,.F.)// 10
	Private oFont11  	:= TFont():New("Arial",,11,,.F.,,,,,.F.,.F.)// 9
	Private oFont11N 	:= TFont():New("Arial",,11,,.T.,,,,,.F.,.F.)// 11
	Private oFont11N1	:= TFont():New("Andale Mono",,11,,.T.,,,,,.F.,.F.)// 11
	Private oFont12  	:= TFont():New("Courier New",,12,,.F.,,,,,.F.,.F.)// 10
	Private oFont12N 	:= TFont():New("Courier New",,12,,.T.,,,,,.F.,.F.)// 12
	Private oFont12A	:= TFont():New("Arial",,12,,.T.,,,,,.F.,.F.)// 10
	Private oFont13  	:= TFont():New("Andale Mono",,11,,.F.,,,,,.F.,.T.)// 10
	Private oFont13N 	:= TFont():New("Arial",,13,,.T.,,,,,.F.,.F.)// 10
	Private oFont13A	:= TFont():New("Arial Black",,13,,.F.,,,,,.F.,.F.)// 10
	Private oFont14  	:= TFont():New("Courier New",,14,,.F.,,,,,.F.,.F.)// 10
	Private oFont14N 	:= TFont():New("Arial",,14,,.T.,,,,,.F.,.F.)// 12
	Private oFont14A	:= TFont():New("Arial Black",,14,,.F.,,,,,.F.,.F.)// 14
	Private oFont16   	:= TFont():New("Calibri",,16,,.F.,,,,,.F.,.F.)// 10
	Private oFont16N 	:= TFont():New("Arial",16,16,,.T.,,,,.F.,.F.)// 12
	Private oFont16A 	:= TFont():New("Arial Black",16,16,,.T.,,,,.F.,.F.)// 12
	Private oFont18  	:= TFont():New("Times New Roman",,18,,.T.,,,,,.F.,.F.)// 12
	Private oFont18N 	:= TFont():New("Arial",,18,,.T.,,,,,.F.,.F.)// 12
	Private oFont18A 	:= TFont():New("Arial Black",18,18,,.T.,,,,.F.,.F.)// 12
	Private oFont20  	:= TFont():New("Times New Roman",,20,,.T.,,,,,.F.,.F.)// 12
	Private oFont20N 	:= TFont():New("Arial",,20,,.T.,,,,,.F.,.F.)// 12
	Private oFont22  	:= TFont():New("Times New Roman",,22,,.T.,,,,,.F.,.F.)// 12
	Private oFont22N 	:= TFont():New("Arial",,22,,.T.,,,,,.F.,.F.)// 12
	Private cBcoCob 	:= ''
	Private lPreView
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro 1 IDENTIFICACAO DO EMITENTE                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	DbSelectArea("COLQRY")
	COLQRY->(DbGoTop())
	
	ProcRegua(COLQRY->(RecCount()))
	
	While !COLQRY->(Eof())
		
		IncProc('COLETA: '+COLQRY->DT5_NUMSOL)
		
		R4305CAB()  //Cabeçalho da Coleta

		R4305COL()  //Itens da Coleta
		
		DT5->(DbSetOrder(1))
		If  DT5->(DbSeek(xFilial("DT5") + COLQRY->DT5_FILORI + COLQRY->DT5_NUMSOL))
			RecLock("DT5", .F.)
			DT5_FIMP := "1"
			MsUnlock()
		EndIf
		
		DbSelectArea("COLQRY")
		COLQRY->(DbSkip())
		
	EndDo
	//_nomearq	:=	"COLETA-" + ALLTRIM(COLQRY->DT5_NUMSOL)+'_'+_cTime
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Finaliza a Impressão                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lPreview
		oFatura:Preview()
	EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³  R4305CAB   ³ AUTOR ³ Fabio Costa        ³ DATA ³ 22.05.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Processamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ 43-SIGATMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R4305CAB()
	
	Local cStartPath := GetSrvProfString("Startpath","")
	Local cLogo  	 := cStartPath + "risa.JPG"  //	:= GetSrvProfString("Startpath","") + "FATURA01.JPG"
	Local cFilMa := cFilAnt //Filial Corrente

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializacao do objeto grafico                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If oFatura == Nil
		
		lPreview 	:= .T.
		
		_cTime := Transform(Time(),"99:99:99")
		_cTime := StrTran( _cTime , ":","" )
		
		oFatura	:= FWMSPrinter():New("COLETA-" + ALLTRIM(COLQRY->DT5_NUMSOL)+'_'+_cTime, IMP_PDF)
		oFatura:SetResolution(78) //Tamanho estipulado para a Danfe
		oFatura:SetPortrait()
		oFatura:SetPaperSize(9)
		oFatura:SetMargin(60,60,60,60)
		
		//oFatura:Setup() // 20-01-14- inibido.
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializacao da pagina do objeto grafico                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oFatura:StartPage()
	
	oFatura:SayBitmap(0000,0002,cLogo,0920,0190)
	
	oFatura:Say(0111,1975,"N° ",oFont22N)
	oFatura:Say(0111,2085,COLQRY->DT5_NUMSOL,oFont22N)
	
	// DADOS DA FILIAL
	dbSelectArea("SM0")
	
	If cFilAnt = '01 01'
		oFatura:Say(0030,1170,"MATRIZ :"+ Alltrim(SM0->M0_FILIAL) + " - " + Alltrim(SM0->M0_CIDENT),oFont13A)
	Else
		oFatura:Say(0030,1170,"FILIAL :"+ Alltrim(SM0->M0_FILIAL) + " - " + Alltrim(SM0->M0_CIDENT),oFont13A)
	EndIf
	
	//oFatura:Say(0080,0930,SM0->M0_ENDCOB+'-'+AllTrim(SM0->M0_BAIRCOB)+'-'+AllTrim(SM0->M0_CIDENT),oFont09N)
	oFatura:Say(0080,0930,Rtrim(SM0->M0_ENDENT) + '-' + AllTrim(SM0->M0_BAIRENT) + '-' + Rtrim(SM0->M0_CIDENT),oFont09N)
	oFatura:Say(0120,0930,"CEP " + Transform(SM0->M0_CEPENT,"@R 99999-999") + '- TEL: ' + SM0->M0_TEL + '- FAX: ' + SM0->M0_FAX,oFont09N)
	oFatura:Say(0160,0930,"CNPJ N° " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") + " -  I.ESTADUAL N° " + Alltrim(SM0->M0_INSC) + " - I.MUNICIPAL N° " + Alltrim(SM0->M0_INSCM),oFont09N)
	
	//EMISSAO
	//------------------------------
	//oFatura:Fillrect( {0310,0020,0380,0350}, oBrush2, "-2")
	oFatura:Say(0234,1680,"Emissão:",oFont14N)
	oFatura:Say(0234,1880,Substr(COLQRY->DT5_DATSOL,7,2)+'/'+Substr(COLQRY->DT5_DATSOL,5,2)+'/'+Substr(COLQRY->DT5_DATSOL,1,4),oFont14)
	oFatura:Say(0234,2160,'Hora:',oFont14N)
	oFatura:Say(0234,2290,Substr(COLQRY->DT5_HORSOL,1,2) + ':' + Substr(COLQRY->DT5_HORSOL,3,2),oFont14)
	//-------------------------------------------------------
	
	//NUMERO DA COLETA
	oFatura :Fillrect( {00260,0020,0330,2410}, oBrush1, "-2")
	//oFatura:Say(0310,0925,"O R D E M   D E   C O L E T A ",oFont18N,,RGB(255,255,255))
	
	//--17-08-15,vl. cnf. Marcelo -
	oFatura:Say(0310,0925-200,"O R D E M   D E   C A R R E G A M E N T O",oFont18N,,RGB(255,255,255))
	
	//SOLICITANTE
	//OFatura:Box(0350,0020,00750,2330/2)
	oFatura:Say(0385,0020,"Solicitante  ",oFont14N)
	oFatura:Say(0385,0270,":",oFont14N)
	oFatura:Say(0385,0310,COLQRY->DUE_NOME,oFont14)
	
	oFatura:Say(0385,1205,"CNPJ:        ",oFont14N)
	oFatura:Say(0385,1445,":",oFont14N)
	If Len(COLQRY->DUE_CGC) == 14
		cCgcCli := Transform(COLQRY->DUE_CGC,"@r 99.999.999/9999-99")
	Else
		cCgcCli := Transform(COLQRY->DUE_CGC,"@r 999.999.999-99")
	EndIf
	oFatura:Say(0385,1485,cCgcCli,oFont14)
	
	// ENDEREÇO DE COLETA
	cEnd	:= COLQRY->DUE_END
	cBairro := COLQRY->DUE_BAIRRO
	cCep	:= COLQRY->DUE_CEP
	cMun	:= COLQRY->DUE_MUN
	cEst	:= COLQRY->DUE_EST
	
	//SEQUENCIA DE ENDEREÇO
	If !Empty(COLQRY->DT5_SEQEND)
		
		If Select("DULQRY") > 0
			DULQRY->(DbCloseArea())
		EndIf
		
		cQuery := " SELECT DUL_END, DUL_BAIRRO, DUL_MUN, DUL_EST, DUL_CEP "
		cQuery += "	FROM " + RetSqlName("DUL") + " DUL "
		cQuery += "  WHERE  "
		cQuery += "    DUL_FILIAL = '" + xFilial('DUL') + "'"
		cQuery += "	   AND DUL_DDD    = '" + COLQRY->DT5_DDD + "' "
		cQuery += "	   AND DUL_TEL    = '" + COLQRY->DT5_TEL + "' "
		cQuery += "	   AND DUL_SEQEND = '" + COLQRY->DT5_SEQEND + "' "
		cQuery += "	   AND DUL.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery( cQuery )
		ConOut(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"DULQRY")
		
		While !DULQRY->(Eof())
			cEnd	:= DULQRY->DUL_END
			cBairro := DULQRY->DUL_BAIRRO
			cCep	:= DULQRY->DUL_CEP
			cMun	:= DULQRY->DUL_MUN
			cEst	:= DULQRY->DUL_EST
			
			DULQRY->(dBSkip())
		EndDo
		
	EndIf
	
	oFatura:Say(0465,0030,"Endereço     ",oFont14N)
	oFatura:Say(0465,0270,":",oFont14N)
	oFatura:Say(0465,0310,cEnd,oFont14)
	
	oFatura:Say(0465,1205,"I.Estadual   ",oFont14N)
	oFatura:Say(0465,1445,":",oFont14N)
	oFatura:Say(0465,1485,COLQRY->DUE_INSCR,oFont14)
	
	oFatura:Say(0545,0030,"Bairro       ",oFont14N)
	oFatura:Say(0545,0270,":",oFont14N)
	oFatura:Say(0545,0310,cBairro,oFont14)
	
	oFatura:Say(0545,1205,"CEP           ",oFont14N)
	oFatura:Say(0545,1445,":",oFont14N)
	oFatura:Say(0545,1485,cCep,oFont14)
	
	oFatura:Say(0625,0030,"Municipio    ",oFont14N)
	oFatura:Say(0625,0270,":",oFont14N)
	oFatura:Say(0625,0310,cMun,oFont14)
	
	oFatura:Say(0625,1205,"UF           ",oFont14N)
	oFatura:Say(0625,1445,":",oFont14N)
	oFatura:Say(0625,1485,cEst,oFont14)
	
	oFatura:Say(0705,0030,"Contato      ",oFont14N)
	oFatura:Say(0705,0270,":",oFont14N)
	oFatura:Say(0705,0310,COLQRY->DUE_CONTAT,oFont14)
	
	oFatura:Say(0705,1205,"Telefone     ",oFont14N)
	oFatura:Say(0705,1445,":",oFont14N)
	oFatura:Say(0705,1485,'('+ Alltrim(COLQRY->DT5_DDD)+')' + ' ' + COLQRY->DT5_TEL,oFont14)
	
	oFatura:Say(0780,0030,"Pedido nº",oFont14N)
	oFatura:Say(0780,0270,":",oFont14N)
	oFatura:Say(0780,0310,COLQRY->C5_FILIAL + ' - ' + COLQRY->C5_NUM ,oFont14)

	oFatura:Say(0780,1205,"Requisição Frete nº",oFont14N)
	oFatura:Say(0780,1565,":",oFont14N)
	oFatura:Say(0780,1605,COLQRY->DF1_XCODRE,oFont14)
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ 	R4305COL   ³ AUTOR ³ Fabio Costa        ³ DATA ³ 22.05.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Processamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ 43-SIGATMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R4305COL()
	
	Local cQuery  := ""
	Local nLinha  := 0
	Local lSZL 	  := .F.
	
	Local cFilCol := COLQRY->DT5_FILDOC
	Local cNumCol := COLQRY->DT5_DOC
	Local cSerCol := COLQRY->DT5_SERIE
	Local cDDD	  := COLQRY->DT5_DDD
	Local cTel	  := COLQRY->DT5_TEL
	Local cSeqEnd := COLQRY->DT5_SEQEND
	Local cFilR9  := ''
	Local cRegDes := ''
	Local cEstDes := ''
	// 2016-10-27 - MH
	Local cCliDes := ""
	
	Local cLojDes := ""	
	
	If Select("ITEMQRY") > 0
		ITEMQRY->(DbCloseArea())
	EndIf
	

		cAliasSql := "DUM"
		cAliasCpo := "DUM"
		
	cQuery := " SELECT " + cAliasCpo + "_FILIAL FILIAL, " + cAliasCpo + "_FILORI FILORI," + cAliasCpo + "_NUMSOL NUMSOL," + cAliasCpo + "_ITEM ITEM, " + CRLF
	cQuery += 			   cAliasCpo + "_CODPRO CODPRO, " + cAliasCpo + "_CODEMB CODEMB," + cAliasCpo + "_QTDVOL QTDVOL," + cAliasCpo + "_PESO PESO, " + CRLF
	cQuery += 			   cAliasCpo + "_PESOM3 PESOM3, " + cAliasCpo + "_VALMER VALMER, SB1.B1_DESC DESCRICAO, " + CRLF
	

/*	
	cQuery := " SELECT " + cAliasCpo + "_FILIAL FILIAL, " + cAliasCpo + "_FILORI FILORI," + cAliasCpo + "_NUMSOL NUMSOL," + cAliasCpo + "_ITEM ITEM, " + CRLF
	cQuery += 			   cAliasCpo + "_CODPRO CODPRO, " + cAliasCpo + "_CODEMB CODEMB," + cAliasCpo + "_QTDVOL QTDVOL," + cAliasCpo + "_PESO PESO, " + CRLF
	cQuery += 			   cAliasCpo + "_PESOM3 PESOM3, " + cAliasCpo + "_VALMER VALMER, SB1.B1_DESC DESCRICAO, " + CRLF
	cQuery += 			   cAliasCpo + "_CLIDES CLIDES, " + cAliasCpo + "_LOJDES LOJDES, " + CRLF
*/	
		cQuery +=   " '' DC, " + CRLF
		cQuery +=   " '' CLIDES, '' LOJDES, '' CDRDES " + CRLF

	
	cQuery += "	FROM "
	cQuery += 	  RetSqlName(cAliasSql) + " " + cAliasSql	+ CRLF
	cQuery += " INNER JOIN " + RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '' AND SB1.B1_COD = " + cAliasCpo + "_CODPRO " + CRLF
	cQuery += "   AND SB1.D_E_L_E_T_ = ''  " + CRLF
	cQuery += " WHERE " + cAliasSql + ".D_E_L_E_T_ = '' " + CRLF
	cQuery += "   AND " + cAliasCpo + "_FILORI = '" + cFilCol + "'  " + CRLF
	cQuery += "   AND " + cAliasCpo + "_NUMSOL = '" + cNumCol + "'  "+ CRLF
	
	ConOut(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ITEMQRY")
	
	TcSetField("ITEMQRY", cAliasCpo + "_PESO"   ,"N",TamSX3(cAliasCpo + "_PESO"   )[1],TamSX3(cAliasCpo + "_PESO"   )[2])
	TcSetField("ITEMQRY", cAliasCpo + "_PESOM3" ,"N",TamSX3(cAliasCpo + "_PESOM3" )[1],TamSX3(cAliasCpo + "_PESOM3" )[2])
	TcSetField("ITEMQRY", cAliasCpo + "_QTDVOL" ,"N",TamSX3(cAliasCpo + "_QTDVOL" )[1],TamSX3(cAliasCpo + "_QTDVOL" )[2])
	TcSetField("ITEMQRY", cAliasCpo + "_VALMER" ,"N",TamSX3(cAliasCpo + "_VALMER" )[1],TamSX3(cAliasCpo + "_VALMER" )[2])
	
	//|---------------------------------------------------------------------------------
	
	nLinha := 0850
	
	//|-- DADOS DO VEICULO E MOTORISTA
	oFatura :Fillrect( {nLinha,0020,nLinha+70,2410}, oBrush1, "-2")
	oFatura:Say(nLinha+50,1025,"V E I C U L O S",oFont18N,,RGB(255,255,255))
	
	nLinha += 120
	
	oFatura:Say(nLinha,0030,"Placa",oFont14N)
	oFatura:Say(nLinha,0160,":",oFont14N)
	If Empty(COLQRY->DF1_XCDVEI)
		DA3->(dbSetOrder(1))
		If DA3->(MsSeek(xFilial("DA3") + COLQRY->DTR_CODVEI ))
			oFatura:Say(nLinha,0200, Transform(StrTran(DA3->DA3_PLACA,"-",""),"@R AAA-9999"),oFont14)
		EndIf
	
		oFatura:Say(nLinha,0470,"Reboque 1",oFont14N) //,,RGB(255,255,255))
		oFatura:Say(nLinha,0700,":",oFont14N)
		DA3->(dbSetOrder(1))
		If DA3->(MsSeek(xFilial("DA3") + COLQRY->DTR_CODRB1 ))
			oFatura:Say(nLinha,0740,Transform(StrTran(DA3->DA3_PLACA,"-",""),"@R AAA-9999"),oFont14)
		Else
			oFatura:Say(nLinha,0740,"----------",oFont14)
		EndIf
		
		oFatura:Say(nLinha,1190,"Reboque 2",oFont14N) //,,RGB(255,255,255))
		oFatura:Say(nLinha,1420,":",oFont14N)
		If DA3->(MsSeek(xFilial("DA3") + COLQRY->DTR_CODRB2 ))
			oFatura:Say(nLinha,1460,Transform(StrTran(DA3->DA3_PLACA,"-",""),"@R AAA-9999"),oFont14)
		Else
			oFatura:Say(nLinha,1460,"----------",oFont14)
		EndIf

		oFatura:Say(nLinha,1850,"Reboque 3",oFont14N) //,,RGB(255,255,255))
		oFatura:Say(nLinha,2080,":",oFont14N)
		If DA3->(MsSeek(xFilial("DA3") + COLQRY->DTR_CODRB3 ))
			oFatura:Say(nLinha,2120,Transform(StrTran(DA3->DA3_PLACA,"-",""),"@R AAA-9999"),oFont14)
		Else
			oFatura:Say(nLinha,2120,"----------",oFont14)
		EndIf	
	
	Else

		DA3->(dbSetOrder(1))
		If DA3->(MsSeek(xFilial("DA3") + COLQRY->DF1_XCDVEI ))
			oFatura:Say(nLinha,0200, Transform(StrTran(DA3->DA3_PLACA,"-",""),"@R AAA-9999"),oFont14)
		EndIf
	
		oFatura:Say(nLinha,0470,"Reboque 1",oFont14N) //,,RGB(255,255,255))
		oFatura:Say(nLinha,0700,":",oFont14N)
		DA3->(dbSetOrder(1))
		If DA3->(MsSeek(xFilial("DA3") + COLQRY->DF1_XRBQ1 ))
			oFatura:Say(nLinha,0740,Transform(StrTran(DA3->DA3_PLACA,"-",""),"@R AAA-9999"),oFont14)
		Else
			oFatura:Say(nLinha,0740,"----------",oFont14)
		EndIf
		
		oFatura:Say(nLinha,1190,"Reboque 2",oFont14N) //,,RGB(255,255,255))
		oFatura:Say(nLinha,1420,":",oFont14N)
		If DA3->(MsSeek(xFilial("DA3") + COLQRY->DF1_XRBQ2))
			oFatura:Say(nLinha,1460,Transform(StrTran(DA3->DA3_PLACA,"-",""),"@R AAA-9999"),oFont14)
		Else
			oFatura:Say(nLinha,1460,"----------",oFont14)
		EndIf

		oFatura:Say(nLinha,1850,"Reboque 3",oFont14N) //,,RGB(255,255,255))
		oFatura:Say(nLinha,2080,":",oFont14N)
		If DA3->(MsSeek(xFilial("DA3") + COLQRY->DF1_XRBQ3 ))
			oFatura:Say(nLinha,2120,Transform(StrTran(DA3->DA3_PLACA,"-",""),"@R AAA-9999"),oFont14)
		Else
			oFatura:Say(nLinha,2120,"----------",oFont14)
		EndIf

	Endif


	nLinha += 80
	
	oFatura:Say(nLinha,0030,"Ordem de Rastreamento",oFont14N) //,,RGB(255,255,255))
	oFatura:Say(nLinha,0480,":",oFont14N)
	
	/*If !Empty(COLQRY->DTQ_XOC)
		oFatura:Say(nLinha,0520,COLQRY->DTQ_XOC,oFont14)
	Else
		oFatura:Say(nLinha,0520,"----------",oFont14)
	EndIf
	*/
	oFatura:Say(nLinha,1205,"Operadora",oFont14N) //,,RGB(255,255,255))
	oFatura:Say(nLinha,1415,":",oFont14N)
	
	/*SA2->(dbSetOrder(1))
	If SA2->(MsSeek(xFilial("SA2") + COLQRY->DTQ_XCODSG + COLQRY->DTQ_XLOJSG ))
		oFatura:Say(nLinha,1455,Alltrim(SA2->A2_NOME),oFont14)
	Else
		oFatura:Say(nLinha,1455,"----------",oFont14)
	EndIf
	*/
	oFatura :Fillrect( {1000,0020,1070,2410}, oBrush1, "-2")
	oFatura:Say(1050,1025,"M O T O R I S T A",oFont18N,,RGB(255,255,255))
	
	cFilVga	:= COLQRY->DTR_FILORI
	cViagem	:= COLQRY->DTR_VIAGEM
	
	If !Empty(cViagem)
		DUP->(dbSetOrder(1))
		If DUP->(MsSeek(xFilial("DUP") + cFilVga + cViagem))
			
			nLinha	:= 1130
			
			While DUP->(!Eof()) .And. DUP->DUP_FILORI + DUP->DUP_VIAGEM == cFilVga + cViagem
				
				DA4->(dbSetOrder(1))
				If DA4->(MsSeek(xFilial("DA4") + DUP->DUP_CODMOT))
					oFatura:Say(nLinha,0030,"Nome     ",oFont14N)
					oFatura:Say(nLinha,0160,":",oFont14N)
					oFatura:Say(nLinha,0200,Alltrim(DA4->DA4_NOME),oFont14)
					
					oFatura:Say(nLinha,1025,"CPF ",oFont14N)
					oFatura:Say(nLinha,1135,":",oFont14N)
					If !Empty(DA4->DA4_CGC)
						oFatura:Say(nLinha,1175,Transform(DA4->DA4_CGC,"@r 999.999.999-99"),oFont14)
					Else
						oFatura:Say(nLinha,1175,"----------",oFont14)
					EndIf
					oFatura:Say(nLinha,1795,"CNH ",oFont14N)
					oFatura:Say(nLinha,1905,":",oFont14N)
					
					If !Empty(DA4->DA4_REGCNH)
						oFatura:Say(nLinha,1945,DA4->DA4_REGCNH,oFont14)
					Else
						oFatura:Say(nLinha,1945,"----------",oFont14)
					EndIf

					nLinha += 60
					oFatura:Say(nLinha,0030,"RG",oFont14N)
					oFatura:Say(nLinha,0160,":",oFont14N)
					oFatura:Say(nLinha,0200,Alltrim(DA4->DA4_RG),oFont14)
					//--FIM 17-08,VL.				
					
				EndIf
				
				nLinha += 60
				
				DUP->(dbSelectArea("DUP"))
				DUP->(dbSkip())
			EndDo
		EndIf
	Else
		nLinha	:= 1130
		DA4->(dbSetOrder(1))
		If DA4->(MsSeek(xFilial("DA4") + DF1->DF1_XCDMOT))
			oFatura:Say(nLinha,0030,"Nome     ",oFont14N)
			oFatura:Say(nLinha,0160,":",oFont14N)
			oFatura:Say(nLinha,0200,Alltrim(DA4->DA4_NOME),oFont14)
			oFatura:Say(nLinha,1025,"CPF ",oFont14N)
			oFatura:Say(nLinha,1135,":",oFont14N)
			If !Empty(DA4->DA4_CGC)
				oFatura:Say(nLinha,1175,Transform(DA4->DA4_CGC,"@r 999.999.999-99"),oFont14)
			Else
				oFatura:Say(nLinha,1175,"----------",oFont14)
			EndIf
			oFatura:Say(nLinha,1795,"CNH ",oFont14N)
			oFatura:Say(nLinha,1905,":",oFont14N)
			If !Empty(DA4->DA4_REGCNH)
				oFatura:Say(nLinha,1945,DA4->DA4_REGCNH,oFont14)
			Else
				oFatura:Say(nLinha,1945,"----------",oFont14)
			EndIf			
			
			nLinha += 60
			oFatura:Say(nLinha,0030,"RG",oFont14N)
			oFatura:Say(nLinha,0160,":",oFont14N)
			oFatura:Say(nLinha,0200,Alltrim(DA4->DA4_RG),oFont14)
			//--FIM 17-08,VL.				
		
		EndIf
				
		nLinha += 60

	Endif
	
	nLinha := 1490  // 1540
	
	oFatura :Fillrect( {nLinha,0020,nLinha+70,2410}, oBrush1, "-2")
	oFatura:Say(nLinha+50,1035,"D E T A L H E S",oFont18N,,RGB(255,255,255)) ///,,RGB(255,255,255))
	
	oFatura :Fillrect({nLinha+80,0020,nLinha+150,2410}, oBrush1,"-2")
	//oFatura:Say(nLinha+125,0030,"EMBARQUE",oFont10A,,RGB(255,255,255))
	oFatura:Say(nLinha+125,0030,"DESTINO",oFont10A,,RGB(255,255,255))
	oFatura:Say(nLinha+125,0300,"PRODUTO",oFont10A,,RGB(255,255,255))
	oFatura:Say(nLinha+125,1100,"EMB.",oFont10A,,RGB(255,255,255))
	oFatura:Say(nLinha+125,1200,"VOLUME",oFont10A,,RGB(255,255,255))
	oFatura:Say(nLinha+125,1460,"PESO",oFont10A,,RGB(255,255,255))
	oFatura:Say(nLinha+125,1815,"PESO M3",oFont10A,,RGB(255,255,255))
	oFatura:Say(nLinha+125,2070,"VALOR",oFont10A,,RGB(255,255,255))
	
	DbSelectArea("ITEMQRY")
	
	ITEMQRY->(DbGoTop())
	
	ProcRegua(ITEMQRY->(RecCount()))
	
	nlinha := 1695 //1745
	
	While !ITEMQRY->(Eof())
	
		// 2016-10-27 - MH
		cCliDes := ITEMQRY->CLIDES
		cLojDes := ITEMQRY->LOJDES	
		
		IncProc('Embarque da Coleta: ' + ITEMQRY->DC)
		
		/*If !Empty(ITEMQRY->DC)
			oFatura:Say(nLinha,0030,ITEMQRY->DC,oFont12N)
		Else
			oFatura:Say(nLinha,0030,"----------",oFont12N)
		EndIf*/
		
		If !Empty(ITEMQRY->CDRDES)
			cCdrDes := ITEMQRY->CDRDES
		ElseIf !Empty(cSeqEnd)
			DUL->(dbSetOrder(1))  // Posicione("DUY",1,xFilial("DUY")+SZL->ZL_CDRDES,"DUY_DESCRI")
			If DUL->(MsSeek(xFilial("DUL") + AvKey(cDDD,"DUL_DDD") + AvKey(cTel,"DUL_TEL") + AvKey(cSeqEnd,"DUL_SEQEND") ))
				cCdrDes := DUL->DUL_CDRDES
			EndIf
		Else
			DUE->(dbSetOrder(1))  //DUE_FILIAL+DUE_CODSOL
			If DUE->(MsSeek(xFilial("DUE") + COLQRY->DT5_CODSOL))
				cCdrDes := DUE->DUE_CDRSOL
			EndIf
		EndIf
		
		DUY->(dbSetOrder(1))  // Posicione("DUY",1,xFilial("DUY")+SZL->ZL_CDRDES,"DUY_DESCRI")
		If DUY->(MsSeek(xFilial("DUY") + cCdrDes))
			cRegDes := DUY->DUY_DESCRI
			cEstDes	:= DUY->DUY_EST
		EndIf
		
		oFatura:Say(nLinha,0030, Alltrim(Substr(cRegDes,01,15)) + "-" + Alltrim(DUY->DUY_EST),oFont12N)
		oFatura:Say(nLinha,0300, left(ITEMQRY->DESCRICAO,40),oFont12N)
		oFatura:Say(nLinha,1100, ITEMQRY->CODEMB,oFont12N)
		oFatura:Say(nLinha,1200, Alltrim(Transform(ITEMQRY->QTDVOL,"@E 99999")), oFont12N)
		oFatura:Say(nLinha,1460, Alltrim(Transform(ITEMQRY->PESO  ,"@E 999,999.9999")), oFont12N)  //999999,9999
		oFatura:Say(nLinha,1815, Alltrim(Transform(ITEMQRY->PESOM3,"@E 999,999.9999")), oFont12N)
		oFatura:Say(nLinha,2070, Alltrim(Transform(ITEMQRY->VALMER,"@E 99,999,999,999.99")),oFont12N)
		
		nLinha += 50
		
		If !Empty(cCliDes)
			SA1->(dbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1") + cCliDes + cLojDes))
				cNomDest := SA1->A1_NOME
				oFatura:Say(nLinha,0400, Alltrim(Substr(cNomDest,1,TamSx3("A1_NOME")[1])),oFont12N)
				nLinha += 50
			EndIf
		EndIf
		
		ITEMQRY->(DbSkip())
		
	EndDo
	
	If Select("ITEMQRY") > 0
		ITEMQRY->(DbCloseArea())
	EndIf
	
	nLinha := 2180 // 2360
	oFatura :Fillrect( {nLinha-20,0020,nLinha+20,2410 }, oBrush2, "-2")
	oFatura :Line( nLinha,0020, nLinha, 2410, RGB(000,000,000), "-4")
	/*If !Empty(COLQRY->DT5_XDOCA)
		oFatura:Say(nLinha+70,0030,"CARREGAMENTO DOCA : " + COLQRY->DT5_XDOCA,oFont18N)
	EndIf*/
	
	nLinha := 2260 // 2440
	
	//|-- PROGRAMAÇÃO
	oFatura :Fillrect( {nLinha,0020,nLinha+70,2410}, oBrush1, "-2")
	oFatura:Say(nLinha+50,1000,"P R O G R A M A Ç Ã O",oFont18N,,RGB(255,255,255))
	
	oFatura:Say(nLinha+130,0030, "Data ",oFont14N)
	oFatura:Say(nLinha+130,0250,":",oFont14N)
	oFatura:Say(nLinha+130,0290, Substr(COLQRY->DT5_DATPRV,7,2)+'/'+Substr(COLQRY->DT5_DATPRV,5,2)+'/'+Substr(COLQRY->DT5_DATPRV,1,4),oFont14)
	
	//oFatura:Say(nLinha+130,1205, "Data Final",oFont14N)
	//oFatura:Say(nLinha+130,1445,":",oFont14N)
	//oFatura:Say(nLinha+130,1485, Substr(COLQRY->DT5_DATPRV,7,2)+'/'+Substr(COLQRY->DT5_DATPRV,5,2)+'/'+Substr(COLQRY->DT5_DATPRV,1,4),oFont14)
	
	oFatura:Say(nLinha+210,0030,"Horário ",oFont14N)
	oFatura:Say(nLinha+210,0250,":",oFont14N)
	oFatura:Say(nLinha+210,0290,Substr(COLQRY->DT5_HORPRV,1,2)+':'+Substr(COLQRY->DT5_HORPRV,3,2),oFont14)
	
	/*//oFatura:Say(nLinha+210,1205,"Hora Final 1",oFont14N)
	oFatura:Say(nLinha+210,0480,"as",oFont14)
	oFatura:Say(nLinha+210,0580,IIF(!Empty(COLQRY->DT5_HRPRV1),Substr(COLQRY->DT5_HRPRV1,1,2)+':'+Substr(COLQRY->DT5_HRPRV1,3,2),"-----"),oFont14)
	
	//oFatura:Say(nLinha+290,0030,"Hora Inicial 2",oFont14N)
	oFatura:Say(nLinha+210,0750,"/",oFont14)
	oFatura:Say(nLinha+210,0850,IIF(!Empty(COLQRY->DT5_HRPRV2),Substr(COLQRY->DT5_HRPRV2,1,2)+':'+Substr(COLQRY->DT5_HRPRV2,3,2),"-----"),oFont14)
	
	//oFatura:Say(nLinha+290,1205,"Hora Final 2",oFont14N)
	oFatura:Say(nLinha+210,1020,"as",oFont14)
	oFatura:Say(nLinha+210,1120,IIF(!Empty(COLQRY->DT5_HRPRV3),Substr(COLQRY->DT5_HRPRV3,1,2)+':'+Substr(COLQRY->DT5_HRPRV3,3,2),"-----"),oFont14)
	*/
	/*Z01->( DbSetOrder(1) )//Z01_FILIAL, Z01_CDEMPR, Z01_FILTM6, R_E_C_N_O_, D_E_L_E_T_
	If Z01->(DbSeek( xFilial("Z01") + cEmpAnt + DTR->DTR_FILORI ))
		cFilR9 := Z01->Z01_CDFR90    // FILIAL PADRAO WEB - CARACTERE DE 3 POSIÇÕES.
	Endif
	*/
	oFatura:Say(nLinha+290,0030,"Viagem ",oFont14N)
	oFatura:Say(nLinha+290,0250,":",oFont14N)
	oFatura:Say(nLinha+290,0290, COLQRY->DTR_FILORI + " (" + cFilR9 + ") - " + COLQRY->DTR_VIAGEM,oFont14)
	
	nLinha := 2570
	
	R4304MSG(nLinha)
	
	nLinha := 2920
	
	oFatura :Fillrect( {nLinha,0020,nLinha+40,2410 }, oBrush2, "-2")
	oFatura :Line( nLinha+20,0020, nLinha+20, 2410, RGB(000,000,000), "-4")
	
	nLinha += 80
	oFatura :Say(nLinha,0030,"PREZADO CLIENTE: PARA PODERMOS MELHORAR NOSSO ATENDIMENTO SOLICITAMOS QUE SEJA ANOTADO OS HORARIOS ABAIXO:",oFont12N)
	nLinha += 50
	oFatura :Say(nLinha+20,0030,"Chegada:_________   Saída:_________ ",oFont12N)
	oFatura :Say(nLinha+20,0730,"Local/Data: __________________________  Carimbo/Assinatura: _____________________________ ",oFont12N)
	
	// PREZADO CLIENTE: PARA PODERMOS MELHORAR NOSSO ATENDIMENTO SOLICITAMOS QUE SEJA ANOTADO OS HORARIOS ABAIXO:
	// CHEGADA :              SAIDA  :
	// LOCAL E DATA : 		  CARIMBO E ASSINATURA
	
	nLinha := 3110
	
	oFatura :Fillrect( {nLinha,0020,nLinha+40,2410 }, oBrush2, "-2")
	oFatura :Line( nLinha+20,0020, nLinha+20, 2410, RGB(000,000,000), "-4")
	
	oFatura :Say(nLinha+80,1000,"@ Totvs Microsiga P12 2020 | Risa SA",oFont10)
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ R4304MSG   ³ AUTOR ³ Marcos Holando      ³ DATA ³ 22.05.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Processamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ 43-SIGATMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R4304MSG(nLinha)
	
	Local aMens 	:= {}
	Local nMsg
	
	oFatura :Fillrect( {nLinha,0020,nLinha+40,2410 }, oBrush2, "-2")
	oFatura :Line( nLinha+18,0020, nLinha+18, 2410, RGB(000,000,000), "-4")
	
	oFatura :Say(nLinha+80,0030,"OBSERVAÇÕES : ",oFont14N)
	
	nLinha += 80
	
	//Abre Tabela SYP Historico de Mensage
	SYP->(dbSetOrder(1))// YP_FILIAL+YP_CHAVE+YP_SEQ
	If SYP->(MsSeek(xFilial("SYP")+COLQRY->DT5_CODOBS))
		oFatura:Say(nLinha,0380,StrTran(Alltrim(SYP->YP_TEXTO),'\13\10',''),oFont14)
	EndIf
	
	nLinha += 60
	
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ AJUSTASX1  ³ AUTOR ³ Marcos Holando      ³ DATA ³ 22.05.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Manutençacao das perguntas do relatorio                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ 43-SIGATMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AjustaSX1(cPerg)
	
	Local cFilIni   := TamSX3("DT5_FILORI")[1]
	Local cColIni   := TamSX3("DT5_NUMSOL")[1]
	Local cFilFim 	:= TamSX3("DT5_FILORI")[1]
	Local cColFim 	:= TamSX3("DT5_NUMSOL")[1]
	
	//Local cPerg	:= "R943R005"
	
	cPerg := PadR(cPerg, Len(SX1->X1_GRUPO), " ")
	
	aHelpPor := {"Informe a Coleta inicial."}
	aHelpEng := {""}
	aHelpEsp := {""}
	PutSx1(	cPerg, "01", "Coleta Inicial", "Coleta Inicial", "Coleta Inicial ", "MV_CH1", "C", cColIni, 0, 0, "G", "", "", "", "","MV_PAR01", "", "", "", "",;
		"", "", "", "", "", "", "", "N", "", "", "", "", aHelpPor, aHelpEng, aHelpEsp )
	
	aHelpPor := {"Informe a Coleta Final."}
	aHelpEng := {""}
	aHelpEsp := {""}
	PutSx1(	cPerg, "02", "Coleta Final ", "Coleta Final ", "Coleta Final ", "MV_CH2", "C", cColFim, 0, 0, "G", "", "", "", "","MV_PAR02", "", "", "", "",;
		"", "", "", "", "", "", "", "N", "", "", "", "", aHelpPor, aHelpEng, aHelpEsp )
	
Return Nil

