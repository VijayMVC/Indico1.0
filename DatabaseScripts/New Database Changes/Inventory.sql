-- Inventory

-------------------------------------------------------------------------------MENU ITEM INSERTS

use [Indico]
GO


DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int
DECLARE @RoleId int

SELECT @RoleId = ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator'

SET @PageId = 1

INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Inventory', 'Inventory', 1, NULL, 14, 1)

SET @MenuItemId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @RoleId)


INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/InventoryItem.aspx','Inventory Items','Items')	 
SET @PageId = SCOPE_IDENTITY()

SELECT TOP 1 @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Inventory' AND Parent IS NULL
			
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Items', 'IteMs', 1, @MenuItemMenuId, 1, 1)

SET @MenuItemId = SCOPE_IDENTITY()


INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @RoleId)




--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/InventoryCategory.aspx','Inventory Category','Category')	 
SET @PageId = SCOPE_IDENTITY()

SELECT TOP 1 @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Inventory' AND Parent IS NULL
			
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Category', 'Category', 1, @MenuItemMenuId, 1, 1)

SET @MenuItemId = SCOPE_IDENTITY()


INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId,@RoleId)



--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--


INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/InventorySubCategory.aspx','Inventory Sub Category','Sub Category')	 
SET @PageId = SCOPE_IDENTITY()

SELECT TOP 1 @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Inventory' AND Parent IS NULL
			
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'SubCategory', 'Sub Category', 1, @MenuItemMenuId, 1, 1)

SET @MenuItemId = SCOPE_IDENTITY()


INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId,@RoleId)
	
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--


INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/InventoryUoM.aspx','Inventory Unit of Measure','Unit of Measure')	 
SET @PageId = SCOPE_IDENTITY()

SELECT TOP 1 @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Inventory' AND Parent IS NULL
			
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'UoM', 'Unit of Measure', 1, @MenuItemMenuId, 1, 1)

SET @MenuItemId = SCOPE_IDENTITY()


INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @RoleId)
	 
	--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

	

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/Purchaser.aspx','Purchaser','Purchaser')	 
SET @PageId = SCOPE_IDENTITY()

SELECT TOP 1 @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Inventory' AND Parent IS NULL
			
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Purchaser', 'Purchaser', 1, @MenuItemMenuId, 1, 1)

SET @MenuItemId = SCOPE_IDENTITY()


INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId,@RoleId)
	 
 --**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
	 
INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/Receipts.aspx','Receipts','Receipts')	 
SET @PageId = SCOPE_IDENTITY()

SELECT TOP 1 @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Inventory' AND Parent IS NULL
			
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Receipts', 'Receipts', 1, @MenuItemMenuId, 1, 1)

SET @MenuItemId = SCOPE_IDENTITY()


INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @RoleId)
	 

 --**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
 


INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/Issues.aspx','Issues','Issues')	 
SET @PageId = SCOPE_IDENTITY()

SELECT TOP 1 @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Inventory' AND Parent IS NULL
			
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Issues', 'Issues', 1, @MenuItemMenuId, 1, 1)

SET @MenuItemId = SCOPE_IDENTITY()


INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @RoleId)

 
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/StockView.aspx','StockView','StockView')	 
SET @PageId = SCOPE_IDENTITY()

SELECT TOP 1 @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Inventory' AND Parent IS NULL
			
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'StockView', 'StockView', 1, @MenuItemMenuId, 1, 1)

SET @MenuItemId = SCOPE_IDENTITY()


INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId,@RoleId)

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

GO



 --------------------------------------------------------------------------------------------------TABLES AND VIEWS

USE [Indico]
GO


IF OBJECT_ID('dbo.SPTran', 'U') IS NOT NULL 
  DROP TABLE  dbo.SPTran
GO


IF OBJECT_ID('dbo.InvItem', 'U') IS NOT NULL 
  DROP TABLE  dbo.InvItem
GO

IF OBJECT_ID('dbo.InvPurchaser', 'U') IS NOT NULL 
  DROP TABLE  dbo.InvPurchaser
GO

IF OBJECT_ID('dbo.InvCategory', 'U') IS NOT NULL 
  DROP TABLE  dbo.InvCategory
GO


