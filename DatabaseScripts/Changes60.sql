USE [Indico]
GO

--**--**--**--**--**--**--**--**--** Inser MenuItemRole Table for Factory Cost Sheet Page --**--**--**--**--**--**--**--**--**
DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Position AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditFactoryCostSheet.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditIndimanPrice.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
--SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Position = (SELECT (MAX([Position])+1) FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES
           (@Page, 'Cost Sheet', 'Cost Sheet', 1, @Parent, @Position , 1)
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditFactoryCostSheet.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditIndimanPrice.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Change MenuItem Name And Page Name --**--**--**--**--**--**--**--**--**
DECLARE @Page AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditFactoryCostSheet.aspx')

UPDATE [dbo].[Page] SET [Title] = 'Cost Sheet' WHERE [ID] = @Page
GO

DECLARE @Page AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditFactoryCostSheet.aspx')

UPDATE [dbo].[Page] SET [Heading] = 'Cost Sheet' WHERE [ID] = @Page
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditFactoryCostSheet.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPrices.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)

UPDATE [dbo].[MenuItem] SET [Name] = 'Cost Sheet' WHERE [ID] = @MenuItem
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditFactoryCostSheet.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPrices.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)

UPDATE [dbo].[MenuItem] SET [Description] = 'Cost Sheet' WHERE [ID] = @MenuItem
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--** Update User Table for User = Adaya --**--**--**--**--**--**--**--**--**

DECLARE @User AS int

SET @User = (SELECT [ID] FROM [dbo].[User] WHERE [UserName] = 'adaya')

UPDATE [dbo].[User] SET [IsDistributor] = 1 WHERE [ID] = @User
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Create Table CostSheet Remarks --**--**--**--**--**--**--**--**--**
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CostSheetRemarks_CostSheet]') AND parent_object_id = OBJECT_ID(N'[dbo].[CostSheetRemarks]'))
ALTER TABLE [dbo].[CostSheetRemarks] DROP CONSTRAINT [FK_CostSheetRemarks_CostSheet]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CostSheetRemarks_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[CostSheetRemarks]'))
ALTER TABLE [dbo].[CostSheetRemarks] DROP CONSTRAINT [FK_CostSheetRemarks_Modifier]
GO

