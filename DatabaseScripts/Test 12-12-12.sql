USE [Indico]
GO
/****** Object:  View [dbo].[DistributorNullPatternPriceLevelCostView]    Script Date: 12/12/2012 12:28:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[DistributorNullPatternPriceLevelCostView]
AS
	SELECT	plc.ID,
			plc.Price,
			plc.PriceLevel,
			plc.FactoryCost,
			plc.IndimanCost,
			dpm.Distributor,
			dpm.Markup,
			(	SELECT	TOP 1 dplc.IndicoCost 
				FROM	DistributorPriceLevelCost dplc WITH (NOLOCK)
				WHERE	dplc.Distributor is null
						AND dplc.PriceTerm = 1
						AND dplc.PriceLevelCost = plc.ID) AS EditedCIFPrice,
			(	SELECT	TOP 1 dplc.IndicoCost 
				FROM	DistributorPriceLevelCost dplc WITH (NOLOCK)
				WHERE	dplc.Distributor is null
						AND dplc.PriceTerm = 2
						AND dplc.PriceLevelCost = plc.ID) AS EditedFOBPrice,
			(	SELECT	TOP 1 CONVERT(VARCHAR(12), dplc.ModifiedDate, 113)
				FROM	DistributorPriceLevelCost dplc WITH (NOLOCK)
				WHERE	dplc.Distributor is null
						AND dplc.PriceTerm = 1
						AND dplc.PriceLevelCost = plc.ID) AS ModifiedDate
	FROM PriceLevelCost plc WITH (NOLOCK)
		 JOIN DistributorPriceMarkup dpm WITH (NOLOCK)
			ON plc.PriceLevel = dpm.PriceLevel
	WHERE dpm.Distributor IS NULL AND plc.Price = 1223	

GO

SELECT	dplc.* 
FROM	DistributorPriceLevelCost dplc WITH (NOLOCK)
WHERE	dplc.Distributor is null
		AND dplc.PriceTerm = 1
		AND dplc.PriceLevelCost = 9784

