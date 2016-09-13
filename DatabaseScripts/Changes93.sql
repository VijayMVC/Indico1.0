USE [Indico]
GO


--***-***--***-***--***-***--***-***--***-***DELETE Invoice Status --***-***--***-***--***-***
DELETE FROM [dbo].[InvoiceStatus]
GO

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

--***-***--***-***--***-***--***-***--***-*** INSERT Invoice Status --***-***--***-***--***-***
INSERT INTO [dbo].[InvoiceStatus] ([Key], [Name]) VALUES('PS','PreShipped')
GO

INSERT INTO [dbo].[InvoiceStatus] ([Key], [Name]) VALUES('S' ,'Shipped')
GO

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

--***-***--***-***--***-***--***-*** ADD New Column to the Invoice  Table --***-***--***-***--***-***

ALTER TABLE [dbo].[Invoice]
ADD [Status] [int] NOT NULL
GO

ALTER TABLE [dbo].[Invoice] WITH CHECK ADD CONSTRAINT [FK_Invoice_Status] FOREIGN KEY ([Status])
REFERENCES [dbo].[InvoiceStatus] ([ID])
GO

ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_Status]
GO

ALTER TABLE [dbo].[Invoice]
ADD [ShipmentDate] [datetime2](7) NOT NULL
GO

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

--***-***--***-***--***-***--***-*** ADD New SP for Get Shipment Dates for Invoice--***-***--***-***--***-***

/****** Object:  StoredProcedure [dbo].[SPC_GetShipmentDates]    Script Date: 04/11/2014 14:42:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetShipmentDates]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetShipmentDates]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetShipmentDates]    Script Date: 04/11/2014 14:42:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SPC_GetShipmentDates]
(
@P_WeekEndDate AS DATETIME2 (7)
)
AS

SELECT [ShipmentDate] FROM [dbo].[OrderDetail] od
WHERE  (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
GROUP BY [ShipmentDate]


GO
--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

/****** Object:  View [dbo].[ReturnShipmentDatesView]    Script Date: 04/11/2014 15:58:29 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnShipmentDatesView]'))
DROP VIEW [dbo].[ReturnShipmentDatesView]
GO

/****** Object:  View [dbo].[ReturnShipmentDatesView]    Script Date: 04/11/2014 15:58:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnShipmentDatesView]
AS 
	
	SELECT GETDATE() AS ShipmentDate
	

GO
--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***
/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 04/11/2014 13:42:13 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyFirmOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 04/11/2014 13:42:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/********* ALTER STORED PROCEDURE [SPC_GetWeeklyFirmOrders]*************/
CREATE PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders] (	
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
	DECLARE @orderid AS int;
	SET @StartOffset = (@P_Set - 1) * @P_MaxRows;
	
	
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
								          (o.[Reservation] IS NULL) AND
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
		          (o.[Reservation] IS NULL) AND
		          (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))AND
				  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
				  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
				  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
				  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))
							
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
												          (o.[Reservation] IS NULL) AND
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

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyHoldOrders]    Script Date: 04/11/2014 14:52:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyHoldOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyHoldOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyHoldOrders]    Script Date: 04/11/2014 14:52:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SPC_GetWeeklyHoldOrders] (	
	@P_WeekEndDate datetime2(7),
	@P_SearchText AS NVARCHAR(255) = '',
	@P_OrderStatus AS NVARCHAR(255) = '',
	--@P_Sort AS int = 0, --0 CreatedDate,--1 VL, --2 Pattern Number, --3 Order Detail Type, --4  Order Detail Status, --5 Old Po No, --6 Coordinator, --7 Distributor, --8 Client, --9 Order Status
	--@P_OrderBy AS bit = 1,  -- 0 ASC , -- 1 DESC
	--@P_Set AS int = 0,
	--@P_MaxRows AS int = 20,
	--@P_RecCount int OUTPUT,
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
	--DECLARE @StartOffset AS int;
	--SET @StartOffset = (@P_Set - 1) * @P_MaxRows;
	
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
				   o.[ID] = @orderid)AND														   
		           (od.[OrderType] = (SELECT odt.[ID] FROM [Indico].[dbo].[OrderType] odt WHERE odt.[Name] = 'SAMPLE')) AND
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
		--(
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
				   o.[ID] = @orderid)AND														   
		          ((o.[Status] = (SELECT os.[ID] FROM [dbo].[OrderStatus] os WHERE os.[Name] = 'Indiman Hold'))OR
		           (o.[Status] = (SELECT os.[ID] FROM [dbo].[OrderStatus] os WHERE os.[Name] = 'Indico Hold'))) AND
				  (@P_OrderStatus = '' OR os.[Name] LIKE '%' + @P_OrderStatus + '%') AND
				  (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))AND
				  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
				  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
				  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
				  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))										
		--)
	/*SELECT * FROM OrderDetails-- WHERE ID > @StartOffset
	
	IF (@P_Set = 1)	
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
												           (od.[OrderType] = (SELECT odt.[ID] FROM [Indico].[dbo].[OrderType] odt WHERE odt.[Name] = 'SAMPLE')) AND
														   (@P_OrderStatus = '' OR os.[Name] LIKE '%' + @P_OrderStatus + '%') AND
														   (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)AND
														   (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
														   (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
														   (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
														   (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))) ord
		END
	ELSE
		BEGIN*/
			--SET @P_RecCount = 0
		--END			

