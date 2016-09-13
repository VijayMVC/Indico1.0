USE [Indico]
GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

/****** Object:  Table [dbo].[ItemMeasurementGuideImage]    Script Date: 09/16/2012 20:50:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[ItemMeasurementGuideImage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Item] [int] NOT NULL,
	[Size] [int] NOT NULL,
	[Filename] [nvarchar](255) NULL,
	[Extension] [varchar](10) NULL,
 CONSTRAINT [PK_ItemMeasurementGuideImage] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemMeasurementGuideImage', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the Item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemMeasurementGuideImage', @level2type=N'COLUMN',@level2name=N'Item'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The size in bytes of the image' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemMeasurementGuideImage', @level2type=N'COLUMN',@level2name=N'Size'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The filename of the image' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemMeasurementGuideImage', @level2type=N'COLUMN',@level2name=N'Filename'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The file extension of the image' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemMeasurementGuideImage', @level2type=N'COLUMN',@level2name=N'Extension'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemMeasurementGuideImage'
GO

ALTER TABLE [dbo].[ItemMeasurementGuideImage]  WITH CHECK ADD  CONSTRAINT [FK_ItemMeasurementGuideImage_Item] FOREIGN KEY([Item])
REFERENCES [dbo].[Item] ([ID])
GO
ALTER TABLE [dbo].[ItemMeasurementGuideImage] CHECK CONSTRAINT [FK_ItemMeasurementGuideImage_Item]
GO
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/

DECLARE @FIRSTID INT
DECLARE @SECONDID INT
SET  @FIRSTID = (SELECT COUNT(*) FROM [dbo].Pattern WHERE CoreCategory = 38)
SET  @SECONDID = (SELECT COUNT(*) FROM [dbo].Pattern WHERE CoreCategory = 39)

IF (@FIRSTID = 0)
BEGIN
	DELETE FROM [dbo].Category WHERE ID = 38
END
ELSE IF (@SECONDID = 0)
BEGIN
	DELETE FROM [dbo].Category WHERE ID = 39
END
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