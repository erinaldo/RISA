#include "PROTHEUS.CH"
#include "TOPCONN.CH"

user function IMPSALHR()
	local oDlg
	local oFont := TFont():New("MS Sans Serif",,10,,.F.,,,,,.F.,.F.)
	local cMatrInicial := space(tamSx3("RA_MAT")[1])
	local cMatrFinal := replicate("Z", tamSx3("RA_MAT")[1])

	oDlg := MsDialog():New(0, 0, 120, 200, "Importa��o de Sal�rio Hora",,,,, CLR_BLACK, CLR_WHITE,,, .T.,,,, .F.)
	TSay():New(10, 7, {||"Matr�cula de"}, oDlg,, oFont,,,, .T., CLR_BLACK, CLR_WHITE, 35, 10,,,,,,)
	TGet():New(7, 45, {|u|iif(pCount() == 0, cMatrInicial, cMatrInicial := u)}, oDlg, 50, 10,,, CLR_BLACK, CLR_WHITE, oFont,,, .T.,,,,,,,,, "ST1", "cMatrInicial",,,, .T., .F.,,,,,,)
	TSay():New(25, 7, {||"Matr�cula at�"}, oDlg,, oFont,,,, .T., CLR_BLACK, CLR_WHITE, 35, 10,,,,,,)
	TGet():New(22, 45, {|u|iif(pCount() == 0, cMatrFinal, cMatrFinal := u)}, oDlg, 50, 10,,, CLR_BLACK, CLR_WHITE, oFont,,, .T.,,,,,,,,,"ST1" , "cMatrFinal",,,, .T., .F.,,,,,,)
	TButton():New(45, 20, "Ok", oDlg, {||iif(IMPORTA(cMatrInicial, cMatrFinal), oDlg:end(),)}, 20, 10,, oFont,, .T.,,,,,,)
	TButton():New(45, 45, "Cancelar", oDlg, {||oDlg:end()}, 35, 10,, oFont,, .T.,,,,,,)
	oDlg:activate(,,,.T.,{||.T.},,,,)
return (.T.)

static function IMPORTA(cMatrInicial, cMatrFinal)
	local cQuery
	default cMatrInicial := space(tamSx3("RA_MAT")[1])
	default cMatrFinal := replicate("Z", tamSx3("RA_MAT")[1])

	// Verifica se existe registro para o filtro
	if (select("QRYNUM") > 0)
		dbSelectArea("QRYNUM")
		dbCloseArea()
	endif
	cQuery := "SELECT "
	cQuery +=     "COUNT(*) NUM "
	cQuery += "FROM "+retSqlName("ST1")+" ST1 "
	cQuery += "WHERE "
	cQuery +=     "D_E_L_E_T_ <> '*' "
	cQuery +=     "AND T1_FILIAL = '"+xFilial("ST1")+"' "
	cQuery +=     "AND T1_CODFUNC IN ( "
	cQuery +=         "SELECT "
	cQuery +=             "RA_MAT "
	cQuery +=         "FROM "+retSqlName("SRA")+" SRA "
	cQuery +=         "WHERE "
	cQuery +=             "SRA.D_E_L_E_T_ <> '*' "
	cQuery +=             "AND RA_SITFOLH <> 'D' "
	cQuery +=             "AND RA_MAT BETWEEN '"+cMatrInicial+"' AND '"+cMatrFinal+"' "
	cQuery +=     ") "
	TCQUERY cQuery New Alias "QRYNUM"
	QRYNUM->(dbSelectArea("QRYNUM"))
	QRYNUM->(dbGoTop())
	if (QRYNUM->(eof()) .or. QRYNUM->NUM = 0)
		msgAlert("N�o h� registros v�lidos para o filtro informado.")
		return (.F.)
	endif
	// Mensagem de confirma��o
	if (!msgYesNo("Deseja importar o sal�rio hora de "+cValToChar(QRYNUM->NUM)+" funcion�rio(s) para o m�dulo Manuten��o de Ativos?", "Importa��o de Sal�rio Hora"))
		return(.F.)
	endif

	// Atualiza a informa��o de sal�rio hora dos funcion�rios (ST1)
	cQuery := "UPDATE "+retSqlName("ST1")+" "
	cQuery += "SET T1_SALARIO = ( "
	cQuery +=     "SELECT "
	cQuery +=         "RA_SALARIO/RA_HRSMES "
	cQuery +=     "FROM "+retSqlName("SRA")+" SRA "
	cQuery +=     "WHERE "
	cQuery +=         "SRA.D_E_L_E_T_ <> '*' "
	cQuery +=         "AND T1_CODFUNC = RA_MAT "
	cQuery += ") "
	cQuery += "WHERE "
	cQuery +=     "D_E_L_E_T_ <> '*' "
	cQuery +=     "AND T1_FILIAL = '"+xFilial("ST1")+"' "
	cQuery +=     "AND T1_CODFUNC IN ( "
	cQuery +=         "SELECT "
	cQuery +=             "RA_MAT "
	cQuery +=         "FROM "+retSqlName("SRA")+" SRA "
	cQuery +=         "WHERE "
	cQuery +=             "SRA.D_E_L_E_T_ <> '*' "
	cQuery +=             "AND RA_SITFOLH <> 'D' "
	cQuery +=             "AND RA_MAT BETWEEN '"+cMatrInicial+"' AND '"+cMatrFinal+"' "
	cQuery +=     ") "
	if (tcSqlExec(cQuery) < 0)
		msgStop("Erro interno. N�o foi poss�vel realizar a importa��o de sal�rio hora deste(s) funcion�rio(s). Contate o suporte.")
		return(.F.)
	endif
	msgInfo("Importa��o conclu�da.")
return (.T.)