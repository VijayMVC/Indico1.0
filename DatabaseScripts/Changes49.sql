USE [Indico]
GO

DECLARE @Status AS int
SET @Status = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'ODS Printing')

UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'ODS Printed' WHERE [ID] = @Status
GO

DECLARE @Status AS int
SET @Status = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Started Printing')

UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Printing Started' WHERE [ID] = @Status
GO

DECLARE @Status AS int
SET @Status = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Started Heat Press')

UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Heat Press Started' WHERE [ID] = @Status
GO

DECLARE @Status AS int
SET @Status = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Started Sewing')

UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Sewing Started' WHERE [ID] = @Status
GO

DECLARE @Status AS int
SET @Status = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Started Packing')

UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Packing Started' WHERE [ID] = @Status
GO

DECLARE @Status AS int
SET @Status = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Started Shipping')

UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Shipping Started' WHERE [ID] = @Status
GO

--**--**--**--**--**--**--**--** Alter Quote Table --**--**--**--**--**--**

ALTER TABLE [dbo].[Quote] 
ADD [Distributor] [int] NULL
GO

ALTER TABLE [dbo].[Quote]  WITH CHECK ADD  CONSTRAINT [FK_Quote_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO

ALTER TABLE [dbo].[Quote] CHECK CONSTRAINT [FK_Quote_Distributor]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 06/20/2013 10:22:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyLessFiveItemOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyLessFiveItemOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 06/20/2013 10:22:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_GetWeeklyLessFiveItemOrders] (		
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN
SELECT  	co.[ID] AS CompanyId,
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
			LEFT OUTER JOIN Reservation r
				ON o.[Reservation] = r.[ID]
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
END

GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 06/20/2013 10:17:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyFirmOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 06/20/2013 10:17:21 ******/
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
SELECT 		co.[ID] AS CompanyId,
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
			WHERE  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate
		
END

GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 06/20/2013 10:44:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyJacketOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyJacketOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 06/20/2013 10:44:15 ******/
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
SELECT DISTINCT  co.[ID] AS CompanyId,
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
			INNER JOIN 	dbo.[OrderDetail] od 
				ON o.ID = od.[Order]
			INNER JOIN [dbo].[Pattern] p
				ON p.[ID] = od.[Pattern]		
	WHERE  p.[Item] = (SELECT [ID] FROM [Indico].[dbo].[Item] WHERE Name = 'JACKET' AND Parent IS NULL)
		    AND  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate
				
END 

GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 06/20/2013 11:20:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklySampleOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklySampleOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 06/20/2013 11:20:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_GetWeeklySampleOrders] (	
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN

SELECT DISTINCT  co.[ID] AS CompanyId,
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
			INNER JOIN 	dbo.[OrderDetail] od 
				ON o.ID = od.[Order]
			LEFT OUTER JOIN Reservation r
				ON o.[Reservation] = r.[ID]		
			WHERE od.[OrderType] = (SELECT [ID] FROM [Indico].[dbo].[OrderType] WHERE [Name] = 'SAMPLE') 
				AND  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate				
END

GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 06/20/2013 11:21:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyReservationOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 06/20/2013 11:21:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders] (		
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN
SELECT DISTINCT  co.[ID] AS CompanyId,
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
			INNER JOIN 	dbo.[OrderDetail] od 
				ON o.ID = od.[Order]	
			INNER JOIN [Reservation] r
				ON o.[Reservation] = r.[ID]
				WHERE  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate					

END

GO


USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 06/20/2013 10:32:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ProductionCapacities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ProductionCapacities]
GO

USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 06/20/2013 10:32:09 ******/
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
		   WHERE od.OrderType = (SELECT [ID] FROM [Indico].[dbo].[OrderType] WHERE [Name] = 'SAMPLE')
				AND o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate)

	)
	
	SELECT * FROM @Capacities

END

GO









