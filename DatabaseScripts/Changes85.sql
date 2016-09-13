USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetIndimanPriceListData]    Script Date: 02/03/2014 14:26:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetIndimanPriceListData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetIndimanPriceListData]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetIndimanPriceListData]    Script Date: 02/03/2014 14:26:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[SPC_GetIndimanPriceListData](

@P_Distributor AS int

)

AS


BEGIN
	
	SET NOCOUNT OFF
	
	SELECT  eplcv.[SportsCategory] AS 'SportsCategory',
		    ISNULL(eplcv.[OtherCategories], '') AS 'OtherCategories',
		    eplcv.[PatternID] AS 'PatternID',
		    ISNULL(eplcv.[ItemSubCategoris], '') AS 'ItemSubCategoris',
		    eplcv.[NickName] AS 'NickName',
		    eplcv.[FabricCodeName] AS 'FabricName',
		    eplcv.[FabricCodenNickName] AS 'FabricCodenNickName', 
		    eplcv.[Number] AS 'Number',
		    eplcv.[ConvertionFactor] AS 'ConvertionFactor', 
			plc.[Price] AS 'Price',
			plc.[ID] AS 'PriceLevelCost',			
			plc.[PriceLevel] AS 'PriceLevel',
			plc.[FactoryCost] AS 'FactoryCost',
			plc.[IndimanCost] AS 'IndimanCost',
			ISNULL(dpm.[Distributor], 0) AS 'Distribuotor',
			dpm.[Markup] AS 'Markup',			
			( SELECT CASE
			
				WHEN (ISNULL((SELECT dplc.[IndicoCost] FROM DistributorPriceLevelCost dplc WITH (NOLOCK)
							  WHERE	((@P_Distributor = 0 AND dplc.[Distributor] IS NULL) 
									OR dplc.[Distributor] = @P_Distributor)								 
									AND dplc.PriceTerm = 1
									AND dplc.PriceLevelCost = plc.ID), 0.00) = 0.00)
					THEN(ISNULL(((100 * plc.[IndimanCost])/ (100 - dpm.[Markup])), 0.00))
				ELSE(ISNULL((SELECT dplc.IndicoCost FROM DistributorPriceLevelCost dplc WITH (NOLOCK)
							  WHERE	 ((@P_Distributor = 0 AND dplc.[Distributor] IS NULL) 
									 OR dplc.[Distributor] = @P_Distributor)
									AND dplc.PriceTerm = 1
									AND dplc.PriceLevelCost = plc.ID), 0.00))
			 END ) AS EditedCIFPrice,		
			 
			 (SELECT CASE
			 		WHEN (ISNULL((SELECT dplc.IndicoCost 
								 FROM	 DistributorPriceLevelCost dplc WITH (NOLOCK)
						         WHERE	((@P_Distributor = 0 AND dplc.[Distributor] IS NULL) 
										OR dplc.[Distributor] = @P_Distributor)
										AND dplc.PriceTerm = 2
										AND dplc.PriceLevelCost = plc.ID), 0.00) = 0.00)
					THEN (ISNULL(((100 * (plc.[IndimanCost] - eplcv.[ConvertionFactor])) / (100 - dpm.[Markup])), 0.00))
					ELSE (SELECT CASE
							WHEN (ISNULL((SELECT dplc.IndicoCost 
										  FROM	 DistributorPriceLevelCost dplc WITH (NOLOCK)
										  WHERE	 ((@P_Distributor = 0 AND dplc.[Distributor] IS NULL) 
												 OR dplc.[Distributor] = @P_Distributor)
												 AND dplc.PriceTerm = 2
												 AND dplc.PriceLevelCost = plc.ID), 0.00) = 0.00)
							THEN (SELECT CASE 
										WHEN (ISNULL((SELECT dplc.IndicoCost FROM DistributorPriceLevelCost dplc WITH (NOLOCK)
																			  WHERE	((@P_Distributor = 0 AND dplc.[Distributor] IS NULL) 
																					 OR dplc.[Distributor] = @P_Distributor)
																					 AND dplc.PriceTerm = 1
																					 AND dplc.PriceLevelCost = plc.ID), 0.00) = 0.00) 
										THEN (0.00) 
										
										ELSE (ISNULL(((SELECT dplc.IndicoCost FROM DistributorPriceLevelCost dplc WITH (NOLOCK)
																			  WHERE	((@P_Distributor = 0 AND dplc.[Distributor] IS NULL) 
																			  OR dplc.[Distributor] = @P_Distributor)
																			  AND dplc.PriceTerm = 1
																			  AND dplc.PriceLevelCost = plc.ID) - eplcv.[ConvertionFactor]) / (1 - ((100 - ((plc.[IndimanCost] * 100)/(SELECT dplc.IndicoCost FROM DistributorPriceLevelCost dplc WITH (NOLOCK)
																																													   WHERE ((@P_Distributor = 0 AND dplc.[Distributor] IS NULL) 
																																													   OR dplc.[Distributor] = @P_Distributor)
																																													   AND dplc.PriceTerm = 1
																																													   AND dplc.PriceLevelCost = plc.ID))) / 100)), 0.00))
							      END)
							ELSE (ISNULL((SELECT dplc.IndicoCost 
										  FROM	 DistributorPriceLevelCost dplc WITH (NOLOCK)
										  WHERE	 ((@P_Distributor = 0 AND dplc.[Distributor] IS NULL) 
												 OR dplc.[Distributor] = @P_Distributor)
												 AND dplc.PriceTerm = 2
												 AND dplc.PriceLevelCost = plc.ID), 0.00))
						  END )
						
			  END ) AS EditedFOBPrice,			
			GETDATE() AS 'ModifiedDate'	 
	FROM PriceLevelCost plc WITH (NOLOCK)
		 JOIN DistributorPriceMarkup dpm WITH (NOLOCK)
			ON plc.PriceLevel = dpm.PriceLevel	
		 JOIN [dbo].[ExcelPriceLevelCostView] eplcv
			ON plc.Price = eplcv.[PriceID]
	WHERE (@P_Distributor = 0 AND dpm.[Distributor] IS NULL) 
		OR dpm.[Distributor] = @P_Distributor 
	ORDER BY eplcv.[SportsCategory]	

