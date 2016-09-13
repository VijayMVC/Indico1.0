

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 03/31/2015 15:29:19 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetailsView]'))
DROP VIEW [dbo].[OrderDetailsView]
GO


/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 03/31/2015 15:29:19 ******/
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
				  0 AS ResolutionProfile,
				  CONVERT(bit,0) AS IsAcceptedTermsAndConditions

GO


/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 03/31/2015 15:36:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewOrderDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewOrderDetails]
GO


/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 03/31/2015 15:36:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SPC_ViewOrderDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',
	@P_LogCompanyID AS int = 0,
	@P_Status AS nvarchar(255),
	@P_Coordinator AS int = 0,
	@P_Distributor AS int = 0,
	@P_Client AS int = 0,
	@P_SelectedDate1 AS datetime2(7) = NULL,
	@P_SelectedDate2 AS datetime2(7) = NULL,
	@P_DistributorClientAddress AS int = 0
	 
)
AS
BEGIN

	SET NOCOUNT ON
	DECLARE @orderid AS int;
	DECLARE @status AS TABLE ( ID int )
	
	IF (ISNUMERIC(@P_SearchText) = 1) 
		BEGIN
			SET @orderid = CONVERT(INT, @P_SearchText)		
		END
	ELSE
		BEGIN	
			SET @orderid = 0
		END;
	
	INSERT INTO @status (ID) SELECT DATA FROM [dbo].Split(@P_Status,',');
	
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
		  ,ISNULL(o.[Label], 0) AS Label
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
		  ,o.[IsAcceptedTermsAndConditions] AS IsAcceptedTermsAndConditions
	  FROM [dbo].[Order] o				
		LEFT OUTER JOIN [dbo].[OrderStatus] os
			ON o.[Status] = os.[ID]
		LEFT OUTER JOIN [dbo].[Company] c
			ON o.[Distributor] = c.[ID]
		LEFT OUTER JOIN [dbo].[User] u
			ON c.[Coordinator] = u.[ID]		
		LEFT OUTER JOIN [dbo].[PaymentMethod] pm
			ON o.[PaymentMethod] = pm.[ID]
		LEFT OUTER JOIN [dbo].[ShipmentMode] sm
			ON o.[ShipmentMode] = sm.[ID]					
		LEFT OUTER JOIN [dbo].[Client] cl
			ON o.[Client] = cl.[ID]				
		LEFT OUTER JOIN [dbo].[User] urc
			ON o.[Creator] = urc.[ID]
		LEFT OUTER JOIN [dbo].[User] urm
			ON o.[Modifier] = urm.[ID]
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
			ON o.[DespatchToExistingClient] = dca.[ID]	
		LEFT OUTER JOIN [dbo].[Country] co
			ON dca.[Country] = co.[ID]
		LEFT OUTER JOIN [dbo].[DestinationPort] dp
			ON dca.[Port] = dp.[ID] 		
		INNER JOIN [dbo].[OrderDetail] od				
			ON o.[ID] = od.[Order]				
		LEFT OUTER JOIN [dbo].[VisualLayout] vl
			ON od.[VisualLayout] = vl.[ID]
		LEFT OUTER JOIN [dbo].[Pattern] p 
			ON od.[Pattern] = p.[ID]
		LEFT OUTER JOIN [dbo].[FabricCode] fc
			ON od.[FabricCode] = fc.[ID]
		LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
			ON od.[Status] = ods.[ID]
		LEFT OUTER JOIN [dbo].[OrderType] ot
			ON od.[OrderType] = ot.[ID]
	WHERE (@P_SearchText = '' OR
			o.[ID] = @orderid OR
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
		   fc.[Name] LIKE '%' + @P_SearchText + '%'  
			)AND
		   (@P_Status = '' OR  (os.[ID] IN (SELECT ID FROM @status)) )  AND											   
		  (@P_LogCompanyID = 0 OR c.[ID] = @P_LogCompanyID)	AND
		  (@P_Coordinator = 0 OR c.[Coordinator] = @P_Coordinator ) AND				  
		  (@P_Distributor = 0 OR o.Distributor = @P_Distributor)	AND
		  (@P_Client = 0 OR o.[Client] = @P_Client) AND				  
		  (@P_DistributorClientAddress = 0 OR o.[DespatchToExistingClient] = @P_DistributorClientAddress) AND
		  ((@P_SelectedDate1 IS NULL AND @P_SelectedDate2 IS NULL) OR (od.[SheduledDate] BETWEEN @P_SelectedDate1 AND @P_SelectedDate2))
	--ORDER BY o.[ID] DESC
				
END





GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 03/31/2015 15:37:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyFirmOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders]
GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 03/31/2015 15:37:42 ******/
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
	@P_Clients AS NVARCHAR(255) = '',
	@P_DistributorClientAddress AS int = 0
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
				  ,ISNULL(o.[Label], 0) AS Label
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
					,o.[IsAcceptedTermsAndConditions] AS IsAcceptedTermsAndConditions
			 FROM [Indico].[dbo].[OrderDetail] od
				LEFT OUTER JOIN [dbo].[Order] o
					ON od.[Order] = o.[ID]
				LEFT OUTER JOIN [dbo].[VisualLayout] vl
					ON od.[VisualLayout] = vl.[ID]
				LEFT OUTER JOIN [dbo].[Pattern] p 
					ON od.[Pattern] = p.[ID]
				JOIN [dbo].[FabricCode] fc
					ON od.[FabricCode] = fc.[ID]
				LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
					ON od.[Status] = ods.[ID]
				LEFT OUTER JOIN [dbo].[OrderType] ot
					ON od.[OrderType] = ot.[ID]
				LEFT OUTER JOIN [dbo].[Company] c
					ON c.[ID] = o.[Distributor]
				LEFT OUTER JOIN [dbo].[User] u
					ON c.[Coordinator] = u.[ID]
				LEFT OUTER JOIN [dbo].[Client] cl
					ON o.[Client] = cl.[ID]
				LEFT OUTER JOIN [dbo].[OrderStatus] os
					ON o.[Status] = os.[ID]
				LEFT OUTER JOIN [dbo].[User] urc
					ON o.[Creator] = urc.[ID]
				LEFT OUTER JOIN [dbo].[User] urm
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
				  (@P_DistributorClientAddress = 0 OR o.[DespatchToExistingClient] = @P_DistributorClientAddress) AND
				  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped' OR [Name] = 'Waiting Info')))
							
	
			SET @P_RecCount = 0
	
		
END



GO



/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 03/31/2015 15:41:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyReservationOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders]
GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 03/31/2015 15:41:18 ******/
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
	@P_Clients AS NVARCHAR(255) = '',
	@P_DistributorClientAddress AS int = 0
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
				  ,ISNULL(o.[Label], 0) AS Label
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
				  ,o.[IsAcceptedTermsAndConditions] AS IsAcceptedTermsAndConditions
			  FROM [Indico].[dbo].[OrderDetail] od
					LEFT OUTER JOIN [dbo].[Order] o
						ON od.[Order] = o.[ID]
					LEFT OUTER JOIN [dbo].[VisualLayout] vl
						ON od.[VisualLayout] = vl.[ID]
					LEFT OUTER JOIN [dbo].[Pattern] p 
						ON od.[Pattern] = p.[ID]
					LEFT OUTER JOIN [dbo].[FabricCode] fc
						ON od.[FabricCode] = fc.[ID]
					LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
						ON od.[Status] = ods.[ID]
					LEFT OUTER JOIN [dbo].[OrderType] ot
						ON od.[OrderType] = ot.[ID]
					LEFT OUTER JOIN [dbo].[Company] c
						ON c.[ID] = o.[Distributor]
					LEFT OUTER JOIN [dbo].[User] u
						ON c.[Coordinator] = u.[ID]
					LEFT OUTER JOIN [dbo].[Client] cl
						ON o.[Client] = cl.[ID]
					LEFT OUTER JOIN [dbo].[OrderStatus] os
						ON o.[Status] = os.[ID]
					LEFT OUTER JOIN [dbo].[User] urc
						ON o.[Creator] = urc.[ID]
					LEFT OUTER JOIN [dbo].[User] urm
						ON o.[Modifier] = urm.[ID] 
					LEFT OUTER JOIN [dbo].[Reservation] res
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
					  (@P_DistributorClientAddress = 0 OR o.[DespatchToExistingClient] = @P_DistributorClientAddress) AND
					  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped' OR [Name] = 'Waiting Info')))
										  
		
	
			SET @P_RecCount = 0
END




GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 03/31/2015 15:42:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklySampleOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklySampleOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 03/31/2015 15:42:35 ******/
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
	@P_Clients AS NVARCHAR(255) = '',
	@P_DistributorClientAddress AS int = 0
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
				  ,ISNULL(o.[Label], 0) AS Label
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
				  ,o.[IsAcceptedTermsAndConditions] AS IsAcceptedTermsAndConditions
			  FROM [Indico].[dbo].[OrderDetail] od
				LEFT OUTER JOIN [dbo].[Order] o
					ON od.[Order] = o.[ID]
				LEFT OUTER JOIN [dbo].[VisualLayout] vl
					ON od.[VisualLayout] = vl.[ID]
				LEFT OUTER JOIN [dbo].[Pattern] p 
					ON od.[Pattern] = p.[ID]
				LEFT OUTER JOIN [dbo].[FabricCode] fc
					ON od.[FabricCode] = fc.[ID]
				LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
					ON od.[Status] = ods.[ID]
				LEFT OUTER JOIN [dbo].[OrderType] ot
					ON od.[OrderType] = ot.[ID]
				LEFT OUTER JOIN [dbo].[Company] c
					ON c.[ID] = o.[Distributor]
				LEFT OUTER JOIN [dbo].[User] u
					ON c.[Coordinator] = u.[ID]
				LEFT OUTER JOIN [dbo].[Client] cl
					ON o.[Client] = cl.[ID]
				LEFT OUTER JOIN [dbo].[OrderStatus] os
					ON o.[Status] = os.[ID]
				LEFT OUTER JOIN [dbo].[User] urc
					ON o.[Creator] = urc.[ID]
				LEFT OUTER JOIN [dbo].[User] urm
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
		           (od.[OrderType] IN ((SELECT odt.[ID] FROM [Indico].[dbo].[OrderType] odt WHERE odt.[Name] = 'SAMPLE' OR odt.[Name] = 'DEV SAMPLE'))) AND
				  (@P_OrderStatus = '' OR os.[Name] LIKE '%' + @P_OrderStatus + '%') AND
				  (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))AND
				  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
				  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
				  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
				  (@P_DistributorClientAddress = 0 OR o.[DespatchToExistingClient] = @P_DistributorClientAddress) AND
				  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped' OR [Name] = 'Waiting Info')))										
	
			SET @P_RecCount = 0		

END


GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 03/31/2015 15:43:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyJacketOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyJacketOrders]
GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 03/31/2015 15:43:42 ******/
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
	@P_Clients AS NVARCHAR(255) = '',
	@P_DistributorClientAddress AS int = 0
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
				  ,ISNULL(o.[Label], 0) AS Label
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
				  ,o.[IsAcceptedTermsAndConditions] AS IsAcceptedTermsAndConditions
			  FROM [Indico].[dbo].[OrderDetail] od
						LEFT OUTER JOIN [dbo].[Order] o
							ON od.[Order] = o.[ID]
						LEFT OUTER JOIN [dbo].[VisualLayout] vl
							ON od.[VisualLayout] = vl.[ID]
						LEFT OUTER JOIN [dbo].[Pattern] p 
							ON od.[Pattern] = p.[ID]
						LEFT OUTER JOIN [dbo].[FabricCode] fc
							ON od.[FabricCode] = fc.[ID]
						LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
							ON od.[Status] = ods.[ID]
						LEFT OUTER JOIN [dbo].[OrderType] ot
							ON od.[OrderType] = ot.[ID]
						LEFT OUTER JOIN [dbo].[Company] c
							ON c.[ID] = o.[Distributor]
						LEFT OUTER JOIN [dbo].[User] u
							ON c.[Coordinator] = u.[ID]
						LEFT OUTER JOIN [dbo].[Client] cl
							ON o.[Client] = cl.[ID]
						LEFT OUTER JOIN [dbo].[OrderStatus] os
							ON o.[Status] = os.[ID]
						LEFT OUTER JOIN [dbo].[User] urc
							ON o.[Creator] = urc.[ID]
						LEFT OUTER JOIN [dbo].[User] urm
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
					  (p.[Item] IN((SELECT i.[ID] FROM [Indico].[dbo].[Item] i WHERE i.[Name] LIKE '%JACKET%' AND i.[Parent] IS NULL))) AND
					  (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))AND
					  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
					  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
					  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
					  (@P_DistributorClientAddress = 0 OR o.[DespatchToExistingClient] = @P_DistributorClientAddress) AND				  
					  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped' OR [Name] = 'Waiting Info')))								
							
			
			SET @P_RecCount = 0					
END 


GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 03/31/2015 15:46:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyLessFiveItemOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyLessFiveItemOrders]
GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 03/31/2015 15:46:47 ******/
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
	@P_Clients AS NVARCHAR(255) = '',
	@P_DistributorClientAddress AS int = 0
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
				  ,ISNULL(o.[Label], 0) AS Label
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
				  ,o.[IsAcceptedTermsAndConditions] AS IsAcceptedTermsAndConditions
			 		FROM [Indico].[dbo].[OrderDetail] od
							LEFT OUTER JOIN [dbo].[Order] o
								ON od.[Order] = o.[ID]
							LEFT OUTER JOIN [dbo].[VisualLayout] vl
								ON od.[VisualLayout] = vl.[ID]
							LEFT OUTER JOIN [dbo].[Pattern] p 
								ON od.[Pattern] = p.[ID]
							LEFT OUTER JOIN [dbo].[FabricCode] fc
								ON od.[FabricCode] = fc.[ID]
							LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
								ON od.[Status] = ods.[ID]
							LEFT OUTER JOIN [dbo].[OrderType] ot
								ON od.[OrderType] = ot.[ID]
							LEFT OUTER JOIN [dbo].[Company] c
								ON c.[ID] = o.[Distributor]
							LEFT OUTER JOIN [dbo].[User] u
								ON c.[Coordinator] = u.[ID]
							LEFT OUTER JOIN [dbo].[Client] cl
								ON o.[Client] = cl.[ID]
							LEFT OUTER JOIN [dbo].[OrderStatus] os
								ON o.[Status] = os.[ID]
							LEFT OUTER JOIN [dbo].[User] urc
								ON o.[Creator] = urc.[ID]
							LEFT OUTER JOIN [dbo].[User] urm
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
							(@P_DistributorClientAddress = 0 OR o.[DespatchToExistingClient] = @P_DistributorClientAddress) AND
							(od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped' OR [Name] = 'Waiting Info')))
	
			SET @P_RecCount = 0
END


GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 03/31/2015 15:48:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyReservationOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 03/31/2015 15:48:05 ******/
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
	@P_Clients AS NVARCHAR(255) = '',
	@P_DistributorClientAddress AS int = 0
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
				  ,ISNULL(o.[Label], 0) AS Label
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
				  ,o.[IsAcceptedTermsAndConditions] AS IsAcceptedTermsAndConditions
			  FROM [Indico].[dbo].[OrderDetail] od
					LEFT OUTER JOIN [dbo].[Order] o
						ON od.[Order] = o.[ID]
					LEFT OUTER JOIN [dbo].[VisualLayout] vl
						ON od.[VisualLayout] = vl.[ID]
					LEFT OUTER JOIN [dbo].[Pattern] p 
						ON od.[Pattern] = p.[ID]
					LEFT OUTER JOIN [dbo].[FabricCode] fc
						ON od.[FabricCode] = fc.[ID]
					LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
						ON od.[Status] = ods.[ID]
					LEFT OUTER JOIN [dbo].[OrderType] ot
						ON od.[OrderType] = ot.[ID]
					LEFT OUTER JOIN [dbo].[Company] c
						ON c.[ID] = o.[Distributor]
					LEFT OUTER JOIN [dbo].[User] u
						ON c.[Coordinator] = u.[ID]
					LEFT OUTER JOIN [dbo].[Client] cl
						ON o.[Client] = cl.[ID]
					LEFT OUTER JOIN [dbo].[OrderStatus] os
						ON o.[Status] = os.[ID]
					LEFT OUTER JOIN [dbo].[User] urc
						ON o.[Creator] = urc.[ID]
					LEFT OUTER JOIN [dbo].[User] urm
						ON o.[Modifier] = urm.[ID] 
					LEFT OUTER JOIN [dbo].[Reservation] res
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
					  (@P_DistributorClientAddress = 0 OR o.[DespatchToExistingClient] = @P_DistributorClientAddress) AND
					  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped' OR [Name] = 'Waiting Info')))
										  
		
	
			SET @P_RecCount = 0
END




GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyHoldOrders]    Script Date: 03/31/2015 15:49:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyHoldOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyHoldOrders]
GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyHoldOrders]    Script Date: 03/31/2015 15:49:28 ******/
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
	@P_Clients AS NVARCHAR(255) = '',
	@P_DistributorClientAddress AS int = 0
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
				  ,ISNULL(o.[Label], 0) AS Label
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
				  ,o.[IsAcceptedTermsAndConditions] AS IsAcceptedTermsAndConditions
			  FROM [Indico].[dbo].[OrderDetail] od
				LEFT OUTER JOIN [dbo].[Order] o
					ON od.[Order] = o.[ID]
				LEFT OUTER JOIN [dbo].[VisualLayout] vl
					ON od.[VisualLayout] = vl.[ID]
				LEFT OUTER JOIN [dbo].[Pattern] p 
					ON od.[Pattern] = p.[ID]
				LEFT OUTER JOIN [dbo].[FabricCode] fc
					ON od.[FabricCode] = fc.[ID]
				LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
					ON od.[Status] = ods.[ID]
				LEFT OUTER JOIN [dbo].[OrderType] ot
					ON od.[OrderType] = ot.[ID]
				LEFT OUTER JOIN [dbo].[Company] c
					ON c.[ID] = o.[Distributor]
				LEFT OUTER JOIN [dbo].[User] u
					ON c.[Coordinator] = u.[ID]
				LEFT OUTER JOIN [dbo].[Client] cl
					ON o.[Client] = cl.[ID]
				LEFT OUTER JOIN [dbo].[OrderStatus] os
					ON o.[Status] = os.[ID]
				LEFT OUTER JOIN [dbo].[User] urc
					ON o.[Creator] = urc.[ID]
				LEFT OUTER JOIN [dbo].[User] urm
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
				  (@P_DistributorClientAddress = 0 OR o.[DespatchToExistingClient] = @P_DistributorClientAddress) AND
				  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped' OR [Name] = 'Waiting Info')))										
		
END


GO
