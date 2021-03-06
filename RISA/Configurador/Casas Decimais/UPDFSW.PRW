#include "totvs.ch"
#include "tbiconn.ch"
#include "dbstruct.ch"
#INCLUDE "Protheus.ch"
#DEFINE _CRLF	Chr(13) + Chr(10)

/*
��������������������������������������������������������������������������
��������������������������������������������������������������������������
����������������������������������������������������������������������Ŀ��
���Fun��o    � UPDFSW  �Autor � TOTVS                 �Data � 25.Jun.09���
����������������������������������������������������������������������Ĵ��
���Descri��o � Compatibilizador de tabelas e campos                    ���
����������������������������������������������������������������������Ĵ��
���Uso       � TOTVS                                                   ���
�����������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������
��������������������������������������������������������������������������
*/
User Function UPDFSW()
Local aEmpresas  := {}
Local aListUpd   := {}
Local aTitulos   := {' ', 'Id.', 'Update', 'Status', 'Projeto' }
Local cTxtIntro  := ''
Local lMarcaItem := .T.
Local oDlgUpd
Local oListUpd
Local oNo        := LoadBitMap(GetResources(),"LBNO")
Local oOk        := LoadBitMap(GetResources(),"LBOK")
Private aDados   := {}


cTxtIntro := "<table width='100%' border='1'>"
cTxtIntro += "<tr>"
cTxtIntro += "<td colspan='2'><font face='Tahoma' size='+1'>Este programa tem por objetivo compatibilizar o ambiente do cliente "
cTxtIntro += "conforme as atualizacoes selecionadas na lista abaixo:</font></td>"
cTxtIntro += "</tr>
cTxtIntro += "<tr>"
cTxtIntro += "<td colspan='2'><font face='Tahoma' color='#FF0000' size='+1'>Estas atualizacoes somente poderao ser realizadas em modo <b>exclusivo!</b><br>"
cTxtIntro += "Faca um backup dos dicion�rios e da Base de Dados antes da atualiza��o para eventuais falhas na atualiza��o."
cTxtIntro += "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>"
cTxtIntro += "</font></td>"
cTxtIntro += "</tr>
cTxtIntro += "</table>

If ( lOpen := MyOpenSm0(.T.) )

	//-- Obtem as Empresas para processamento...
	SM0->(dbGotop())
	While !SM0->(Eof())
  		If Ascan(aEmpresas,{ |x| x[2] == SM0->M0_CODIGO}) == 0 .And. !Empty(SM0->M0_CODIGO) //--So adiciona no array se a empresa for diferente
			Aadd(aEmpresas,{.T.,;
							SM0->M0_CODIGO,;
							SM0->M0_CODFIL,;
							SM0->M0_FILIAL,;
							SM0->(Recno()) })
		EndIf			
		SM0->(dbSkip())
	EndDo	

	SM0->(DbGoTop())
	RpcSetType(3) 
	RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL) //"99","01"
	lMsFinalAuto := .F.
	
	//-- Obtem a lista de Updates disponiveis para execucao:
	aListUpd   := GetListUpd()

	DEFINE MSDIALOG oDlgUpd; 
	TITLE 'Update Compatibilizador' ;
	FROM 00,00 TO 500,700 PIXEL
	
	TSay():New(002,005,{|| cTxtIntro },oDlgUpd,,,,,,.T.,,,340,200,,,,.T.,,.T.)
	
	oListUpd := TWBrowse():New(	53,10,330,140,,aTitulos,,oDlgUpd,,,,,,,,,,,,,"ARRAY",.T.)
	oListUpd:bLDblClick := {|| aListUpd[oListUpd:nAt,1] := !aListUpd[oListUpd:nAt,1], oListUpd:Refresh()}
	oListUpd:SetArray( aListUpd )
	oListUpd:bLine      := {|| {	If(aListUpd[oListUpd:nAt,1], oOk, oNo),;
							   		aListUpd[oListUpd:nAT,2],;
									aListUpd[oListUpd:nAT,3],;
									aListUpd[oListUpd:nAT,4],;
									aListUpd[oListUpd:nAT,5] } }

	TButton():New( 210,140, 'Marca/Desmarca Pendentes', oDlgUpd,;
					{|| Aeval(aListUpd,{|aElem| aElem[1] := If(aElem[4] == 'Pendente', lMarcaItem, .F.)}), lMarcaItem := !lMarcaItem, oListUpd:Refresh() },; 
					075,015,,,,.T.,,,,,,)

	TButton():New( 210,270, 'Marca/Desmarca Todos', oDlgUpd,;
					{|| Aeval(aListUpd,{|aElem|aElem[1] := lMarcaItem}), lMarcaItem := !lMarcaItem, oListUpd:Refresh() },; 
					075,015,,,,.T.,,,,,,)


	TButton():New( 230,005, 'Selecionar Empresas', oDlgUpd,;
					{|| aEmpresas := UPDSelectSM0(@aEmpresas) },; 
					075,015,,,,.T.,,,,,,)


	TButton():New( 230,140, 'Processar...', oDlgUpd,;
					{|| RpcClearEnv(), MsgRun('Aguarde o termino do Processamento',,{||UPDProcUpd( aListUpd, aEmpresas )}), oDlgUpd:End()},; 
					075,015,,,,.T.,,,,,,)

	TButton():New( 230,270, 'Cancelar', oDlgUpd,;
					{|| RpcClearEnv(), oDlgUpd:End()},; 
					075,015,,,,.T.,,,,,,)	
	
	ACTIVATE MSDIALOG oDlgUpd CENTERED
