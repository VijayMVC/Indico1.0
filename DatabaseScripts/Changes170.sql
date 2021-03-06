USE [Indico]
GO

--------------------------- indico CIF/FOB Prices pages --------------------------------------

DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

DECLARE @IndimanAdministrator int
DECLARE @IndimanCoordinator int
DECLARE @IndicoAdministrator int
--DECLARE @IndicoCoordinator int

SET @IndimanAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @IndimanCoordinator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Coordinator')
SET @IndicoAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Administrator')
--SET @IndicoCoordinator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')

-- CIF --

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/EditIndicoCIFPriceLevel.aspx','Indico CIF Price','Indico CIF Price')	 
SET @PageId = SCOPE_IDENTITY()

SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/EditIndicoPrice.aspx')
						AND Parent IS NULL)
						)

INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indico CIF Price', 'Indico CIF Price', 1, @MenuItemMenuId, 4, 1)
SET @MenuItemId = SCOPE_IDENTITY()	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanCoordinator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoAdministrator) 

SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/EditIndimanPrice.aspx')
						AND Parent IS NULL)
						)
						
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indico CIF Price', 'Indico CIF Price', 1, @MenuItemMenuId, 11, 1)
SET @MenuItemId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)

-- FOB--	 						

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/EditIndicoFOBPriceLevel.aspx','Indico FOB Price','Indico FOB Price')     
SET @PageId = SCOPE_IDENTITY()     

SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/EditIndicoPrice.aspx')
						AND Parent IS NULL)
						)

INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indico FOB Price', 'Indico FOB Price', 1, @MenuItemMenuId, 5, 1)
SET @MenuItemId = SCOPE_IDENTITY()	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanCoordinator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoAdministrator)	

SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/EditIndimanPrice.aspx')
						AND Parent IS NULL)
						)
						
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indico FOB Price', 'Indico FOB Price', 1, @MenuItemMenuId, 12, 1)
SET @MenuItemId = SCOPE_IDENTITY()	
						
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
	 	 
GO

------------- Indico Price Changes ---------------------------------------

/****** Object:  Table [dbo].[PriceLevelNew]    Script Date: 9/12/2015 4:36:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PriceLevelNew](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Volume] [nvarchar](64) NOT NULL,
	[Markup] [decimal] NOT NULL,
	[LastModifier] [int] NOT NULL,
	[LastModifiedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_PriceLevelNew] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceLevelNew', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the price level' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceLevelNew', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The volume of the price level' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceLevelNew', @level2type=N'COLUMN',@level2name=N'Volume'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indico price level markup' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceLevelNew', @level2type=N'COLUMN',@level2name=N'Markup'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last modifier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceLevelNew', @level2type=N'COLUMN',@level2name=N'LastModifier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last modified date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceLevelNew', @level2type=N'COLUMN',@level2name=N'LastModifiedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceLevelNew'
GO

ALTER TABLE [dbo].[PriceLevelNew]  WITH CHECK ADD  CONSTRAINT [FK_PriceLevelNew_User] FOREIGN KEY([LastModifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[PriceLevelNew] CHECK CONSTRAINT [FK_PriceLevelNew_User]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

INSERT INTO [dbo].[PriceLevelNew] ([Name], [Volume], [Markup], [LastModifier], [LastModifiedDate])
     VALUES ('Level1', '1 - 10', '30.0', 1, GETDATE())
GO

INSERT INTO [dbo].[PriceLevelNew] ([Name], [Volume], [Markup], [LastModifier], [LastModifiedDate])
     VALUES ('Level2', '11 - 499', '22.0', 1, GETDATE())
GO

INSERT INTO [dbo].[PriceLevelNew] ([Name], [Volume], [Markup], [LastModifier], [LastModifiedDate])
     VALUES ('Level3', '500+', '15.0', 1, GETDATE())
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  View [dbo].[IndicoCIFPriceView]    Script Date: 12/09/2015 14:48:38 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IndicoCIFPriceView]'))
DROP VIEW [dbo].[IndicoCIFPriceView]
GO


/****** Object:  View [dbo].[IndicoCIFPriceView]    Script Date: 9/12/2015 8:01:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[IndicoCIFPriceView]
AS
	SELECT	c.ID AS CostSheetId,
			ca.Name AS CoreCategory,
			i.Name AS ItemCategory,
			p.ID AS PatternId,
			p.Number AS PatternCode,
			p.NickName AS PatternNickName,
			f.ID AS FabricId,
			f.Code AS FabricCode,
			f.Name AS FabricName,
			--p.ConvertionFactor AS ConversionFactor,
			ISNULL(c.FOBFactor,0.0) AS ConversionFactor,
			ISNULL(c.QuotedCIF, 0.0) AS IndimanPrice,			
			ISNULL((SELECT TOP 1 (u.GivenName + ' ' + u.FamilyName) As LastModifier
				FROM IndimanCostSheetRemarks ir
				JOIN [User] u
				ON ir.Modifier = u.ID
				WHERE CostSheet = c.ID ORDER BY ir.ID DESC), 
				(SELECT GivenName + ' ' + u.FamilyName AS LastModifier FROM [User] WHERE ID = c.Modifier)
				) AS LastModifier,
			ISNULL((SELECT TOP 1 ModifiedDate FROM IndimanCostSheetRemarks WHERE CostSheet = c.ID  ORDER BY ID DESC), c.CreatedDate) AS ModifiedDate,
			ISNULL((SELECT TOP 1 Remarks FROM IndimanCostSheetRemarks WHERE CostSheet = c.ID  ORDER BY ID DESC),'') AS Remarks						
	FROM CostSheet c
		JOIN Pattern p
			ON c.Pattern = p.ID
		JOIN FabricCode f
			ON c.Fabric = f.ID
		JOIN [User] u
			ON c.Modifier = u.ID	
		LEFT OUTER JOIN Category ca
			ON ca.ID = p.CoreCategory
		LEFT OUTER JOIN Item i
			ON i.ID = p.Item
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

-- Indiman CIF/ FOB pages

DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

DECLARE @IndimanAdministrator int

SET @IndimanAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

-- CIF --

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/ViewIndimanCIFPrices.aspx','Indiman CIF Price','Indiman CIF Price')	 
SET @PageId = SCOPE_IDENTITY()

SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/EditIndimanPrice.aspx')
						AND Parent IS NULL)
						)
						
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indiman CIF Price', 'Indiman CIF Price', 1, @MenuItemMenuId, 11, 1)
SET @MenuItemId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)

-- FOB--	 						

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/ViewIndimanFOBPrices.aspx','Indiman FOB Price','Indiman FOB Price')     
SET @PageId = SCOPE_IDENTITY()     

SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/EditIndimanPrice.aspx')
						AND Parent IS NULL)
						)
						
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indiman FOB Price', 'Indiman FOB Price', 1, @MenuItemMenuId, 12, 1)
SET @MenuItemId = SCOPE_IDENTITY()	
						
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
	 	 
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
