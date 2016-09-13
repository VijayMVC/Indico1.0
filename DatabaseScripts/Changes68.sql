USE [Indico]
GO

DECLARE @ID AS int
DECLARE @Pattern AS int
DECLARE @TotalFabricCost AS decimal(8,2)
DECLARE @TotalAccessoriesCost AS decimal(8,2)
DECLARE @HPCost AS decimal(8,2)
DECLARE @LabelCost AS decimal(8,2)
DECLARE @Other AS decimal(8,2) 
DECLARE @Finance AS decimal(8,2)
DECLARE @Wastage AS decimal(8,2)
DECLARE @CM AS decimal(8,2)
DECLARE @DutyRate AS decimal(8,2)
DECLARE @MarginRate AS decimal(8,2)
DECLARE @Accessory AS int 
DECLARE @Const AS decimal(8,2)
DECLARE @AccPattern AS int
DECLARE @Fabric AS int
DECLARE @FabConstant AS decimal(8,2)
DECLARE @CostSheet AS int
DECLARE @AccessoryCost AS decimal(8,2)
DECLARE @AccessoryTotal AS decimal(8,2)
DECLARE @ACCCOST AS decimal(8,2)
DECLARE @FabricPrice AS decimal(8,2)
DECLARE @FabricCost AS decimal(8,2)
DECLARE @FabricTotal AS decimal(8,2)
DECLARE @SubWastage AS decimal(8,2)
DECLARE @SubFinance AS decimal(8,2)
DECLARE @FOBCost AS decimal(8,2)
DECLARE @CalWastage AS decimal(8,2)
DECLARE @CalFinance AS decimal(8,2)
DECLARE @CalDuty AS decimal(8,2)
DECLARE @CalMarginRate AS decimal(8,2)
SET @AccessoryCost = 0
SET @AccessoryTotal = 0
SET @FabricCost = 0
SET @FabricTotal = 0 
SET @SubWastage = 0
SET @SubFinance = 0
SET @FOBCost = 0


DECLARE CostSheetCursor CURSOR FAST_FORWARD FOR
 
SELECT [ID]
      ,[Pattern]
      ,[TotalFabricCost]
      ,[TotalAccessoriesCost]
      ,[HPCost]
      ,[LabelCost]
      ,[Other]
      ,[Finance]
      ,[Wastage]
      ,[CM]
      ,[DutyRate]
      ,[MarginRate]
  FROM [Indico].[dbo].[CostSheet]
  
OPEN CostSheetCursor 
	FETCH NEXT FROM CostSheetCursor INTO @ID, @Pattern, @TotalFabricCost, @TotalAccessoriesCost, @HPCost, @LabelCost, @Other, @Finance, @Wastage, @CM, @DutyRate, @MarginRate 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
				
				
				
				SET @CalWastage =  ROUND((@Wastage * 100) , 2, 1)
				SET @CalFinance =  ROUND((@Finance * 100) , 2, 1)
				SET @CalDuty =  ROUND((@DutyRate * 100) , 2, 1)
				SET @CalMarginRate =  12.5
				SET @SubWastage  = ROUND((((@TotalAccessoriesCost + @HPCost + @LabelCost + @Other) * @CalWastage)/100) , 2, 1)
				SET @SubFinance  = ROUND(((( @TotalFabricCost + @TotalAccessoriesCost + @HPCost + @LabelCost + @Other) * @CalFinance)/100) , 2, 1)
				SET @FOBCost =  ROUND((@TotalFabricCost + @TotalAccessoriesCost + @HPCost + @LabelCost + @Other + @SubFinance + @SubWastage + @CM) , 2, 1)
				
				
				
				  UPDATE [dbo].[CostSheet] SET [Wastage] = @CalWastage,
											   [Finance] = @CalFinance,
											   [SubWastage] = @SubWastage,
											   [SubFinance] = @SubFinance,
											   [MarginRate] = @CalMarginRate,
											   [DutyRate] = @CalDuty,
											   [JKFOBCost] = @FOBCost
										 WHERE [ID] = @ID
				
				
	SET @AccessoryCost = 0			
	SET @AccessoryTotal = 0
	SET @FabricCost = 0			
	SET @FabricTotal = 0
	SET @SubWastage = 0			
	SET @SubFinance = 0
	SET @FOBCost = 0
			
		FETCH NEXT FROM CostSheetCursor INTO  @ID, @Pattern, @TotalFabricCost, @TotalAccessoriesCost, @HPCost, @LabelCost, @Other, @Finance, @Wastage, @CM, @DutyRate, @MarginRate 
	END
CLOSE CostSheetCursor 
DEALLOCATE CostSheetCursor
-----/--------
GO