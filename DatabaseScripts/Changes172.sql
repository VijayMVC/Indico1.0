USE [Indico]
GO

-- Factory FOB page

DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

DECLARE @FactoryAdministrator int
DECLARE @IndimanAdministrator int

SET @FactoryAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')
SET @IndimanAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/FactoryPrices.aspx','Factory Price','Factory Price')	 
SET @PageId = SCOPE_IDENTITY()

--Indiman menu item

SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/EditIndimanPrice.aspx')
						AND Parent IS NULL)
						)
						
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Factory Price', 'Factory Price', 1, @MenuItemMenuId, 13, 1)
SET @MenuItemId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)

--Factory menu item

SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/ViewPrices.aspx')
						AND Parent IS NULL)
						)

INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Factory Price', 'Factory Price', 1, @MenuItemMenuId, 6, 1)
SET @MenuItemId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @FactoryAdministrator)
	 	 
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

