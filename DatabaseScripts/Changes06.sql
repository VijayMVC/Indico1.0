USE [Indico]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

DECLARE @MenuItemID int
DECLARE @PageId int

-- Update 'Price Markups' position
SET @PageId = (SELECT [ID]  FROM [dbo].[Page] WHERE [Name] = '/ViewPriceMarckups.aspx')
SET @MenuItemID = (SELECT ID FROM [dbo].[MenuItem] WHERE [Page] = @PageId AND [Position] = 3 ) 
UPDATE [dbo].[MenuItem] SET [Position] = 6 WHERE ID = @MenuItemID


-- Update 'Price Levels' position
SET @PageId = (SELECT [ID]  FROM [dbo].[Page] WHERE [Name] = '/ViewPriceLevels.aspx')
SET @MenuItemID = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @PageId AND [Position] = 3)
UPDATE [dbo].[MenuItem] SET [Position] = 5 WHERE ID = @MenuItemID
GO

DECLARE @ManufactureAdministrator int
SET @ManufactureAdministrator = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
    
DECLARE @PageId int
DECLARE @MenuItemTabId int
DECLARE @MenuItemMenuId int

SET @PageId = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditIndimanPrice.aspx')
SET @MenuItemTabId = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Prices' AND Page = @PageId) 


-- EditIndicoPrice.aspx
SET @PageId = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditIndicoPrice.aspx' ) 

INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indico Price', 'Indico Price', 1, @MenuItemTabId, 3, 1)
SET @MenuItemMenuId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @ManufactureAdministrator) 
	 
-- EditFactoryPrice.aspx
SET @PageId = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditFactoryPrice.aspx') 

INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Factory Price', 'Factory Price', 1, @MenuItemTabId, 4, 1)
SET @MenuItemMenuId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @ManufactureAdministrator) 
GO
	 

/****** Object:  View [dbo].[ReturnStringView]    Script Date: 09/20/2012 15:05:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[PendingPricesView] 
AS 
	SELECT pt.*
	FROM [Indico].[dbo].[Pattern] pt
		LEFT OUTER JOIN [Indico].[dbo].[Price] pr
			ON pt.ID = pr.Pattern
	WHERE pr.Pattern IS NULL	

GO

-- Insert New Page 'PendingPrice.aspx'
INSERT INTO [dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/PendingPrice.aspx', 'Pending Prices', 'Pending Prices')
GO

-- Add New Menu Item 'Pending Prices'--
DECLARE @PageId int
DECLARE @MenuItemTabId int
DECLARE @MenuItemMenuId int
DECLARE @ManufactureAdministrator int

SET @ManufactureAdministrator = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

SET @PageId = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditIndimanPrice.aspx')

SET @MenuItemTabId = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Name] = 'Prices' AND Page = 27) 

SET @PageId = (SELECT [ID] FROM [dbo] .[Page] WHERE [Name] = '/PendingPrice.aspx')

INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Pending Prices', 'Prices Prices', 1, @MenuItemTabId, 7, 1)
SET @MenuItemMenuId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @ManufactureAdministrator) 
GO


/****** Object:  View [dbo].[PendingPricesView]    Script Date: 09/20/2012 17:33:13 ******/

ALTER VIEW [dbo].[PendingPricesView] 
AS 
	SELECT pt.ID,
		   pt.Number AS PatternNumber,
		   pt.NickName AS NickName,
		   g.Name AS Gender,
		   i.Name AS SubItemName,		  
		   ag.Name AS AgeGroup,
		   c.Name AS CoreCategory,
		   pt.CorePattern
	FROM [Indico].[dbo].[Pattern] pt
		LEFT OUTER JOIN [Indico].[dbo].[Price] pr
			ON pt.ID = pr.Pattern
		JOIN [Indico].[dbo].[Item] i
			ON pt.SubItem = i.ID
		JOIN [Indico].[dbo].[Gender] g
			ON pt.Gender = g.ID
		JOIN [Indico].[dbo].[Category] c
			ON pt.CoreCategory = c.ID
		JOIN [Indico].[dbo].[AgeGroup] ag
			ON pt.AgeGroup = ag.ID
	WHERE pr.Pattern IS NULL	

GO


--- ADD New Column in VisualLayout Table "IsCommonProduct"
ALTER TABLE [dbo].[VisualLayout] ADD IsCommonProduct bit NULL
GO


