#include 'totvs.ch
#include 'rwmake.ch'
#include 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ±±
±±ºPrograma  ³MOV01PVD   ºAutor  ³ Marcelo Joner      º Data ³ 19/11/2020 º±±
±±ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ±±
±±ºDesc.     ³Ponto de entrada executado na geração do Pedido de Venda viaº±±
±±º          ³faturamento de Romaneios de Saída.                          º±±
±±ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ±±
±±ºUso       ³ Gestão de Cereais                                          º±±
±±ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
User Function MOV01PVD()

Local aArea := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Havendo Ct. Venda vinculado, replica Req. Frete³
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
