#Include "Protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BSC_CM1   �Autor  �Alexandre Caetano   � Data � 13/Dez/2017 ���
�������������������������������������������������������������������������͹��
���Desc.     �Busca Custo M�dio (B2_CM1) quando selecionado o produto na  ���
���          �solicita��o de compra                                       ���
�������������������������������������������������������������������������͹��
���Uso       �Exclusivo RISA                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function BSC_CM1()
Local cRet
Local cFilC1
Local cFilB1
Local cProdC1  

ChkFile("SB1")
ChkFile("SB2")
    
cFilC1	:= xFilial("SC1")
cFilB1	:= xFilial("SB1") 		
cProdC1	:= M->C1_PRODUTO

cRet	:= Posicione( "SB2"	,1	,avKey( cFilC1, "B2_FILIAL" ) + avKey( cProdC1, "B2_COD" ) +;
           avKey( Posicione( "SB1"	,1	,cFilB1 + cProdC1	,"B1_LOCPAD" ),"B2_LOCAL" )	,"B2_CM1" )
Return(cRet)