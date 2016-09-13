USE [Indico]
GO

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 08/27/2013 10:01:07 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetailsView]'))
DROP VIEW [dbo].[OrderDetailsView]
GO

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 08/27/2013 10:01:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OrderDetailsView]
AS
		SELECT --DISTINCT TOP 100 PERCENT
			co.[ID] AS CompanyId,
			co.[Name] AS CompanyName,
			o.[ID] AS OrderId,
			o.[Date],
			o.[CreatedDate] AS OrderCreatedDate,			
			o.[EstimatedCompletionDate],
			o.[OrderSubmittedDate],
			o.[ModifiedDate] AS OrderModifiedDate,			
			o.[IsTemporary],			
			o.[PurchaseOrderNo],
			o.[OldPONo] AS OldPurchaseOrderNo,			
			o.[Reservation] AS ReservationId,			
			cl.[ID] AS ClientId,
			cl.[Name] AS ClientName,
			u.[ID] AS UserId,
			u.[Username] AS Username,
			dco.[GivenName] AS UserGivenName,
			dco.[FamilyName] AS UserFamilyName,
			u.[Company] AS UserCompany,
			os.[ID] AS [StatusId],
			os.[Name] AS [Status]--,
		FROM dbo.[Order] o
			INNER JOIN dbo.[OrderStatus] os
				ON  os.[ID] = o.[Status]
			INNER JOIN dbo.[Company] co
				ON co.[ID] = o.[Distributor]
			INNER JOIN dbo.[Client] cl
				ON cl.[ID] = o.[Client]
			INNER JOIN dbo.[User] u
				ON u.[ID] = o.[Creator]	
			INNER JOIN [dbo].[User] dco
				ON dco.[ID] = co.[Coordinator]		


GO


--**--**--**--**--**--**--**--**--** CREATE TABLE [dbo].[Unit] --**--**--**--**--**--**--**--**--**

