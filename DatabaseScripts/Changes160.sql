USE [Indico]
GO

/****** Object:  View [dbo].[CostSheetDetailsView]    Script Date: 10/08/2015 16:08:15 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CostSheetDetailsView]'))
DROP VIEW [dbo].[CostSheetDetailsView]
GO

/****** Object:  View [dbo].[CostSheetDetailsView]    Script Date: 10/08/2015 16:08:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[CostSheetDetailsView]
AS
SELECT ch.[ID] AS CostSheet
      ,p.[Number] + ' - ' + p.[NickName] AS Pattern
      ,fc.[Code] + ' - ' + fc.[Name]  AS Fabric    
      --,ISNULL(ch.[QuotedFOBCost], ISNULL(ch.[JKFOBCost], 0.00)) QuotedFOBCost 
      ,(
		ISNULL(ch.[QuotedFOBCost], ISNULL(
			((ISNULL(p.[SMV], 0.00) * ISNULL(ch.[SMVRate], 0.00)))
		   + ISNULL(ch.[TotalFabricCost], 0.00)
		   + ISNULL(ch.[TotalAccessoriesCost], 0.00)
		   + ISNULL(ch.[HPCost], 0.00)
		   + ISNULL(ch.[LabelCost], 0.00)
		   + ISNULL(ch.[Other], 0.00)
		   + ( (ISNULL(ch.[TotalAccessoriesCost], 0.00) + ISNULL(ch.[HPCost], 0.00)+ ISNULL(ch.[LabelCost], 0.00)+ ISNULL(ch.[Other], 0.00)) * 1.03  )
		   + ((ISNULL(ch.[TotalFabricCost], 0.00) + ISNULL(ch.[TotalAccessoriesCost], 0.00) + ISNULL(ch.[HPCost], 0.00) + ISNULL(ch.[LabelCost], 0.00) + ISNULL(ch.[Other], 0.00) + (( (ISNULL(ch.[TotalAccessoriesCost], 0.00) + ISNULL(ch.[HPCost], 0.00)+ ISNULL(ch.[LabelCost], 0.00)+ ISNULL(ch.[Other], 0.00)) * 1.03  )) ) * 1.04)
        , 0.00)
        )
        ) QuotedFOBCost    
      ,ISNULL(ch.[QuotedCIF], 0.00) AS QuotedCIF     
      ,ISNULL(ch.[QuotedMP], 0.00) AS QuotedMP
      ,ISNULL(ch.[ExchangeRate], 0.00) AS ExchangeRate   
      ,ISNULL(cat.[Name], '') AS Category
      ,ISNULL(p.[SMV], 0.00) AS SMV
      ,ISNULL(ch.[SMVRate], 0.00) AS SMVRate
      --,ISNULL(ch.[CalculateCM], 0.00) AS CalculateCM
      ,(ISNULL(p.[SMV], 0.00) * ISNULL(ch.[SMVRate], 0.00)) AS CalculateCM
      ,ISNULL(ch.[TotalFabricCost], 0.00) AS TotalFabricCost
      ,ISNULL(ch.[TotalAccessoriesCost], 0.00) AS TotalAccessoriesCost 
      ,ISNULL(ch.[HPCost], 0.00) AS HPCost
      ,ISNULL(ch.[LabelCost], 0.00) AS LabelCost 
      --,ISNULL(ch.[CM], 0.00) AS CM 
      ,(ISNULL(p.[SMV], 0.00) * ISNULL(ch.[SMVRate], 0.00)) AS CM 
      ,ISNULL(ch.[JKFOBCost], 0.00) AS JKFOBCost 
      ,ISNULL(ch.[Roundup], 0.00) AS Roundup 
      ,ISNULL(ch.[DutyRate], 0.00) AS DutyRate 
      ,ISNULL(ch.[SubCons], 0.00) AS SubCons 
      ,ISNULL(ch.[MarginRate], 0.00) AS MarginRate 
      --,ISNULL(ch.[Duty], 0.00) AS Duty 
      ,(((SELECT CASE WHEN (ISNULL(ch.[ExchangeRate], 0.00) =0) THEN 0 ELSE (ISNULL(ch.[QuotedFOBCost], ISNULL(ch.[JKFOBCost], 0.00)) / ISNULL(ch.[ExchangeRate], 0.00)) END )) * ISNULL(ch.[DutyRate], 0.00)) AS Duty 
      --,ISNULL(ch.[FOBAUD], 0.00) AS FOBAUD
      ,(SELECT CASE WHEN (ISNULL(ch.[ExchangeRate], 0.00) =0) THEN 0 ELSE (ISNULL(ch.[QuotedFOBCost], ISNULL(ch.[JKFOBCost], 0.00)) / ISNULL(ch.[ExchangeRate], 0.00)) END )  AS FOBAUD
      ,ISNULL(ch.[AirFregiht], 0.00) AS AirFregiht 
      ,ISNULL(ch.[ImpCharges], 0.00) AS ImpCharges 
      --,ISNULL(ch.[Landed], 0.00) AS Landed 
      ,(
			(SELECT CASE WHEN (ISNULL(ch.[ExchangeRate], 0.00) =0) THEN 0 ELSE (ISNULL(ch.[QuotedFOBCost], ISNULL(ch.[JKFOBCost], 0.00)) / ISNULL(ch.[ExchangeRate], 0.00)) END )
			+ (((SELECT CASE WHEN (ISNULL(ch.[ExchangeRate], 0.00) =0) THEN 0 ELSE (ISNULL(ch.[QuotedFOBCost], ISNULL(ch.[JKFOBCost], 0.00)) / ISNULL(ch.[ExchangeRate], 0.00)) END )) * ISNULL(ch.[DutyRate], 0.00))
			+ (ISNULL(ch.[CONS1], 0.00) * ISNULL(ch.[Rate1], 0.00) )
			+ (ISNULL(ch.[CONS2], 0.00) * ISNULL(ch.[Rate2], 0.00) )
			+ (ISNULL(ch.[CONS3], 0.00) * ISNULL(ch.[Rate3], 0.00) ) 
			+ (ISNULL(ch.[InkCons], 0.00) * ISNULL(ch.[InkRate], 0.00) * 1.02)
			+ (ISNULL(ch.[PaperCons], 0.00) * ISNULL(ch.[PaperRate], 0.00) * 1.02 )
			+ ISNULL(ch.[AirFregiht], 0.00)
			+ ISNULL(ch.[ImpCharges], 0.00)
			+ ISNULL(ch.[MGTOH], 0.00)
			+ ISNULL(ch.[IndicoOH], 0.00)
			+ ISNULL(ch.[Depr], 0.00)
      ) AS Landed
      ,ISNULL(ch.[MGTOH], 0.00) AS MGTOH
      ,ISNULL(ch.[IndicoOH], 0.00) AS IndicoOH 
      --,ISNULL(ch.[InkCost], 0.00) AS InkCost 
      ,(ISNULL(ch.[InkCons], 0.00) * ISNULL(ch.[InkRate], 0.00) * 1.02)  AS InkCost 
      --,ISNULL(ch.[PaperCost], 0.00) AS PaperCost 
      ,(ISNULL(ch.[PaperCons], 0.00) * ISNULL(ch.[PaperRate], 0.00) * 1.02 ) AS PaperCost
  FROM [Indico].[dbo].[CostSheet] ch
	JOIN [dbo].[Pattern] p
		ON ch.[Pattern] = p.[ID]
	JOIN [dbo].[FabricCode] fc
		ON ch.[Fabric] = fc.[ID]
	JOIN [dbo].[Category] cat
		ON p.[CoreCategory] = cat.[ID]
	WHERE p.[IsActive] = 1

GO


