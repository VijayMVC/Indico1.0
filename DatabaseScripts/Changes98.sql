USE [Indico]
GO

DELETE FROm [dbo].[Reservation]
GO

ALTER TABLE [dbo].[Reservation]
DROP COLUMN [IsRepeat] 
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Reservation_Client]') AND parent_object_id = OBJECT_ID(N'[dbo].[Reservation]'))
ALTER TABLE [dbo].[Reservation] DROP CONSTRAINT [FK_Reservation_Client]
GO

ALTER TABLE [dbo].[Reservation]
ALTER COLUMN [Client] nvarchar(255) NULL
GO

ALTER TABLE [dbo].[Reservation]
ALTER COLUMN [ShipTo] [int] NULL
GO


ALTER TABLE [dbo].[Reservation] WITH CHECK ADD CONSTRAINT [FK_Reservation_ShipTo] FOREIGN KEY ([ShipTo])
REFERENCES [dbo].[DistributorClientAddress] ([ID])
Go

ALTER TABLE [dbo].[Reservation] CHECK CONSTRAINT [FK_Reservation_ShipTo]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Reservation_DestinationPort]') AND parent_object_id = OBJECT_ID(N'[dbo].[Reservation]'))
ALTER TABLE [dbo].[Reservation] DROP CONSTRAINT [FK_Reservation_DestinationPort]
GO

ALTER TABLE [dbo].[Reservation]
DROP COLUMN [DestinationPort]
GO



