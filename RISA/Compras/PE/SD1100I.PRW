/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � SD1100I  �Autor  �Lincoln Rossetto    � Data �   03/06/09  ���
�������������������������������������������������������������������������͹��
���Desc.     �  Ponto de Entrada  chamado na inclus�o de cada item do     ���
v���          � documento de entrada (inclus�o)                           ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao de Cereais                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SD1100I()
    
 



              



//                                            ^
//                                            |
/*Implemente o ponto de entrada antes da chamada do Bloco de Fun��o do Gest�o de Cereais....*/
//**************************************************************************************************************************************
//������������������������������������������������������������������������������������������������������������������������������������Ŀ
//� Espec�fico para ser utilizado pelo Gest�o de Cereais 																			  �
//�������������������������������������������������������������������������������������������������������������������������������������
If ExistBlock("xSD1100I")
	ExecBlock("xSD1100I", .F., .F. )
EndIf

Return     