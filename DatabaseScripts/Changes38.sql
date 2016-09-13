USE [Indico]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Quote_Client]') AND parent_object_id = OBJECT_ID(N'[dbo].[Quote]'))
ALTER TABLE [dbo].[Quote] DROP CONSTRAINT [FK_Quote_Client]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Quote_Distributor]') AND parent_object_id = OBJECT_ID(N'[dbo].[Quote]'))
ALTER TABLE [dbo].[Quote] DROP CONSTRAINT [FK_Quote_Distributor]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Quote_Fabric]') AND parent_object_id = OBJECT_ID(N'[dbo].[Quote]'))
ALTER TABLE [dbo].[Quote] DROP CONSTRAINT [FK_Quote_Fabric]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Quote_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[Quote]'))
ALTER TABLE [dbo].[Quote] DROP CONSTRAINT [FK_Quote_Pattern]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Quote_PriceTerm]') AND parent_object_id = OBJECT_ID(N'[dbo].[Quote]'))
ALTER TABLE [dbo].[Quote] DROP CONSTRAINT [FK_Quote_PriceTerm]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Quote_VlNumber]') AND parent_object_id = OBJECT_ID(N'[dbo].[Quote]'))
ALTER TABLE [dbo].[Quote] DROP CONSTRAINT [FK_Quote_VlNumber]
GO

USE [Indico]
GO

/****** Object:  Table [dbo].[Quote]    Script Date: 04/22/2013 12:43:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Quote]') AND type in (N'U'))
DROP TABLE [dbo].[Quote]
GO

USE [Indico]
GO

/****** Object:  Table [dbo].[Quote]    Script Date: 04/22/2013 12:43:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Quote](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DateQuoted] [datetime2](7) NOT NULL,
	[QuoteExpiryDate] [datetime2](7) NOT NULL,
	[Distributor] [int] NULL,
	[Client] [int] NULL,
	[ClientEmail] [nvarchar](255) NOT NULL,
	[JobName] [nvarchar](255) NULL,
	[VLNumber] [int] NULL,
	[Pattern] [int] NULL,
	[Fabric] [int] NULL,
	[Qty] [int] NULL,
	[DeliveryDate] [datetime2] NULL,
	[PriceTerm] [int] NULL,
	[IndimanPrice] [decimal](8,2) NULL,
	[Notes] [nvarchar](255) NULL,
 CONSTRAINT [PK_Quote] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_Client] FOREIGN KEY([Client])
REFERENCES [dbo].[Client] ([ID])
GO

ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_Client]
GO

ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO

ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_Distributor]
GO

ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_Fabric] FOREIGN KEY([Fabric])
REFERENCES [dbo].[FabricCode] ([ID])
GO

ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_Fabric]
GO

ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO

ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_Pattern]
GO

ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_PriceTerm] FOREIGN KEY([PriceTerm])
REFERENCES [dbo].[PriceTerm] ([ID])
GO

ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_PriceTerm]
GO

ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_VLNumber] FOREIGN KEY([VLNumber])
REFERENCES [dbo].[VisualLayout] ([ID])
GO

ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_VLNumber]
GO


--**--**--**--**--**--**--**--**--**--** ADD New Records to the Page Table --**--**--**--**--**--**--**--**--**--**

INSERT INTO [dbo].[Page] ([Name],[Title],[Heading])
VALUES('/ViewQuotes.aspx',
	   'Quotes',
	   'Quotes'
	  )
GO	  
INSERT INTO [dbo].[Page] ([Name],[Title],[Heading])
VALUES('/AddEditQuote.aspx',
	   'Quote',
	   'Quote'
	  )
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--**--** ADD New Records to the MenuItem Table --**--**--**--**--**--**--**--**--**
DECLARE @Page AS int 
DECLARE @Position AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewQuotes.aspx')
SET @Position = (SELECT MAX(Position)+1 FROM [dbo].[MenuItem] WHERE Parent IS NULL)

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page] ,[Name] ,[Description] ,[IsActive] ,[Parent] ,[Position] ,[IsVisible])
     VALUES
           (
               @Page, 
               'Quotes',
               'Quotes',
               1,
               NULL,
               @Position,
               1         
           )
GO

DECLARE @Page AS int 
DECLARE @Parent AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewQuotes.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page] ,[Name] ,[Description] ,[IsActive] ,[Parent] ,[Position] ,[IsVisible])
     VALUES
           (
               @Page, 
               'Quotes',
               'Quotes',
               1,
               @Parent,
               1,
               1         
           )
GO


DECLARE @Page AS int 
DECLARE @SubPage AS int

DECLARE @Parent AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditQuote.aspx')
SET @SubPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewQuotes.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @SubPage AND [Parent] IS NOT NULL)

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page] ,[Name] ,[Description] ,[IsActive] ,[Parent] ,[Position] ,[IsVisible])
     VALUES
           (
               @Page, 
               'Quotes',
               'Quotes',
               1,
               @Parent,
               2,
               0         
           )
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--**--** ADD New Records to the MenuItemRole Table --**--**--**--**--**--**--**--**--**

--- Indico Administrator
DECLARE @Role AS int
DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @ParentMenuItem AS int

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indico Administrator')
SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewQuotes.aspx')
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL) 

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
VALUES(
		@MenuItem,
		@Role
	  )
GO

DECLARE @Role AS int
DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @ParentMenuItem AS int

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indico Administrator')
SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewQuotes.aspx')
SET @ParentMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL) 
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @ParentMenuItem)

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
VALUES(
		@MenuItem,
		@Role
	  )
GO

DECLARE @Role AS int
DECLARE @MainPage AS int
DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @ParentMenuItem AS int


SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indico Administrator')
SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditQuote.aspx')
SET @MainPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewQuotes.aspx')
SET @ParentMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @MainPage AND [Parent] IS NOT NULL) 
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @ParentMenuItem)

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
VALUES(
		@MenuItem,
		@Role
	  )
GO


---- Indico Coordinator
DECLARE @Role AS int
DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @ParentMenuItem AS int

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewQuotes.aspx')
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL) 

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
VALUES(
		@MenuItem,
		@Role
	  )
GO

DECLARE @Role AS int
DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @ParentMenuItem AS int

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewQuotes.aspx')
SET @ParentMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL) 
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @ParentMenuItem)

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
VALUES(
		@MenuItem,
		@Role
	  )
GO

DECLARE @Role AS int
DECLARE @MainPage AS int
DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @ParentMenuItem AS int


SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditQuote.aspx')
SET @MainPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewQuotes.aspx')
SET @ParentMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @MainPage AND [Parent] IS NOT NULL) 
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @ParentMenuItem)

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
VALUES(
		@MenuItem,
		@Role
	  )
GO