USE[Indico] 
GO

/****** Object:  View [dbo].[PriceLevelCostView]    Script Date: 01/17/2013 11:26:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/********* ALTER VIEW [PriceLevelCostView] *************/
ALTER VIEW [dbo].[PriceLevelCostView]
AS
	SELECT	p.ID,
			p.[Pattern],
			p.[FabricCode],
			pt.[Number],
			pt.[NickName],
			pt.[Item],
			pt.[SubItem],
			pt.[CoreCategory],
			fc.[Name] AS FabricCodeName,
			ISNULL(i.Name, '') AS ItemSubCategory,
			(	SELECT c.Name + ',' AS [text()] 
				FROM Pattern p WITH (NOLOCK)
					JOIN PatternOtherCategory poc 
						ON poc.Pattern = p.ID 
					JOIN Category c WITH (NOLOCK)
						ON poc.Category = c.ID	
				WHERE Number = pt.Number FOR XML PATH('')) AS OtherCategories,
			pt.ConvertionFactor	
	FROM	Indico.dbo.Price p WITH (NOLOCK)
			JOIN Indico.dbo.Pattern pt WITH (NOLOCK)
				ON p.Pattern = pt.ID
			JOIN Indico.dbo.FabricCode fc WITH (NOLOCK)
				ON p.FabricCode = fc.ID
			LEFT OUTER JOIN Indico.dbo.Item i WITH (NOLOCK)
				ON i.ID = pt.[SubItem]	
	INNER JOIN (
		SELECT p.[Pattern] AS PatternId,
				p.[FabricCode] AS FaricCodeId
		FROM	Indico.dbo.Price p WITH (NOLOCK)
				JOIN Indico.dbo.PriceLevelCost plc WITH (NOLOCK)
					ON p.ID	= plc.Price
				JOIN dbo.Pattern pt WITH (NOLOCK)
					ON p.Pattern = pt.ID 
		WHERE pt.IsActive = 1
		GROUP BY p.[Pattern], p.[FabricCode]) G			
			ON p.[Pattern] = G.PatternId
			AND p.[FabricCode] = G.FaricCodeId		
		
GO

/* DELETE EXTRA SIZE CHART VALUES FROM SIZE CHART TABLE, MESUREMENT LOCATION ID = 90*/
 DELETE FROM [dbo].[SizeChart] where [ID] between 4459 and  4476
 
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


/* DELETE EXTRA PRICE DETAILS ----***-- */

DELETE DistributorPriceLevelCost 
FROM  DistributorPriceLevelCost dplc
	JOIN PriceLevelCost plc1
		ON dplc.PriceLevelCost = plc1.ID 
	JOIN Price p
		ON plc1.Price = p.ID
WHERE p.ID IN (626, 960, 40, 570, 329, 87, 979, 499, 503, 1082, 58, 399)		

DELETE PriceLevelCost 
FROM  PriceLevelCost plc1
	JOIN Price p
		ON plc1.Price = p.ID
WHERE p.ID IN (626, 960, 40, 570, 329, 87, 979, 499, 503, 1082, 58, 399)

DELETE Price 
FROM  Price p
WHERE p.ID IN (626, 960, 40, 570, 329, 87, 979, 499, 503, 1082, 58, 399)
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
