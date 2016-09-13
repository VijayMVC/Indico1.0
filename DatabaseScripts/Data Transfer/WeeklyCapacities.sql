USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySamplesOrders]    Script Date: 05/28/2012 13:16:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklySampleOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklySampleOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 05/28/2012 12:17:40 ******/
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
		ot.[ID] AS OrderTypeId,
		ot.[Name] AS OrderType,
		vl.[ID] AS VisualLayoutId,
		vl.[Name] AS VisualLayout,
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
			WHERE od.OrderType=4 
				AND  o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
--Reservation_Orders----------

USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 05/28/2012 13:19:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyReservationOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 05/28/2012 12:17:40 ******/
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
		ot.[ID] AS OrderTypeId,
		ot.[Name] AS OrderType,
		vl.[ID] AS VisualLayoutId,
		vl.[Name] AS VisualLayout,
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
				WHERE  o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate

END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
--- Firm_Orders----------

USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 05/28/2012 13:24:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyFirmOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 05/28/2012 13:00:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


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
		ot.[ID] AS OrderTypeId,
		ot.[Name] AS OrderType,
		vl.[ID] AS VisualLayoutId,
		vl.[Name] AS VisualLayout,
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
			WHERE  o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate

END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
--- Jackets Orders------

USE [Indico]
GO
/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 05/28/2012 13:29:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyJacketOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyJacketOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 05/28/2012 13:26:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


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
		ot.[ID] AS OrderTypeId,
		ot.[Name] AS OrderType,
		vl.[ID] AS VisualLayoutId,
		vl.[Name] AS VisualLayout,
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
	WHERE p.Item = 22
				AND  o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate
END 

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
--Less Five Items -------

USE [Indico]
GO
/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 05/28/2012 13:33:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyLessFiveItemOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyLessFiveItemOrders]
GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 05/28/2012 12:17:40 ******/
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
				ot.[ID] AS OrderTypeId,
				ot.[Name] AS OrderType,
				vl.[ID] AS VisualLayoutId,
				vl.[Name] AS VisualLayout,
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
				AND  o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate
END

GO
