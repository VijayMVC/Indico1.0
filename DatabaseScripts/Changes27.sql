 USE[Indico] 
 GO
  
/****** Object:  View [dbo].[ExcelPriceLevelCostView]    Script Date: 01/29/2013 16:24:52 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ExcelPriceLevelCostView]'))
DROP VIEW [dbo].[ExcelPriceLevelCostView]
GO


/****** Object:  View [dbo].[ExcelPriceLevelCostView]    Script Date: 01/29/2013 16:24:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ExcelPriceLevelCostView]
AS

SELECT		p.ID AS 'PriceID',
			c.Name AS 'SportsCategory',
			(	SELECT c.Name + ',' AS [text()] 
				FROM Pattern p
					JOIN PatternOtherCategory poc 
						ON poc.Pattern = p.ID 
					JOIN Category c
						ON poc.Category = c.ID	
				WHERE Number = pt.Number FOR XML PATH('')) AS 'OtherCategories',
			p.[Pattern] AS 'PatternID',
			(	SELECT  i.Name
				FROM Item i  
				WHERE i.ID = SubItem) AS ItemSubCategoris,
			pt.[NickName],
			fc.[Name] AS FabricCodeName,	
			fc.[NickName] AS FabricCodenNickName,
			pt.[Number],	
			pt.ConvertionFactor	
	FROM	Indico.dbo.Price p
			JOIN Indico.dbo.Pattern pt
				ON p.Pattern = pt.ID
			JOIN Indico.dbo.FabricCode fc
				ON p.FabricCode = fc.ID
			LEFT OUTER JOIN Indico.dbo.Item i
				ON i.ID = pt.[SubItem]
			JOIN Indico.dbo.Category c
				ON pt.CoreCategory = C.ID
	INNER JOIN (
		SELECT p.[Pattern] AS PatternId,
				p.[FabricCode] AS FaricCodeId
		FROM	Indico.dbo.Price p
				JOIN Indico.dbo.PriceLevelCost plc
					ON p.ID	= plc.Price
				JOIN Indico.dbo.Pattern pt 
					ON p.Pattern = pt.ID 
		WHERE pt.IsActive = 1 AND p.[EnableForPriceList] = 1
		GROUP BY p.[Pattern], p.[FabricCode]) G			
			ON p.[Pattern] = G.PatternId
			AND p.[FabricCode] = G.FaricCodeId	

GO

DECLARE @PATID AS int

SET @PATID = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number]='3123' AND [NickName] = 'BASKETBALL SHORTS LADIES ADULT  SIDE PANELS' )    
  
  DELETE [dbo].[SizeChart]  
  FROM [dbo].[SizeChart] sc
  	JOIN [dbo].[Pattern] p 
		ON sc.[Pattern] = p.[ID] 
  WHERE p.[ID] = @PATID
  
  DELETE [dbo].[PatternItemAttributeSub]   
  FROM [dbo].[PatternItemAttributeSub] pias
  	JOIN [dbo].[Pattern] p 
		ON pias.[Pattern] = p.[ID] 
  WHERE p.[ID] = @PATID
  
  DELETE [dbo].[PatternOtherCategory]    
  FROM [dbo].[PatternOtherCategory] poc
  	JOIN [dbo].[Pattern] p 
		ON poc.[Pattern] = p.[ID] 
  WHERE p.[ID] = @PATID
  
  DELETE [dbo].[Pattern]  
  FROM [dbo].[Pattern] p 
  WHERE p.[ID] = @PATID