IF OBJECT_ID('dbo.SPType', 'U') IS NOT NULL 
  DROP TABLE  dbo.SPType
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--


  /****** Object:  Table [dbo].[InvPurchaser]    ******/

  SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[InvPurchaser](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_Purchaser] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the purchaser' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvPurchaser', @level2type=N'COLUMN',@level2name=N'ID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'name of the purchaser' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvPurchaser', @level2type=N'COLUMN',@level2name=N'Name'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--



  /****** Object:  Table [dbo].[InvCategory]    ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[InvCategory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Parent] [int] NULL,
 CONSTRAINT [PK_InvCategory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[InvCategory]  WITH CHECK ADD  CONSTRAINT [FK_Category_Parent] FOREIGN KEY([Parent])
REFERENCES [dbo].[InvCategory] ([ID])
GO

ALTER TABLE [dbo].[InvCategory] CHECK CONSTRAINT [FK_Category_Parent]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvCategory', @level2type=N'COLUMN',@level2name=N'ID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'name of the category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvCategory', @level2type=N'COLUMN',@level2name=N'Name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'foreign key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvCategory', @level2type=N'COLUMN',@level2name=N'Parent'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--



  /****** Object:  Table [dbo].[InvItem]    ******/

  SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[InvItem](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100)  NULL,
	[Category] [int]  NULL,
	[SubCategory] [int]  NULL,
	[Colour] [nvarchar](30)  NULL,
	[Attribute] [nvarchar](100)  NULL,
	[MinLevel] [int]  NULL,
	[Uom] [int]  NULL,
	[Supplier] [int]  NULL,
	[Purchaser] [int]  NULL,
	[Status] [int]  NULL,
	[Code] [nvarchar](30) NULL,
 CONSTRAINT [PK_InvItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[InvItem]  WITH CHECK ADD  CONSTRAINT [FK_InvItem_Category] FOREIGN KEY([Category])
REFERENCES [dbo].[InvCategory] ([ID])
GO

ALTER TABLE [dbo].[InvItem] CHECK CONSTRAINT [FK_InvItem_Category]
GO

ALTER TABLE [dbo].[InvItem]  WITH CHECK ADD  CONSTRAINT [FK_InvItem_SubCategory] FOREIGN KEY([SubCategory])
REFERENCES [dbo].[InvCategory] ([ID])
GO

ALTER TABLE [dbo].[InvItem] CHECK CONSTRAINT [FK_InvItem_SubCategory]
GO

ALTER TABLE [dbo].[InvItem]  WITH CHECK ADD  CONSTRAINT [FK_InvItem_SupplierCode] FOREIGN KEY([Supplier])
REFERENCES [dbo].[Supplier] ([ID])
GO

ALTER TABLE [dbo].[InvItem] CHECK CONSTRAINT [FK_InvItem_SupplierCode]
GO

ALTER TABLE [dbo].[InvItem]  WITH CHECK ADD  CONSTRAINT [FK_InvItem_Uom] FOREIGN KEY([Uom])
REFERENCES [dbo].[Unit] ([ID])
GO

ALTER TABLE [dbo].[InvItem] CHECK CONSTRAINT [FK_InvItem_Uom]
GO

ALTER TABLE [dbo].[InvItem]  WITH CHECK ADD  CONSTRAINT [Fk_PurchaserId] FOREIGN KEY([Purchaser])
REFERENCES [dbo].[InvPurchaser] ([ID])
GO

ALTER TABLE [dbo].[InvItem] CHECK CONSTRAINT [Fk_PurchaserId]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvItem', @level2type=N'COLUMN',@level2name=N'Id'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'name of the item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvItem', @level2type=N'COLUMN',@level2name=N'Name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Category of the item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvItem', @level2type=N'COLUMN',@level2name=N'Category'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SubCategory of the item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvItem', @level2type=N'COLUMN',@level2name=N'SubCategory'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Colour of the item ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvItem', @level2type=N'COLUMN',@level2name=N'Colour'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'attribute of the item ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvItem', @level2type=N'COLUMN',@level2name=N'Attribute'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'minimum level of the item ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvItem', @level2type=N'COLUMN',@level2name=N'MinLevel'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unit of measure ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvItem', @level2type=N'COLUMN',@level2name=N'Uom'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'supplier code ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvItem', @level2type=N'COLUMN',@level2name=N'Supplier'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the purchaser ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvItem', @level2type=N'COLUMN',@level2name=N'Purchaser'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Active Status ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvItem', @level2type=N'COLUMN',@level2name=N'Status'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--


  /****** Object:  Table [dbo].[SPType]    ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SPType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_SPType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the type of transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SPType', @level2type=N'COLUMN',@level2name=N'ID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'name of the type of transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SPType', @level2type=N'COLUMN',@level2name=N'Name'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SPTran](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Type] [int] NULL,
	[Tranno] [nvarchar](30) NULL,
	[TranDate] [date] NULL,
	[Item] [int] NULL,
	[Qty] [int] NULL,
	[PONo] [nvarchar](30) NULL,
	[Creator] [int] NULL,
	[CreatedDate] [date] NULL,
	[Modifier] [int] NULL,
	[ModifierDate] [date] NULL,
	[Notes] [nvarchar](200) NULL,
 CONSTRAINT [PK_SPTran] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[SPTran]  WITH CHECK ADD  CONSTRAINT [FK_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[SPTran] CHECK CONSTRAINT [FK_Creator]
GO

ALTER TABLE [dbo].[SPTran]  WITH CHECK ADD  CONSTRAINT [FK_ItemId] FOREIGN KEY([Item])
REFERENCES [dbo].[InvItem] ([Id])
GO

ALTER TABLE [dbo].[SPTran] CHECK CONSTRAINT [FK_ItemId]
GO

ALTER TABLE [dbo].[SPTran]  WITH CHECK ADD  CONSTRAINT [FK_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[SPTran] CHECK CONSTRAINT [FK_Modifier]
GO

ALTER TABLE [dbo].[SPTran]  WITH CHECK ADD  CONSTRAINT [FK_TypeID] FOREIGN KEY([Type])
REFERENCES [dbo].[SPType] ([ID])
GO

ALTER TABLE [dbo].[SPTran] CHECK CONSTRAINT [FK_TypeID]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SPTran', @level2type=N'COLUMN',@level2name=N'ID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N' type of transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SPTran', @level2type=N'COLUMN',@level2name=N'Type'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'no of transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SPTran', @level2type=N'COLUMN',@level2name=N'Tranno'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date of transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SPTran', @level2type=N'COLUMN',@level2name=N'TranDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SPTran', @level2type=N'COLUMN',@level2name=N'Item'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'quantity of the item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SPTran', @level2type=N'COLUMN',@level2name=N'Qty'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PONo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SPTran', @level2type=N'COLUMN',@level2name=N'PONo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'created person of the transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SPTran', @level2type=N'COLUMN',@level2name=N'Creator'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'created date of transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SPTran', @level2type=N'COLUMN',@level2name=N'CreatedDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'the person who have m odified the record' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SPTran', @level2type=N'COLUMN',@level2name=N'Modifier'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date of modification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SPTran', @level2type=N'COLUMN',@level2name=N'ModifierDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'notes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SPTran', @level2type=N'COLUMN',@level2name=N'Notes'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GetInventoryItemsView]'))
	DROP VIEW [dbo].[GetInventoryItemsView]

/****** Object:  View [dbo].[GetInventoryItemsView]    Script Date: 06/23/2015 14:34:02 ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[GetInventoryItemsView]
AS
      SELECT  i.[Id],
              i.[Code]
	         ,i.[Name]
             ,c.[Name] AS [Category]
	         ,c.ID AS [CategoryID]
             ,sc.Name AS [SubCategory]
	         ,sc.ID AS [SubCategoryID]
             ,[Colour]
             ,[Attribute]
             ,[MinLevel]
             ,u.[Name] AS [Uom]
	         ,u.ID AS [UomID]
             ,s.Name AS [SupplierCode]
	         ,s.ID AS [SupplierCodeID]
             ,p.Name AS [Purchaser]
	         ,p.ID AS [PurchaserID]
             ,[Status]
     FROM [dbo].[InvItem] i
	        INNER JOIN [dbo].[InvCategory] c
		            ON i.Category = c.ID
	        INNER JOIN [dbo].[InvCategory] sc
		            ON i.SubCategory = sc.ID
	        INNER JOIN [dbo].[Unit] u
		            ON u.ID = i.Uom 
	        INNER JOIN [dbo].[Supplier] s
		            ON i.Supplier = s.ID
	        INNER JOIN [dbo].[InvPurchaser] p
		            ON i.Purchaser = p.ID

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReceiptQtyView]'))
	DROP VIEW [dbo].[ReceiptQtyView]

/****** Object:  View [dbo].[ReceiptQtyView]    Script Date: 06/23/2015 14:34:02 ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReceiptQtyView]
AS
       SELECT  Item,
	           ReceiptSum=(SELECT SUM(Qty) FROM SPTran WHERE Type=1 AND Item=sp.Item)
	   FROM SPTran sp
	   WHERE Type=1
	   GROUP BY sp.Item

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IssueQtyView]'))
	DROP VIEW [dbo].[IssueQtyView]

/****** Object:  View [dbo].[IssueQtyView]    Script Date: 06/23/2015 14:34:02 ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[IssueQtyView]
AS
       SELECT  Item,
	           IssueSum=(SELECT SUM(Qty) FROM SPTran WHERE Type=2 AND Item=sp.Item)
	   FROM SPTran sp
	   WHERE Type=2
	   GROUP BY sp.Item

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[BalanceQtyView]'))
	DROP VIEW [dbo].[BalanceQtyView]
GO
/****** Object:  View [dbo].[BalanceQtyView]    Script Date: 06/23/2015 14:34:02 ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[BalanceQtyView]
AS
       SELECT  rq.Item,
	           rq.Item AS ReceiptQty,
			   iq.IssueSum AS IssueQty,
			   ISNULL(rq.ReceiptSum-iq.IssueSum,rq.ReceiptSum) AS balance
		FROM ReceiptQtyView rq
		         LEFT OUTER JOIN IssueQtyView iq
			            ON rq.Item=iq.Item
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ItemBalance]'))
	DROP VIEW [dbo].[ItemBalance]
GO

/****** Object:  View [dbo].[ItemBalance]    Script Date: 06/23/2015 14:34:02 ******/
CREATE VIEW [dbo].[ItemBalance]
AS
       SELECT gi.Id,
              gi.Code,
			  gi.Name,
			  gi.Category,
			  gi.SubCategory,
			  gi.Colour,
			  gi.Attribute,
			  gi.MinLevel,
			  gi.Uom,
			  gi.SupplierCode,
			  gi.Purchaser,
			  ISNULL(b.balance, 0) AS Balance
	   FROM GetInventoryItemsView gi
	        LEFT OUTER JOIN BalanceQtyView b
				ON B.Item=gi.Id

GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ItemBalanceView]'))
	DROP VIEW [dbo].[ItemBalanceView]