END

GO

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 04/11/2014 14:55:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyJacketOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyJacketOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 04/11/2014 14:55:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/********* ALTER STORED PROCEDURE [SPC_GetWeeklyJacketOrders]*************/

CREATE PROCEDURE [dbo].[SPC_GetWeeklyJacketOrders] (	
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
						  (p.[Item] = (SELECT i.[ID] FROM [Indico].[dbo].[Item] i WHERE i.[Name] = 'JACKET' AND i.[Parent] IS NULL)) AND
						  (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)AND
						  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
						  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
						  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
						  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))
					GROUP BY  o.[ID]
		 )
	
		INSERT INTO @Orders ([OrderID]) 
		SELECT  ID FROM Orders WHERE Number > @StartOffset;	
	*/
	---WITH OrderDetails AS
		--(
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
				  ,o.[Creator] AS CreatorID
				  ,cl.[Name] AS Client
				  ,os.[Name] AS OrderStatus
				  ,o.[Status] AS OrderStatusID
				  ,urc.[GivenName] + ' ' + urc.[FamilyName] AS Creator
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
					  (p.[Item] = (SELECT i.[ID] FROM [Indico].[dbo].[Item] i WHERE i.[Name] = 'JACKET' AND i.[Parent] IS NULL)) AND
					  (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))AND
					  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
					  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
					  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND				  
					  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))	
							
							
			/*WHERE  o.[ID] IN (SELECT [OrderID] FROM @Orders) AND
				   (@orderid = 0 OR o.[ID] = @orderid) AND
				   (p.[Item] = (SELECT i.[ID] FROM [Indico].[dbo].[Item] i WHERE i.[Name] = 'JACKET' AND i.[Parent] IS NULL)) AND
				   (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))*/
	--	)
	/*SELECT * FROM OrderDetails --WHERE ID > @StartOffset
	
	IF (@P_Set = 1)	
		BEGIN 
			SELECT  @P_RecCount = COUNT(ord.[ID]) 
			FROM (SELECT DISTINCT o.[ID]  FROM [Indico].[dbo].[OrderDetail] od
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
														  (p.[Item] = (SELECT i.[ID] FROM [Indico].[dbo].[Item] i WHERE i.[Name] = 'JACKET' AND i.[Parent] IS NULL)) AND
														  (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)AND
														  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
														  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
														  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
														  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled'))))ord
		END
	ELSE
		BEGIN*/
			SET @P_RecCount = 0
		--END					
END 



