USE[Indico]
GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-** Add New Column to the PriceChange Email List --**-**-**-**--**-**-**-**--**-**-**-**
ALTER TABLE [dbo].[PriceChangeEmailList]
ADD [IsCC] [bit] NULL
GO

UPDATE [dbo].[PriceChangeEmailList] SET [IsCC] = 0
GO

ALTER TABLE [dbo].[PriceChangeEmailList]
ALTER COLUMN [IsCC] [bit] NOT NULL
GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**UPDATE [IsActiveWS] in Pattern Table--**-**-**-**--**-**-**-**--**-**-**-**

UPDATE [dbo].[Pattern] SET [IsActiveWS] = 0
GO
--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**UPDATE Order Detail Status --**-**-**-**--**-**-**-**--**-**-**-**
DECLARE @ID AS int

SET @ID = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Start Printing')
UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Started Printing' WHERE [ID] = @ID
GO

DECLARE @ID AS int

SET @ID = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Start HeatPress')
UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Started Heat Press' WHERE [ID] = @ID
GO

DECLARE @ID AS int

SET @ID = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Start Sewing')
UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Started Sewing' WHERE [ID] = @ID
GO

DECLARE @ID AS int

SET @ID = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Start Packing')
UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Started Packing' WHERE [ID] = @ID
GO

DECLARE @ID AS int