GO

CREATE VIEW [dbo].[ItemBalanceView]
AS
       SELECT gi.Id,
              gi.Code,
     gi.Name,
     gi.Category,
     gi.SubCategory,
     gi.Colour,
     gi.Attribute,
     gi.MinLevel,
     gi.Uom,
     gi.SupplierCode,
     gi.Purchaser,
     ISNULL(b.balance, 0) AS Balance
    FROM GetInventoryItemsView gi
         LEFT OUTER JOIN BalanceQtyView b
    ON B.Item=gi.Id


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  View [dbo].[ReceiptsView]    Script Date: 06/23/2015 14:34:02 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReceiptsView]'))
	DROP VIEW [dbo].[ReceiptsView]
GO

CREATE VIEW [dbo].[ReceiptsView]
AS
	SELECT	sp.ID,
			sp.Tranno AS TransactionNo,
			sp.TranDate AS [Date],
			sp.Item,
			iv.Name AS ItemName,
			sp.Qty AS Quantity
	FROM SPTran sp
		INNER JOIN	InvItem iv
			ON sp.Item = iv.ID
	WHERE sp.Type = 1

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  View [dbo].[IssuesView]    Script Date: 06/23/2015 14:34:02 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IssuesView]'))
	DROP VIEW [dbo].[IssuesView]
