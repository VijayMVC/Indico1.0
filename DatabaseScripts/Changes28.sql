USE [Indico]
GO

DECLARE @Item AS int
DECLARE @Pattern AS int

SET @Item = (SELECT [ID] FROM [dbo].[Item] WHERE [Name] = 'SHIRT PLACKET NECK SET IN' AND [Parent] IS NULL) 
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '070')

DELETE [dbo].[SizeChart]
FROM [dbo].[SizeChart] sc
JOIN [dbo].[MeasurementLocation] ml
	ON sc.[MeasurementLocation] = ml.[ID] 
WHERE Pattern = @Pattern AND ml.[Item] = @Item
GO


DELETE [dbo].[DistributorPriceLevelCost]
FROM [dbo].[DistributorPriceLevelCost] dplc 
WHERE dplc.[Distributor] = 991
GO


DELETE [dbo].[DistributorPriceMarkup]
FROM [dbo].[DistributorPriceMarkup] dpm 
WHERE dpm.[Distributor] = 991
GO	  
  
/****** Object:  StoredProcedure [dbo].[SPC_DeleteDistributorPriceMarkup]    Script Date: 01/30/2013 15:05:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_DeleteDistributorPriceMarkup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_DeleteDistributorPriceMarkup]
GO

/****** Object:  StoredProcedure [dbo].[SPC_DeleteDistributorPriceMarkup]    Script Date: 01/30/2013 15:05:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_DeleteDistributorPriceMarkup]
(
	@P_Distributor int	
)
AS 
BEGIN

	DECLARE @RetVal int
	
	BEGIN TRY
	
		DELETE [dbo].[DistributorPriceLevelCost]
		FROM [dbo].[DistributorPriceLevelCost] dplc  
		WHERE   dplc.[Distributor] = @P_Distributor 
		
		DELETE [dbo].[DistributorPriceMarkup] 
		FROM [dbo].[DistributorPriceMarkup] dpm 
		WHERE	dpm.[Distributor] = @P_Distributor 
		
		SET @RetVal = 1
	END TRY
	BEGIN CATCH
		SET @RetVal = 0
	END CATCH
	
	SELECT @RetVal AS RetVal
END


GO

--**--**--**--**--**--**--**--** ADD NEW COLUMN TO THE PATTERN TABLE --**--**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[Pattern]
ADD HTSCode NVARCHAR(64) NULL

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**