SET @ID = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Start Shipping')
UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Started Shipping' WHERE [ID] = @ID
GO
--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 06/13/2013 11:37:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyLessFiveItemOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyLessFiveItemOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 06/13/2013 11:37:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SPC_GetWeeklyLessFiveItemOrders] (		
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN
SELECT DISTINCT od.[ID] AS OrderDetailId,
				c.[ID] AS CompanyId,
				c.[Name] AS CompanyName,
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
				u.[Company] AS UserCompany,
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
			FROM [Order] o
				JOIN OrderDetail od
					ON o.ID = od.[Order]  
				JOIN OrderDetailQty odq 
					ON od.ID = odq.OrderDetail
				LEFT OUTER JOIN Reservation r
					ON o.Reservation =r.ID 
				JOIN dbo.[OrderType] ot
					ON ot.[ID] = od.[OrderType]	
				JOIN dbo.[VisualLayout] vl
					ON vl.[ID] = od.[VisualLayout] 
				JOIN Pattern p
					ON p.ID = od.Pattern
				JOIN dbo.[FabricCode] fc
					ON fc.[ID] = vl.[FabricCode]
				JOIN Company c
					ON o.Distributor = c.ID
				JOIN [User] u
					ON c.Coordinator = u.ID
				JOIN Client cl 
					ON o.Client = cl.ID 
				JOIN OrderStatus os 
					ON o.[Status] = os.ID  
				LEFT OUTER JOIN dbo.[ShipmentMode] shm
					ON shm.[ID] = o.[ShipmentMode] 
				LEFT OUTER JOIN dbo.[Label] l
					ON l.[ID]  = od.[Label]
			WHERE o.ID IN(SELECT o.ID
							 FROM dbo.[Order] o
								  JOIN OrderDetail od 
									   ON o.ID = od.[Order] 
								  JOIN OrderDetailQty odq
									   ON od.ID = odq.OrderDetail
							GROUP BY o.ID
							HAVING SUM(odq.Qty) <= 5						
							UNION					
							SELECT o.ID	
							FROM dbo.[Order] o
								  JOIN OrderDetail od 
									   ON o.ID = od.[Order] 
								  JOIN OrderDetailQty odq
									   ON od.ID = odq.OrderDetail
								  JOIN Reservation res 
									   ON o.Reservation = res.ID
							GROUP BY o.ID
							HAVING SUM(odq.Qty) <= 5)
				AND  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate
				AND p.IsActive = 1
END
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 06/13/2013 11:42:52 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyFirmOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 06/13/2013 11:42:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/********* ALTER STORED PROCEDURE [SPC_GetWeeklyFirmOrders]*************/
CREATE PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders] (	
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN
SELECT  od.[ID] AS OrderDetailId,
		c.[ID] AS CompanyId,
		c.[Name] AS CompanyName,
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
		u.[Company] AS UserCompany,
		ot.[ID] AS OrderTypeId,
		ot.[Name] AS OrderType,
		vl.[ID] AS VisualLayoutId,
		vl.[NamePrefix] AS NamePrefix,
		vl.[NameSuffix] AS NameSuffix ,
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
	FROM [Order] o
		JOIN OrderDetail od
			ON o.ID = od.[Order]  
		JOIN dbo.[OrderType] ot
			ON ot.[ID] = od.[OrderType]	
		JOIN dbo.[VisualLayout] vl
			ON vl.[ID] = od.[VisualLayout] 
		JOIN Pattern p
			ON p.ID = od.Pattern
		JOIN dbo.[FabricCode] fc
			ON fc.[ID] = vl.[FabricCode]
		JOIN Company c
			ON o.Distributor = c.ID
		JOIN [User] u
			ON c.Coordinator = u.ID
		JOIN Client cl 
			ON o.Client = cl.ID 
		JOIN OrderStatus os 
			ON o.[Status] = os.ID  
		LEFT OUTER JOIN dbo.[ShipmentMode] shm
			ON shm.[ID] = o.[ShipmentMode] 
		LEFT OUTER JOIN dbo.[Label] l
			ON l.[ID]  = od.[Label]
			WHERE  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate
		AND p.IsActive = 1

END
GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 06/13/2013 11:44:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyJacketOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyJacketOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 06/13/2013 11:44:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/********* ALTER STORED PROCEDURE [SPC_GetWeeklyJacketOrders]*************/

CREATE PROCEDURE [dbo].[SPC_GetWeeklyJacketOrders] (	
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN
SELECT  od.[ID] AS OrderDetailId,
		c.[ID] AS CompanyId,
		c.[Name] AS CompanyName,
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
		u.[Company] AS UserCompany,
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
	FROM [Order] o
		JOIN OrderDetail od
			ON o.ID = od.[Order]  
		JOIN dbo.[OrderType] ot
			ON ot.[ID] = od.[OrderType]	
		JOIN dbo.[VisualLayout] vl
			ON vl.[ID] = od.[VisualLayout] 
		JOIN Pattern p
			ON p.ID = od.Pattern
		JOIN dbo.[FabricCode] fc
			ON fc.[ID] = vl.[FabricCode]
		JOIN Company c
			ON o.Distributor = c.ID
		JOIN [User] u
			ON c.Coordinator = u.ID
		JOIN Client cl 
			ON o.Client = cl.ID 
		JOIN OrderStatus os 
			ON o.[Status] = os.ID  
		LEFT OUTER JOIN dbo.[ShipmentMode] shm
			ON shm.[ID] = o.[ShipmentMode] 
		LEFT OUTER JOIN dbo.[Label] l
			ON l.[ID]  = od.[Label]
	WHERE p.Item = (SELECT ID FROM [Indico].[dbo].[Item] WHERE Name = 'JACKET' AND Parent IS NULL)
				AND  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate
				AND p.IsActive = 1
END 
GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 06/13/2013 11:46:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyReservationOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 06/13/2013 11:46:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders] (		
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN
SELECT  od.[ID] AS OrderDetailId,
		c.[ID] AS CompanyId,
		c.[Name] AS CompanyName,
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
		u.[Company] AS UserCompany,
		ot.[ID] AS OrderTypeId,
		ot.[Name] AS OrderType,
		vl.[ID] AS VisualLayoutId,
		vl.[NamePrefix] AS NamePreffix, 
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
	FROM [Order] o
		JOIN OrderDetail od
			ON o.ID = od.[Order] 		
		JOIN Reservation r
			ON o.Reservation =r.ID 
		JOIN dbo.[OrderType] ot
			ON ot.[ID] = od.[OrderType]	
		JOIN dbo.[VisualLayout] vl
			ON vl.[ID] = od.[VisualLayout] 
		JOIN Pattern p
			ON p.ID = od.Pattern
		JOIN dbo.[FabricCode] fc
			ON fc.[ID] = vl.[FabricCode]
		JOIN Company c
			ON o.Distributor = c.ID
		JOIN [User] u
			ON c.Coordinator = u.ID
		JOIN Client cl 
			ON o.Client = cl.ID 
		JOIN OrderStatus os 
			ON o.[Status] = os.ID  
		LEFT OUTER JOIN dbo.[ShipmentMode] shm
			ON shm.[ID] = o.[ShipmentMode] 
		LEFT OUTER JOIN dbo.[Label] l
			ON l.[ID]  = od.[Label]
				WHERE  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate
					AND p.IsActive = 1

END
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 06/13/2013 11:47:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklySampleOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklySampleOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 06/13/2013 11:47:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SPC_GetWeeklySampleOrders] (	
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN

SELECT  od.[ID] AS OrderDetailId,
		c.[ID] AS CompanyId,
		c.[Name] AS CompanyName,
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
		u.[Company] AS UserCompany,
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
	FROM [Order] o
		JOIN OrderDetail od
			ON o.ID = od.[Order] 		
		LEFT OUTER JOIN Reservation r
			ON o.Reservation =r.ID 
		JOIN dbo.[OrderType] ot
			ON ot.[ID] = od.[OrderType]	
		JOIN dbo.[VisualLayout] vl
			ON vl.[ID] = od.[VisualLayout] 
		JOIN Pattern p
			ON p.ID = od.Pattern
		JOIN dbo.[FabricCode] fc
			ON fc.[ID] = vl.[FabricCode]
		JOIN Company c
			ON o.Distributor = c.ID
		JOIN [User] u
			ON c.Coordinator = u.ID
		JOIN Client cl 
			ON o.Client = cl.ID 
		JOIN OrderStatus os 
			ON o.[Status] = os.ID  
		LEFT OUTER JOIN dbo.[ShipmentMode] shm
			ON shm.[ID] = o.[ShipmentMode] 
		LEFT OUTER JOIN dbo.[Label] l
			ON l.[ID]  = od.[Label]
			WHERE od.OrderType = (SELECT [ID] FROM [Indico].[dbo].[OrderType] WHERE [Name] = 'SAMPLE') 
				AND  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate
				AND p.IsActive = 1
END
GO

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 06/13/2013 12:00:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ProductionCapacities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ProductionCapacities]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 06/13/2013 12:00:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SPC_ProductionCapacities] (	
	
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN

	DECLARE @Capacities TABLE
	(
		Firms int,
		ResevationOrders int,
		Resevations int,
		Holds int,
		Less5Items int,
		Jackets int,
		Samples int
	)
	
	INSERT INTO @Capacities
	VALUES
	(
		-- Firm Orders
		(	SELECT  ISNULL(SUM(odq.Qty),0) AS Firms  
			FROM [Order] o
				JOIN OrderDetail od
					ON o.ID = od.[Order]  
				JOIN OrderDetailQty odq 
					ON od.ID = odq.OrderDetail 
						WHERE o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate),
		-- Resevation order quantities
		(	SELECT ISNULL(SUM(odq.Qty),0) AS ResevationOrders
			FROM [Order] o
				JOIN OrderDetail od
					ON o.ID = od.[Order]  
				JOIN OrderDetailQty odq 
					ON od.ID = odq.OrderDetail
				JOIN Reservation r
					ON o.Reservation = r.ID 
			WHERE o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate),
		-- Resevation quantities
		(	SELECT ISNULL(SUM(r.Qty), 0) AS Resevations 
			FROM [Order] o
				JOIN Reservation r
					ON o.Reservation = r.ID 
			WHERE o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate),
		-- Hold
		0,
		-- Less5Items
		(SELECT ISNULL(COUNT(o.ID),0) AS Less5Items 
		FROM dbo.[Order] o
		WHERE o.ID IN (	 SELECT o.ID	
						 FROM dbo.[Order] o
							  JOIN OrderDetail od 
								   ON o.ID = od.[Order] 
							  JOIN OrderDetailQty odq
								   ON od.ID = odq.OrderDetail
						GROUP BY o.ID
						HAVING SUM(odq.Qty) <= 5
						UNION
						SELECT o.ID	
						FROM dbo.[Order] o
							  JOIN OrderDetail od 
								   ON o.ID = od.[Order] 
							  JOIN OrderDetailQty odq
								   ON od.ID = odq.OrderDetail
							  JOIN Reservation res 
								   ON o.Reservation = res.ID
						GROUP BY o.ID
						HAVING SUM(odq.Qty) <= 5)AND o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) 
												AND o.DesiredDeliveryDate <= @P_WeekEndDate),

		-- JacketsOrders
		(	SELECT  ISNULL(COUNT(o.ID), 0) AS Jackets  
			FROM [Order] o
				JOIN OrderDetail od
					ON o.ID = od.[Order]  
				JOIN Pattern p
					ON p.ID = od.Pattern
				JOIN Item i
					ON i.ID = p.Item
			WHERE i.Name IN('PANT','JACKET','WINDCHEATER')AND i.Parent IS NULL
				AND  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate
				AND p.IsActive = 1),
				
		-- SampleOrders
		(  SELECT ISNULL(COUNT(*), 0) AS Samples 
	       FROM dbo.[Order] o
                JOIN OrderDetail od
					ON o.ID =od.[Order]
				LEFT OUTER JOIN  Reservation res
					ON o.Reservation=res.ID
		   WHERE od.OrderType = 4 
				AND o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate)

	)
	
	SELECT * FROM @Capacities

