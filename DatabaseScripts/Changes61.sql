USE [Indico]
GO


--**--**--**--**--**--**--**--**--** Inser Page Table for PackingList Page --**--**--**--**--**--**--**--**--**
INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/ViewPackingLists.aspx', 'Packing Lists', 'Packing Lists')
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser MenuItem Table for PackingList Page --**--**--**--**--**--**--**--**--**

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Position AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPackingLists.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Position = (SELECT (MAX([Position])+1) FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES
           (@Page, 'Packing Lists', 'Packing Lists', 1, @Parent, @Position , 0)
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser MenuItemRole Table for ViewPackingLists Page --**--**--**--**--**--**--**--**--**
DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPackingLists.aspx')
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

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPackingLists.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
--**--**--**--**--**--**--**--**--** Add new columns to the CostSheet Table --**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[CostSheet]
ADD [SubCons] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [DutyRate] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [CF1] [nvarchar] (150) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [CF2] [nvarchar] (150) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [CF3] [nvarchar] (150) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [CONS1] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [CONS2] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [CONS3] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [InkCons] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [PaperCons] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [Rate1] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [Rate2] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [Rate3] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [InkRate] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [PaperRate] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [MarginRate] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [FOBAUD] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [Duty] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [Cost1] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [Cost2] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [Cost3] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [InkCost] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [PaperCost] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [MGTOH] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [IndicoOH] [decimal] (8,2) NULL
GO


ALTER TABLE [dbo].[CostSheet]
ADD [Depr] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [Landed] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [IndimanCIF] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [QuotedCIF] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [FobFactor] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [IndimanFOB] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [CalMGN] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [ActMgn] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [MP] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [QuotedMP] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [ExchangeRate] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [AirFregiht] [decimal] (8,2) NULL
GO

ALTER TABLE [dbo].[CostSheet]
ADD [ImpCharges] [decimal] (8,2) NULL
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Update The Fabric Table --**--**--**--**--**--**--**--**--**

--DECLARE @Code AS nvarchar(255)
--DECLARE @Desc AS nvarchar(255)
--DECLARE @Width AS nvarchar(255)
--DECLARE @Const AS nvarchar(255)
--DECLARE @GSM AS nvarchar(255)
--DECLARE @Color AS nvarchar(255)
--DECLARE @Price AS decimal (8,2)
--DECLARE @Unit AS int
--DECLARE @Supplier AS int
--DECLARE @FabricID AS int
--DECLARE @SupplierID AS int
--DECLARE @UnitID AS int
--DECLARE @ColorID AS int

--DECLARE FabricCursor CURSOR FAST_FORWARD FOR
 
--SELECT [FabricCode]
--      ,[FabricDesc]
--      ,[FabWidth]
--      ,[FabConst]
--      ,[FabGSM]
--      ,[FabColour]      
--      ,[FabricPrice]      
--      ,[Unit]
--      ,[Supplier]       
--  FROM [Indman_Sub_CostSheetsSQL].[dbo].[Fabric]
  
--OPEN FabricCursor 
--	FETCH NEXT FROM FabricCursor INTO @Code, @Desc, @Width , @Const, @GSM, @Color, @Price, @Unit, @Supplier   
--	WHILE @@FETCH_STATUS = 0 
--	BEGIN 
	
--		SET @FabricID = (SELECT f.[ID] FROM [Indico].[dbo].[FabricCode] f WHERE f.[Code] = @Code)
--		SET @SupplierID = (SELECT s.[ID] FROM [Indico].[dbo].[Supplier] s WHERE s.[Name] = (SELECT ss.[SupplierName] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Supplier] ss WHERE ss.[SupplierID] = @Supplier))
--		SET @UnitID= (SELECT u.[ID] FROM [Indico].[dbo].[Unit] u WHERE u.[Name] = (SELECT uu.[Unit] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Unit] uu WHERE uu.[UnitID] = @Unit))
--		SET @ColorID = (SELECT ac.[ID] FROM [Indico].[dbo].[AccessoryColor] ac WHERE ac.[Name] = @Color)
		
--		UPDATE [dbo].[FabricCode] 
--		SET [GSM] = @GSM,
--			[Supplier] = @SupplierID,
--			[FabricPrice] = @Price,
--			[Fabricwidth] = @Width,
--			[Unit] = @UnitID,
--			[FabricColor] = @ColorID
--		WHERE [ID] = @FabricID
		