EndIf
Return

/*
//����������������������������������������������������������������������Ŀ
//� Funcao para quantidade                                               �
//����������������������������������������������������������������������Ĵ
*/
User Function FSW01Des()
Local aRet := {}

//����������������������������������������������������������������������Ŀ
//� ESTRUTURA DO ARRAY aRET:                                             �
//����������������������������������������������������������������������Ĵ
//� aRet[01] - (C) Nome da Function                                      �
//� aRet[02] - (C) Descritivo do Update                                  �
//� aRet[03] - (L) Situacao para determinar se o Update ja foi executado �
//� aRet[04] - (C) Projeto L�gico                                        �
//������������������������������������������������������������������������
AAdd( aRet, 'UPDFSW01')
AAdd( aRet, 'Decimais QTDE' )
AAdd( aRet, .F. )
AAdd( aRet, 'GENESIS' )

Return( aRet )

/*
//����������������������������������������������������������������������Ŀ
//� Funcao para valor                                                    �
//����������������������������������������������������������������������Ĵ
*/
User Function FSW02Des()
Local aRet := {}

//����������������������������������������������������������������������Ŀ
//� ESTRUTURA DO ARRAY aRET:                                             �
//����������������������������������������������������������������������Ĵ
//� aRet[01] - (C) Nome da Function                                      �
//� aRet[02] - (C) Descritivo do Update                                  �
//� aRet[03] - (L) Situacao para determinar se o Update ja foi executado �
//� aRet[04] - (C) Projeto L�gico                                        �
//������������������������������������������������������������������������
AAdd( aRet, 'UPDFSW02')
AAdd( aRet, 'Decimais VALOR' )
AAdd( aRet, .F. )
AAdd( aRet, 'GENESIS' )