/****** Object:  View [dbo].[ReservationDetailsView]    Script Date: 05/21/2014 10:21:51 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReservationDetailsView]'))
DROP VIEW [dbo].[ReservationDetailsView]
GO

USE [Indico]
GO

/****** Object:  View [dbo].[ReservationDetailsView]    Script Date: 05/21/2014 10:21:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[ReservationDetailsView]
AS

SELECT r.[ID]
      ,RIGHT(CAST('RES-0000' + CAST(r.[ReservationNo] AS VARCHAR) AS VARCHAR), 10) AS ReservationNo     
      ,r.[OrderDate] AS OrderDate
      ,ISNULL(r.[Pattern], 0) AS PatternID
      ,ISNULL(p.[Number] + ' - ' + p.[NickName], '') AS Pattern
      ,r.[Coordinator] AS CoordinatorID
      ,cu.[GivenName] + ' ' + cu.[FamilyName] AS Coordinator
      ,r.[Distributor] AS DistributorID
      ,d.[Name] AS Distributor      
      ,ISNULL(r.[Client], '') AS Client
      ,ISNULL(r.[ShipTo], 0) AS ShipToID
      ,ISNULL(dca.[Address] + ' ' + dca.[Suburb] + ' ' + ISNULL(dca.[State], '') + ' ' + c.[ShortName] + ' ' + dca.[PostCode], '') AS ShipTo   
      ,ISNULL(r.[ShipmentMode], 0) AS ShipmentModeID
      ,ISNULL(sm.[Name], '') AS ShipmentMode
      ,r.[ShipmentDate] AS ShipmentDate
      ,r.[Qty] AS Qty
      ,(SELECT ISNULL(SUM(odq.Qty),0)
			FROM [OrderDetail] od				
				JOIN OrderDetailQty odq 
					ON od.ID = odq.OrderDetail
				JOIN Reservation r
					ON od.Reservation = r.ID )	 AS UsedQty		
	  ,(SELECT r.[Qty] - (SELECT ISNULL(SUM(odq.Qty),0)
			FROM [OrderDetail] od				
				JOIN OrderDetailQty odq 
					ON od.ID = odq.OrderDetail
				JOIN Reservation r
					ON od.Reservation = r.ID )) AS Balance
      ,ISNULL(r.[Notes], '') AS Notes
      ,r.[DateCreated] AS DateCreated
      ,r.[DateModified] AS DateModified
      ,r.[Creator] AS CreatorID
      ,rc.[GivenName] + ' ' + rc.[FamilyName] AS Creator
      ,r.[Modifier] AS ModifierID
      ,rm.[GivenName] + ' ' + rm.[FamilyName] AS Modifier
      ,r.[Status] AS StatusID
      ,rs.[Name] AS [Status]
  FROM [Indico].[dbo].[Reservation] r
	LEFT OUTER JOIN [dbo].[Pattern] p
		ON r.[Pattern] = p.[ID]
	JOIN [dbo].[User] cu
		ON r.[Coordinator] = cu.[ID]
	JOIN [dbo].[Company] d
		ON r.[Distributor] = d.[ID]	
	LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
		ON r.[ShipTo] = dca.[ID]
	JOIN [dbo].[Country] c
		ON dca.[Country] = c.[ID] 		
	LEFT OUTER JOIN [dbo].[ShipmentMode] sm
		ON r.[ShipmentMode] = sm.[ID]	
	JOIN [dbo].[User] rc
		ON r.[Creator] = rc.[ID]
	JOIN [dbo].[User] rm
		ON r.[Modifier] = rm.[ID]
	JOIN [dbo].[ReservationStatus] rs
		ON r.[Status] = rs.[ID]


GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
 
INSERT INTO [dbo].[ReservationStatus] ([Name], [Description]) VALUES ('New', 'New Reservation')
GO
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 05/21/2014 17:16:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ProductionCapacities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ProductionCapacities]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 05/21/2014 17:16:41 ******/
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
						WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
						AND (o.[Reservation] IS NULL)
						AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold')))),
		-- Resevation order quantities
		(	SELECT ISNULL(SUM(odq.Qty),0) AS ResevationOrders
			FROM [OrderDetail] od				
				JOIN OrderDetailQty odq 
					ON od.ID = odq.OrderDetail
				JOIN Reservation r
					ON od.Reservation = r.ID 
			WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
			AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold')))),
		-- Resevation quantities
		(	SELECT DISTINCT ISNULL(SUM(r.Qty), 0) AS Resevations 
			FROM [Order] o
				JOIN [OrderDetail] od
					on o.[ID] = od.[Order]
				JOIN Reservation r
					ON o.Reservation = r.ID 
			WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
			AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold')))),
		-- Hold
		(	SELECT ISNULL(SUM(odq.[Qty]), 0) AS Hold
			 FROM [dbo].[OrderDetailQty] odq 
				JOIN [dbo].[OrderDetail] od
					ON	odq.[OrderDetail] = od.[ID]
				JOIN [dbo].[Order] o
					ON od.[Order] = o.[ID]
			 WHERE ((o.[Status] = (SELECT os.[ID] FROM [dbo].[OrderStatus] os WHERE os.[Name] = 'Indiman Hold')) OR
					((o.[Status] = (SELECT os.[ID] FROM [dbo].[OrderStatus] os WHERE os.[Name] = 'Indico Hold')))) AND
				   (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate) AND
				   (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold')))),
		-- Less5Items
		(SELECT ISNULL(SUM(odq.[Qty]), 0)  AS Less5Items				 
										FROM dbo.[Order] o
											JOIN [OrderDetail] od
												ON o.[ID] = od.[Order]
											JOIN [OrderDetailQty] odq
												ON od.[ID] = odq.[OrderDetail]
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
														HAVING SUM(odq.Qty) <= 5)AND (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
														AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold')))),

		-- JacketsOrders
		(SELECT ISNULL(SUM(odq.[Qty]), 0) AS Jackets 				  
										FROM [Order] o
											JOIN OrderDetail od
												ON o.ID = od.[Order]
											JOIN [OrderDetailQty] odq
												ON od.[ID] = odq.[OrderDetail]
											JOIN Pattern p
												ON p.ID = od.Pattern
											JOIN Item i
												ON i.ID = p.Item
										WHERE i.Name IN('JACKET')AND i.Parent IS NULL
											AND  (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
											AND  (p.IsActive = 1)
											AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold')))),
						
		-- SampleOrders
		(SELECT ISNULL(SUM(odq.[Qty]), 0) AS Samples											 
							   FROM dbo.[Order] o
									JOIN OrderDetail od
										ON o.ID =od.[Order]
									JOIN [OrderDetailQty] odq
										ON od.[ID] = odq.[OrderDetail]
									LEFT OUTER JOIN  Reservation res
										ON o.Reservation=res.ID
							   WHERE od.OrderType = (SELECT [ID] FROM [Indico].[dbo].[OrderType] WHERE [Name] = 'SAMPLE')
									AND (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
									AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold'))))

	)
	
	SELECT * FROM @Capacities

END
GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 05/21/2014 17:22:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyReservationOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 05/21/2014 17:22:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders] (		
	@P_WeekEndDate datetime2(7),
	@P_SearchText AS NVARCHAR(255) = '',
	@P_OrderStatus AS NVARCHAR(255) = '',
	@P_Sort AS int = 0, --0 CreatedDate,--1 VL, --2 Pattern Number, --3 Order Detail Type, --4  Order Detail Status, --5 Old Po No, --6 Coordinator, --7 Distributor, --8 Client, --9 Order Status
	@P_OrderBy AS bit = 1,  -- 0 ASC , -- 1 DESC
	@P_Set AS int = 0,
	@P_MaxRows AS int = 20,
	@P_RecCount int OUTPUT,
	@P_Coordinator AS NVARCHAR(255) = '',
	@P_Distributor AS NVARCHAR(255) = '',
	@P_Clients AS NVARCHAR(255) = ''
)
AS
BEGIN

	SET NOCOUNT ON
	DECLARE @Orders TABLE
	(
    OrderID int NOT NULL
	);
	DECLARE @StartOffset AS int;
	SET @StartOffset = (@P_Set - 1) * @P_MaxRows;
	
	DECLARE @orderid AS int;
	IF (ISNUMERIC(@P_SearchText) = 1 )
		BEGIN
			SET @orderid = CONVERT(int, @P_SearchText)		
		END
	ELSE
		BEGIN
			SET @orderid = 0
		END;
		
		/*WITH Orders AS
		(
			SELECT DISTINCT TOP (@P_Set * @P_MaxRows)
			CONVERT(int, ROW_NUMBER() OVER ( ORDER BY o.[ID] DESC))
			AS Number,
			o.[ID]	
			 FROM [Indico].[dbo].[OrderDetail] od
										JOIN [dbo].[Order] o
											ON od.[Order] = o.[ID]
										JOIN [dbo].[VisualLayout] vl
											ON od.[VisualLayout] = vl.[ID]
										JOIN [dbo].[Pattern] p 
											ON od.[Pattern] = p.[ID]
										JOIN [dbo].[FabricCode] fc
											ON od.[FabricCode] = fc.[ID]
										LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
											ON od.[Status] = ods.[ID]
										JOIN [dbo].[OrderType] ot
											ON od.[OrderType] = ot.[ID]
										JOIN [dbo].[Company] c
											ON c.[ID] = o.[Distributor]
										JOIN [dbo].[User] u
											ON c.[Coordinator] = u.[ID]
										JOIN [dbo].[Client] cl
											ON o.[Client] = cl.[ID]
										JOIN [dbo].[OrderStatus] os
											ON o.[Status] = os.[ID]
										JOIN [dbo].[User] urc
											ON o.[Creator] = urc.[ID]
										JOIN [dbo].[User] urm
											ON o.[Modifier] = urm.[ID] 
										JOIN [dbo].[Reservation] res
											ON o.[Reservation] = res.[ID] 
									WHERE (@P_SearchText = '' OR
										   o.[OldPONo] LIKE '%' + @P_SearchText + '%' OR
										   u.[GivenName]  LIKE '%' + @P_SearchText + '%' OR
										   u.[FamilyName] LIKE '%' + @P_SearchText + '%' OR
										   p.[Number] LIKE '%' + @P_SearchText + '%' OR 
										   p.[NickName] LIKE '%' + @P_SearchText + '%' OR
										   vl.[NamePrefix] LIKE '%' + @P_SearchText + '%' OR 
										   vl.[NameSuffix] LIKE '%' + @P_SearchText + '%' OR 
										   ods.[Name] LIKE '%' + @P_SearchText + '%' OR 
										   ot.[Name] LIKE '%' + @P_SearchText + '%' OR
										   c.[Name] LIKE '%' + @P_SearchText + '%' OR 
										   cl.[Name] LIKE '%' + @P_SearchText + '%' OR					
										   fc.[Code] LIKE '%' + @P_SearchText + '%' OR 
										   fc.[Name] LIKE '%' + @P_SearchText + '%'  OR
										   o.[ID] = @orderid )AND
										  (@P_OrderStatus = '' OR os.[Name] LIKE '%' + @P_OrderStatus + '%') AND
										  (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)AND
										  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
										  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
										  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
										  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))
										  
									GROUP BY o.[ID]
			)
	
		INSERT INTO @Orders ([OrderID]) 
		SELECT  ID FROM Orders WHERE Number > @StartOffset;	
	*/
	--WITH OrderDetails AS
	--	(
			SELECT 			
				   od.[ID] AS OrderDetail
				  ,ot.[Name] AS OrderType
				  ,vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),'') AS VisualLayout
				  ,od.[VisualLayout] AS VisualLayoutID
				  ,od.[Pattern] AS PatternID
				  ,p.[Number] + ' - ' + p.[NickName] AS Pattern
				  ,od.[FabricCode] AS FabricID
				  ,fc.[Code] + ' - ' + fc.[Name] AS Fabric
				  ,od.[VisualLayoutNotes] AS VisualLayoutNotes      
				  ,od.[Order] AS 'Order'
				  ,ISNULL(od.[Label], 0) AS Label
				  ,ISNULL(ods.[Name], 'New') AS OrderDetailStatus
				  ,ISNULL(od.[Status], 0) AS OrderDetailStatusID
				  ,od.[ShipmentDate] AS ShipmentDate
				  ,od.[SheduledDate] AS SheduledDate      
				  ,od.[RequestedDate] AS RequestedDate
				  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]),0) AS Quantity      
				  ,(SELECT DATEDIFF(day, od.[RequestedDate], od.[SheduledDate])) AS 'DateDiffrence'
				  ,ISNULL(o.[OldPONo], '') AS 'PurONo'
				  ,c.[Name] AS Distributor
				  ,u.[GivenName] + ' ' + u.[FamilyName] AS Coordinator
				  ,cl.[Name] AS Client
				  ,os.[Name] AS OrderStatus
				  ,o.[Status] AS OrderStatusID
				  ,urc.[GivenName] + ' ' + urc.[FamilyName] AS Creator
				  ,o.[Creator] AS CreatorID
				  ,o.[CreatedDate] AS CreatedDate
				  ,urm.[GivenName] + ' ' + urm.[FamilyName] AS Modifier
				  ,o.[ModifiedDate] AS ModifiedDate
				  ,ISNULL(pm.[Name], '') AS PaymentMethod
				  ,ISNULL(sm.[Name], '') AS ShipmentMethod
				  ,o.[IsWeeklyShipment]  AS WeeklyShiment
				  ,o.[IsCourierDelivery]  AS CourierDelivery
				  ,o.[IsAdelaideWareHouse] AS AdelaideWareHouse
				  ,o.[IsFollowingAddress] AS FollowingAddress
				  ,ISNULL(dca.[CompanyName] + ' ' + dca.[Address] + ' ' + dca.[Suburb] + ' ' + ISNULL(dca.[State], '') + ' ' + co.[ShortName] + ' ' + dca.[PostCode], '') AS ShippingAddress
				  ,ISNULL(dp.[Name], '') AS DestinationPort
				  ,ISNULL(vl.[ResolutionProfile], 0 ) AS ResolutionProfile
			  FROM [Indico].[dbo].[OrderDetail] od
					JOIN [dbo].[Order] o
						ON od.[Order] = o.[ID]
					JOIN [dbo].[VisualLayout] vl
						ON od.[VisualLayout] = vl.[ID]
					JOIN [dbo].[Pattern] p 
						ON od.[Pattern] = p.[ID]
					JOIN [dbo].[FabricCode] fc
						ON od.[FabricCode] = fc.[ID]
					LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
						ON od.[Status] = ods.[ID]
					JOIN [dbo].[OrderType] ot
						ON od.[OrderType] = ot.[ID]
					JOIN [dbo].[Company] c
						ON c.[ID] = o.[Distributor]
					JOIN [dbo].[User] u
						ON c.[Coordinator] = u.[ID]
					JOIN [dbo].[Client] cl
						ON o.[Client] = cl.[ID]
					JOIN [dbo].[OrderStatus] os
						ON o.[Status] = os.[ID]
					JOIN [dbo].[User] urc
						ON o.[Creator] = urc.[ID]
					JOIN [dbo].[User] urm
						ON o.[Modifier] = urm.[ID] 
					JOIN [dbo].[Reservation] res
						ON od.[Reservation] = res.[ID]
					LEFT OUTER JOIN [dbo].[PaymentMethod] pm
						ON o.[PaymentMethod] = pm.[ID]
					LEFT OUTER JOIN [dbo].[ShipmentMode] sm
						ON o.[ShipmentMode] = sm.[ID]
					LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
						ON o.[DespatchToExistingClient] = dca.[ID]
					LEFT OUTER JOIN [dbo].[Country] co
						ON dca.[Country] = co.[ID]
					LEFT OUTER JOIN [dbo].[DestinationPort] dp
						ON dca.[Port] = dp.[ID] 
				WHERE (@P_SearchText = '' OR
					   o.[OldPONo] LIKE '%' + @P_SearchText + '%' OR
					   u.[GivenName]  LIKE '%' + @P_SearchText + '%' OR
					   u.[FamilyName] LIKE '%' + @P_SearchText + '%' OR
					   p.[Number] LIKE '%' + @P_SearchText + '%' OR 
					   p.[NickName] LIKE '%' + @P_SearchText + '%' OR
					   vl.[NamePrefix] LIKE '%' + @P_SearchText + '%' OR 
					   vl.[NameSuffix] LIKE '%' + @P_SearchText + '%' OR 
					   ods.[Name] LIKE '%' + @P_SearchText + '%' OR 
					   ot.[Name] LIKE '%' + @P_SearchText + '%' OR
					   c.[Name] LIKE '%' + @P_SearchText + '%' OR 
					   cl.[Name] LIKE '%' + @P_SearchText + '%' OR					
					   fc.[Code] LIKE '%' + @P_SearchText + '%' OR 
					   fc.[Name] LIKE '%' + @P_SearchText + '%'  OR
					   o.[ID] = @orderid )AND
					  (@P_OrderStatus = '' OR os.[Name] LIKE '%' + @P_OrderStatus + '%') AND
					  (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))AND
					  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
					  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
					  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
					  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold')))
										  
		
	--	)
	--SELECT * FROM OrderDetails --WHERE ID > @StartOffset
	
	/*IF (@P_Set = 1)	
		BEGIN 
			SELECT  @P_RecCount = COUNT(ord.[ID]) 
			FROM (SELECT DISTINCT o.[ID] FROM [Indico].[dbo].[OrderDetail] od
														JOIN [dbo].[Order] o
															ON od.[Order] = o.[ID]
														JOIN [dbo].[VisualLayout] vl
															ON od.[VisualLayout] = vl.[ID]
														JOIN [dbo].[Pattern] p 
															ON od.[Pattern] = p.[ID]
														JOIN [dbo].[FabricCode] fc
															ON od.[FabricCode] = fc.[ID]
														LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
															ON od.[Status] = ods.[ID]
														JOIN [dbo].[OrderType] ot
															ON od.[OrderType] = ot.[ID]
														JOIN [dbo].[Company] c
															ON c.[ID] = o.[Distributor]
														JOIN [dbo].[User] u
															ON c.[Coordinator] = u.[ID]
														JOIN [dbo].[Client] cl
															ON o.[Client] = cl.[ID]
														JOIN [dbo].[OrderStatus] os
															ON o.[Status] = os.[ID]
														JOIN [dbo].[User] urc
															ON o.[Creator] = urc.[ID]
														JOIN [dbo].[User] urm
															ON o.[Modifier] = urm.[ID] 
														JOIN [dbo].[Reservation] res
															ON o.[Reservation] = res.[ID] 
													WHERE (@P_SearchText = '' OR
														   o.[OldPONo] LIKE '%' + @P_SearchText + '%' OR
														   u.[GivenName]  LIKE '%' + @P_SearchText + '%' OR
														   u.[FamilyName] LIKE '%' + @P_SearchText + '%' OR
														   p.[Number] LIKE '%' + @P_SearchText + '%' OR 
														   p.[NickName] LIKE '%' + @P_SearchText + '%' OR
														   vl.[NamePrefix] LIKE '%' + @P_SearchText + '%' OR 
														   vl.[NameSuffix] LIKE '%' + @P_SearchText + '%' OR 
														   ods.[Name] LIKE '%' + @P_SearchText + '%' OR 
														   ot.[Name] LIKE '%' + @P_SearchText + '%' OR
														   c.[Name] LIKE '%' + @P_SearchText + '%' OR 
														   cl.[Name] LIKE '%' + @P_SearchText + '%' OR					
														   fc.[Code] LIKE '%' + @P_SearchText + '%' OR 
														   fc.[Name] LIKE '%' + @P_SearchText + '%'  OR
														   o.[ID] = @orderid )AND
														  (@P_OrderStatus = '' OR os.[Name] LIKE '%' + @P_OrderStatus + '%') AND
												          (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)AND
														  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
										                  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
														  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
														  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))) ord
		END
	ELSE
		BEGIN*/
			SET @P_RecCount = 0
		--END	
END





GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
/****** Object:  StoredProcedure [dbo].[SPC_GetCartonsDetails]    Script Date: 05/23/2014 10:12:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetCartonsDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetCartonsDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetCartonsDetails]    Script Date: 05/23/2014 10:12:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SPC_GetCartonsDetails] (	
@P_WeekEndDate datetime2(7) 
)	
AS 
BEGIN

	  SELECT pl.[CartonNo] AS 'Carton' 
		    ,ISNULL((SELECT SUM(plci.[Count]) FROM [dbo].[PackingListCartonItem] plci WHERE plci.[PackingList] = pl.[ID]),0) AS 'FillQty'
		    ,ISNULL((SELECT SUM(plsq.[Qty]) FROM [dbo].[PackingListSizeQty] plsq WHERE plsq.[PackingList] = pl.[ID]), 0) AS 'TotalQty'
		    ,ISNULL(dca.[CompanyName], '') AS 'CompanyName'
			,dca.[Address] AS 'Address'
			,dca.[Suburb]  AS 'Suberb' 
			,ISNULL(dca.[State],'') AS 'State'
			,dca.[PostCode]  AS 'PostCode'				 
			,c.[ShortName] AS 'Country'
			,ISNULL(o.[ShipmentMode], 0) AS ShimentModeID
			,ISNULL(sm.[Name], 'AIR') AS ShipmentMode
			,ISNULL(o.[DespatchToExistingClient], 0) AS 'ShipTo'
	  FROM [Indico].[dbo].[PackingList] pl
		JOIN [dbo].[OrderDetail] od 
			ON pl.[OrderDetail] = od.[ID]
		JOIN [dbo].[Order] o 
			ON od.[Order] = o.[ID]
		JOIN [dbo].[DistributorClientAddress] dca
			ON o.[DespatchToExistingClient] = dca.[ID]
		JOIN [dbo].[Country] c
			ON dca.[Country] = c.[ID]
		JOIN [dbo].[ShipmentMode] sm
			ON o.[ShipmentMode] = sm.[ID]
	  WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
  
 END
 
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
/****** Object:  View [dbo].[ReturnCartonsDetailsView]    Script Date: 05/23/2014 10:22:43 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnCartonsDetailsView]'))
DROP VIEW [dbo].[ReturnCartonsDetailsView]
GO

/****** Object:  View [dbo].[ReturnCartonsDetailsView]    Script Date: 05/23/2014 10:22:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ReturnCartonsDetailsView]
AS
			SELECT 0  AS Carton
				  ,0  AS FillQty
				  ,0  AS TotalQty
				  ,'' AS CompanyName
				  ,'' AS [Address]
				  ,'' AS Suberb 
				  ,'' AS [State]
				  ,'' AS PostCode				 
				  ,'' AS Country
				  ,0  AS ShimentModeID
				  ,'' AS ShipmentMode
				  ,0  AS ShipTo


GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**