/****** Object:  Table [dbo].[CostSheetRemarks]    Script Date: 09/16/2013 09:17:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CostSheetRemarks]') AND type in (N'U'))
DROP TABLE [dbo].[CostSheetRemarks]
GO

/****** Object:  Table [dbo].[CostSheetRemarks]    Script Date: 09/16/2013 09:17:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CostSheetRemarks](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CostSheet] [int] NOT NULL,
	[Remarks] [nvarchar](512) NOT NULL,
	[Modifier] [int] NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_CostSheetRemarks] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[CostSheetRemarks]  WITH CHECK ADD  CONSTRAINT [FK_CostSheetRemarks_CostSheet] FOREIGN KEY([CostSheet])
REFERENCES [dbo].[CostSheet] ([ID])
GO

ALTER TABLE [dbo].[CostSheetRemarks] CHECK CONSTRAINT [FK_CostSheetRemarks_CostSheet]
GO

ALTER TABLE [dbo].[CostSheetRemarks]  WITH CHECK ADD  CONSTRAINT [FK_CostSheetRemarks_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[CostSheetRemarks] CHECK CONSTRAINT [FK_CostSheetRemarks_Modifier]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Add Two Column To the CostSheet Table --**--**--**--**--**--**--**--**--**
ALTER TABLE [dbo].[CostSheet]
ADD [SubWastage] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [SubFinance] [decimal] (8,2) NULL
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Change MenuItem Name And Page Name --**--**--**--**--**--**--**--**--**

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddPatternFabricPrice.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPrices.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)

UPDATE [dbo].[MenuItem] SET [Name] = 'Manage Pattern Fabric' WHERE [ID] = @MenuItem
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddPatternFabricPrice.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPrices.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)

UPDATE [dbo].[MenuItem] SET [Description] = 'Manage Pattern Fabric' WHERE [ID] = @MenuItem
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddPatternFabricPrice.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditIndimanPrice.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)

UPDATE [dbo].[MenuItem] SET [Name] = 'Manage Pattern Fabric' WHERE [ID] = @MenuItem
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddPatternFabricPrice.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditIndimanPrice.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)

UPDATE [dbo].[MenuItem] SET [Description] = 'Manage Pattern Fabric' WHERE [ID] = @MenuItem
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  Table [dbo].[Carton]    Script Date: 09/13/2013 12:43:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Carton]') AND type in (N'U'))
DROP TABLE [dbo].[Carton]
GO

/****** Object:  Table [dbo].[Carton]    Script Date: 09/12/2013 12:56:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Carton](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_Carton] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

INSERT INTO [Indico].[dbo].[Carton]([Name]) VALUES('60X40X17 CM')
GO

INSERT INTO [Indico].[dbo].[Carton]([Name]) VALUES('60X40X28 CM')
GO

INSERT INTO [Indico].[dbo].[Carton]([Name]) VALUES('60X40X40 CM')
GO

/****** Object:  Table [dbo].[PackingList]    Script Date: 09/13/2013 12:44:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PackingList]') AND type in (N'U'))
DROP TABLE [dbo].[PackingList]
GO


/****** Object:  Table [dbo].[PackingList]    Script Date: 09/12/2013 12:56:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PackingList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CartonNo] [int] NOT NULL, 
	[WeeklyProductionCapacity] [int] NOT NULL,
	[OrderDetail] [int] NOT NULL,
	[PackingQty] [int] NOT NULL,
	[Carton] [int] NOT NULL, 
	[Remarks] [nvarchar](512) NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[Modifier] [int] NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_PackingList] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PackingList]  WITH CHECK ADD  CONSTRAINT [FK_PackingList_WeeklyProductionCapacity] FOREIGN KEY([WeeklyProductionCapacity])
REFERENCES [dbo].[WeeklyProductionCapacity] ([ID])
GO
ALTER TABLE [dbo].[PackingList] CHECK CONSTRAINT [FK_PackingList_WeeklyProductionCapacity]
GO

ALTER TABLE [dbo].[PackingList]  WITH CHECK ADD  CONSTRAINT [FK_PackingList_OrderDetail] FOREIGN KEY([OrderDetail])
REFERENCES [dbo].[OrderDetail] ([ID])
GO
ALTER TABLE [dbo].[PackingList] CHECK CONSTRAINT [FK_PackingList_OrderDetail]
GO

ALTER TABLE [dbo].[PackingList]  WITH CHECK ADD  CONSTRAINT [FK_PackingList_Carton] FOREIGN KEY([Carton])
REFERENCES [dbo].[Carton] ([ID])
GO

ALTER TABLE [dbo].[PackingList] CHECK CONSTRAINT [FK_PackingList_Carton]
GO

ALTER TABLE [dbo].[PackingList]  WITH CHECK ADD  CONSTRAINT [FK_PackingList_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[PackingList] CHECK CONSTRAINT [FK_PackingList_Creator]
GO

ALTER TABLE [dbo].[PackingList]  WITH CHECK ADD  CONSTRAINT [FK_PackingList_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[PackingList] CHECK CONSTRAINT [FK_PackingList_Modifier]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  Table [dbo].[PackingListSizeQty]    Script Date: 09/13/2013 13:11:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PackingListSizeQty](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PackingList] [int] NOT NULL,
	[Size] [int] NOT NULL,
	[Qty] [int] NOT NULL,
 CONSTRAINT [PK_PackingListSizeQty] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PackingListSizeQty', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Packing List id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PackingListSizeQty', @level2type=N'COLUMN',@level2name=N'PackingList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Size of the packing list' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PackingListSizeQty', @level2type=N'COLUMN',@level2name=N'Size'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Quantity of the packing list' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PackingListSizeQty', @level2type=N'COLUMN',@level2name=N'Qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PackingListSizeQty'
GO

ALTER TABLE [dbo].[PackingListSizeQty]  WITH CHECK ADD  CONSTRAINT [FK_PackingListSizeQty_PackingList] FOREIGN KEY([PackingList])
REFERENCES [dbo].[PackingList] ([ID])
GO

ALTER TABLE [dbo].[PackingListSizeQty] CHECK CONSTRAINT [FK_PackingListSizeQty_PackingList]
GO

ALTER TABLE [dbo].[PackingListSizeQty]  WITH CHECK ADD  CONSTRAINT [FK_PackingListSizeQty_Size1] FOREIGN KEY([Size])
REFERENCES [dbo].[Size] ([ID])
GO

ALTER TABLE [dbo].[PackingListSizeQty] CHECK CONSTRAINT [FK_PackingListSizeQty_Size1]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  Table [dbo].[PackingListCartonItem]    Script Date: 09/13/2013 13:11:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PackingListCartonItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PackingList] [int] NOT NULL,
	[Size] [int] NOT NULL,
	[Count] [int] NOT NULL DEFAULT(0),
 CONSTRAINT [PK_PackingListCartonItem] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PackingListCartonItem', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Packing List id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PackingListCartonItem', @level2type=N'COLUMN',@level2name=N'PackingList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Size of the packing list' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PackingListCartonItem', @level2type=N'COLUMN',@level2name=N'Size'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Added count' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PackingListCartonItem', @level2type=N'COLUMN',@level2name=N'Count'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PackingListCartonItem'
GO

ALTER TABLE [dbo].[PackingListCartonItem]  WITH CHECK ADD  CONSTRAINT [FK_PackingListCartonItem_PackingList] FOREIGN KEY([PackingList])
REFERENCES [dbo].[PackingList] ([ID])
GO

ALTER TABLE [dbo].[PackingListCartonItem] CHECK CONSTRAINT [FK_PackingListCartonItem_PackingList]
GO

ALTER TABLE [dbo].[PackingListCartonItem]  WITH CHECK ADD  CONSTRAINT [FK_PackingListCartonItem_Size] FOREIGN KEY([Size])
REFERENCES [dbo].[Size] ([ID])
GO

ALTER TABLE [dbo].[PackingListCartonItem] CHECK CONSTRAINT [FK_PackingListCartonItem_Size]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser Page Table for PackingList Page --**--**--**--**--**--**--**--**--**
INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/PackingList.aspx', 'Packing List', 'Packing List')
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser MenuItem Table for PackingList Page --**--**--**--**--**--**--**--**--**

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Position AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/PackingList.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Position = (SELECT (MAX([Position])+1) FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES
           (@Page, 'Packing List', 'Packing List', 1, @Parent, @Position , 1)
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser MenuItemRole Table for Supplier Page --**--**--**--**--**--**--**--**--**
DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/PackingList.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/PackingList.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO