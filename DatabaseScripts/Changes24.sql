USE [Indico] 
GO

/****** Object:  StoredProcedure [dbo].[SPC_CloneDistributorPriceMarkup]    Script Date: 01/16/2013 14:18:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_CloneDistributorPriceMarkup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_CloneDistributorPriceMarkup]
GO

USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_CloneDistributorPriceMarkup]    Script Date: 01/16/2013 14:18:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SPC_CloneDistributorPriceMarkup]
(
	@P_ExistDistributor int,
	@P_NewDistributor int
)
AS BEGIN

	DECLARE @RetVal int
	
	BEGIN TRY

		INSERT INTO [dbo].[DistributorPriceMarkup]([Distributor], [PriceLevel], [Markup])
		SELECT @P_NewDistributor,
			   [PriceLevel],
			   [Markup] 				
		FROM [dbo].[DistributorPriceMarkup]
		WHERE (@P_ExistDistributor = 0 AND [Distributor] IS NULL)
		OR [Distributor] = @P_ExistDistributor 

		INSERT INTO [dbo].[DistributorPriceLevelCost] ([Distributor], [PriceTerm], [PriceLevelCost], [IndicoCost], [ModifiedDate], [Modifier])
		SELECT @P_NewDistributor,
			   [PriceTerm],
			   [PriceLevelCost],
			   [IndicoCost],
			   (SELECT (GETDATE())),
			   [Modifier]			
		FROM [dbo].[DistributorPriceLevelCost] 
		WHERE (@P_ExistDistributor = 0 AND [Distributor] IS NULL) 
		OR [Distributor] = @P_ExistDistributor 
		
		SET @RetVal = 1
	END TRY
	BEGIN CATCH
		SET @RetVal = 0
	END CATCH
	
	SELECT @RetVal AS RetVal
END


GO

/****** Object:  View [dbo].[ReturnIntView]    Script Date: 01/16/2013 14:16:30 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnIntView]'))
DROP VIEW [dbo].[ReturnIntView]
GO

USE [Indico]
GO

/****** Object:  View [dbo].[ReturnIntView]    Script Date: 01/16/2013 14:16:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[ReturnIntView] 
AS 
	SELECT  0 as RetVal



GO

