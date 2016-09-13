USE [Indico]
GO

/****** Object:  View [dbo].[PackingListView]    Script Date: 10/23/2013 11:44:07 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[PackingListView]'))
DROP VIEW [dbo].[PackingListView]
GO

/****** Object:  View [dbo].[PackingListView]    Script Date: 10/23/2013 09:35:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PackingListView]
AS
 SELECT --DISTINCT TOP 100 PERCENT
  pl.ID,
  wpc.ID AS WeeklyProductionCapacity,
  pl.CartonNo,
  o.ID AS OrderNumber,  
  od.[ID] AS OrderDetailId,
  vl.NamePrefix  + CAST(ISNULL(vl.NameSuffix,'') AS VarChar) AS VLName,
  p.NickName,
  d.Name AS Distributor,
  c.Name AS Client,
  wpc.WeekendDate,
  ISNULL((SELECT SUM(QTY) FROM [dbo].[PackingListSizeQty] WHERE PackingList = pl.ID),0) AS PackingTotal,
  ISNULL((SELECT SUM([Count]) FROM [dbo].[PackingListCartonItem] WHERE PackingList = pl.ID),0) AS ScannedTotal    
 FROM  dbo.[PackingList] pl
  INNER JOIN dbo.[OrderDetail] od
   ON pl.OrderDetail = od.ID
  INNER JOIN dbo.[Order] o
   ON od.[Order] = o.ID
  INNER JOIN dbo.[VisualLayout] vl
   ON od.[VisualLayout] = vl.ID 
  INNER JOIN dbo.Pattern p
   ON od.Pattern = p.ID
  INNER JOIN dbo.Client c
   ON o.Client = c.ID
  INNER JOIN dbo.Company d
   ON o.Distributor = d.ID 
  INNER JOIN dbo.WeeklyProductionCapacity wpc
   ON pl.WeeklyProductionCapacity = wpc.ID 
GO

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**


DECLARE @Fabric AS int 
DECLARE @MainFabric AS int
DECLARE @Pattern AS int
DECLARE @CostSheet AS int

SET @Fabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F061')
SET @MainFabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F016')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '052')
SET @CostSheet = (SELECT [ID] FROM [dbo].[CostSheet] WHERE [Pattern] = @Pattern AND [Fabric] = @MainFabric)

INSERT INTO [Indico].[dbo].[PatternSupportFabric] ([Fabric], [FabConstant], [CostSheet]) VALUES (@Fabric, 1.40, @CostSheet)
GO

DECLARE @Fabric AS int 
DECLARE @MainFabric AS int
DECLARE @Pattern AS int
DECLARE @CostSheet AS int

SET @Fabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'NWL')
SET @MainFabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F016')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '052')
SET @CostSheet = (SELECT [ID] FROM [dbo].[CostSheet] WHERE [Pattern] = @Pattern AND [Fabric] = @MainFabric)

INSERT INTO [Indico].[dbo].[PatternSupportFabric] ([Fabric], [FabConstant], [CostSheet]) VALUES (@Fabric, 0.20, @CostSheet)
GO


DECLARE @Accessory AS int 
DECLARE @Pattern AS int

SET @Accessory = (SELECT [ID] FROM [dbo].[Accessory] WHERE [Name] = 'B4H 18L PL')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '052')

INSERT INTO [Indico].[dbo].[PatternSupportAccessory] ([Accessory], [AccConstant], [Pattern]) VALUES (@Accessory, 4.00, @Pattern)
GO

DECLARE @Accessory AS int 
DECLARE @Pattern AS int

SET @Accessory = (SELECT [ID] FROM [dbo].[Accessory] WHERE [Name] = 'NECK TAPE - 3/8"(10MM)')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '052')

INSERT INTO [Indico].[dbo].[PatternSupportAccessory] ([Accessory], [AccConstant], [Pattern]) VALUES (@Accessory, 0.65, @Pattern)
GO

DECLARE @Accessory AS int 
DECLARE @Pattern AS int

SET @Accessory = (SELECT [ID] FROM [dbo].[Accessory] WHERE [Name] = 'TWILL TAPE - 5MM')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '052')

INSERT INTO [Indico].[dbo].[PatternSupportAccessory] ([Accessory], [AccConstant], [Pattern]) VALUES (@Accessory, 0.65, @Pattern)
GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

DECLARE @ID AS int
DECLARE @Pattern AS int
DECLARE @Accessory AS int 
DECLARE @Const AS decimal(8,2)
DECLARE @AccPattern AS int
DECLARE @Fabric AS int
DECLARE @FabConstant AS decimal(8,2)
DECLARE @CostSheet AS int
DECLARE @AccessoryCost AS decimal(8,2)
DECLARE @AccessoryTotal AS decimal(8,2)
DECLARE @ACCCOST AS decimal(8,2)
SET @AccessoryCost = 0
SET @AccessoryTotal = 0

DECLARE CostSheetCursor CURSOR FAST_FORWARD FOR
 
SELECT [ID]
      ,[Pattern]      
  FROM [Indico].[dbo].[CostSheet]
   WHERE [Pattern] = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '052')
  
OPEN CostSheetCursor 
	FETCH NEXT FROM CostSheetCursor INTO @ID, @Pattern
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
				DECLARE AccessoryCursor CURSOR FAST_FORWARD FOR
				 
				SELECT [Accessory]
					  ,[AccConstant]
					  ,[Pattern]
				FROM [Indico].[dbo].[PatternSupportAccessory]
				WHERE [Pattern] = @Pattern
				  
				OPEN AccessoryCursor 
					FETCH NEXT FROM AccessoryCursor INTO @Accessory, @Const, @AccPattern
					WHILE @@FETCH_STATUS = 0 
					BEGIN 
						
						SET @ACCCOST =  (SELECT SUM(a.[Cost]) FROM [dbo].[Accessory] a WHERE a.[ID] = @Accessory)
						
						SET @AccessoryCost = (@Const * @ACCCOST)			
						
						SET @AccessoryTotal = ROUND((@AccessoryTotal+@AccessoryCost), 2)
							
							
							
						FETCH NEXT FROM AccessoryCursor INTO  @Accessory, @Const, @AccPattern
					END
				CLOSE AccessoryCursor 
				DEALLOCATE AccessoryCursor	
				
				
				--PRINT @AccessoryTotal
				--PRINT @Pattern
				--PRINT '----------------------------'
				UPDATE [dbo].[CostSheet] SET [TotalAccessoriesCost] = @AccessoryTotal WHERE [ID] = @ID
				
				
				
	SET @AccessoryCost = 0			
	SET @AccessoryTotal = 0	
			
		FETCH NEXT FROM CostSheetCursor INTO  @ID, @Pattern
	END
CLOSE CostSheetCursor 
DEALLOCATE CostSheetCursor
-----/--------
GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

--**-**--**-**--**-**--**-**--**-**--**-**--**-** Update Cost Sheet --**-**--**-**--**-**--**-**--**-**--**-**

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
  WHERE [Pattern] = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '052')
  
OPEN CostSheetCursor 
	FETCH NEXT FROM CostSheetCursor INTO @ID, @Pattern, @TotalFabricCost, @TotalAccessoriesCost, @HPCost, @LabelCost, @Other, @Finance, @Wastage, @CM, @DutyRate, @MarginRate 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
				
				SET @SubWastage  = ROUND((((@TotalAccessoriesCost + @HPCost + @LabelCost + @Other) * @Wastage)/100) , 2, 1)
				SET @SubFinance  = ROUND(((( @TotalFabricCost + @TotalAccessoriesCost + @HPCost + @LabelCost + @Other) * @Finance)/100) , 2, 1)
				SET @FOBCost =  ROUND((@TotalFabricCost + @TotalAccessoriesCost + @HPCost + @LabelCost + @Other + @SubFinance + @SubWastage + @CM) , 2, 1)
				
				
				
				  UPDATE [dbo].[CostSheet] SET [SubWastage] = @SubWastage,
											   [SubFinance] = @SubFinance,											  										  
											   [JKFOBCost] = @FOBCost
										 WHERE [ID] = @ID
					/*PRINT @TotalFabricCost
					PRINT @TotalFabricCost
					PRINT @SubWastage
					PRINT @SubFinance
					PRINT '-------------------------------------'*/
									
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

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

