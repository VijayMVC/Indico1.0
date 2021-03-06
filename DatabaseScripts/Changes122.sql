USE [Indico]
GO

--SELECT [Fabric]
--FROM [dbo].[CostSheet]
--WHERE [Fabric] NOT IN (SELECT [FabricCode] FROM [dbo].[Price] WHERE [Pattern] = 290) AND [Pattern] = 290


--DECLARE @ID AS int
DECLARE @Pattern AS int
DECLARE @Fabric AS int
DECLARE @NotFabric AS int 
DECLARE @Price AS int 
DECLARE @PriceLevel AS int 
DECLARE @FobCost AS decimal(8,2)
DECLARE @CIF AS decimal(8,2)

DECLARE CostSheetCursor CURSOR FAST_FORWARD FOR 
SELECT [Pattern]
	  ,[Fabric]	
FROM [dbo].[CostSheet]
OPEN CostSheetCursor 
	FETCH NEXT FROM CostSheetCursor INTO @Pattern, @Fabric
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
	
			------------------------------------
			
			DECLARE CostSheetFabricCursor CURSOR FAST_FORWARD FOR 
			SELECT [Fabric]
				  ,ISNULL(ISNULL([QuotedFOBCost], [JKFOBCost]),0.00)
				  ,ISNULL(ISNULL([QuotedCIF], [IndimanCIF]),0.00)
			FROM [dbo].[CostSheet]
			WHERE [Fabric] NOT IN (SELECT [FabricCode] FROM [dbo].[Price] WHERE [Pattern] = @Pattern) AND [Pattern] = @Pattern
			OPEN CostSheetFabricCursor 
				FETCH NEXT FROM CostSheetFabricCursor INTO @NotFabric, @FobCost, @CIF
				WHILE @@FETCH_STATUS = 0 
				BEGIN 
				
				INSERT INTO [dbo].[Price] ([Pattern], [FabricCode], [Remarks], [Creator], [CreatedDate], [Modifier], [ModifiedDate], [EnableForPriceList])
				VALUES (@Pattern, @NotFabric, NULL, 1, GETDATE(), 1, GETDATE(), 0)
				
				SET @Price = SCOPE_IDENTITY()
				
				
				-----------------------------------
						DECLARE PriceLavelCursor CURSOR FAST_FORWARD FOR 
						SELECT [ID]     
						FROM [Indico].[dbo].[PriceLevel]
						OPEN PriceLavelCursor 
							FETCH NEXT FROM PriceLavelCursor INTO @PriceLevel
							WHILE @@FETCH_STATUS = 0 
							BEGIN 
							
									INSERT INTO [dbo].[PriceLevelCost] ([Price], [PriceLevel], [FactoryCost], [IndimanCost], [Creator], [CreatedDate], [Modifier], [ModifiedDate])
									VALUES(@Price, @PriceLevel, @FobCost, @CIF, 1, GETDATE(), 1, GETDATE())
							 
							
								FETCH NEXT FROM PriceLavelCursor INTO @PriceLevel
							END 

						CLOSE PriceLavelCursor 
						DEALLOCATE PriceLavelCursor	
				
				-----------------------------------
				
				
					FETCH NEXT FROM CostSheetFabricCursor INTO @NotFabric, @FobCost, @CIF
				END 

			CLOSE CostSheetFabricCursor 
			DEALLOCATE CostSheetFabricCursor	
						
			
			------------------------------------
	
	
	
		FETCH NEXT FROM CostSheetCursor INTO @Pattern, @Fabric
	END 

CLOSE CostSheetCursor 
DEALLOCATE CostSheetCursor		
-----/--------
GO

--SELECT [ID]
--      ,[Pattern]
--      ,[FabricCode]     
--FROM [dbo].[Price] p
--WHERE p.[FabricCode] NOT IN (SELECT [Fabric] FROM [dbo].[CostSheet] WHERE [Pattern] = 290) AND [Pattern] = 290