/****** Object:  Table [dbo].[Unit]    Script Date: 08/27/2013 10:58:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Unit]') AND type in (N'U'))
DROP TABLE [dbo].[Unit]
GO

/****** Object:  Table [dbo].[Unit]    Script Date: 08/27/2013 10:58:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Unit](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](255) NULL,
 CONSTRAINT [PK_Unit] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--** CREATE NEW TABLE SUPPLIER --**--**--**--**--**--**--**--**--**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Supplier_Country]') AND parent_object_id = OBJECT_ID(N'[dbo].[Supplier]'))
ALTER TABLE [dbo].[Supplier] DROP CONSTRAINT [FK_Supplier_Country]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Supplier_Creator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Supplier]'))
ALTER TABLE [dbo].[Supplier] DROP CONSTRAINT [FK_Supplier_Creator]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Supplier_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[Supplier]'))
ALTER TABLE [dbo].[Supplier] DROP CONSTRAINT [FK_Supplier_Modifier]
GO

/****** Object:  Table [dbo].[Supplier]    Script Date: 08/27/2013 11:18:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Supplier]') AND type in (N'U'))
DROP TABLE [dbo].[Supplier]
GO

/****** Object:  Table [dbo].[Supplier]    Script Date: 08/27/2013 11:18:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Supplier](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Country] [int] NOT NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[Modifier] [int] NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Supplier] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Supplier]  WITH CHECK ADD  CONSTRAINT [FK_Supplier_Country] FOREIGN KEY([Country])
REFERENCES [dbo].[Country] ([ID])
GO

ALTER TABLE [dbo].[Supplier] CHECK CONSTRAINT [FK_Supplier_Country]
GO

ALTER TABLE [dbo].[Supplier]  WITH CHECK ADD  CONSTRAINT [FK_Supplier_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[Supplier] CHECK CONSTRAINT [FK_Supplier_Creator]
GO

ALTER TABLE [dbo].[Supplier]  WITH CHECK ADD  CONSTRAINT [FK_Supplier_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[Supplier] CHECK CONSTRAINT [FK_Supplier_Modifier]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** DROP THE CONSTRAINT [FK_AccessoryCategory_Accessory] --**--**--**--**--**--**--**--**--**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_AccessoryCategory_Accessory]') AND parent_object_id = OBJECT_ID(N'[dbo].[AccessoryCategory]'))
ALTER TABLE [dbo].[AccessoryCategory] DROP CONSTRAINT [FK_AccessoryCategory_Accessory]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** DROP THE CONSTRAINT [FK_PatternAccessory_AccessoryCategory] --**--**--**--**--**--**--**--**--**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternAccessory_AccessoryCategory]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternAccessory]'))
ALTER TABLE [dbo].[PatternAccessory] DROP CONSTRAINT [FK_PatternAccessory_AccessoryCategory]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** DROP THE CONSTRAINT [FK_VisualLayoutAccessory_AccessoryCategory] --**--**--**--**--**--**--**--**--**
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_VisualLayoutAccessory_AccessoryCategory]') AND parent_object_id = OBJECT_ID(N'[dbo].[VisualLayoutAccessory]'))
ALTER TABLE [dbo].[VisualLayoutAccessory] DROP CONSTRAINT [FK_VisualLayoutAccessory_AccessoryCategory]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** RENAME TABLE NAME ACCESSORY TO ACCESSORY CATEGORY --**--**--**--**--**--**--**--**--**
sp_RENAME '[Accessory]' , 'AccessoryCategory_1'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--** RENAME TABLE NAME ACCESSORY CATEGORY TO ACCESSORY --**--**--**--**--**--**--**--**--**

sp_RENAME '[AccessoryCategory]' , 'Accessory'
GO

sp_RENAME '[AccessoryCategory_1]' , 'AccessoryCategory'
GO

sp_RENAME 'dbo.Accessory.Accessory' , 'AccessoryCategory', 'COLUMN'
GO

ALTER TABLE [dbo].[Accessory]  WITH CHECK ADD  CONSTRAINT [FK_Accessory_AccessoryCategory] FOREIGN KEY([AccessoryCategory])
REFERENCES [dbo].[AccessoryCategory] ([ID])
GO

ALTER TABLE [dbo].[Accessory] CHECK CONSTRAINT [FK_Accessory_AccessoryCategory]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--** ADD NEW COLUMNS TO THE [AccessoryCategory] TABLE --**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[Accessory]
ADD [Description] [nvarchar] (255) NULL
GO

ALTER TABLE [dbo].[Accessory]
ADD [Cost] [decimal](4,2) NULL
GO

ALTER TABLE [dbo].[Accessory]
ADD [SuppCode] [nvarchar] (255) NULL
GO

ALTER TABLE [dbo].[Accessory]
ADD [Unit] [int] NULL
GO

ALTER TABLE [dbo].[Accessory]  WITH CHECK ADD  CONSTRAINT [FK_Accessory_Unit] FOREIGN KEY([Unit])
REFERENCES [dbo].[Unit] ([ID])
GO

ALTER TABLE [dbo].[Accessory] CHECK CONSTRAINT [FK_Accessory_Unit]
GO

ALTER TABLE [dbo].[Accessory]
ADD [Supplier] [int] NULL
GO

ALTER TABLE [dbo].[Accessory]  WITH CHECK ADD  CONSTRAINT [FK_Accessory_Supplier] FOREIGN KEY([Supplier])
REFERENCES [dbo].[Supplier] ([ID])
GO

ALTER TABLE [dbo].[Accessory] CHECK CONSTRAINT [FK_Accessory_Supplier]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** RENAME COLUMN NAME ACCESSORY CATEGORY TO ACCESSORY --**--**--**--**--**--**--**--**--**

sp_RENAME 'PatternAccessory.[AccessoryCategory]' , 'Accessory', 'COLUMN'
GO

ALTER TABLE [dbo].[PatternAccessory]  WITH CHECK ADD  CONSTRAINT [FK_PatternAccessory_Accessory] FOREIGN KEY([Accessory])
REFERENCES [dbo].[Accessory] ([ID])
GO

ALTER TABLE [dbo].[PatternAccessory] CHECK CONSTRAINT [FK_PatternAccessory_Accessory]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** RENAME COLUMN NAME ACCESSORY CATEGORY TO ACCESSORY --**--**--**--**--**--**--**--**--**

sp_RENAME 'VisualLayoutAccessory.[AccessoryCategory]' , 'Accessory', 'COLUMN'
GO

ALTER TABLE [dbo].[VisualLayoutAccessory]  WITH CHECK ADD  CONSTRAINT [FK_VisualLayoutAccessory_Accessory] FOREIGN KEY([Accessory])
REFERENCES [dbo].[Accessory] ([ID])
GO

ALTER TABLE [dbo].[VisualLayoutAccessory] CHECK CONSTRAINT [FK_VisualLayoutAccessory_Accessory]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--** ADD NEW COLUMN TO FABRIC --**--**--**--**--**--**--**--**--**
ALTER TABLE [dbo].[FabricCode]
ADD [Fabricwidth] [nvarchar] (255) NULL
GO

UPDATE [dbo].[FabricCode] SET [Supplier] = NULL
GO

ALTER TABLE [dbo].[FabricCode]
ALTER COLUMN [Supplier] [int] NULL
GO

ALTER TABLE [dbo].[FabricCode]  WITH CHECK ADD  CONSTRAINT [FK_FabricCode_Supplier] FOREIGN KEY([Supplier])
REFERENCES [dbo].[Supplier] ([ID])
GO

ALTER TABLE [dbo].[FabricCode] CHECK CONSTRAINT [FK_FabricCode_Supplier]
GO

ALTER TABLE [dbo].[FabricCode]
ADD [Unit] [int] NULL
GO

ALTER TABLE [dbo].[FabricCode]  WITH CHECK ADD  CONSTRAINT [FK_FabricCode_Unit] FOREIGN KEY([Unit])
REFERENCES [dbo].[Unit] ([ID])
GO

ALTER TABLE [dbo].[FabricCode] CHECK CONSTRAINT [FK_FabricCode_Unit]
GO

ALTER TABLE [dbo].[FabricCode]
ADD [FabricColor] [int] NULL
GO

ALTER TABLE [dbo].[FabricCode]  WITH CHECK ADD  CONSTRAINT [FK_FabricCode_FabricColor] FOREIGN KEY([FabricColor])
REFERENCES [dbo].[AccessoryColor] ([ID])
GO

ALTER TABLE [dbo].[FabricCode] CHECK CONSTRAINT [FK_FabricCode_FabricColor]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** CHANGE COLUMN NAME LandedCost to FabricPrice  --**--**--**--**--**--**--**--**--**

sp_RENAME 'FabricCode.[LandedCost]' , 'FabricPrice', 'COLUMN'
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--** CREATE New Table Patter Support Fabric --**--**--**--**--**--**--**--**--**


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternSupportAccessory_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternSupportFabric]'))
ALTER TABLE [dbo].[PatternSupportFabric] DROP CONSTRAINT [FK_PatternSupportAccessory_Pattern]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternSupportFabric_Fabric]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternSupportFabric]'))
ALTER TABLE [dbo].[PatternSupportFabric] DROP CONSTRAINT [FK_PatternSupportFabric_Fabric]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternSupportFabric_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternSupportFabric]'))
ALTER TABLE [dbo].[PatternSupportFabric] DROP CONSTRAINT [FK_PatternSupportFabric_Pattern]
GO

/****** Object:  Table [dbo].[PatternSupportFabric]    Script Date: 08/27/2013 15:55:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PatternSupportFabric]') AND type in (N'U'))
DROP TABLE [dbo].[PatternSupportFabric]
GO

/****** Object:  Table [dbo].[PatternSupportFabric]    Script Date: 08/27/2013 15:55:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PatternSupportFabric](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pattern] [int] NOT NULL,
	[Fabric] [int] NOT NULL,
	[FabConstant] [decimal](8, 2) NOT NULL,
 CONSTRAINT [PK_PatternSupportFabric] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PatternSupportFabric]  WITH CHECK ADD  CONSTRAINT [FK_PatternSupportFabric_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO

ALTER TABLE [dbo].[PatternSupportFabric] CHECK CONSTRAINT [FK_PatternSupportFabric_Pattern]
GO

ALTER TABLE [dbo].[PatternSupportFabric]  WITH CHECK ADD  CONSTRAINT [FK_PatternSupportFabric_Fabric] FOREIGN KEY([Fabric])
REFERENCES [dbo].[FabricCode] ([ID])
GO

ALTER TABLE [dbo].[PatternSupportFabric] CHECK CONSTRAINT [FK_PatternSupportFabric_Fabric]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--** CREATE New Table Patter Support Accessory --**--**--**--**--**--**--**--**--**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternSupportAccessory_Accessory]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternSupportAccessory]'))
ALTER TABLE [dbo].[PatternSupportAccessory] DROP CONSTRAINT [FK_PatternSupportAccessory_Accessory]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternSupportAccessory_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternSupportAccessory]'))
ALTER TABLE [dbo].[PatternSupportAccessory] DROP CONSTRAINT [FK_PatternSupportAccessory_Pattern]
GO

/****** Object:  Table [dbo].[PatternSupportAccessory]    Script Date: 09/02/2013 12:02:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PatternSupportAccessory]') AND type in (N'U'))
DROP TABLE [dbo].[PatternSupportAccessory]
GO

/****** Object:  Table [dbo].[PatternSupportAccessory]    Script Date: 09/02/2013 12:02:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PatternSupportAccessory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pattern] [int] NOT NULL,
	[Accessory] [int] NOT NULL,
	[AccConstant] [decimal](8, 2) NOT NULL,
 CONSTRAINT [PK_PatternSupportAccessory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PatternSupportAccessory]  WITH CHECK ADD  CONSTRAINT [FK_PatternSupportAccessory_Accessory] FOREIGN KEY([Accessory])
REFERENCES [dbo].[Accessory] ([ID])
GO

ALTER TABLE [dbo].[PatternSupportAccessory] CHECK CONSTRAINT [FK_PatternSupportAccessory_Accessory]
GO

ALTER TABLE [dbo].[PatternSupportAccessory]  WITH CHECK ADD  CONSTRAINT [FK_PatternSupportAccessory_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO

ALTER TABLE [dbo].[PatternSupportAccessory] CHECK CONSTRAINT [FK_PatternSupportAccessory_Pattern]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** CREATE New Table CostSheet --**--**--**--**--**--**--**--**--**
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CostSheet_Creator]') AND parent_object_id = OBJECT_ID(N'[dbo].[CostSheet]'))
ALTER TABLE [dbo].[CostSheet] DROP CONSTRAINT [FK_CostSheet_Creator]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CostSheet_Fabric]') AND parent_object_id = OBJECT_ID(N'[dbo].[CostSheet]'))
ALTER TABLE [dbo].[CostSheet] DROP CONSTRAINT [FK_CostSheet_Fabric]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CostSheet_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[CostSheet]'))
ALTER TABLE [dbo].[CostSheet] DROP CONSTRAINT [FK_CostSheet_Modifier]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CostSheet_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[CostSheet]'))
ALTER TABLE [dbo].[CostSheet] DROP CONSTRAINT [FK_CostSheet_Pattern]
GO

/****** Object:  Table [dbo].[CostSheet]    Script Date: 09/02/2013 12:03:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CostSheet]') AND type in (N'U'))
DROP TABLE [dbo].[CostSheet]
GO

/****** Object:  Table [dbo].[CostSheet]    Script Date: 09/02/2013 12:03:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CostSheet](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pattern] [int] NOT NULL,
	[Fabric] [int] NOT NULL,
	[TotalFabricCost] [decimal](8, 2) NULL,
	[TotalAccessoriesCost] [decimal](8, 2) NULL,
	[HPCost] [decimal](8, 2) NOT NULL,
	[LabelCost] [decimal](8, 2) NOT NULL,
	[Other] [decimal](8, 2) NULL,
	[Finance] [decimal](8, 2) NOT NULL,
	[Wastage] [decimal](8, 2) NOT NULL,
	[FOBExp] [decimal](8, 2) NOT NULL,
	[CM] [decimal](8, 2) NOT NULL,
	[JKFOBCost] [decimal](8, 2) NOT NULL,
	[QuotedFOBCost] [decimal](8, 2) NULL,
	[Roundup] [decimal](8, 2) NULL,
	[SMV] [decimal](8, 2) NULL,
	[SMVRate] [decimal](8, 2) NULL,
	[CalculateCM] [decimal](8, 2) NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[Modifier] [int] NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_CostSheet] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[CostSheet]  WITH CHECK ADD  CONSTRAINT [FK_CostSheet_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[CostSheet] CHECK CONSTRAINT [FK_CostSheet_Creator]
GO

ALTER TABLE [dbo].[CostSheet]  WITH CHECK ADD  CONSTRAINT [FK_CostSheet_Fabric] FOREIGN KEY([Fabric])
REFERENCES [dbo].[FabricCode] ([ID])
GO

ALTER TABLE [dbo].[CostSheet] CHECK CONSTRAINT [FK_CostSheet_Fabric]
GO

ALTER TABLE [dbo].[CostSheet]  WITH CHECK ADD  CONSTRAINT [FK_CostSheet_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[CostSheet] CHECK CONSTRAINT [FK_CostSheet_Modifier]
GO

ALTER TABLE [dbo].[CostSheet]  WITH CHECK ADD  CONSTRAINT [FK_CostSheet_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO

ALTER TABLE [dbo].[CostSheet] CHECK CONSTRAINT [FK_CostSheet_Pattern]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** CREATE New Table PatternHistory  --**--**--**--**--**--**--**--**--**
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternHistory_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternHistory]'))
ALTER TABLE [dbo].[PatternHistory] DROP CONSTRAINT [FK_PatternHistory_Modifier]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternHistory_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternHistory]'))
ALTER TABLE [dbo].[PatternHistory] DROP CONSTRAINT [FK_PatternHistory_Pattern]
GO

/****** Object:  Table [dbo].[PatternHistory]    Script Date: 09/02/2013 13:16:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PatternHistory]') AND type in (N'U'))
DROP TABLE [dbo].[PatternHistory]
GO

/****** Object:  Table [dbo].[PatternHistory]    Script Date: 09/02/2013 13:16:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PatternHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pattern] [int] NOT NULL,
	[Modifier] [int] NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_PatternHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PatternHistory]  WITH CHECK ADD  CONSTRAINT [FK_PatternHistory_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[PatternHistory] CHECK CONSTRAINT [FK_PatternHistory_Modifier]
GO

ALTER TABLE [dbo].[PatternHistory]  WITH CHECK ADD  CONSTRAINT [FK_PatternHistory_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO

ALTER TABLE [dbo].[PatternHistory] CHECK CONSTRAINT [FK_PatternHistory_Pattern]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--** Insert Scripts Unit Table --**--**--**--**--**--**--**--**--**

INSERT INTO [Indico].[dbo].[Unit] ([Name], [Description]) VALUES ('YDS', 'YDS')
GO

INSERT INTO [Indico].[dbo].[Unit] ([Name], [Description]) VALUES ('MTR' , 'MTR')
GO

INSERT INTO [Indico].[dbo].[Unit] ([Name], [Description]) VALUES ('PCS', 'PCS')
GO

INSERT INTO [Indico].[dbo].[Unit] ([Name], [Description]) VALUES ('NOS', 'NOS')
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Insert Scripts Supplier Table --**--**--**--**--**--**--**--**--**

INSERT INTO [Indico].[dbo].[Supplier]([Name], [Country], [Creator], [CreatedDate], [Modifier], [ModifiedDate])
     VALUES
           ('MTC',(SELECT [ID] FROM [dbo].[Country] WHERE [Name] LIKE '%TAIWAN%'), 1, GETDATE(), 1, GETDATE())
GO

INSERT INTO [Indico].[dbo].[Supplier]([Name], [Country], [Creator], [CreatedDate], [Modifier], [ModifiedDate])
     VALUES
           ('HANMAX',(SELECT [ID] FROM [dbo].[Country] WHERE [ShortName] LIKE '%TAIWAN%'), 1, GETDATE(), 1, GETDATE())
GO

INSERT INTO [Indico].[dbo].[Supplier]([Name], [Country], [Creator], [CreatedDate], [Modifier], [ModifiedDate])
     VALUES
           ('CHARLES PARSON',(SELECT [ID] FROM [dbo].[Country] WHERE [ShortName] LIKE '%SRI LANKA%'), 1, GETDATE(), 1, GETDATE())
GO

INSERT INTO [Indico].[dbo].[Supplier]([Name], [Country], [Creator], [CreatedDate], [Modifier], [ModifiedDate])
     VALUES
           ('NATURAB',(SELECT [ID] FROM [dbo].[Country] WHERE [ShortName] LIKE '%SRI LANKA%'), 1, GETDATE(), 1, GETDATE())
GO

INSERT INTO [Indico].[dbo].[Supplier]([Name], [Country], [Creator], [CreatedDate], [Modifier], [ModifiedDate])
     VALUES
           ('LOCAL',(SELECT [ID] FROM [dbo].[Country] WHERE [ShortName] LIKE '%SRI LANKA%'), 1, GETDATE(), 1, GETDATE())
GO

INSERT INTO [Indico].[dbo].[Supplier]([Name], [Country], [Creator], [CreatedDate], [Modifier], [ModifiedDate])
     VALUES
           ('SUZHOU LAISHENG IMP EXP CO',(SELECT [ID] FROM [dbo].[Country] WHERE [ShortName] LIKE '%CHINA%'), 1, GETDATE(), 1, GETDATE())
GO

INSERT INTO [Indico].[dbo].[Supplier]([Name], [Country], [Creator], [CreatedDate], [Modifier], [ModifiedDate])
     VALUES
           ('ADELIDE TRIMS',(SELECT [ID] FROM [dbo].[Country] WHERE [ShortName] LIKE '%AUSTRALIA%'), 1, GETDATE(), 1, GETDATE())
GO

INSERT INTO [Indico].[dbo].[Supplier]([Name], [Country], [Creator], [CreatedDate], [Modifier], [ModifiedDate])
     VALUES
           ('MRC',(SELECT [ID] FROM [dbo].[Country] WHERE [ShortName] LIKE '%AUSTRALIA%'), 1, GETDATE(), 1, GETDATE())
GO

INSERT INTO [Indico].[dbo].[Supplier]([Name], [Country], [Creator], [CreatedDate], [Modifier], [ModifiedDate])
     VALUES
           ('SRITEX',(SELECT [ID] FROM [dbo].[Country] WHERE [ShortName] LIKE '%Hong Kong%'), 1, GETDATE(), 1, GETDATE())
GO

INSERT INTO [Indico].[dbo].[Supplier]([Name], [Country], [Creator], [CreatedDate], [Modifier], [ModifiedDate])
     VALUES
           ('PALM BRANCH',(SELECT [ID] FROM [dbo].[Country] WHERE [ShortName] LIKE '%CHINA%'), 1, GETDATE(), 1, GETDATE())
GO

INSERT INTO [Indico].[dbo].[Supplier]([Name], [Country], [Creator], [CreatedDate], [Modifier], [ModifiedDate])
     VALUES
           ('ASICS',(SELECT [ID] FROM [dbo].[Country] WHERE [ShortName] LIKE '%AUSTRALIA%'), 1, GETDATE(), 1, GETDATE())
GO

INSERT INTO [Indico].[dbo].[Supplier]([Name], [Country], [Creator], [CreatedDate], [Modifier], [ModifiedDate])
     VALUES
           ('LA FONTE',(SELECT [ID] FROM [dbo].[Country] WHERE [ShortName] LIKE '%ITALY%'), 1, GETDATE(), 1, GETDATE())
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Insert Scripts AccesssoryCategory Table --**--**--**--**--**--**--**--**--**

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('BUTTONS', 'B')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('ELASTICS', 'E')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('ZIPS', 'Z')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('VELCRO', 'V')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('TAPE', 'T')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('EMB', 'E')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('SNAP', 'S')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('Plastic Buckle', 'PB')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('RIB', 'R')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('RIB FABRIC', 'RF')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('Draw Cord', 'DC')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('EYELET', 'EY')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('TOGGELESS', 'TO')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('CORD', 'C')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('LABEL', 'L')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('NECK TAPE', 'NT')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('CHAMOIS', 'CH')
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**



--**--**--**--**--**--**--**--**--** Insert Scripts Accesssory Table --**--**--**--**--**--**--**--**--**
DELETE FROM [dbo].[Accessory]
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('4HB'
           ,'4HB'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%BUTTONS%' )
           ,'4 HOLE BUTTON'
           ,0.03
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%SRITEX%' ))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('2CM ELASTIC'
           ,'2CM'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ELASTICS%' )
           ,'2CM ELASTIC'
           ,0.12	
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%NATURAB%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('VELCRO - HOOK'
           ,'VH'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%VELCRO%' )
           ,'2CM ELASTIC'
           ,0.00	
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%ADELIDE TRIMS%'))
GO


INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('NYLON 05 OE ZIP'
           ,'NY'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ZIPS%' )
           ,'Nylon No. 05 O/E Zipper'
           ,0.60	
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%YKK%'))
GO


INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('NYLON 03 CE ZIP'
           ,'NY'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ZIPS%' )
           ,'NYLON 03 CE ZIP'
           ,0.25		
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%YKK%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('ASICS Neck Tape'
           ,'AS'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'TAPE')
           ,'ASICS Neck Tape'
           ,0.00		
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LOCAL%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('EMB - "Australia" at back'
           ,'EMB'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%EMB%' )
           ,'EMB - "Australia" at back'
           ,1.50		
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%MRC%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('EMB - Asics polo 3 logos'
           ,'EMB'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%EMB%' )
           ,'EMB - "Asics polo" 3 logos'
           ,0.50		
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%MRC%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('EMB - Asics polo 3 logos'
           ,'EMB'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%EMB%' )
           ,'EMB - "Asics polo" 3 logos'
           ,0.50		
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%MRC%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('13MM S/T snap button col: Nickle'
           ,'13MM'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%SNAP%' )
           ,'EMB - "Asics polo" 3 logos'
           ,0.10	
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%SRITEX%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('TWILL TAPE 1 CM'
           ,'TWILL'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'TAPE' )
           ,'10mm Twill Tape	0.08'
           ,0.08	
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LOCAL%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('NYLON TAPE'
           ,'NT'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'TAPE' )
           ,'1.5 " width Tape'
           ,0.20	
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LOCAL%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Plastic buckle'
           ,'PB'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%Plastic buckle%' )
           ,'1.5 " width Tape'
           ,0.25	
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%SRITEX%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('1" width - Elastic Chlorine resistant'
           ,'ecr'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ELASTICS%' )
           ,'1" width - Elastic Chlorine resistant'
           ,0.15	
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%NATURAB%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('VELCRO - LOOP'
           ,'PB'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%VELCRO%' )
           ,'50 mm * 25 mm    (DTM)'
           ,0.03	
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%SRITEX%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('NECK TAPE'
           ,'NT'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'TAPE' )
           ,'neck tape 10mm Width 100% polyester'
           ,0.10	
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%SRITEX%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Herringbone'
           ,'H'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'TAPE' )
           ,'herringbone 1CM	0.15'
           ,0.15	
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%NATURAB%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Seam Tape'
           ,'ST'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'TAPE' )
           ,'1/4 " (5mm) width -100% Poly seam tapes'
           ,0.08	
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%NATURAB%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Knit Tape'
           ,'KT'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'TAPE' )
           ,'1" width Knit tape at neck placket'
           ,0.25	
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%SRITEX%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Rubber Button'
           ,'RB'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%BUTTONS%' )
           ,'04 holes 15 mm'
           ,0.03
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LOCAL%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('VELCRO (HOOK AND LOOP)'
           ,'V'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%VELCRO%' )
           ,'VELCRO (HOOK AND LOOP)'
           ,0.55
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%SRITEX%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('RIB (CUFF AND WB)'
           ,'RIB'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'RIB' )
           ,'RIB (CUFF AND WB) 130 CX 14 CMM'
           ,1.75
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%MTC%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('RIB FABRIC'
           ,'RIB'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%RIB FABRIC%' )
           ,NULL
           ,3.50
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%MTC%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Draw cord - Lace type Draw cord with Tip ends'
           ,'DC'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'CORD')
           ,'Draw cord - Lace type Draw cord with Tip ends'
           ,0.15
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%NATURAB%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('POCKET ZIP NYLON 03'
           ,'PZN'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ZIPS%' )
           ,'POCKET ZIP NYLON 03'
           ,0.20
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%YKK%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('2" Elastic'
           ,'2E'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ELASTICS%' )
           ,'2" Elastic'
           ,0.25
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%NATURAB%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Nil'
           ,'N'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ELASTICS%' )
           ,'Nil'
           ,0.00
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,NULL)
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Velcro'
           ,'V'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%VELCRO%' )
           ,'1" Width, Hook & Loop'
           ,0.50
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%SRITEX%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Draw Cord'
           ,'DC'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'CORD' )
           ,NULL
           ,0.00
           ,NULL
           ,NULL
           ,NULL)
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('3/4" WIDTH ELASTIC'
           ,'WE'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ELASTICS%' )
           ,'3/4" WIDTH ELASTIC'
           ,0.12
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LOCAL%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('NYLON 03 OE ZIP'
           ,'N'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ZIPS%' )
           ,'# 03 NYLON O/E ZIPPER'
           ,0.60
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%YKK%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('TOGGLES - 2HOLE PLASTIC'
           ,'T'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%TOGGELESS%' )
           ,'TOGGLES - 2HOLE PLASTIC'
           ,0.10
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%SRITEX%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('3 MM 100% POLYESTER ELASTIC'
           ,'3MM'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'CORD' )
           ,'TOGGLES - 2HOLE PLASTIC'
           ,NULL
           ,NULL
           ,NULL
           ,NULL)
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('1" Elastic'
           ,'E'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ELASTICS%' )
           ,'1'' WIDTH ELASTIC'
           ,0.12
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LOCAL%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('1.5" ELASTIC'
           ,'ET'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ELASTICS%' )
           ,'1.5" WIDTH ELASTIC'
           ,0.15
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%NATURAB%'))
GO


INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('EMBROIDERY 10X10CM	'
           ,'E10'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%EMB%' )
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL)
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('LABEL'
           ,'L'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%LABEL%' )
           ,'SUBLIMATED SATIN LABEL'
           ,0.10
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LOCAL%'))
GO


INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('TWILL TAPE FOR POCKET'
           ,'TTFP'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'TAPE' )
           ,NULL
           ,0.08
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LOCAL%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('LGT-001'
           ,'LEG'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'TAPE' )
           ,'LEG GRIPPER TAPE - 1 INCH WIDTH'
           ,0.55
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%PALM BRANCH%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('ASICS Neck Tape'
           ,'ANT'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%NECK TAPE%' )
           ,'ASICS Neck Tape'
           ,0.00
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%ASICS%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('EMB - (duplicate) "Australia" at back'
           ,'EMB'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%EMB%' )
           ,'EMB - (duplicate) "Australia" at back'
           ,1.50
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%MRC%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Draw String'
           ,'DS'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'CORD')
           ,'100% Poly 5 mm Drawstrings'
           ,0.10
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%NATURAB%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Elasticated cuffs  1 cm width after folding'
           ,'EC'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ELASTICS%' )
           ,'Elasticated cuffs  1 cm width after folding'
           ,0.12
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%NATURAB%'))
GO


INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('EMB - Asics pant 2 logos'
           ,'EMB'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%EMB%' )
           ,'EMB - Asics n Kookaburra logos'
           ,0.45
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%MRC%'))
GO


INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('NYLON 03 CEI ZIP'
           ,'NCZ'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ZIPS%' )
           ,'03 NYLON C/E INVISIBLE ZIPPER'
           ,0.40
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%YKK%'))
GO


INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('ZIP-OFF'
           ,'ZIP'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ZIPS%' )
           ,'ZIPPER FOR ZIP OFF SLEEVES O/E L/IN AND R/IN'
           ,0.60	
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%YKK%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Draw Cord (3mm) Elasticated'
           ,'DC'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%Draw cord%' )
           ,'3mm width Elasticated draw cord at bottom hem'
           ,0.10
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%SRITEX%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('1.25'' ELASTIC'
           ,'E'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ELASTICS%' )
           ,'1.25'' WIDTH ELASTIC'
           ,0.12
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LOCAL%'))
GO


INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('5mm Cord'
           ,'5C'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'CORD' )
           ,'5mm Flat Cord with Tip Ends'
           ,0.15
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LOCAL%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('1 3/4" Width Elastic'
           ,'WE'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ELASTICS%' )
           ,'1 3/4" Width Elastic'
           ,0.18
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LOCAL%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('TWILL TAPE (5mm)'
           ,'TT'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'TAPE' )
           ,'5mm Twill Tape for Shoulder'
           ,0.07
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%NATURAB%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('CH-001'
           ,'CH'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%CHAMOIS%' )
           ,'CYCLING CHAMOIS - MENS - RED BLACK'
           ,0.00
           ,'049.M.25Y.0202.E'
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LA FONTE%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('CH-002'
           ,'CH'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%CHAMOIS%' )
           ,'CYLING CHAMOIS - LADIES - PINK'
           ,0.00
           ,'012.W.02Z.0909.Z'
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LA FONTE%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('CH-004'
           ,'CH'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%CHAMOIS%' )
           ,'SAT - CHAMOIS - MENS - GREEN/BLACK'
           ,0.00
           ,'068.M.25Y.0202.A'
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LA FONTE%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('CH-005'
           ,'CH'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%CHAMOIS%' )
           ,'SAT - CHAMOIS - LADIES - PINK'
           ,0.00
           ,'072.W.314.0202.A'
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LA FONTE%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('CH-003'
           ,'CH'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%CHAMOIS%' )
           ,'TRIATHLON CHAMOIS - UNISEX'
           ,0.00
           ,'036.W.02B.0303.Z'
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LA FONTE%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Rubber Elastic 8mm'
           ,'CH'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%ELASTICS%' )
           ,'Rubber Elastic 8mm'
           ,0.05
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LOCAL%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Twill Tape - 1.5 CM'
           ,'TT'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] = 'TAPE' )
           ,'100% cotton twill tape 1.5cms width'
           ,0.05
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%YDS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%LOCAL%'))
GO

INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('EMBROIDERY 7 X 7 CM # 3040'
           ,'E'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%EMB%' )
           ,'EMBROIDERY 7 X 7 CM # 3040'
           ,0.80
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%MRC%'))
GO


INSERT INTO [Indico].[dbo].[Accessory]
           ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES
           ('Plastic Buckles 3/4"'
           ,'PB'
           ,(SELECT [ID] FROM [dbo].[AccessoryCategory] WHERE [Name] LIKE '%Plastic buck%' )
           ,'Plastic Buckles 3/4"'
           ,0.06
           ,NULL
           ,(SELECT [ID] FROM [dbo].[Unit] WHERE [Name] LIKE '%PCS%')
           ,(SELECT [ID] FROM [dbo].[Supplier] WHERE [Name] LIKE '%SRITEX%'))
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--** Update MenuItem Table --**--**--**--**--**--**--**--**--**


DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAccessories.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPatterns.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)

UPDATE [dbo].[MenuItem] SET [Name] = 'Accessories' WHERE [ID] = @MenuItem
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAccessories.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPatterns.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
UPDATE [dbo].[MenuItem] SET [Description] = 'Accessories' WHERE [ID] = @MenuItem
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAccessoryCategories.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPatterns.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)

UPDATE [dbo].[MenuItem] SET [Name] = 'Accessory Categories' WHERE [ID] = @MenuItem
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAccessoryCategories.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPatterns.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)

UPDATE [dbo].[MenuItem] SET [Description] = 'Accessory Categories' WHERE [ID] = @MenuItem
GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Update Page Table --**--**--**--**--**--**--**--**--**
DECLARE @Page AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAccessoryCategories.aspx')
UPDATE [dbo].[Page] SET [Heading] = 'Accessory Categories' WHERE [ID] = @Page
GO

DECLARE @Page AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAccessories.aspx')
UPDATE [dbo].[Page] SET [Heading] = 'Accessories' WHERE [ID] = @Page
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser Page Table for Supplier Page --**--**--**--**--**--**--**--**--**
INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/ViewSuppliers.aspx', 'Suppliers', 'Suppliers')
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser MenuItem Table for Supplier Page --**--**--**--**--**--**--**--**--**

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Position AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewSuppliers.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAgeGroups.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Position = (SELECT (MAX([Position])+1) FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES
           (@Page, 'Suppliers', 'Suppliers', 1, @Parent, @Position , 1)
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser MenuItemRole Table for Supplier Page --**--**--**--**--**--**--**--**--**
DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewSuppliers.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAgeGroups.aspx')
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

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewSuppliers.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAgeGroups.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Coordinator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewSuppliers.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAgeGroups.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indico Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO
DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewSuppliers.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAgeGroups.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser Page Table for Unit Page --**--**--**--**--**--**--**--**--**
INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/ViewUnits.aspx', 'Units', 'Units')
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser MenuItem Table for Unit Page --**--**--**--**--**--**--**--**--**

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Position AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewUnits.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAgeGroups.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Position = (SELECT (MAX([Position])+1) FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES
           (@Page, 'Units', 'Units', 1, @Parent, @Position , 1)
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser MenuItemRole Table for Supplier Page --**--**--**--**--**--**--**--**--**
DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewUnits.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAgeGroups.aspx')
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

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewUnits.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAgeGroups.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Coordinator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewUnits.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAgeGroups.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indico Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO
DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewUnits.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAgeGroups.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Insert Page Table for Factory Cost Sheet Page --**--**--**--**--**--**--**--**--**
INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/AddEditFactoryCostSheet.aspx', 'Factory Cost Sheet', 'Factory Cost Sheet')
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser MenuItem Table for Factory Cost Sheet Page --**--**--**--**--**--**--**--**--**

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Position AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditFactoryCostSheet.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPrices.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
--SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Position = (SELECT (MAX([Position])+1) FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES
           (@Page, 'Factory Cost Sheet', 'Factory Cost Sheet', 1, @Parent, @Position , 1)
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Inser MenuItemRole Table for Factory Cost Sheet Page --**--**--**--**--**--**--**--**--**
DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditFactoryCostSheet.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPrices.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditFactoryCostSheet.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPrices.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Coordinator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--** Drop Pattern Column From PatternSupportAccessory TAble --**--**--**--**--**--**--**--**--**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternSupportAccessory_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternSupportAccessory]'))
ALTER TABLE [dbo].[PatternSupportAccessory] DROP CONSTRAINT [FK_PatternSupportAccessory_Pattern]
GO

ALTER TABLE [dbo].[PatternSupportAccessory]
DROP COLUMN [Pattern]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Insert CostSheet Column From PatternSupportAccessory TAble --**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[PatternSupportAccessory]
ADD [CostSheet] [int] NOT NULL
GO

ALTER TABLE [dbo].[PatternSupportAccessory]  WITH CHECK ADD  CONSTRAINT [FK_PatternSupportAccessory_CostSheet] FOREIGN KEY([CostSheet])
REFERENCES [dbo].[CostSheet] ([ID])
GO

ALTER TABLE [dbo].[PatternSupportAccessory] CHECK CONSTRAINT [FK_PatternSupportAccessory_CostSheet]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Drop Pattern Column From PatternSupportFabric TAble --**--**--**--**--**--**--**--**--**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternSupportFabric_Pattern]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternSupportFabric]'))
ALTER TABLE [dbo].[PatternSupportFabric] DROP CONSTRAINT [FK_PatternSupportFabric_Pattern]
GO


ALTER TABLE [dbo].[PatternSupportFabric]
DROP COLUMN [Pattern]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Insert CostSheet Column From PatternSupportFabric TAble --**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[PatternSupportFabric]
ADD [CostSheet] [int] NOT NULL
GO

ALTER TABLE [dbo].[PatternSupportFabric]  WITH CHECK ADD  CONSTRAINT [FK_PatternSupportFabric_CostSheet] FOREIGN KEY([CostSheet])
REFERENCES [dbo].[CostSheet] ([ID])
GO

ALTER TABLE [dbo].[PatternSupportFabric] CHECK CONSTRAINT [FK_PatternSupportFabric_CostSheet]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** DELETE PRICE  --**--**--**--**--**--**--**--**--**


/****** Object:  StoredProcedure [dbo].[SPC_DeletePrice]    Script Date: 09/11/2013 10:57:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_DeletePrice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_DeletePrice]
GO

/****** Object:  StoredProcedure [dbo].[SPC_DeletePrice]    Script Date: 09/11/2013 10:57:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SPC_DeletePrice]
(
	@P_Price int	
)
AS 

BEGIN

	DECLARE @RetVal int
	
	BEGIN TRY

				DELETE [dbo].[DistributorPriceLevelCost] 
				  FROM [dbo].[DistributorPriceLevelCost] dplc
						 JOIN [dbo].[PriceLevelCost] plc
							ON dplc.[PriceLevelCost] = plc.[ID]
						 JOIN [dbo].[Price] p
							ON plc.[Price] = p.[ID]
				  WHERE p.[ID] = @P_Price
						
				DELETE [dbo].[LabelPriceLevelCost]
				  FROM [dbo].[LabelPriceLevelCost] lplc
						 JOIN [dbo].[PriceLevelCost] plc
							ON lplc.[PriceLevelCost] = plc.[ID]
						 JOIN [dbo].[Price] p
							ON plc.[Price] = p.[ID]
				  WHERE p.[ID] = @P_Price
						
						
				DELETE [dbo].[PriceLevelCost] 
				  FROM [dbo].[PriceLevelCost] plc
						 JOIN [dbo].[Price] p
							ON plc.[Price] = p.[ID]
				  WHERE p.[ID] = @P_Price
				  
				DELETE [dbo].[PriceRemarks] 
				  FROM [dbo].[PriceRemarks] pr
						 JOIN [dbo].[Price] p
							ON pr.[Price] = p.[ID]
				  WHERE p.[ID] = @P_Price
				  
				DELETE [dbo].[IndimanPriceRemarks] 
				  FROM [dbo].[IndimanPriceRemarks] ipr
						 JOIN [dbo].[Price] p
							ON ipr.[Price] = p.[ID]
				  WHERE p.[ID] = @P_Price
				  
				DELETE [dbo].[FactoryPriceRemarks] 
				  FROM [dbo].[FactoryPriceRemarks] fpr
						 JOIN [dbo].[Price] p
							ON fpr.[Price] = p.[ID]
				  WHERE p.[ID] = @P_Price
				  
				DELETE [dbo].[PriceHistroy] 
				  FROM [dbo].[PriceHistroy] ph
						 JOIN [dbo].[Price] p
							ON ph.[Price] = p.[ID]
				  WHERE p.[ID] = @P_Price
						
				DELETE [dbo].[Price] 
				  FROM [dbo].[Price] p			
				  WHERE p.[ID] = @P_Price
		
		SET @RetVal = 1
		
	END TRY
	BEGIN CATCH
	
		SET @RetVal = 0
		
	END CATCH
	SELECT @RetVal AS RetVal		
END




GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


