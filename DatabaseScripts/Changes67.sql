USE [Indico] 
GO


DECLARE @Fabric AS int 
DECLARE @MainFabric AS int
DECLARE @Pattern AS int
DECLARE @CostSheet AS int

SET @Fabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F061')
SET @MainFabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F061+F044')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '1493')
SET @CostSheet = (SELECT [ID] FROM [dbo].[CostSheet] WHERE [Pattern] = @Pattern AND [Fabric] = @MainFabric)

INSERT INTO [Indico].[dbo].[PatternSupportFabric] ([Fabric], [FabConstant], [CostSheet]) VALUES (@Fabric, 1.50, @CostSheet)
GO

DECLARE @Fabric AS int 
DECLARE @MainFabric AS int
DECLARE @Pattern AS int
DECLARE @CostSheet AS int

SET @Fabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F044')
SET @MainFabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F061+F044')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '1493')
SET @CostSheet = (SELECT [ID] FROM [dbo].[CostSheet] WHERE [Pattern] = @Pattern AND [Fabric] = @MainFabric)

INSERT INTO [Indico].[dbo].[PatternSupportFabric] ([Fabric], [FabConstant], [CostSheet]) VALUES (@Fabric, 0.30, @CostSheet)
GO

DECLARE @Fabric AS int 
DECLARE @MainFabric AS int
DECLARE @Pattern AS int
DECLARE @CostSheet AS int

SET @Fabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'NWL')
SET @MainFabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F061+F044')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '1493')
SET @CostSheet = (SELECT [ID] FROM [dbo].[CostSheet] WHERE [Pattern] = @Pattern AND [Fabric] = @MainFabric)

INSERT INTO [Indico].[dbo].[PatternSupportFabric] ([Fabric], [FabConstant], [CostSheet]) VALUES (@Fabric, 0.20, @CostSheet)
GO

DECLARE @Fabric AS int 
DECLARE @MainFabric AS int
DECLARE @Pattern AS int
DECLARE @CostSheet AS int

SET @Fabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F061+F044')
SET @MainFabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F061+F044')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '1493')
SET @CostSheet = (SELECT [ID] FROM [dbo].[CostSheet] WHERE [Pattern] = @Pattern AND [Fabric] = @MainFabric)

INSERT INTO [Indico].[dbo].[PatternSupportFabric] ([Fabric], [FabConstant], [CostSheet]) VALUES (@Fabric, 0.00, @CostSheet)
GO


DECLARE @Accessory AS int 
DECLARE @Pattern AS int

SET @Accessory = (SELECT [ID] FROM [dbo].[Accessory] WHERE [Name] = 'B4H 18L PL')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '1493')

INSERT INTO [Indico].[dbo].[PatternSupportAccessory] ([Accessory], [AccConstant], [Pattern]) VALUES (@Accessory, 5.00, @Pattern)
GO

DECLARE @Accessory AS int 
DECLARE @Pattern AS int

SET @Accessory = (SELECT [ID] FROM [dbo].[Accessory] WHERE [Name] = 'NECK TAPE - 3/8"(10MM)')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '1493')

INSERT INTO [Indico].[dbo].[PatternSupportAccessory] ([Accessory], [AccConstant], [Pattern]) VALUES (@Accessory, 0.65, @Pattern)
GO

DECLARE @Accessory AS int 
DECLARE @Pattern AS int

SET @Accessory = (SELECT [ID] FROM [dbo].[Accessory] WHERE [Name] = 'TWILL TAPE - 5MM')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '1493')

INSERT INTO [Indico].[dbo].[PatternSupportAccessory] ([Accessory], [AccConstant], [Pattern]) VALUES (@Accessory, 0.60, @Pattern)
GO
--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-** DELETE Item Attributes --**--**-**-**--**--**-**-**--**--**-**-**

DELETE [dbo].[PatternItemAttributeSub]
  FROM [Indico].[dbo].[PatternItemAttributeSub] p
	JOIN [dbo].[ItemAttribute] ia
		ON p.[ItemAttribute] = ia.[ID]
	  JOIN [dbo].[Item] i
		ON i.[ID] = ia.[Item]
WHERE i.[Parent] IS NOT NULL
GO

DELETE [dbo].[ItemAttribute]
FROM [dbo].[ItemAttribute] ia
  JOIN [dbo].[Item] i
	ON i.[ID] = ia.[Item]
WHERE i.[Parent] IS NOT NULL 
GO

--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**