Return( aRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � UPDFSW01 �Autor  � DLeme                 �Data  � 20.Abr.12���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza��es Modal Aquaviario                              ���
�������������������������������������������������������������������������Ĵ��
���Projeto   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Bardella                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function UPDFSW01()
Local aRet      := {{},{},{},{},{},{},{},{}}

//����������������������������������������������������������������������Ŀ
//� ESTRUTURA DO ARRAY aRET:                                             �
//����������������������������������������������������������������������Ĵ
//� aRet[01] - Array com os dados SX2                                    �
//� aRet[02] - Array com os dados SIX                                    �
//� aRet[03] - Array com os dados SX3                                    �
//� aRet[04] - Array com os dados SX5                                    �
//� aRet[05] - Array com os dados SX7                                    �
//� aRet[06] - Array com os dados SXA                                    �
//� aRet[07] - Array com os dados SXB                                    �
//� aRet[08] - Array com os dados SX6                                    �
//������������������������������������������������������������������������

aRet[3] := TMSAtuSX3("campos_quant.ini",16,5) //arquivo com campos, tamanho padr�o, decimal padr�o)

Return(aRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � UPDFSW01 �Autor  � DLeme                 �Data  � 20.Abr.12���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza��es Modal Aquaviario                              ���
�������������������������������������������������������������������������Ĵ��
���Projeto   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Bardella                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function UPDFSW02()
Local aRet      := {{},{},{},{},{},{},{},{}}

//����������������������������������������������������������������������Ŀ
//� ESTRUTURA DO ARRAY aRET:                                             �
//����������������������������������������������������������������������Ĵ
//� aRet[03] - Array com os dados SX3                                    �
//������������������������������������������������������������������������

aRet[3] := TMSAtuSX3("campos_vunit.ini",16,8) //arquivo com campos, tamanho padr�o, decimal padr�o)

Return(aRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �UPDPROCUPD� Autor � Fabrica de Software   � Data � 13.Nov.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � PROCESSA A ATUALIZACAO DO AMBIENTE                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function UPDProcUpd( aListUpd, aEmpresas )
Local nAux       := 0
Local nEmpresa   := 0

Local aEstrutSX3 := {}

Local   cTCBuild  := "TCGetBuild"
Local   cTopBuild := ""

Local aTarefas   := {}
Local aSX3       := {}
Local aAtualiza  := {{},{},{},{},{},{},{},{}}
Local aResumo    := {}

Local aArqUpd    := {}

Local i          := 0
Local j          := 0

aEstrutSX3 := {"X3_ARQUIVO","X3_ORDEM"		,"X3_CAMPO"		,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"	,"X3_TITSPA"	,;
		  		   "X3_TITENG" ,"X3_DESCRIC"	,"X3_DESCSPA"	,"X3_DESCENG"	,"X3_PICTURE"	,"X3_VALID"		,"X3_USADO"		,"X3_RELACAO"	,;
				   "X3_F3"		,"X3_NIVEL"		,"X3_RESERV"	,"X3_CHECK"		,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,;
				   "X3_CONTEXT","X3_OBRIGAT"	,"X3_VLDUSER"	,"X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,;
				   "X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	}


For nEmpresa := 1 To Len(aEmpresas)
	If aEmpresas[nEmpresa,1]
		If !( lOpen := MyOpenSm0(.F.) )
			MsgStop( "Atualiza��o da empresa " + aEmpresas[nEmpresa,2] + "/" + aEmpresas[nEmpresa,3] + " n�o efetuada." )
			Exit
		EndIf
		If lOpen
			SM0->(DbGoTo(aEmpresas[nEmpresa,5]))
			RpcSetType(3) 
			RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
			lMsFinalAuto := .F.

			aTarefas   := {}
			aSX3       := {}
			aAtualiza  := {{},{},{},{},{},{},{},{}}

			//�����������������������Ŀ
			//�INICIO DAS ATUALIZACOES�
			//�������������������������
			For nAux := 1 To Len(aListUpd)
				If aListUpd[nAux,1]
			
					//-- Obtem a lista de tarefas conforme updates selecionados na lista
					aTarefas := &( 'U_' + aListUpd[nAux,2] + '()' )
			
					For i := 1 To Len(aTarefas[3]) //-- SX3
						AAdd( aSX3, aTarefas[3,i] )
					Next
			
				EndIf
			Next
			
			//�������������������Ŀ
			//� ATUALIZANDO O SX3 �
			//���������������������
			SX3->(DbSetOrder(2))	
			For i := 1 To Len(aSX3)
				If !Empty(aSX3[i,1])
					If AScan(aArqUpd, aSX3[i,1]) == 0
						aAdd(aArqUpd,aSX3[i,1])
					EndIf
					If !SX3->(dbSeek(aSX3[i,3]))
						RecLock("SX3",.T.)
					Else
						RecLock("SX3",.F.)
					EndIf
					For j:=1 To Len(aSX3[i])
						If SX3->(FieldPos(aEstrutSX3[j])) > 0 .And. aSX3[i,j] != NIL
							SX3->(FieldPut(FieldPos(aEstrutSX3[j]),aSX3[i,j]))
						EndIf
					Next j
					SX3->(dbCommit())
					SX3->(MsUnLock())

					AAdd( aAtualiza[3], aSX3[i] )
					
				EndIf
			Next i
			
			__SetX31Mode(.F.) //// Altera��o f�sica dos arquivos

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For i := 1 To Len(aArqUpd)
				If Select(aArqUpd[i]) > 0
					DbSelectArea(aArqUpd[i])
					dbCloseArea()
				EndIf
	
				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[i] >= "NQ " .AND. aArqUpd[i] <= "NZZ" ) .OR. ( aArqUpd[i] >= "O0 " .AND. aArqUpd[i] <= "NZZ" ) ) .AND.;
						!aArqUpd[i] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[i] ) > 0
					dbSelectArea( aArqUpd[i] )
					dbCloseArea()
				EndIf

				X31UpdTable(aArqUpd[i])
				
				If __GetX31Error()
					MsgAlert(__GetX31Trace())
					Aviso("Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+ aArqUpd[i] + ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2)
				EndIf
				
				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf
			
			Next i

			RpcClearEnv()			
			AAdd(aResumo, {aEmpresas[nEmpresa,2] + ' - ' + aEmpresas[nEmpresa,3] + ': ' + aEmpresas[nEmpresa,4], aAtualiza} )
			
		EndIf
	EndIf
Next

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GetListUpd� Autor �FSW                    � Data � 13.Nov.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a Lista com os Updates disponiveis para Realizacao ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetListUpd()
Local aList     := {}
Local nAux      := 0

For nAux := 1 To 2
	cUpdate := StrZero(nAux,2)
	If FindFunction( 'U_FSW' + cUpdate + 'Des' )
	
		aRet := &('U_FSW' + cUpdate + 'Des()' )
		AAdd( aList, {	.F.,;
						aRet[1],;
						aRet[2],;
						IIf(aRet[3], 'Executado', 'Pendente'),;
						aRet[4] } )
	EndIf
Next
Return(aList)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �UPDSelectSM0� Autor �FSW                  � Data � 14.Nov.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe janela para escolha das empresas que devem ser       ���
���          � processadas                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function UPDSelectSM0(aEmpresas)
Local oDlgSM0
Local oListBox
Local aHList     := {}
Local oOk        := LoadBitMap(GetResources(),"LBOK")
Local oNo        := LoadBitMap(GetResources(),"LBNO")
Local lMarcaItem := .T.

DEFINE MSDIALOG oDlgSM0 TITLE 'Selecione as Empresas para o processamento...' From 9,0 To 30,52

AAdd( aHList, ' ')
AAdd( aHList, 'Empresa' )
AAdd( aHList, 'Filial' )
AAdd( aHList, 'Nome' )
AAdd( aHList, 'Id.')

oListBox := TWBrowse():New(005,005,155,145,,aHList,,oDlgSM0,,,,,,,,,,,,, "ARRAY", .T. )
oListBox:SetArray( aEmpresas )
oListBox:bLine := {|| {	If(aEmpresas[oListBox:nAT,1], oOk, oNo),;
						aEmpresas[oListBox:nAT,2],;
						aEmpresas[oListBox:nAT,3],;
						aEmpresas[oListBox:nAT,4],;
						aEmpresas[oListBox:nAT,5]}}

oListBox:bLDblClick := {|| aEmpresas[oListBox:nAt,1] := !aEmpresas[oListBox:nAt,1], oListBox:Refresh()}

DEFINE SBUTTON FROM    4,170 TYPE 1 ACTION (oDlgSM0:End())   ENABLE OF oDlgSM0
DEFINE SBUTTON FROM 18.5,170 TYPE 11 ACTION (Aeval(aEmpresas,{|aElem|aElem[1] := lMarcaItem}), lMarcaItem := !lMarcaItem,,oListBox:Refresh()) ONSTOP 'Marca/Desmarca' ENABLE OF oDlgSM0

ACTIVATE MSDIALOG oDlgSM0 CENTERED

Return( aEmpresas )

//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Fun��o de processamento abertura do SM0 modo exclusivo
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)
Local lOpen := .F.
Local nLoop := 0
For nLoop := 1 To 20
	If MPDicInDB()
		If lShared
			OpenSm0(,.T.)
		Else
			OpenSM0Excl(,.F.)
		EndIf
		If !Empty( Select( 'SM0' ) )
			lOpen := .T.
			Exit
		EndIF
	Else
		dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )
		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf
	EndIf
	Sleep( 500 )