--		FETCH NEXT FROM FabricCursor INTO  @Code, @Desc, @Width , @Const, @GSM, @Color, @Price, @Unit, @Supplier   
--	END
--CLOSE FabricCursor 
--DEALLOCATE FabricCursor
-------/--------
--GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Create New Table [CostSheetImages] --**--**--**--**--**--**--**--**--**


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ICostSheetImages_CostSheet]') AND parent_object_id = OBJECT_ID(N'[dbo].[CostSheetImages]'))
ALTER TABLE [dbo].[CostSheetImages] DROP CONSTRAINT [FK_ICostSheetImages_CostSheet]
GO

/****** Object:  Table [dbo].[CostSheetImages]    Script Date: 09/24/2013 12:06:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CostSheetImages]') AND type in (N'U'))
DROP TABLE [dbo].[CostSheetImages]
GO

/****** Object:  Table [dbo].[CostSheetImages]    Script Date: 09/24/2013 12:06:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[CostSheetImages](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CostSheet] [int] NOT NULL,
	[Size] [int] NOT NULL,
	[Filename] [nvarchar](255) NULL,
	[Extension] [varchar](10) NULL,
 CONSTRAINT [PK_CostSheetImages] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[CostSheetImages]  WITH CHECK ADD  CONSTRAINT [FK_ICostSheetImages_CostSheet] FOREIGN KEY([CostSheet])
REFERENCES [dbo].[CostSheet] ([ID])
GO

ALTER TABLE [dbo].[CostSheetImages] CHECK CONSTRAINT [FK_ICostSheetImages_CostSheet]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Create New Table [IndimanCostSheetRemarks] --**--**--**--**--**--**--**--**--**


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_IndimanCostSheetRemarks_CostSheet]') AND parent_object_id = OBJECT_ID(N'[dbo].[IndimanCostSheetRemarks]'))
ALTER TABLE [dbo].[IndimanCostSheetRemarks] DROP CONSTRAINT [FK_IndimanCostSheetRemarks_CostSheet]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_IndimanCostSheetRemarks_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[IndimanCostSheetRemarks]'))
ALTER TABLE [dbo].[IndimanCostSheetRemarks] DROP CONSTRAINT [FK_IndimanCostSheetRemarks_Modifier]
GO

/****** Object:  Table [dbo].[IndimanCostSheetRemarks]    Script Date: 09/24/2013 12:09:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[IndimanCostSheetRemarks]') AND type in (N'U'))
DROP TABLE [dbo].[IndimanCostSheetRemarks]
GO

/****** Object:  Table [dbo].[IndimanCostSheetRemarks]    Script Date: 09/24/2013 12:09:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[IndimanCostSheetRemarks](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CostSheet] [int] NOT NULL,
	[Remarks] [nvarchar](512) NOT NULL,
	[Modifier] [int] NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_IndimanCostSheetRemarks] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[IndimanCostSheetRemarks]  WITH CHECK ADD  CONSTRAINT [FK_IndimanCostSheetRemarks_CostSheet] FOREIGN KEY([CostSheet])
REFERENCES [dbo].[CostSheet] ([ID])
GO

ALTER TABLE [dbo].[IndimanCostSheetRemarks] CHECK CONSTRAINT [FK_IndimanCostSheetRemarks_CostSheet]
GO

ALTER TABLE [dbo].[IndimanCostSheetRemarks]  WITH CHECK ADD  CONSTRAINT [FK_IndimanCostSheetRemarks_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[IndimanCostSheetRemarks] CHECK CONSTRAINT [FK_IndimanCostSheetRemarks_Modifier]
GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser Page Table for PackingList Page --**--**--**--**--**--**--**--**--**
INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/FillCarton.aspx', 'Fill Carton', 'Fill Carton')
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser MenuItem Table for PackingList Page --**--**--**--**--**--**--**--**--**

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Position AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/FillCarton.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Position = (SELECT (MAX([Position])+1) FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES
           (@Page, 'Fill Carton', 'Fill Carton', 1, @Parent, @Position , 0)
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser MenuItemRole Table for ViewPackingLists Page --**--**--**--**--**--**--**--**--**
DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/FillCarton.aspx')
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

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/FillCarton.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Update MenuItem PriceList --**--**--**--**--**--**--**--**--**

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/PackingList.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = 68 AND [Parent] = 4)


UPDATE [dbo].[MenuItem] SET [IsVisible] = 0 WHERE [ID] = @MenuItem
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
