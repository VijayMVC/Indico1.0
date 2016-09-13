--**----**----**----**-- DELETE DISTRIBUTORPRICELEVELCOST DUPLICATE RECORD --**----**----**----**----**--
DECLARE @Pattern AS int
DECLARE @PriceID AS int
DECLARE @DPLCID AS int
DECLARE @ID AS int

SET @Pattern = (SELECT [ID] FROM [Indico].[dbo].[Pattern] WHERE [Number] = '1883')

SET @PriceID = (SELECT [ID] FROM [Indico].[dbo].[Price] WHERE [Pattern] = @Pattern AND [FabricCode] = 52)

DECLARE Deletedplc CURSOR FAST_FORWARD FOR 
 
SELECT [ID] 
FROM [Indico].[dbo].[PriceLevelCost] 
WHERE [Price] = @PriceID

OPEN Deletedplc 
	FETCH NEXT FROM Deletedplc INTO @ID
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
	 SET @DPLCID = (SELECT TOP 1 [ID]FROM [Indico].[dbo].[DistributorPriceLevelCost] WHERE [PriceLevelCost] = @ID)
	 
	 DELETE [Indico].[dbo].[DistributorPriceLevelCost] WHERE [ID] = @DPLCID 
	 
		FETCH NEXT FROM Deletedplc INTO @ID
	END 

CLOSE Deletedplc 
DEALLOCATE Deletedplc	

GO

--**----**----**----**-- DELETE DISTRIBUTORPRICELEVELCOST WHERE PATTERN RECORD 620--**----**----**----**----**--

/*DECLARE @Pattern AS int
DECLARE @PriceID AS int
DECLARE @DPLCID AS int
DECLARE @ID AS int

SET @Pattern = (SELECT [ID] FROM [Indico].[dbo].[Pattern] WHERE [Number] = '620')

SET @PriceID = (SELECT [ID] FROM [Indico].[dbo].[Price] WHERE [Pattern] = @Pattern AND [FabricCode] = 5)

DECLARE Deletedplc CURSOR FAST_FORWARD FOR 
 
SELECT [ID] 
FROM [Indico].[dbo].[PriceLevelCost] 
WHERE [Price] = @PriceID

OPEN Deletedplc 
	FETCH NEXT FROM Deletedplc INTO @ID
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
	 SET @DPLCID = (SELECT TOP 1 [ID]FROM [Indico].[dbo].[DistributorPriceLevelCost] WHERE [PriceLevelCost] = @ID)
	 
	 DELETE [Indico].[dbo].[DistributorPriceLevelCost] WHERE [ID] = @DPLCID 
	 
		FETCH NEXT FROM Deletedplc INTO @ID
	END 

CLOSE Deletedplc 
DEALLOCATE Deletedplc	

GO*/