GO

CREATE VIEW [dbo].[IssuesView]
AS
	SELECT	sp.ID,
			sp.Tranno as TransactionNo,
			sp.TranDate as [Date],
			sp.Item,
			iv.Name AS ItemName,
			sp.Qty AS Quantity
	FROM SPTran sp
		INNER JOIN InvItem iv
			ON sp.Item = iv.Id
	WHERE sp.Type = 2

GO


------------------------------------------------------------------------------------------------------------------------------------ Transfer Data

--------------------------------SPType

DBCC CHECKIDENT ('[Indico].[dbo].[SPType]', RESEED, 1);
GO

INSERT INTO [Indico].[dbo].[SPType]([Name])
             SELECT Type
			 FROM [Indiman Database].[dbo].[SPType] AS spp


---------------------------------InvPurchaser

DBCC CHECKIDENT ('[Indico].[dbo].[InvPurchaser]', RESEED, 1);
GO
INSERT INTO [Indico].[dbo].[InvPurchaser](Name)
             SELECT Purchaser 
			 FROM [Indiman Database].[dbo].[SPPurchaser] AS spp
             

---------------------------------InvCategory

DBCC CHECKIDENT ('[Indico].[dbo].[InvCategory]', RESEED, 1);
GO
INSERT INTO [Indico].[dbo].[InvCategory](Name)
        SELECT Category 
		FROM [Indiman Database].[dbo].[SPCategory]