Next nLoop

Return lOpen

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAtuSX3 � Autor � TOTVS      � Data � 20.Mar.11���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna os dados para atualizacao do SX3                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMSAtuSX3(cArq, nTam, nDec)

Local aSX3      := {}
Local aCpos,nI
Local aArea := GetArea()
Local nReg := 1

Default nDecimais := nDec
Default nTam := nTam

//�����������������������������������Ŀ
//�VERIFICA AS PROPRIEDADES DOS CAMPOS�
//�������������������������������������
dbSelectArea("SX3")
SX3->(DbSetOrder(2))

aCpos := {}

nHandle := FT_FUse(cArq)

If nHandle = -1
	return
endif

// Posiciona na primeria linha
FT_FGoTop()

// Retorna o n�mero de linhas do arquivo
nLast := FT_FLastRec()
//primeira linha (quantidade, casas)
cLine  := FT_FReadLn()
nDecimais := val(substr(cLine,at("|",cLine)+1,10))      
nTam      := val(substr(cLine,1,at("|",cLine)-1))
FT_FSKIP()

While !FT_FEOF()
	cLine  := FT_FReadLn()
	aAdd(aCpos,cLine)		
	// Pula para pr�xima linha
	FT_FSKIP()
End
// Fecha o Arquivo

FT_FUSE()

