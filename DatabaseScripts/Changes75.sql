USE [Indico]
GO

--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*


DECLARE @ID AS int
DECLARE @Pattern AS int
DECLARE @PSA AS int 
DECLARE @Accessory AS int 
DECLARE @AccConstant AS decimal(8,2) 
DECLARE @TotAccessory AS decimal(8,2)
DECLARE @Price AS decimal(8,2)
DECLARE @AccCost AS decimal(8,2)
SET @TotAccessory = 0
DECLARE CostSheetCursor CURSOR FAST_FORWARD FOR
 
SELECT [ID]
      ,[Pattern]      
  FROM [Indico].[dbo].[CostSheet]
  
OPEN CostSheetCursor 
	FETCH NEXT FROM CostSheetCursor INTO @ID, @Pattern
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		 
			DECLARE AccessoryCursor CURSOR FAST_FORWARD FOR
				 
				SELECT [ID]
					  ,[Accessory]
					  ,[AccConstant]					 
				  FROM [Indico].[dbo].[PatternSupportAccessory]
				  WHERE [Pattern] = @Pattern
				  
				OPEN AccessoryCursor 
					FETCH NEXT FROM AccessoryCursor INTO @PSA, @Accessory, @AccConstant
					WHILE @@FETCH_STATUS = 0 
					BEGIN 
					
						SET @Price = (SELECT SUM(a.[Cost]) FROM [dbo].[Accessory] a WHERE a.[ID] = @Accessory)
						
						SET @AccCost = (@AccConstant * @Price)			
						
						SET @TotAccessory = ROUND((@TotAccessory + @AccCost), 2)
					
											
						FETCH NEXT FROM AccessoryCursor INTO @PSA, @Accessory, @AccConstant
					END
				CLOSE AccessoryCursor 
				DEALLOCATE AccessoryCursor	
				
				
				UPDATE [dbo].[CostSheet] SET [TotalAccessoriesCost]	 = @TotAccessory WHERE [ID] = @ID
				
			SET @Price = 0
			SET @AccCost = 0
			SET @TotAccessory = 0
		
		FETCH NEXT FROM CostSheetCursor INTO @ID, @Pattern
	END
CLOSE CostSheetCursor 
DEALLOCATE CostSheetCursor
GO

--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*--**--**--*/*
