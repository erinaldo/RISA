#include 'totvs.ch
#include 'rwmake.ch'
#include 'protheus.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������ͱ�
���Programa  �CTV01PVD    �Autor  � Marcelo Joner     � Data � 19/11/2020 ���
��������������������������������������������������������������������������ͱ�
���Desc.     �Ponto de entrada executado na gera��o do Pedido de Venda via���
���          �NF Manual na rotina de Ct. Venda.                           ���
��������������������������������������������������������������������������ͱ�
���Uso       � Gest�o de Cereais                                          ���
��������������������������������������������������������������������������ͱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CTV01PVD()

Local aArea := GetArea()

//�������������������������������������������������
//�Havendo Ct. Venda vinculado, replica Req. Frete�
//�������������������������������������������������
dbSelectArea("ZDP")
If !EMPTY(ZDP->ZDP_CODREQ)
    M->C5_XCODRE := ZDP->ZDP_CODREQ
    
    dbSelectArea("GXS")
    GXS->(dbSetOrder(1))
    GXS->(dbGoTop())
    If GXS->(dbSeek(xFilial("GXS") + M->C5_XCODRE))
        If GXS->GXS_MRKBR == .T.
            M->C5_FRETE := IIF(GXS->GXS_XTIPOF == "2", GXS->GXS_FRTPES, GXS->GXS_FRTPES /1000 * M->C5_PBRUTO)
        EndIf
    EndIf
EndIf

RestArea(aArea)

Return