DbSelectArea("SX3")
DbSetOrder(2) //X3_CAMPO
ProcRegua(nReg)
For nI := 1 To Len(aCpos)

		IncProc(" Campo "+ alltrim(aCpos[nI]) )
		DbSeek(aCpos[nI])
		cPicture := "@E " + Repl("9",Min(18,X3_TAMANHO+nDecimais-X3_DECIMAL)-nDecimais-1)+"."+Repl("9",nDecimais)

		Aadd(aSX3,{X3_ARQUIVO,;		//Arquivo
					X3_ORDEM,;		//Ordem
					X3_CAMPO,;		//Campo
					X3_TIPO,;		//Tipo
					nTam,;          //Min(18,X3_TAMANHO+nDecimais-X3_DECIMAL),;                   //Tamanho
					nDecimais,;		//Decimal                               
					X3_TITULO,;		//Titulo
					X3_TITSPA,;		//Titulo SPA
					X3_TITENG,;		//Titulo ENG
					X3_DESCRIC,;	//Descricao
					X3_DESCSPA,;	//Descricao SPA
					X3_DESCENG,;	//Descricao ENG
					cPicture,;  	//Picture
					X3_VALID,;					//VALID
					X3_USADO,;	//USADO
					X3_RELACAO,;				//RELACAO
					X3_F3,;					//F3
					X3_NIVEL,;						//NIVEL
					X3_RESERV,;	//RESERV
					X3_CHECK,;					//CHECK
					X3_TRIGGER,;					//TRIGGER
					X3_PROPRI,;					//PROPRI
					X3_BROWSE,;					//BROWSE
					X3_VISUAL,;					//VISUAL
					X3_CONTEXT,;					//CONTEXT
					X3_OBRIGAT,;					//OBRIGAT
					X3_VLDUSER,;//VLDUSER
					X3_CBOX,;	//CBOX
					X3_CBOXSPA,;	//CBOX SPA
					X3_CBOXENG,;	//CBOX ENG
					X3_PICTVAR,;					//PICTVAR
					X3_WHEN,;//WHEN
					X3_INIBRW,;					//INIBRW
					X3_GRPSXG,;					//SXG
					X3_FOLDER,;					//FOLDER
					X3_PYME})					//PYME

		nReg++
Next nI
RestArea(aArea)
			
Return(aSX3)