END
GO


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_QuoteChangeEmailList_User]') AND parent_object_id = OBJECT_ID(N'[dbo].[QuoteChangeEmailList]'))
ALTER TABLE [dbo].[QuoteChangeEmailList] DROP CONSTRAINT [FK_QuoteChangeEmailList_User]
GO

/****** Object:  Table [dbo].[PriceChangeEmailList]    Script Date: 06/13/2013 16:44:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[QuoteChangeEmailList]') AND type in (N'U'))
DROP TABLE [dbo].[QuoteChangeEmailList]
GO

/****** Object:  Table [dbo].[PriceChangeEmailList]    Script Date: 06/13/2013 16:44:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[QuoteChangeEmailList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[User] [int] NULL,
	[IsCC] bit NOT NULL,
 CONSTRAINT [PK_QuoteChangeEmailList] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[QuoteChangeEmailList]  WITH CHECK ADD  CONSTRAINT [FK_QuoteChangeEmailList_User] FOREIGN KEY([User])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[QuoteChangeEmailList] CHECK CONSTRAINT [FK_QuoteChangeEmailList_User]
GO

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 06/14/2013 10:05:57 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetailsView]'))
DROP VIEW [dbo].[OrderDetailsView]
GO

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 06/14/2013 10:05:57 ******/
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


