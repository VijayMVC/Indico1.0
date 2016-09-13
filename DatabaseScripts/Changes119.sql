USE [Indico]
GO

ALTER TABLE [dbo].[PatternSupportAccessory]
ADD [CostSheet] int NULL
GO


--DECLARE @ID AS int
DECLARE @AccConstant AS decimal(8,2)
DECLARE @Pattern AS int
DECLARE @ID AS int
DECLARE @CostSheet AS int
DECLARE @Accessory AS int 
DECLARE @AccCostSheet AS TABLE (costsheet int, accessory int, pattern int, const decimal(8,2), psa int)

DECLARE AccessoryCostSheet CURSOR FAST_FORWARD FOR 
SELECT [ID]
	  ,[Accessory]
	  ,[AccConstant]
      ,[Pattern]
  FROM [Indico].[dbo].[PatternSupportAccessory] 
OPEN AccessoryCostSheet 

	FETCH NEXT FROM AccessoryCostSheet INTO @ID, @Accessory, @AccConstant, @Pattern 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 	
		
	--***-**--***-**--***-**--***-**--***-**--***-**--***-**
	
	DECLARE @Round AS int  = 1
	
						DECLARE NewCostSheet CURSOR FAST_FORWARD FOR 
							SELECT [ID]
							  FROM [Indico].[dbo].[CostSheet]
							  WHERE [Pattern] = @Pattern
							  
						OPEN NewCostSheet 

							FETCH NEXT FROM NewCostSheet INTO @CostSheet
							WHILE @@FETCH_STATUS = 0 
							BEGIN 						
						
							
							IF(@Round = 1)
								BEGIN 
								
								INSERT @AccCostSheet(costsheet, accessory, pattern, const, psa) VALUES(@CostSheet, @Accessory, @Pattern, @AccConstant, @ID)
								
								SET @Round  = @Round + 1
								
								END
							ELSE
								BEGIN 
									
									INSERT @AccCostSheet(costsheet, accessory, pattern, const, psa) VALUES(@CostSheet, @Accessory, @Pattern, @AccConstant, 0)									
								
								END
									
							FETCH NEXT FROM NewCostSheet INTO @CostSheet
							END 

						CLOSE NewCostSheet 
						DEALLOCATE NewCostSheet		
	
	
	--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**
	
	
		FETCH NEXT FROM AccessoryCostSheet INTO @ID, @Accessory, @AccConstant, @Pattern 
	END 
CLOSE AccessoryCostSheet 
DEALLOCATE AccessoryCostSheet		
-----/--------
--GO

DECLARE @cssheet AS int
DECLARE @acc AS int
DECLARE @pat AS int
DECLARE @const AS decimal(8,2)
DECLARE @psa AS int

DECLARE LabelCursor CURSOR FAST_FORWARD FOR 

SELECT costsheet
	  ,accessory
	  ,pattern
	  ,const
	  ,psa
FROM @AccCostSheet

OPEN LabelCursor 
	FETCH NEXT FROM LabelCursor INTO @cssheet, @acc, @pat, @const, @psa
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
			IF(@psa > 0)
				BEGIN
					UPDATE [dbo].[PatternSupportAccessory] SET [CostSheet] = @cssheet WHERE [ID] = @psa
				END
			ELSE
				BEGIN
				
						INSERT INTO [dbo].[PatternSupportAccessory] ([Accessory], [AccConstant], [Pattern], [CostSheet]) 
									VALUES (@acc, @const, @pat, @cssheet)
				
				END
	
		FETCH NEXT FROM LabelCursor INTO @cssheet, @acc, @pat, @const, @psa
	END 

CLOSE LabelCursor 
DEALLOCATE LabelCursor		
-----/--------
GO


ALTER TABLE [dbo].[PatternSupportAccessory]
ALTER COLUMN [CostSheet] int NOT NULL
GO

ALTER TABLE [dbo].[PatternSupportAccessory] WITH CHECK ADD CONSTRAINT [FK_PatternSupportAccessory_CostSheet] FOREIGN KEY ([CostSheet])
REFERENCES [dbo].[CostSheet] ([ID])
GO

ALTER TABLE [dbo].[PatternSupportAccessory] CHECK CONSTRAINT [FK_PatternSupportAccessory_CostSheet]
GO



UPDATE [dbo].[PriceLevelCost] SET [IndimanCost] = 22.35 WHERE [Price] = (SELECT [ID] FROm [dbo].[Price] WHERE [Pattern] = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '3024'))
GO

--SELECT * FROM @AccCostSheet	ORDER BY pattern