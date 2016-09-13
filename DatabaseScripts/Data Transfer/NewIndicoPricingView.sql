USE [Indico]
GO

/****** Object:  View [dbo].[PriceLevelCostView]    Script Date: 08/01/2012 20:58:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[PriceLevelCostView]
AS
	SELECT
			p.ID,
			p.[Pattern],
			p.[FabricCode],
			pt.[Number],
			pt.[NickName],
			pt.[Item],
			pt.[SubItem],
			pt.[CoreCategory],
			fc.[Name]
	FROM	Indico.dbo.Price p
			JOIN Indico.dbo.Pattern pt
				ON p.Pattern = pt.ID
			JOIN Indico.dbo.FabricCode fc
				ON p.FabricCode = fc.ID
	INNER JOIN (
		SELECT p.[Pattern] AS PatternId,
				p.[FabricCode] AS FaricCodeId
		FROM	Indico.dbo.Price p
				JOIN Indico.dbo.PriceLevelCost plc
					ON p.ID	= plc.Price
		GROUP BY p.[Pattern], p.[FabricCode]) G			
	ON p.[Pattern] = G.PatternId
		AND p.[FabricCode] = G.FaricCodeId		

GO

/*	SELECT	p.[ID],
			p.[Pattern],
			p.[FabricCode],
			pt.[Number],
			pt.[NickName],
			pt.[Item],
			pt.[SubItem],
			pt.[CoreCategory],
			fc.[Name],			
			plc.[ID] AS PriceLevelCostID,
			plc.[PriceLevel],
			plc.[FactoryCost],
			plc.[IndimanCost]
	FROM	Indico.dbo.Price p
			JOIN Indico.dbo.Pattern pt
				ON p.Pattern = pt.ID
			JOIN Indico.dbo.FabricCode fc
				ON p.FabricCode = fc.ID
			JOIN Indico.dbo.PriceLevelCost plc
				ON p.ID	= plc.Price 
	INNER JOIN (
		SELECT p.[Pattern] AS PatternId,
				p.[FabricCode] AS FaricCodeId,
				COUNT(*) AS count1
		FROM	Indico.dbo.Price p
				JOIN Indico.dbo.PriceLevelCost plc
					ON p.ID	= plc.Price
		GROUP BY p.[Pattern], p.[FabricCode]) G			
	ON p.[Pattern] = G.PatternId
		AND p.[FabricCode] = G.FaricCodeId
		
		------------------------------------

		SELECT p.[Pattern],
				p.[FabricCode],
				COUNT(*) AS count1
		FROM	Indico.dbo.Price p
				--JOIN Indico.dbo.Pattern pt
				--	ON p.Pattern = pt.ID
				--JOIN Indico.dbo.FabricCode fc
				--	ON p.FabricCode = fc.ID
				JOIN Indico.dbo.PriceLevelCost plc
					ON p.ID	= plc.Price
		GROUP BY p.[Pattern], p.[FabricCode]
		HAVING COUNT(*) > 8
*/


