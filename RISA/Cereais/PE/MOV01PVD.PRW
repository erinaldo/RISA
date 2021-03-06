#include 'totvs.ch
#include 'rwmake.ch'
#include 'protheus.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������ͱ�
���Programa  �MOV01PVD   �Autor  � Marcelo Joner      � Data � 19/11/2020 ���
��������������������������������������������������������������������������ͱ�
���Desc.     �Ponto de entrada executado na gera��o do Pedido de Venda via���
���          �faturamento de Romaneios de Sa�da.                          ���
��������������������������������������������������������������������������ͱ�
���Uso       � Gest�o de Cereais                                          ���
��������������������������������������������������������������������������ͱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MOV01PVD()

Local aArea := GetArea()

//�������������������������������������������������
//�Havendo Ct. Venda vinculado, replica Req. Frete�
//�������������������������������������������������
If !EMPTY((cAliasTMP)->CV)
    dbSelectArea("ZDP")
    ZDP->(dbSetOrder(1))
    ZDP->(dbGoTop())
    If ZDP->(dbSeek(SUBSTR((cAliasTMP)->CV, 3, TAMSX3("ZDP_FILIAL")[1]) + (cAliasTMP)->CV))
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
    EndIf
EndIf

RestArea(aArea)

Return
