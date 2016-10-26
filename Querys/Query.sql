SELECT */*[ID]
      ,[ID_EMP]
      ,[ID_FIL]
      ,[ID_PROC]
      ,[PROCES]
      ,[ID_TRANS]
      ,[TRANSAC]
      ,[ID_ORI]
      ,[ID_ENT]
      ,[XML_ERP]
      ,[DATEINT]
      ,[TIMEINT]
      ,[ID_RET]
      ,[XML_RET]
      ,[DATERET]
      ,[TIMERET]
      ,[XML_ERR]
      ,[STATUS]*/
  FROM [INTEGRACAO].[dbo].[XML]
 WHERE [ID_EMP] = '80'
       [ID_FIL] = '01'
   AND [ID_PROC] = '001'
   AND [STATUS] = 5
GO

INSERT INTO [INTEGRACAO].[dbo].[XML]
           ([ID_EMP]
           ,[ID_FIL]
           ,[ID_PROC]
           ,[PROCES]
           ,[ID_TRANS]
           ,[TRANSAC]
           ,[ID_ORI]
           ,[ID_ENT]
           ,[XML_ERP]
           ,[DATEINT]
           ,[TIMEINT]
           ,[STATUS])
     VALUES
           ('80'
           ,'01'
           ,'001'
           ,'Cliente'
           ,'2'
           ,'Alteração'
           ,'1'
           ,'00000201'
           ,'<CLIENTE>
<ID_EMP><![CDATA[80]]></ID_EMP>
<ID_FIL><![CDATA[01]]></ID_FIL>
<ID_PROC><![CDATA[001]]></ID_PROC>
<PROCES><![CDATA[Cliente]]></PROCES>
<ID_TRANS><![CDATA[2]]></ID_TRANS>
<TRANSAC><![CDATA[Alteração]]></TRANSAC>
<ID_ORI><![CDATA[1]]></ID_ORI>
<ID_ENT><![CDATA[00000201]]></ID_ENT>
<COD_PULSAR><![CDATA[]]></COD_PULSAR>
<RAZÃO_SOCIAL><![CDATA[BANCO BRADESCO SA]]></RAZÃO_SOCIAL>
<NOME_FANTASIA><![CDATA[BANCO BRADESCO]]></NOME_FANTASIA>
<CNPJ><![CDATA[60746948000112]]></CNPJ>
<PESSOA><![CDATA[J]]></PESSOA>
<TIPO><![CDATA[F]]></TIPO>
<INS_ESTAD><![CDATA[ISENTO]]></INS_ESTAD>
<INS_MUNICIP><![CDATA[98077724]]></INS_MUNICIP>
<ENDEREÇO><![CDATA[CIDADE DE DEUS, S/N]]></ENDEREÇO>
<BAIRRO><![CDATA[VILA YARA]]></BAIRRO>
<COMPLEMENTO><![CDATA[]]></COMPLEMENTO>
<CIDADE><CIDADE>
<CODIGO><![CDATA[34401]]></CODIGO>
<DESCRIÇÃO><![CDATA[OSASCO]]></DESCRIÇÃO>
<UF><![CDATA[SAO PAULO]]></UF>
</CIDADE></CIDADE>
<CEP><![CDATA[06029900]]></CEP>
<DDD><![CDATA[011]]></DDD>
<TELEFONE><![CDATA[36845122]]></TELEFONE>
<EMAIL><![CDATA[4260.ARNALDO@BRADESCO.COM.BR	]]></EMAIL>
<GRUPO><![CDATA[OUT]]></GRUPO>
<TIPO_PESSOA><![CDATA[OS]]></TIPO_PESSOA>
<TIPO_CLIENTE><![CDATA[1]]></TIPO_CLIENTE>
<SEGMENTO><![CDATA[000003]]></SEGMENTO>
<CLASSIF_RF><![CDATA[000004]]></CLASSIF_RF>
<SEGMENTO><![CDATA[000003]]></SEGMENTO>
<AGLUTINA_FAT><![CDATA[N]]></AGLUTINA_FAT>
<GERA_BOLETO><![CDATA[N]]></GERA_BOLETO>
<COMPROV_INSERC><![CDATA[N]]></COMPROV_INSERC>
<GERA_CARTA><![CDATA[N]]></GERA_CARTA>
<TIPO_NEGOCIACAO><![CDATA[0]]></TIPO_NEGOCIACAO>
<PORCENTAGEM><![CDATA[0]]></PORCENTAGEM>
<DATA_ABERTURA>  /  /  </DATA_ABERTURA>
</CLIENTE>'
           ,'20160623'
           ,'11:22:41'
           ,0)
GO

UPDATE [INTEGRACAO].[dbo].[XML]
   SET [ID_RET] = 1
      ,[XML_RET] = '<?xml version="1.0" encoding="UTF-8"?>
                    <Cliente>
                      <ID_RET>1</ID_RET>
                    </Cliente>'
      ,[DATERET] = GETDATE()
      ,[TIMERET] = CURRENT_TIMESTAMP
	  ,[STATUS] = 5
WHERE [ID] = 3
GO

CREATE PROCEDURE SP_XML(@ID_EMP NCHAR(2), @ID_FIL NCHAR(2), @ID_PROC NCHAR(3), @STATUS NCHAR(1), @XML XML OUT) AS
BEGIN
set @XML = (SELECT [ID_RET]
              FROM [INTEGRACAO].[dbo].[XML]
             WHERE [ID_EMP] = @ID_EMP
               AND [ID_FIL] = @ID_FIL
               AND [ID_PROC] = @ID_PROC
               AND [STATUS] = @STATUS)
END
GO

use PROTHEUS_DEV01

select * from SIX where INDICE = 'SE1' AND CHAVE LIKE '%E1_FILIAL+E1_NUM+%' ORDER BY INDICE,ORDEM,EMPRESA

select * from SIX where INDICE = 'SE1' AND EMPRESA = '54' ORDER BY EMPRESA,INDICE,ORDEM
