USE [Indico]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

DECLARE @PageId int
DECLARE @MenuItemTabId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

DECLARE @SalesAdministrator int

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
	 VALUES ('/PriceList.aspx','Price List','Price List')
SET @PageId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItem]([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Price List', 'Price List', 1, 29, 8, 1)
SET @MenuItemTabId = SCOPE_IDENTITY()	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemTabId, 7)
GO

DELETE FROM Indico.dbo.MenuItemRole WHERE MenuItem = 55
DELETE FROM Indico.dbo.MenuItem WHERE Name = 'Sports Categories'
DELETE FROM Indico.dbo.Page WHERE Name = 'Sports Categories'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PriceListDownloads_Distributor]') AND parent_object_id = OBJECT_ID(N'[dbo].[PriceListDownloads]'))
ALTER TABLE [dbo].[PriceListDownloads] DROP CONSTRAINT [FK_PriceListDownloads_Distributor]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PriceListDownloads_PriceTerm]') AND parent_object_id = OBJECT_ID(N'[dbo].[PriceListDownloads]'))
ALTER TABLE [dbo].[PriceListDownloads] DROP CONSTRAINT [FK_PriceListDownloads_PriceTerm]
GO

/****** Object:  Table [dbo].[PriceListDownloads]    Script Date: 08/31/2012 19:09:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PriceListDownloads]') AND type in (N'U'))
DROP TABLE [dbo].[PriceListDownloads]
GO

/****** Object:  Table [dbo].[PriceListDownloads]    Script Date: 08/31/2012 18:47:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceListDownloads](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Distributor] [int] NULL,
	[PriceTerm] [int] NOT NULL,
	[EditedPrice] [bit] NOT NULL,
	[CreativeDesign] [decimal] NULL,
	[StudioDesign] [decimal] NULL,
	[ThirdPartyDesign] [decimal] NULL,
	[Position1] [decimal] NULL,
	[Position2] [decimal] NULL,
	[Position3] [decimal] NULL,
	[FileName] [nvarchar](256) NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_PriceListDownloads] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PriceListDownloads]  WITH CHECK ADD CONSTRAINT [FK_PriceListDownloads_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO
ALTER TABLE [dbo].[PriceListDownloads] CHECK CONSTRAINT [FK_PriceListDownloads_Distributor]
GO

ALTER TABLE [dbo].[PriceListDownloads]  WITH CHECK ADD CONSTRAINT [FK_PriceListDownloads_PriceTerm] FOREIGN KEY([PriceTerm])
REFERENCES [dbo].[PriceTerm] ([ID])
GO
ALTER TABLE [dbo].[PriceListDownloads] CHECK CONSTRAINT [FK_PriceListDownloads_PriceTerm]
GO

ALTER TABLE [dbo].[PriceListDownloads]  WITH CHECK ADD  CONSTRAINT [FK_PriceListDownloads_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[PriceListDownloads] CHECK CONSTRAINT [FK_PriceListDownloads_Creator]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
