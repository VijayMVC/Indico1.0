USE [Indico]
GO



/****** DROP ORDER *******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Client]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Client]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Creator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Creator]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_DeliveryMethod]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_DeliveryMethod]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_DestinationPort]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_DestinationPort]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Distributor]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Distributor]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Invoice]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Invoice]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Modifier]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_OrderStatus]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_OrderStatus]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_PaymentMethod]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_PaymentMethod]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Printer]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Printer]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Reservation]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Reservation]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_ShipmentMode]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_ShipmentMode]
GO

-- Delete Order dependencies

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OrderDetail_Order]') AND parent_object_id = OBJECT_ID(N'[dbo].[OrderDetail]'))
ALTER TABLE [dbo].[OrderDetail] DROP CONSTRAINT [FK_OrderDetail_Order]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_InvoiceOrder_Order]') AND parent_object_id = OBJECT_ID(N'[dbo].[InvoiceOrder]'))
ALTER TABLE [dbo].[InvoiceOrder] DROP CONSTRAINT [FK_InvoiceOrder_Order]
GO

/****** Object:  Table [dbo].[Order]    Script Date: 01/22/2013 14:40:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Order]') AND type in (N'U'))
DROP TABLE [dbo].[Order]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--*

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DistributorAddress_Country]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorClientAddress]'))
ALTER TABLE [dbo].[DistributorClientAddress] DROP CONSTRAINT [FK_DistributorAddress_Country]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DistributorAddressr_Country]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorClientAddress]'))
ALTER TABLE [dbo].[DistributorClientAddress] DROP CONSTRAINT [FK_DistributorAddressr_Country]
GO

/****** Object:  Table [dbo].[DistributorClientAddress]    Script Date: 01/23/2013 17:50:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistributorClientAddress]') AND type in (N'U'))
DROP TABLE [dbo].[DistributorClientAddress]
GO



/****** Object:  Table [dbo].[DistributorClientAddress]    Script Date: 01/22/2013 17:26:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DistributorClientAddress](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Distributor] [int] NOT NULL,
	[Address] [nvarchar](255) NOT NULL,
	[Suburb] [nvarchar](255) NOT NULL,
	[PostCode] [nvarchar](255) NOT NULL,
	[Country] [int] NOT NULL,
	[ContactName] [nvarchar](255) NOT NULL,
	[ContactPhone] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_DistributorClientAddress] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[DistributorClientAddress]  WITH CHECK ADD  CONSTRAINT [FK_DistributorAddress_Country] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO

ALTER TABLE [dbo].[DistributorClientAddress] CHECK CONSTRAINT [FK_DistributorAddress_Country]
GO

ALTER TABLE [dbo].[DistributorClientAddress]  WITH CHECK ADD  CONSTRAINT [FK_DistributorAddressr_Country] FOREIGN KEY([Country])
REFERENCES [dbo].[Country] ([ID])
GO

ALTER TABLE [dbo].[DistributorClientAddress] CHECK CONSTRAINT [FK_DistributorAddressr_Country]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  Table [dbo].[Order]    Script Date: 01/22/2013 14:41:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Order](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderNumber] [nvarchar](64) NULL,
	[Date] [datetime2](7) NOT NULL,
	[DesiredDeliveryDate] [datetime2](7) NULL,
	[Client] [int] NOT NULL,
	[Distributor] [int] NOT NULL,
	[OrderSubmittedDate] [datetime2](7) NOT NULL,
	[EstimatedCompletionDate] [datetime2](7) NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,		
	[ShipmentDate] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
	[Creator] [int] NOT NULL,
	[Modifier] [int] NOT NULL,
	[PaymentMethod] [int] NULL,
	[OrderUsage] [nvarchar](255) NULL,	
	[PurchaseOrderNo] [int] NULL,	
	[Converted] [bit] NULL,
	[OldPONo] [nvarchar](255) NULL,
	[PhotoApprovalReq] [bit] NULL,
	[Invoice] [int] NULL,
	[Printer] [int] NULL,
	[IsTemporary] [bit] NOT NULL,	
	[IsRepeat] [bit] NOT NULL,
	[ShipmentMode] [int] NULL,
	[ShipTo] [int] NULL,
	[DespatchTo] [int] NULL,
	[ShipToExistingClient] [int] NULL,
	[DespatchToExistingClient] [int] NULL,
	[IsWeeklyShipment] [bit] NULL,
	[IsCourierDelivery] [bit] NULL,
	[IsAdelaiseWareHouse] [bit] NULL,
	[IsMentionAddress] [bit] NULL,
	[IsFollowingAddress] [bit] NULL,
	[Reservation] [int] NULL,
	[IsShipToDistributor] [bit] NULL,
	[IsShipExistingDistributor] [bit] NULL,
	[IsShipNewClient] [bit] NULL,
	[IsDespatchDistributor] [bit] NULL,
	[IsDespatchExistingDistributor] [bit] NULL,
	[IsDespatchNewClient] [bit] NULL
 CONSTRAINT [PK_Order] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_Client] FOREIGN KEY([Client])
REFERENCES [dbo].[Client] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Client]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Creator]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Distributor]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_Invoice] FOREIGN KEY([Invoice])
REFERENCES [dbo].[Invoice] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Invoice]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Modifier]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_OrderStatus] FOREIGN KEY([Status])
REFERENCES [dbo].[OrderStatus] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_OrderStatus]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_PaymentMethod] FOREIGN KEY([PaymentMethod])
REFERENCES [dbo].[PaymentMethod] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_PaymentMethod]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_Printer] FOREIGN KEY([Printer])
REFERENCES [dbo].[Printer] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Printer]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_Reservation] FOREIGN KEY([Reservation])
REFERENCES [dbo].[Reservation] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Reservation]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_ShipTo] FOREIGN KEY([ShipTo])
REFERENCES [dbo].[Company] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_ShipTo]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_DespatchTo] FOREIGN KEY([DespatchTo])
REFERENCES [dbo].[Company] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_DespatchTo]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_ShipToExistingClient] FOREIGN KEY([ShipToExistingClient])
REFERENCES [dbo].[DistributorClientAddress] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_ShipToExistingClient]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_DespatchToExistingClient] FOREIGN KEY([DespatchToExistingClient])
REFERENCES [dbo].[DistributorClientAddress] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_DespatchToExistingClient]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_ShipmentMode] FOREIGN KEY([ShipmentMode])
REFERENCES [dbo].[ShipmentMode] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_ShipmentMode]
GO

ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetail_Order] FOREIGN KEY([Order])
REFERENCES [dbo].[Order] ([ID])
GO

ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_Order]
GO

ALTER TABLE [dbo].[InvoiceOrder]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceOrder_Order] FOREIGN KEY([Order])
REFERENCES [dbo].[Order] ([ID])
GO

ALTER TABLE [dbo].[InvoiceOrder] CHECK CONSTRAINT [FK_InvoiceOrder_Order]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 01/23/2013 14:41:05 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetailsView]'))
DROP VIEW [dbo].[OrderDetailsView]
GO

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 01/23/2013 09:22:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OrderDetailsView]
AS
	SELECT --DISTINCT TOP 100 PERCENT
			od.[ID] AS OrderDetailId,
			co.[ID] AS CompanyId,
			co.[Name] AS CompanyName,
			o.[ID] AS OrderId,
			o.[Date],
			o.[CreatedDate] AS OrderCreatedDate,
			o.[DesiredDeliveryDate],
			o.[EstimatedCompletionDate],
			o.[OrderSubmittedDate],
			o.[ModifiedDate] AS OrderModifiedDate,
			o.[ShipmentDate] AS OrderShipmentDate,
			o.[IsTemporary],
			o.[OrderNumber],
			o.[PurchaseOrderNo],
			o.[OldPONo] AS OldPurchaseOrderNo,			
			o.[Reservation] AS ReservationId,			
			cl.[ID] AS ClientId,
			cl.[Name] AS ClientName,
			u.[ID] AS UserId,
			u.[Username] AS Username,
			u.[GivenName] AS UserGivenName,
			u.[FamilyName] AS UserFamilyName,
			ot.[ID] AS OrderTypeId,
			ot.[Name] AS OrderType,
			vl.[ID] AS VisualLayoutId,
			vl.[NamePrefix] AS NamePrefix,
			vl.[NameSuffix] AS NameSuffix,
			p.[ID] AS PatternId,
			p.[Number] AS PatternNumber,
			fc.[ID] AS FabricId,
			fc.[Name] AS Fabric,
			fc.[NickName] AS FabricNickName,
			os.[ID] AS [StatusId],
			os.[Name] AS [Status],
			l.[ID] AS LabelID,
			l.[Name] AS LabelName,
			l.[LabelImagePath]
		FROM dbo.[Order] o
			INNER JOIN dbo.[OrderStatus] os
				ON  os.[ID] = o.[Status]
			INNER JOIN dbo.[OrderDetail] od
				ON o.[ID] = od.[Order] 
			INNER JOIN dbo.[OrderType] ot
				ON ot.[ID] = od.[OrderType]
			INNER JOIN dbo.[VisualLayout] vl
				ON vl.[ID] = od.[VisualLayout]
			INNER JOIN dbo.[Pattern] p
				ON p.[ID] = vl.[Pattern]
			INNER JOIN dbo.[FabricCode] fc
				ON fc.[ID] = vl.[FabricCode]
			INNER JOIN dbo.[Company] co
				ON co.[ID] = o.[Distributor]
			INNER JOIN dbo.[Client] cl
				ON cl.[ID] = o.[Client]
			INNER JOIN dbo.[User] u
				ON u.[ID] = o.[Creator]			
			LEFT OUTER JOIN dbo.[Label] l
				ON l.[ID]  = od.[Label]


GO