GO

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 04/11/2014 14:58:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyLessFiveItemOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyLessFiveItemOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 04/11/2014 14:58:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_GetWeeklyLessFiveItemOrders] (		
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
								o.[ID] IN (SELECT o.ID
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
											HAVING SUM(odq.Qty) <= 5) AND
							(od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)AND
							(@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
							(@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
							(@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
							(od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))
						GROUP BY  o.[ID]
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
								o.[ID] IN (SELECT o.ID
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
											HAVING SUM(odq.Qty) <= 5) AND
							(od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))AND
							(@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
							(@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
							(@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
							(od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))
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
														  (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate) AND
															o.[ID] IN (SELECT o.ID
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
																		HAVING SUM(odq.Qty) <= 5)AND
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

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 04/11/2014 15:06:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyReservationOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 04/11/2014 15:06:51 ******/
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
						ON o.[Reservation] = res.[ID]
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
					  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))
										  
		
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

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 04/11/2014 15:08:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklySampleOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklySampleOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 04/11/2014 15:08:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[SPC_GetWeeklySampleOrders] (	
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
				   o.[ID] = @orderid)AND														   
		           (od.[OrderType] = (SELECT odt.[ID] FROM [Indico].[dbo].[OrderType] odt WHERE odt.[Name] = 'SAMPLE')) AND
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
		--(
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
				   o.[ID] = @orderid)AND														   
		           (od.[OrderType] = (SELECT odt.[ID] FROM [Indico].[dbo].[OrderType] odt WHERE odt.[Name] = 'SAMPLE')) AND
				  (@P_OrderStatus = '' OR os.[Name] LIKE '%' + @P_OrderStatus + '%') AND
				  (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))AND
				  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
				  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
				  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
				  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))										
		--)
	/*SELECT * FROM OrderDetails-- WHERE ID > @StartOffset
	
	IF (@P_Set = 1)	
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
												           (od.[OrderType] = (SELECT odt.[ID] FROM [Indico].[dbo].[OrderType] odt WHERE odt.[Name] = 'SAMPLE')) AND
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

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***
/****** Object:  StoredProcedure [dbo].[SPC_CreatePackingList]    Script Date: 04/11/2014 15:10:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_CreatePackingList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_CreatePackingList]
GO

/****** Object:  StoredProcedure [dbo].[SPC_CreatePackingList]    Script Date: 04/11/2014 15:10:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SPC_CreatePackingList]
(
	@P_WeekEndDate Datetime,
	@P_Creator INT
)
AS BEGIN
	
	DECLARE @RetVal int
	DECLARE @OrderDetailID INT
	DECLARE @PackingListID INT
	DECLARE @WeeklyProductionCapacityID INT
	DECLARE @CartonNo INT	
	DECLARE @TempOrderDetail TABLE 
	(
		ID INT NOT NULL
	)
	
	DECLARE @TempOrderDetailQty TABLE 
	(
		ID INT NOT NULL,
		Size INT NOT NULL,
		Qty INT NOT NULL
	)
	
	BEGIN TRY
		
		SET @CartonNo = 0
	
		INSERT INTO @TempOrderDetail (ID)
		SELECT ID FROM [dbo].[OrderDetail] od
		WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
	
		WHILE EXISTS(SELECT * FROM @TempOrderDetail )
			BEGIN	
				
				SET @CartonNo = @CartonNo + 1
				SET @OrderDetailID = (SELECT TOP 1 ID FROM @TempOrderDetail)				
				
				DELETE FROM @TempOrderDetailQty
				
				INSERT INTO @TempOrderDetailQty (ID, Size, Qty)
				SELECT ID, Size, Qty FROM [dbo].OrderDetailQty 
				WHERE OrderDetail = @OrderDetailID AND Qty > 0
				
				IF ((SELECT COUNT(ID) FROM @TempOrderDetailQty)> 0)
					BEGIN					
						SET @WeeklyProductionCapacityID = (SELECT ID FROM [dbo].WeeklyProductionCapacity WHERE WeekendDate = @P_WeekendDate)
					
						INSERT INTO [dbo].[PackingList]
								   ([CartonNo]
								   ,[WeeklyProductionCapacity]
								   ,[OrderDetail]
								   ,[PackingQty]
								   ,[Carton]
								   ,[Remarks]
								   ,[Creator]
								   ,[CreatedDate]
								   ,[Modifier]
								   ,[ModifiedDate])
						VALUES
						   (0
						   ,@WeeklyProductionCapacityID
						   ,@OrderDetailID
						   ,0
						   ,1
						   ,''
						   ,@P_Creator
						   , (SELECT (GETDATE()))
						   ,@P_Creator
						   , (SELECT (GETDATE())))						   					
						
						SET @PackingListID = SCOPE_IDENTITY()
						
						WHILE EXISTS(SELECT * FROM @TempOrderDetailQty )
							BEGIN	
								
								INSERT INTO [Indico].[dbo].[PackingListSizeQty]
									   ([PackingList]
									   ,[Size]
									   ,[Qty])
								 VALUES
									    (@PackingListID
									   ,(SELECT TOP 1 Size FROM @TempOrderDetailQty)
									   ,(SELECT TOP 1 Qty FROM @TempOrderDetailQty))
																							
								DELETE TOP(1) FROM @TempOrderDetailQty				
							END							
				END				
				
			DELETE TOP(1) FROM @TempOrderDetail
		END	
			
		SET @RetVal = 1	
	END TRY
	BEGIN CATCH
		SET @RetVal = 0
	END CATCH
	
	SELECT @RetVal AS RetVal
END




GO


--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

/****** Object:  StoredProcedure [dbo].[SPC_GetCartonsDetails]    Script Date: 04/11/2014 15:19:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetCartonsDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetCartonsDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetCartonsDetails]    Script Date: 04/11/2014 15:19:08 ******/
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
	  FROM [Indico].[dbo].[PackingList] pl
	  JOIN [dbo].[OrderDetail] od 
		ON pl.[OrderDetail] = od.[ID]
	  WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
  
 END



GO

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

/****** Object:  StoredProcedure [dbo].[SPC_GetInvoiceOrderDetails]    Script Date: 04/11/2014 15:20:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetInvoiceOrderDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetInvoiceOrderDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetInvoiceOrderDetails]    Script Date: 04/11/2014 15:20:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/

/****** Object:  StoredProcedure [dbo].[SPC_GetInvoiceOrderDetails]    Script Date: 04/17/2014 10:01:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetInvoiceOrderDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetInvoiceOrderDetails]
GO


/****** Object:  StoredProcedure [dbo].[SPC_GetInvoiceOrderDetails]    Script Date: 04/17/2014 10:01:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/

CREATE PROC [dbo].[SPC_GetInvoiceOrderDetails]
(
	@P_Invoice int,
	@P_ShipTo int,
	@P_IsNew AS bit = 1,
	@P_WeekEndDate datetime2(7), --- OrderDetail Table Shipment Date
	@P_ShipmentMode int
)
AS BEGIN

	IF(@P_IsNew = 1)

			BEGIN
						SELECT od.[ID] AS OrderDetail
							  ,ot.[Name] AS OrderType
							  ,vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),'') AS VisualLayout
							  ,od.[VisualLayout] AS VisualLayoutID
							  ,od.[Pattern] AS PatternID
							  ,p.[Number] + ' - ' + p.[NickName] AS Pattern
							  ,od.[FabricCode] AS FabricID
							  ,fc.[Code] + ' - ' + fc.[Name] AS Fabric							   
							  ,od.[Order] AS 'Order'	
							  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]),0) AS Quantity       
							  ,ISNULL(o.[OldPONo], '') AS 'PurONo'
							  ,c.[Name] AS Distributor
							  ,u.[GivenName] + ' ' + u.[FamilyName] AS Coordinator
							  ,cl.[Name] AS Client							 
							  ,(SELECT CASE
										WHEN (ISNULL((SELECT TOP 1 co.[QuotedFOBCost] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00) = 0.00)
											THEN  	(ISNULL((SELECT TOP 1 co.[JKFOBCost] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00))
										ELSE (ISNULL((SELECT TOP 1 co.[QuotedFOBCost] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00))
								END) AS 'FactoryRate'														  
							  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]), 0) AS 'Qty'
							  ,g.[Name] AS 'Gender'
							  ,ISNULL(ag.[Name], '') AS 'AgeGroup'
							  ,(SELECT CASE
										WHEN (ISNULL((SELECT TOP 1 co.[QuotedCIF] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00) = 0.00)
											THEN  	(ISNULL((SELECT TOP 1 co.[IndimanCIF] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00))
										ELSE (ISNULL((SELECT TOP 1 co.[QuotedCIF] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00))
								END) AS 'IndimanRate'	
							  ,0 AS 'InvoiceOrder'
						  FROM [Indico].[dbo].[OrderDetail] od
							JOIN [dbo].[Order] o
								ON od.[Order] = o.[ID]
							JOIN [dbo].[VisualLayout] vl
								ON od.[VisualLayout] = vl.[ID]
							JOIN [dbo].[Pattern] p 
								ON od.[Pattern] = p.[ID]
							JOIN [dbo].[FabricCode] fc
								ON od.[FabricCode] = fc.[ID]						
							JOIN [dbo].[OrderType] ot
								ON od.[OrderType] = ot.[ID]
							JOIN [dbo].[Company] c
								ON c.[ID] = o.[Distributor]
							JOIN [dbo].[User] u
								ON c.[Coordinator] = u.[ID]
							JOIN [dbo].[Client] cl
								ON o.[Client] = cl.[ID]	
							JOIN [dbo].[Gender] g
								ON p.[Gender] = g.[ID]
							LEFT OUTER JOIN [dbo].[AgeGroup] ag
								ON p.[AgeGroup] = ag.[ID]					
						WHERE (@P_ShipTo = 0 OR o.[DespatchToExistingClient] = @P_ShipTo) AND
							  (@P_ShipmentMode = 0 OR o.[ShipmentMode] = @P_ShipmentMode) AND
							  (od.[ShipmentDate] = @P_WeekEndDate)
			END
	ELSE
			BEGIN
			
						SELECT od.[ID] AS OrderDetail
							  ,ot.[Name] AS OrderType
							  ,vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),'') AS VisualLayout
							  ,od.[VisualLayout] AS VisualLayoutID
							  ,od.[Pattern] AS PatternID
							  ,p.[Number] + ' - ' + p.[NickName] AS Pattern
							  ,od.[FabricCode] AS FabricID
							  ,fc.[Code] + ' - ' + fc.[Name] AS Fabric							      
							  ,od.[Order] AS 'Order'	
							  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]),0) AS Quantity       
							  ,ISNULL(o.[OldPONo], '') AS 'PurONo'
							  ,c.[Name] AS Distributor
							  ,u.[GivenName] + ' ' + u.[FamilyName] AS Coordinator
							  ,cl.[Name] AS Client							 
							  ,ISNULL(iod.[FactoryPrice], 0.00) AS 'FactoryRate'
							  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]), 0) AS 'Qty'
							  ,g.[Name] AS 'Gender'
							  ,ISNULL(ag.[Name], '') AS 'AgeGroup'							  
							  ,(SELECT CASE 
									WHEN (ISNULL(iod.[IndimanPrice], 0.00) = 0.00 )
									THEN 
										(SELECT CASE
											WHEN (ISNULL((SELECT TOP 1 co.[QuotedCIF] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00) = 0.00)
												THEN  	(ISNULL((SELECT TOP 1 co.[IndimanCIF] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00))
											ELSE (ISNULL((SELECT TOP 1 co.[QuotedCIF] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00))											
									     END) 
									ELSE (ISNULL(iod.[IndimanPrice],0.00))
									END) AS 'IndimanRate'
							  ,iod.[ID] AS 'InvoiceOrder'
						 FROM [Indico].[dbo].[OrderDetail] od
							JOIN [dbo].[Order] o
								ON od.[Order] = o.[ID]
							JOIN [dbo].[VisualLayout] vl
								ON od.[VisualLayout] = vl.[ID]
							JOIN [dbo].[Pattern] p 
								ON od.[Pattern] = p.[ID]
							JOIN [dbo].[FabricCode] fc
								ON od.[FabricCode] = fc.[ID]						
							JOIN [dbo].[OrderType] ot
								ON od.[OrderType] = ot.[ID]
							JOIN [dbo].[Company] c
								ON c.[ID] = o.[Distributor]
							JOIN [dbo].[User] u
								ON c.[Coordinator] = u.[ID]
							JOIN [dbo].[Client] cl
								ON o.[Client] = cl.[ID]	
							JOIN [dbo].[Gender] g
								ON p.[Gender] = g.[ID]
							LEFT OUTER JOIN [dbo].[AgeGroup] ag
								ON p.[AgeGroup] = ag.[ID]
							JOIN [dbo].[InvoiceOrder] iod
								ON od.[ID] = iod.[OrderDetail]					
						WHERE (@P_ShipTo = 0 OR o.[DespatchToExistingClient] = @P_ShipTo) AND
							  (@P_Invoice = 0 OR iod.[Invoice] = @P_Invoice) AND
							  (@P_ShipmentMode = 0 OR o.[ShipmentMode] = @P_ShipmentMode) AND
							  (od.[ShipmentDate] = @P_WeekEndDate)
			END
		
END



GO
--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***


/****** Object:  StoredProcedure [dbo].[SPC_GetPackingListDetails]    Script Date: 04/11/2014 15:23:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetPackingListDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetPackingListDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetPackingListDetails]    Script Date: 04/11/2014 15:23:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SPC_GetPackingListDetails] (	
@P_WeekEndDate datetime2(7)
)	
AS 
BEGIN	
	SELECT pl.ID AS PackingList,
		   wpc.ID AS WeeklyProductionCapacity,
		   pl.CartonNo,
		   o.ID AS OrderNumber,		
		   od.[ID] AS OrderDetail,
		   vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),'') AS VLName,
		   p.[Number] + ' ' + p.[NickName] AS Pattern,
		   d.Name AS Distributor,
		   c.Name AS Client,
		   wpc.WeekendDate AS WeekendDate,
		   ISNULL((SELECT SUM(QTY) FROM [dbo].[PackingListSizeQty] WHERE PackingList = pl.ID),0) AS PackingTotal,
		   ISNULL((SELECT SUM([Count]) FROM [dbo].[PackingListCartonItem] WHERE PackingList = pl.ID),0) AS ScannedTotal,
		   ISNULL(o.[ShipmentMode], 0) AS ShimentModeID,
			ISNULL(shm.[Name], 'AIR') AS ShipmentMode,
			ISNULL(dca.[CompanyName], '') AS 'CompanyName',
			dca.[Address] AS 'Address',
			dca.[Suburb]  AS 'Suberb' ,
			ISNULL(dca.[State],'') AS 'State',
			dca.[PostCode]  AS 'PostCode',			 
			coun.[ShortName] AS 'Country',
			dca.[ContactName] + ' ' + dca.[ContactPhone] AS 'ContactDetails',
			o.[IsWeeklyShipment] AS 'IsWeeklyShipment',
			[IsAdelaideWareHouse] AS 'IsAdelaideWareHouse',
			ISNULL(o.[DespatchToExistingClient], 0) AS 'ShipTo'		
	FROM  dbo.[PackingList] pl
		INNER JOIN dbo.[OrderDetail] od
			ON pl.OrderDetail = od.ID
		INNER JOIN dbo.[Order] o
			ON od.[Order] = o.ID
		INNER JOIN dbo.[VisualLayout] vl
			ON od.[VisualLayout] = vl.ID	
		INNER JOIN dbo.Pattern p
			ON od.Pattern = p.ID
		INNER JOIN dbo.Client c
			ON o.Client = c.ID
		INNER JOIN dbo.Company d
			ON o.Distributor = d.ID	
		INNER JOIN dbo.WeeklyProductionCapacity wpc
			ON pl.WeeklyProductionCapacity = wpc.ID
		JOIN [dbo].[ShipmentMode] shm
			ON o.[ShipmentMode] = shm.[ID] 	
		JOIN [dbo].[DistributorClientAddress] dca
			ON o.[DespatchToExistingClient] = dca.[ID]
		JOIN [dbo].[Country] coun
			ON dca.[Country] = coun.[ID]		
	WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
	ORDER BY pl.[CartonNo] ASC
END




GO

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyAddressDetails]    Script Date: 04/11/2014 15:25:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyAddressDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyAddressDetails]
GO

USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyAddressDetails]    Script Date: 04/11/2014 15:25:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SPC_GetWeeklyAddressDetails] (	
@P_WeekEndDate datetime2(7),
@P_CompanyName NVARCHAR(255) = '',
@P_ShipmentMode int = 0 
)	
AS 
BEGIN
	
		SELECT	   od.[ID] AS OrderDetail
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
				  ,ISNULL(o.[OldPONo], '') AS 'PurONo'
				  ,c.[Name] AS Distributor
				  ,u.[GivenName] + ' ' + u.[FamilyName] AS Coordinator
				  ,cl.[Name] AS Client
				  ,os.[Name] AS OrderStatus
				  ,o.[Status] AS OrderStatusID				  
				  ,ISNULL(o.[ShipmentMode], 0) AS ShimentModeID
				  ,ISNULL(shm.[Name], 'AIR') AS ShipmentMode
				  ,ISNULL(dca.[CompanyName], '') AS 'CompanyName'
				  ,dca.[Address] AS 'Address'
				  ,dca.[Suburb]  AS 'Suberb' 
				  ,ISNULL(dca.[State],'') AS 'State'
				  ,dca.[PostCode]  AS 'PostCode'				 
				  ,coun.[ShortName] AS 'Country'
				  ,dca.[ContactName] + ' ' + dca.[ContactPhone] AS 'ContactDetails'
				  ,o.[IsWeeklyShipment] AS 'IsWeeklyShipment'
				  ,[IsAdelaideWareHouse] AS 'IsAdelaideWareHouse'
				  ,ISNULL(o.[DespatchToExistingClient], 0) AS 'ShipTo'
				  ,ISNULL(CAST((SELECT CASE
										WHEN (p.[SubItem] IS NULL)
											THEN  	('')
										ELSE (CAST((SELECT TOP 1 hsc.[Code] FROM [dbo].[HSCode] hsc WHERE hsc.[ItemSubCategory] = p.[SubItem] AND hsc.[Gender] = p.[Gender]) AS nvarchar(64)))
								END) AS nvarchar (64)), '') AS 'HSCode'
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
				JOIN [dbo].[ShipmentMode] shm
					ON o.[ShipmentMode] = shm.[ID] 
				JOIN [dbo].[DistributorClientAddress] dca
					ON o.[DespatchToExistingClient] = dca.[ID]
				JOIN [dbo].[Country] coun
					ON dca.[Country] = coun.[ID]
			WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate))) AND
				  (@P_CompanyName = '' OR dca.[CompanyName] = @P_CompanyName ) AND
				  (@P_ShipmentMode = 0 OR shm.[ID] = @P_ShipmentMode)
			ORDER BY cl.[Name]

	END 



GO

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyOrderDetailQtys]    Script Date: 04/11/2014 15:29:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyOrderDetailQtys]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyOrderDetailQtys]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyOrderDetailQtys]    Script Date: 04/11/2014 15:29:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/********* CREATE STORED PROCEDURE [SPC_GetWeeklyOrderDetailQtys]*************/
CREATE PROCEDURE [dbo].[SPC_GetWeeklyOrderDetailQtys] (	
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN
		SELECT	 od.[ID] AS OrderDetail
				,odq.[Size] AS SizeID
				,odq.[Qty] AS Quantity				 
			  FROM [Indico].[dbo].[OrderDetail] od				
				INNER JOIN [dbo].[OrderDetailQty] odq
					ON odq.[OrderDetail] = od.[ID]				
			WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate))) AND
				   odq.[Qty] > 0
	
END


GO


--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySummary]    Script Date: 04/11/2014 15:50:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklySummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklySummary]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySummary]    Script Date: 04/11/2014 15:50:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SPC_GetWeeklySummary] (	
@P_WeekEndDate datetime2(7) --Shipment Date in OrderDetail Table
)	
AS 
BEGIN
		SELECT 
				ISNULL(dca.CompanyName, '') AS 'CompanyName', 
				ISNULL(SUM(odq.Qty), 0) AS  'Qty' , 
				ISNULL(sm.[Name], 'AIR') AS 'ShipmentMode',
				ISNULL(sm.[ID], 0) AS 'ShipmentModeID',
				ISNULL(dca.[ID], 0) AS 'DistributorClientAddress'
		  FROM [Indico].[dbo].[DistributorClientAddress] dca
		 JOIN [dbo].[ORDER] o
			ON o.[DespatchToExistingClient] = dca.ID
		 JOIN [dbo].[OrderDetail] od
			ON od.[Order] = o.ID
		 JOIN [dbo].[OrderDetailQty] odq
			ON odq.[OrderDetail] = od.ID
		 JOIN [dbo].[ShipmentMode] sm
			ON o.[ShipmentMode] = sm.[ID]
		WHERE (od.[ShipmentDate] = @P_WeekEndDate)
		GROUP BY dca.CompanyName, sm.[Name], sm.[ID],dca.[ID]
END


GO

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 04/11/2014 15:51:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ProductionCapacities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ProductionCapacities]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 04/11/2014 15:51:15 ******/
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
						AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))),
		-- Resevation order quantities
		(	SELECT ISNULL(SUM(odq.Qty),0) AS ResevationOrders
			FROM [Order] o
				JOIN OrderDetail od
					ON o.ID = od.[Order]  
				JOIN OrderDetailQty odq 
					ON od.ID = odq.OrderDetail
				JOIN Reservation r
					ON o.Reservation = r.ID 
			WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
			AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))),
		-- Resevation quantities
		(	SELECT DISTINCT ISNULL(SUM(r.Qty), 0) AS Resevations 
			FROM [Order] o
				JOIN [OrderDetail] od
					on o.[ID] = od.[Order]
				JOIN Reservation r
					ON o.Reservation = r.ID 
			WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
			AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))),
		-- Hold
		(	SELECT ISNULL(COUNT(odq.[Qty]), 0) AS Hold
			 FROM [dbo].[OrderDetailQty] odq 
				JOIN [dbo].[OrderDetail] od
					ON	odq.[OrderDetail] = od.[ID]
				JOIN [dbo].[Order] o
					ON od.[Order] = o.[ID]
			 WHERE ((o.[Status] = (SELECT os.[ID] FROM [dbo].[OrderStatus] os WHERE os.[Name] = 'Indiman Hold')) OR
					((o.[Status] = (SELECT os.[ID] FROM [dbo].[OrderStatus] os WHERE os.[Name] = 'Indico Hold')))) AND
				   (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate) AND
				   (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))),
		-- Less5Items
		(SELECT ISNULL(COUNT(ord.[ID]), 0)AS Less5Items FROM [dbo].[Order] ord
				 WHERE ord.[ID] IN (SELECT o.[ID]
												FROM dbo.[Order] o
													JOIN [OrderDetail] od
														ON o.[ID] = od.[Order]
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
																AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled'))))),

		-- JacketsOrders
		(SELECT ISNULL(COUNT(ord.[ID]), 0) AS Jackets  FROM [dbo].[Order] ord
				 WHERE ord.[ID] IN (SELECT o.[ID] 
										FROM [Order] o
											JOIN OrderDetail od
												ON o.ID = od.[Order]  
											JOIN Pattern p
												ON p.ID = od.Pattern
											JOIN Item i
												ON i.ID = p.Item
										WHERE i.Name IN('JACKET')AND i.Parent IS NULL
											AND  (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
											AND  (p.IsActive = 1)
											AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled'))))),
						
		-- SampleOrders
		(SELECT ISNULL(COUNT(ord.[ID]), 0) AS Samples  FROM [dbo].[Order] ord
											 WHERE ord.[ID] IN (SELECT o.[ID]
															   FROM dbo.[Order] o
																	JOIN OrderDetail od
																		ON o.ID =od.[Order]
																	LEFT OUTER JOIN  Reservation res
																		ON o.Reservation=res.ID
															   WHERE od.OrderType = (SELECT [ID] FROM [Indico].[dbo].[OrderType] WHERE [Name] = 'SAMPLE')
																	AND (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
																	AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))))

	)
	
	SELECT * FROM @Capacities

END



GO

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--*** Add new columns to the OrderDetailsView--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 04/16/2014 13:52:23 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetailsView]'))
DROP VIEW [dbo].[OrderDetailsView]
GO

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 04/16/2014 13:52:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OrderDetailsView]
AS
			SELECT
				  0 AS OrderDetail,
				  '' AS OrderType,
				  '' AS VisualLayout,
				  0 AS VisualLayoutID,
				  0 AS PatternID,
				  '' AS Pattern,
				  0 AS FabricID,
				  '' AS Fabric,
				  '' AS VisualLayoutNotes,      
				  0 AS 'Order',
				  0 AS Label,
				  '' AS OrderDetailStatus,
				  0 AS OrderDetailStatusID,
				  GETDATE() AS ShipmentDate,
				  GETDATE() AS SheduledDate,
				  GETDATE() AS RequestedDate,
				  0 AS Quantity,
				  0 AS 'DateDiffrence',
				  '' AS 'PurONo',
				  '' AS Distributor,
				  '' AS Coordinator,
				  '' AS Client,
				  '' AS OrderStatus,
				  0 AS OrderStatusID,
				  '' AS Creator,
				  0 AS CreatorID,
				  GETDATE() AS CreatedDate,
				  '' AS Modifier,
				  GETDATE() AS ModifiedDate,
				  '' AS PaymentMethod,
				  '' AS ShipmentMethod,
				  CONVERT(bit,0) AS WeeklyShiment,
				  CONVERT(bit,0) AS CourierDelivery,
				  CONVERT(bit,0) AS AdelaideWareHouse,
				  CONVERT(bit,0) AS FollowingAddress,
				  '' AS ShippingAddress,
				  '' AS DestinationPort,
				  0 AS ResolutionProfile

GO
--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

DECLARE @ParentPage As int 
DECLARE @Page AS int 
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Position AS int 
DECLARE @Role AS int 


INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES('/Home.aspx', 'Home', 'Home')

SET @Page  = SCOPE_IDENTITY()
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Parent] IS NULL AND [Page] = @ParentPage)
SET @Position = (SELECT MAX([Position]) + 1 FROM [dbo].[MenuItem] WHERE [Parent] = @Parent) 

INSERT INTO [Indico].[dbo].[MenuItem] ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible]) VALUES (@Page, 'Home', 'Home', 1, @Parent, @Position, 0)

SET @MenuItem = SCOPE_IDENTITY()
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)


SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')

INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)

GO




DECLARE @Page As int 
DECLARE @MenuItem AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Parent] IS NULL AND [Page] = @Page)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Coordinator')


INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Coordinator')

INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

DECLARE @ParentPage As int 
DECLARE @Page AS int 
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Position AS int 
DECLARE @Role AS int


SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/Home.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Parent] IS NULL AND [Page] = @ParentPage)
SET @MenuItem  = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Parent] = @Parent AND [Page] = @Page)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Coordinator')

INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

DECLARE @ParentPage As int 
DECLARE @Page AS int 
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Position AS int 
DECLARE @Role AS int


SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/Home.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Parent] IS NULL AND [Page] = @ParentPage)
SET @MenuItem  = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Parent] = @Parent AND [Page] = @Page)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Coordinator')

INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO


DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @Parent AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/Home.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Parent] IS NULL AND [Page] = @ParentPage)

UPDATE [dbo].[MenuItem] SET [Page] = @Page WHERE [ID] = @Parent
GO

--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 04/17/2014 14:17:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewOrderDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewOrderDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 04/17/2014 14:17:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_ViewOrderDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',
	@P_OrderStatus AS NVARCHAR(255) = '',
	@P_Sort AS int = 0, --0 CreatedDate,--1 VL, --2 Pattern Number, --3 Order Detail Type, --4  Order Detail Status, --5 Old Po No, --6 Coordinator, --7 Distributor, --8 Client, --9 Order Status
	@P_OrderBy AS bit = 1,  -- 0 ASC , -- 1 DESC
	@P_Set AS int = 0,
	@P_MaxRows AS int = 20,
	@P_RecCount int OUTPUT,
	@P_LogCompanyID AS int = 0,
	@P_Status AS nvarchar(255),
	@P_Coordinator AS NVARCHAR(255) = '',
	@P_Distributor AS NVARCHAR(255) = '',
	@P_Clients AS NVARCHAR(255) = '',
	@P_SelectedDate1 AS datetime2(7) = NULL,
	@P_SelectedDate2 AS datetime2(7) = NULL
	 
)
AS
BEGIN

	SET NOCOUNT ON
	DECLARE @Orders TABLE
	(
    OrderID int NOT NULL
	);
	DECLARE @StartOffset AS int;
	DECLARE @orderid AS int;
	SET @StartOffset = (@P_Set - 1) * @P_MaxRows;	
	
	IF (ISNUMERIC(@P_SearchText) = 1) 
		BEGIN
			SET @orderid = CONVERT(INT, @P_SearchText)		
		END
	ELSE
		BEGIN	
			SET @orderid = 0
		END;
	
	--WITH Orders AS
	--	(
		--SELECT
		/*SELECT DISTINCT TOP (@P_Set * @P_MaxRows)
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
									WHERE os.[ID] IN (SELECT DATA FROM [dbo].Split((@P_Status),',')) AND
										  (@P_SearchText = '' OR
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
										  (@P_LogCompanyID = 0 OR c.[ID] = @P_LogCompanyID)	AND
										  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
										  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
										  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
										  ((@P_SelectedDate1 IS NULL AND @P_SelectedDate2 IS NULL) OR (od.[SheduledDate] BETWEEN @P_SelectedDate1 AND @P_SelectedDate2))									  
								    GROUP BY o.[ID]*/
	--	)
	
	--INSERT INTO @Orders ([OrderID]) 
	--SELECT  ID FROM Orders WHERE Number > @StartOffset;	
	 
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
			WHERE os.[ID] IN (SELECT DATA FROM [dbo].Split((@P_Status),',')) AND
				  (@P_SearchText = '' OR
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
				  (@P_LogCompanyID = 0 OR c.[ID] = @P_LogCompanyID)	AND
				  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
				  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
				  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
				  ((@P_SelectedDate1 IS NULL AND @P_SelectedDate2 IS NULL) OR (od.[SheduledDate] BETWEEN @P_SelectedDate1 AND @P_SelectedDate2))
			ORDER BY o.[ID] DESC
		--)*/
	--SELECT * FROM Orders --WHERE ID > @StartOffset
	
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
													WHERE os.[ID] IN (SELECT DATA FROM [dbo].Split((@P_Status),',')) AND
														  (@P_SearchText = '' OR
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
														  (@P_LogCompanyID = 0 OR c.[ID] = @P_LogCompanyID)AND
														  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
														  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
														  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%')AND
														  ((@P_SelectedDate1 IS NULL AND @P_SelectedDate2 IS NULL) OR (od.[SheduledDate] BETWEEN @P_SelectedDate1 AND @P_SelectedDate2))) ord*/
		--END
	--ELSE
		--BEGIN
			SET @P_RecCount = 0
		--END			
END

GO
--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***--***-***


