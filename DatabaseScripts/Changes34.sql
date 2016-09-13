USE[Indico]
GO

UPDATE OrderDetailStatus SET [Name] = 'ODS Printing', [Description] = 'Factory ODS Printing' WHERE Name = 'Submitted' ; 
GO

ALTER TABLE OrderDetailStatus 
	ADD [Priority] int NULL
GO

UPDATE OrderDetailStatus SET [Priority] = 1 WHERE ID = 1
UPDATE OrderDetailStatus SET [Priority] = 2 WHERE ID = 2
UPDATE OrderDetailStatus SET [Priority] = 3 WHERE ID = 3
UPDATE OrderDetailStatus SET [Priority] = 4 WHERE ID = 4
UPDATE OrderDetailStatus SET [Priority] = 5 WHERE ID = 5
UPDATE OrderDetailStatus SET [Priority] = 6 WHERE ID = 6
UPDATE OrderDetailStatus SET [Priority] = 7 WHERE ID = 7
GO

ALTER TABLE OrderDetailStatus 
	ALTER COLUMN [Priority] int NOT NULL
GO

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 03/15/2013 11:29:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 03/15/2013 14:59:56 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetailsView]'))
DROP VIEW [dbo].[OrderDetailsView]
GO

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 03/15/2013 14:59:56 ******/
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

GO

--**-**--**--**-**--**--**-**--**--**-**--** Changes MenuItem Role --**-**--**--**-**--**--**-**--**--**-**--**--**-**--**
DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @Role AS int
DECLARE @NewPage AS int
DECLARE @NewMenuItem AS int
DECLARE @Parent AS int
 

SET @Page = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/ViewClientOrders.aspx')
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Distributor Administrator')
SET @NewPage = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @NewMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @NewPage AND [Parent] IS NULL)

UPDATE [dbo].[MenuItemRole] SET [MenuItem] = @NewMenuItem WHERE [MenuItem] = @MenuItem AND [Role] = @Role
GO
--**-**--**--**-**--**--**-**--**--**-**--** Changes MenuItem Role --**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @Role AS int
DECLARE @NewPage AS int
DECLARE @NewMenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/ViewClientOrders.aspx')
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Distributor Coordinator')
SET @NewPage = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @NewMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @NewPage AND [Parent] IS NULL)

UPDATE [dbo].[MenuItemRole] SET [MenuItem] = @NewMenuItem WHERE [MenuItem] = @MenuItem AND [Role] = @Role
GO
--**-**--**--**-**--**--**-**--**--**-**--** Changes MenuItem Role --**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @Role AS int
DECLARE @NewPage AS int
DECLARE @NewMenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/ViewClientOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Distributor Administrator')
SET @NewPage = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @NewPage AND [Parent] IS NULL)
SET @NewMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @NewPage AND [Parent] = @Parent)

UPDATE [dbo].[MenuItemRole] SET [MenuItem] = @NewMenuItem WHERE [MenuItem] = @MenuItem AND [Role] = @Role
GO

--**-**--**--**-**--**--**-**--**--**-**--** Changes MenuItem Role --**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @Role AS int
DECLARE @NewPage AS int
DECLARE @NewMenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/ViewClientOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Distributor Coordinator')
SET @NewPage = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @NewPage AND [Parent] IS NULL)
SET @NewMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @NewPage AND [Parent] = @Parent)

UPDATE [dbo].[MenuItemRole] SET [MenuItem] = @NewMenuItem WHERE [MenuItem] = @MenuItem AND [Role] = @Role
GO

--**-**--**--**-**--**--**-**--**--**-**--** Changes MenuItem Role --**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @Role AS int
DECLARE @NewPage AS int
DECLARE @NewMenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/ViewClientOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Page = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/AddEditClientOrder.aspx')
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Distributor Administrator')
SET @NewPage = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @NewPage AND [Parent] IS NULL)
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @NewPage AND [Parent] = @Parent)
SET @NewPage = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/AddEditOrder.aspx')
SET @NewMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @NewPage AND [Parent] = @Parent)

UPDATE [dbo].[MenuItemRole] SET [MenuItem] = @NewMenuItem WHERE [MenuItem] = @MenuItem AND [Role] = @Role
GO

--**-**--**--**-**--**--**-**--**--**-**--** Changes MenuItem Role --**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @Role AS int
DECLARE @NewPage AS int
DECLARE @NewMenuItem AS int
DECLARE @Parent AS int

SET @Page = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/ViewClientOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Page = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/AddEditClientOrder.aspx')
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Distributor Coordinator')
SET @NewPage = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @NewPage AND [Parent] IS NULL)
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @NewPage AND [Parent] = @Parent)
SET @NewPage = (SELECT [ID] from [dbo].[Page] WHERE [Name] = '/AddEditOrder.aspx')
SET @NewMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @NewPage AND [Parent] = @Parent)

UPDATE [dbo].[MenuItemRole] SET [MenuItem] = @NewMenuItem WHERE [MenuItem] = @MenuItem AND [Role] = @Role
GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

