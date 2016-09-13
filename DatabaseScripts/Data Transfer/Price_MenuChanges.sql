USE [Indico]
GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Delete Existing Items --
DELETE FROM [dbo].[MenuItemRole]
      WHERE [MenuItem] IN (77,76,40,39,38,37,36,35,34,33,32,31,30,29)
      
DELETE FROM [dbo].[MenuItem]
      WHERE [ID] IN (77,76,40,39,38,37,36,35,34,33,32,31,30)
      
DELETE FROM [dbo].[MenuItem]
      WHERE [ID] = 29 AND [Parent] IS NULL
GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

-- Insert New Items --
DECLARE @FactoryAdministrator int
DECLARE @ManufactureAdministrator int
DECLARE @ManufactureCoordinator int
DECLARE @SalesAdministrator int
DECLARE @SalesCoordinator int

SET @FactoryAdministrator = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')
SET @ManufactureAdministrator = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @SalesAdministrator = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indico Administrator')
    
DECLARE @PageId int
DECLARE @MenuItemTabId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int
     
/*----- Prices Tab Factory ------------------------------------------------------------------------------------------*/

-- ViewPrices.aspx
SET @PageId = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPrices.aspx')

INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Prices', 'Prices', 1, NULL, 5, 1)
SET @MenuItemTabId = SCOPE_IDENTITY()	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemTabId, @FactoryAdministrator) 	
	 
INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Pattern Prices', 'Pattern Prices', 1, @MenuItemTabId, 1, 1)
SET @MenuItemMenuId = SCOPE_IDENTITY()	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @FactoryAdministrator)
	 
--AddPatternFabricPrice.aspx
SET @PageId = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddPatternFabricPrice.aspx')

INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	VALUES (@PageId,'Add Pattern Fabric','Add Pattern Fabric', 1, @MenuItemTabId, 1, 0)
SET @MenuItemMenuId = SCOPE_IDENTITY() 	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @FactoryAdministrator)

-- EditFactoryPrice.aspx
SET @PageId = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditFactoryPrice.aspx')

INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Factory Price', 'Factory Price', 1, @MenuItemTabId, 2, 1)
SET @MenuItemMenuId = SCOPE_IDENTITY() 	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @FactoryAdministrator)

INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Factory Price', 'Factory Price', 1, @MenuItemMenuId, 2, 0)
SET @MenuItemId = SCOPE_IDENTITY() 	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @FactoryAdministrator)

/*----- Prices Tab Manufacture --------------------------------------------------------------------------------------*/	 
	 
-- EditIndimanPrice.aspx
SET @PageId = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditIndimanPrice.aspx')

INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Prices', 'Prices', 1, NULL, 5, 1)
SET @MenuItemTabId = SCOPE_IDENTITY() 	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemTabId, @ManufactureAdministrator)
	 
INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indiman Prices', 'Indiman Prices', 1, @MenuItemTabId, 1, 1)
SET @MenuItemMenuId = SCOPE_IDENTITY() 	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @ManufactureAdministrator)

-- AddPatternFabricPrice.aspx
SET @PageId = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddPatternFabricPrice.aspx')

INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Add Pattern Fabric', 'Pattern Fabric Price', 1, @MenuItemTabId, 2, 1)
SET @MenuItemMenuId = SCOPE_IDENTITY() 	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @ManufactureAdministrator)	 	 

-- ViewPriceLevels.aspx
SET @PageId = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPriceLevels.aspx')

INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Price Levels', 'Price Levels', 1, @MenuItemTabId, 3, 1)
SET @MenuItemMenuId = SCOPE_IDENTITY() 	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @ManufactureAdministrator)	 
	 	 	 
-- ViewPriceMarckups.aspx
SET @PageId = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPriceMarckups.aspx')

INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Price Markups', 'Price Markups', 1, @MenuItemTabId, 3, 1)
SET @MenuItemMenuId = SCOPE_IDENTITY() 	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @ManufactureAdministrator)	 

/*----- Prices Tab Sales --------------------------------------------------------------------------------------------*/	 
	 
-- EditIndicoPrice.aspx
SET @PageId = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditIndicoPrice.aspx')

INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Prices', 'Prices', 1, NULL, 5, 1)
SET @MenuItemTabId = SCOPE_IDENTITY()	 

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemTabId, @SalesAdministrator)
	 
INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indico Price', 'Indico Price', 1, @MenuItemTabId, 1, 1)
SET @MenuItemMenuId = SCOPE_IDENTITY() 

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @SalesAdministrator)	 

-- ViewPriceMarckups.aspx
SET @PageId = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPriceMarckups.aspx')

INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Price Markups', 'Price Markups', 1, @MenuItemTabId, 2, 1)
SET @MenuItemMenuId = SCOPE_IDENTITY() 	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @SalesAdministrator)
	 
-- PriceList.aspx
SET @PageId = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/PriceList.aspx')

UPDATE [dbo].[MenuItem]
   SET [Parent] = @MenuItemTabId, [Position] = 3
WHERE  [Page] = @PageId 
GO	 
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/	 	 