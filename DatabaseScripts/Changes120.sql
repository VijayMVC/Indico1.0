USE [Indico]
GO

/****** Object:  View [dbo].[PriceLevelCostView]    Script Date: 12/01/2014 09:58:05 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[PriceLevelCostView]'))
DROP VIEW [dbo].[PriceLevelCostView]
GO

/****** Object:  View [dbo].[PriceLevelCostView]    Script Date: 12/01/2014 09:58:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/********* ALTER VIEW [PriceLevelCostView] *************/
CREATE VIEW [dbo].[PriceLevelCostView]
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
			pt.ConvertionFactor,	
			p.[EnableForPriceList]
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


--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

