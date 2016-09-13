USE [Indico]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].PrinterType
ADD [Prefix] nvarchar (5) NULL 
GO

ALTER TABLE [dbo].PrinterType
DROP COLUMN [Description]
GO

INSERT INTO [Indico].[dbo].[PrinterType]([Name], [Prefix])
     VALUES('DYO', 'DY-')
GO

UPDATE [dbo].PrinterType
	SET Prefix = 'CS-'
FROM [dbo].PrinterType
WHERE Name = 'DYED'
GO

UPDATE [dbo].PrinterType
	SET Prefix = 'VL-'
FROM [dbo].PrinterType
WHERE Name = 'SUBLIMATED'
GO	

-- Update Page table
UPDATE [dbo].Page SET Title = 'Print Types' FROM [dbo] .Page WHERE Title = 'Printer Types' AND ID = 40
UPDATE [dbo].Page SET Heading = 'Print Types' FROM [dbo] .Page WHERE Heading = 'Printer Types' AND ID = 40
GO

-- Update Menu Item
UPDATE  [dbo].MenuItem SET Name = 'Print Types' FROM [dbo].MenuItem WHERE Name = 'Printer Types' AND ID = 50
UPDATE [dbo].MenuItem SET [Description] = 'Print Types' FROM [dbo].MenuItem WHERE [Description] = 'Printer Types' AND ID = 50
GO

-- Change the Column name to NamePrefix in Visual layout table
EXEC sp_rename 'VisualLayout.Name', 'NamePrefix', 'column'
GO

ALTER TABLE [dbo].VisualLayout
ADD [NameSuffix] int NULL 
GO

ALTER TABLE [dbo].VisualLayout
ADD [CreatedDate] [datetime2](7) NULL 
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  Table [dbo].[AcquiredVisulaLayoutName]    Script Date: 09/06/2012 21:39:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AcquiredVisulaLayoutName](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL 
 CONSTRAINT [PK_AcquiredVisulaLayoutName] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AcquiredVisulaLayoutName', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the acquired visual layout name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AcquiredVisulaLayoutName', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The record created date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AcquiredVisulaLayoutName', @level2type=N'COLUMN',@level2name=N'CreatedDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AcquiredVisulaLayoutName'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 09/06/2012 15:28:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[OrderDetailsView]
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
			o.[ShipTo] ShipToClientAddress,
			o.[Reservation] AS ReservationId,
			shm.[ID] AS OrderShipmentModeId,
			shm.[Name] AS OrderShipmentMode,
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
			LEFT OUTER JOIN dbo.[ShipmentMode] shm
				ON shm.[ID] = o.[ShipmentMode] 
			LEFT OUTER JOIN dbo.[Label] l
				ON l.[ID]  = od.[Label]

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  View [dbo].[LastRecordOfVisullayoutPrefixVL]    Script Date: 09/06/2012 21:51:26 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[LastRecordOfVisullayoutPrefixVL]'))
DROP VIEW [dbo].[LastRecordOfVisullayoutPrefixVL]
GO

CREATE VIEW LastRecordOfVisullayoutPrefixVL
 AS
	SELECT TOP 1 [ID]
			,[NamePrefix]
			,[NameSuffix]
	  FROM [Indico].[dbo].[VisualLayout]
	  WHERE NamePrefix = 'VL-' AND NameSuffix IS NOT NULL
	  ORDER BY [CreatedDate] DESC
GO

/****** Object:  View [dbo].[LastRecordOfVisullayoutPrefixDY]    Script Date: 09/06/2012 21:51:09 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[LastRecordOfVisullayoutPrefixDY]'))
DROP VIEW [dbo].[LastRecordOfVisullayoutPrefixDY]
GO

CREATE VIEW LastRecordOfVisullayoutPrefixDY
 AS
	  SELECT TOP 1 [ID] 
			,[NamePrefix]
			,[NameSuffix]
	  FROM [Indico].[dbo].[VisualLayout]
	  WHERE NamePrefix = 'DY-' AND NameSuffix IS NOT NULL
	  ORDER BY [CreatedDate] DESC
GO

/****** Object:  View [dbo].[LastRecordOfVisullayoutPrefixCS]    Script Date: 09/06/2012 21:50:54 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[LastRecordOfVisullayoutPrefixCS]'))
DROP VIEW [dbo].[LastRecordOfVisullayoutPrefixCS]
GO

CREATE VIEW LastRecordOfVisullayoutPrefixCS
AS
	SELECT TOP 1 [ID]
			,[NamePrefix]
			,[NameSuffix]
	  FROM [Indico].[dbo].[VisualLayout]
	  WHERE NamePrefix = 'CS-' AND NameSuffix IS NOT NULL
	  ORDER BY [CreatedDate] DESC
GO

--- Change Price List to "Download to Excel"------

UPDATE [dbo].MenuItem SET Name = 'Download to Excel' WHERE ID = 70 AND Page = 58
GO
UPDATE [dbo].MenuItem SET [Description] = 'Download to Excel' WHERE ID = 70 AND Page = 58
GO

UPDATE [dbo].Pattern SET NickName = 'POLO SHIRT UNISEX ADULT STAND UP SHORT SLEEVE SET IN' WHERE Number = '052' AND ID = 290
GO
UPDATE [dbo].Pattern SET NickName = 'RUGBY JERSEY MENS YOUTH' WHERE Number = '010' AND ID = 292
GO
UPDATE [dbo].Pattern SET NickName = 'MENS YOUTH' WHERE Number = '1235' AND ID = 25
GO
  