INSERT INTO [Indico].[dbo].[InvCategory](Name,Parent)
        SELECT SubCategory,
		       CategoryId
		FROM [Indiman Database].[dbo].[SPSubCategory]


---------------------------------Supplier
		
INSERT INTO [Indico].[dbo].[Supplier] (Name, Country,Creator,CreatedDate,Modifier,ModifiedDate)
	SELECT sps.Supplier,14,3,GETDATE(),3,GETDATE() FROM [Indiman Database].[dbo].[SPSupplier] sps
		LEFT OUTER JOIN [Indico].[dbo].[Supplier] s
			ON sps.Supplier =  s.Name COLLATE Latin1_General_CI_AS 
	WHERE s.ID IS NULL


---------------------------------InvItem

 INSERT INTO [Indico].[dbo].[InvItem](Name,Category,SubCategory,Colour,Attribute,MinLevel,Uom,Supplier,Purchaser,[Status],Code)
		     SELECT Itemname,
					(SELECT TOP 1 isp.ID FROM [Indiman Database].[dbo].[SPCategory] s
						INNER JOIN [Indico].[dbo].[InvCategory] isp
							ON s.Category = isp.Name COLLATE Latin1_General_CI_AS 
					  WHERE s.CategoryId = i.CategoryID)  AS cid ,
					(SELECT TOP 1 isp.ID FROM [Indiman Database].[dbo].[SPSubCategory] s
						INNER JOIN [Indico].[dbo].[InvCategory] isp
							ON s.SubCategory = isp.Name COLLATE Latin1_General_CI_AS 
					  WHERE s.SubCategoryId = i.SubCategoryID)  AS scid ,
					Colour,
					Attribute,
					MinLevel,
					(SELECT TOP 1 isp.ID FROM [Indiman Database].[dbo].[SPUom] s
						INNER JOIN [Indico].[dbo].[Unit] isp
							ON s.Uom = isp.Name COLLATE Latin1_General_CI_AS 
					  WHERE s.UomId = i.UomId)  AS Uid,
					(SELECT TOP 1 isp.ID FROM [Indiman Database].[dbo].[SPSupplier] s
						INNER JOIN [Indico].[dbo].[Supplier] isp
							ON s.Supplier = isp.Name COLLATE Latin1_General_CI_AS 
					  WHERE s.SupplierID = i.SupplierID)  AS SupplierID,
					PurchaserID,
					CAST(Inactive as int),
					Code
		    FROM [Indiman Database].[dbo].[SPItems] i


---------------------------------SPTran

DBCC CHECKIDENT ('[Indico].[dbo].[SPTran]', RESEED, 1);
GO

INSERT INTO [Indico].[dbo].[SPTran] (Type,Tranno,TranDate,Item,Qty,PONo,Creator,CreatedDate,Modifier,ModifierDate,Notes)
	         SELECT TypeID,
			 Tranno,
			 Trandate,
			 (SELECT TOP 1 isp.ID FROM [Indiman Database].[dbo].[SPItems] s
						INNER JOIN [Indico].[dbo].[InvItem] isp
							ON s.Code = isp.Code COLLATE Latin1_General_CI_AS 
					  WHERE s.ItemID = spt.ItemId)  AS ItemID,
			 Qty,
			 PONo,
			 2,
			 CreatedDate,
			 NULL,
			 ModifiedDate,
			 Notes
	         FROM [Indiman Database].[dbo].[SPTrans] spt