USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 03/27/2014 11:42:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewOrderDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewOrderDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 03/27/2014 11:42:42 ******/
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

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 03/27/2014 14:00:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyFirmOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 03/27/2014 14:00:08 ******/
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

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 03/27/2014 14:58:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyJacketOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyJacketOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 03/27/2014 14:58:48 ******/
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
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 03/27/2014 15:06:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyLessFiveItemOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyLessFiveItemOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 03/27/2014 15:06:25 ******/
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

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 03/27/2014 15:12:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyReservationOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 03/27/2014 15:12:42 ******/
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

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 03/27/2014 15:17:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklySampleOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklySampleOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 03/27/2014 15:17:45 ******/
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
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 03/27/2014 15:27:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ProductionCapacities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ProductionCapacities]
GO
/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 03/27/2014 15:27:58 ******/
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
						WHERE (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)
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
			WHERE (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)
			AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))),
		-- Resevation quantities
		(	SELECT DISTINCT ISNULL(SUM(r.Qty), 0) AS Resevations 
			FROM [Order] o
				JOIN [OrderDetail] od
					on o.[ID] = od.[Order]
				JOIN Reservation r
					ON o.Reservation = r.ID 
			WHERE (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)
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
																HAVING SUM(odq.Qty) <= 5)AND (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)
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
											AND  (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)
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
																	AND (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)
																	AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))))

	)
	
	SELECT * FROM @Capacities

END


GO

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**



/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyHoldOrders]    Script Date: 03/28/2014 10:16:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyHoldOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyHoldOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyHoldOrders]    Script Date: 03/28/2014 10:16:25 ******/
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
		          ((o.[Status] = (SELECT os.[ID] FROM [dbo].[OrderStatus] os WHERE os.[Name] = 'Indiman Hold'))OR
		           (o.[Status] = (SELECT os.[ID] FROM [dbo].[OrderStatus] os WHERE os.[Name] = 'Indico Hold'))) AND
				  (@P_OrderStatus = '' OR os.[Name] LIKE '%' + @P_OrderStatus + '%') AND
				  (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)AND
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


--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**
INSERT INTO [Indico].[dbo].[WeeklyProductionCapacity]
           ([WeekNo]
           ,[WeekendDate]
           ,[Capacity]
           ,[Notes]
           ,[NoOfHolidays])
     VALUES
           (53
           ,'2016-12-30 00:00:00.0000000'
           ,0
           ,NULL
           ,0)
GO

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**




