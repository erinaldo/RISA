#include "protheus.ch"
#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTGRDVW   �Autor  �Marcelo Joner       � Data �  25/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada utilizado para adicionar novas informa��es ���
���          �a interface de consulta estoque no cadastro do produto.     ���
�������������������������������������������������������������������������͹��
���Uso       �Gest�o de Cereais                                            ��
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MTGRDVW()
                       




//                                            ^
//                                            |
/*Implemente o ponto de entrada antes da chamada do Bloco de Fun��o do Gest�o de Cereais....*/
//*************************************************************************************************************************************
//�������������������������������������������������������������������������������������������������������������������������������������
//� Espec�fico para ser utilizado pelo Gest�o de Cereais 																			  �
//�������������������������������������������������������������������������������������������������������������������������������������
If ExistBlock("xMTGRDVW")
	ExecBlock("xMTGRDVW", .F., .F., PARAMIXB)
EndIf

Return