GO


INSERT INTO [dbo].[Page]
           ([Name]
           ,[Title]
           ,[Heading])
     VALUES
           ('/Dashboard.aspx'
           ,'Dash Board'
           ,'Dash Board')
GO


DECLARE @PAGE AS int
SET @PAGE = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/Dashboard.aspx')

INSERT INTO [dbo].[MenuItem]
           ([Page]
           ,[Name]
           ,[Description]
           ,[IsActive]
           ,[Parent]
           ,[Position]
           ,[IsVisible])
     VALUES
           (@PAGE
           ,'Dash Board'
           ,'Dash Board'
           ,1
           ,NULL
           ,1
           ,1)
GO

DECLARE @PAGE AS int
DECLARE @MENUITEM AS int
DECLARE @ROLE AS int

SET @PAGE = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/Dashboard.aspx')
SET @MENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @PAGE AND [Parent] IS NULL)
SET @ROLE = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Distributor Administrator')

INSERT INTO [dbo].[MenuItemRole]
           ([MenuItem]
           ,[Role])
     VALUES
           (@MENUITEM
           ,@ROLE)
GO

DECLARE @PAGE AS int
DECLARE @MENUITEM AS int
DECLARE @ROLE AS int

SET @PAGE = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/Dashboard.aspx')
SET @MENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @PAGE AND [Parent] IS NULL)
SET @ROLE = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Distributor Coordinator')

INSERT INTO [dbo].[MenuItemRole]
           ([MenuItem]
           ,[Role])
     VALUES
           (@MENUITEM
           ,@ROLE)
GO










