#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������`���������������������������ͻ��
���Programa  �CXESP07   �Autor  �Marcelo Joner        � Data � 09/04/2018 ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o executada no recalculo das informa��es de pesagem na ���
���          �rotina personalizada de Pesagens. Utilizado para recalculo  ���
���          �das informa��es de classifica��o.                           ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Risa S/A                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CXESP07()

Local aArea			:= GetArea()
Local lUpdCla		:= .F.
Local lUpdSub		:= .F.
Local nI			:= 0
Local cTpCt			:= SUBSTR(cDocumento, 1, 2)
Local cTpOper		:= IIF(cTpCt == "CC" .or. cTipoPesagem = "07", "G3", IIF(cTpCt == "CV", "G8", "G7"))
Local nQtdDesCla	:= aScan(aHeaderClas,{|x| ALLTRIM(x[2]) == 'ZCC_QUANT'})

//���������������������������������������������������������
//�Executa regras caso existam defini��es de classifica��o�
//���������������������������������������������������������
If Len(aColsClas2) > 0

	//�������������������������������������������������������������������������
	//�Executa fun��o do Addon Gest�o de Cereais para calculo da classifica��o�
	//�������������������������������������������������������������������������
	nPesoBalanca := nPesoBruto - nPesoTara
	U_MOV01PCLA(nPesoBalanca, lUpdCla, lUpdSub, cTpOper)

	//���������������������������������������������������������
	//�Atualiza os totais da pesagem com base na classifica��o�
	//���������������������������������������������������������
	nPesoDesconto := 0
	For nI := 1 To Len(aColsClas)
		dbSelectArea("ZCH")
		ZCH->(dbSetOrder(1))
		ZCH->(dbGoTop())
		ZCH->(dbSeek(xFilial("ZCH") + aColsClas2[nI][1]))

		//������������������������������������������������������������������������
		//�Desconto do item de classifica��o comp�e o total de descontos da carga�
		//������������������������������������������������������������������������
		If ZCH->ZCH_CARGA != "2"
			nPesoDesconto += ROUND(aColsClas[nI][nQtdDesCla], 0)
		EndIf
	Next nI

	//�����������������������������
	//�Recalcula totais da pesagem�
	//�����������������������������
	nPesoBalanca := nPesoBruto - nPesoTara
	nPesoLiquido := nPesoBalanca - nPesoDesconto
EndIf

RestArea(aArea)

Return