END

GO


--**-***--**-***--**-***--**-***--**-***--**-***--**-***--**-***--**-***--**-***--**-***--**-***--**-***--**-***--**-***--**-***--**-***--**-***--**-***--**-***

/****** Object:  View [dbo].[ReturnIndimanPriceListDataView]    Script Date: 02/03/2014 14:34:32 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnIndimanPriceListDataView]'))
DROP VIEW [dbo].[ReturnIndimanPriceListDataView]
GO

/****** Object:  View [dbo].[ReturnIndimanPriceListDataView]    Script Date: 02/03/2014 14:34:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnIndimanPriceListDataView]
AS

	SELECT     '' AS 'SportsCategory',
			   '' AS 'OtherCategories', 
			   0 AS 'PatternID', 
			   '' AS 'ItemSubCategoris',
			   '' AS 'NickName',
			   '' AS 'FabricName',
			   '' AS 'FabricCodenNickName', 
			   '' AS 'Number', 
			   0.0 AS 'ConvertionFactor', 
			   0 AS 'Price',
			   0 AS 'PriceLevelCost',			
			   0 AS 'PriceLevel',
			   0.0 AS 'FactoryCost',
			   0.0 AS 'IndimanCost',
			   0 AS 'Distribuotor',
			   0.0 AS 'Markup',			
			   0.0 AS 'EditedCIFPrice',
			   0.0 AS 'EditedFOBPrice',			
			   GETDATE() AS 'ModifiedDate'
			 


GO


