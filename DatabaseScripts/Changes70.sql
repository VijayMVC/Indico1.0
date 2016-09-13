USE [Indico]
GO


/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 10/16/2013 10:54:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewOrderDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewOrderDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 10/16/2013 10:54:15 ******/
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
	
	WITH Orders AS
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
								    GROUP BY o.[ID]
		)
	
	INSERT INTO @Orders ([OrderID]) 
	SELECT  ID FROM Orders WHERE Number > @StartOffset;	
	 
	WITH OrderDetails AS
		(
			SELECT 			
				CONVERT(int, ROW_NUMBER() OVER (
				ORDER BY 
					CASE 
						WHEN (@p_Sort = 0 AND @p_OrderBy = 0) THEN o.[CreatedDate]
					END ASC,
					CASE						
						WHEN (@p_Sort = 0 AND @p_OrderBy = 1) THEN o.[CreatedDate]
					END DESC,
					CASE 
						WHEN (@p_Sort = 1 AND @p_OrderBy = 0) THEN vl.[NamePrefix]
					END ASC,
					CASE						
						WHEN (@p_Sort = 1 AND @p_OrderBy = 1) THEN vl.[NamePrefix]
					END DESC,
					CASE 
						WHEN (@p_Sort = 2 AND @p_OrderBy = 0) THEN p.[Number]
					END ASC,
					CASE						
						WHEN (@p_Sort = 2 AND @p_OrderBy = 1) THEN p.[Number]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 3 AND @p_OrderBy = 0) THEN ot.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 3 AND @p_OrderBy = 1) THEN ot.[Name]
					END DESC,
					CASE 
						WHEN (@p_Sort = 4 AND @p_OrderBy = 0) THEN ods.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 4 AND @p_OrderBy = 1) THEN ods.[Name]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 5 AND @p_OrderBy = 0) THEN o.[OldPONo]
					END ASC,
					CASE						
						WHEN (@p_Sort = 5 AND @p_OrderBy = 1) THEN o.[OldPONo]
					END DESC,
					CASE 
						WHEN (@p_Sort = 6 AND @p_OrderBy = 0) THEN u.[GivenName]
					END ASC,
					CASE						
						WHEN (@p_Sort = 6 AND @p_OrderBy = 1) THEN u.[GivenName]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 7 AND @p_OrderBy = 0) THEN c.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 7 AND @p_OrderBy = 1) THEN c.[Name]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 8 AND @p_OrderBy = 0) THEN cl.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 8 AND @p_OrderBy = 1) THEN cl.[Name]
					END DESC,
					CASE 
						WHEN (@p_Sort = 9 AND @p_OrderBy = 0) THEN os.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 9 AND @p_OrderBy = 1) THEN os.[Name]
					END DESC			
					)) AS ID
				  , od.[ID] AS OrderDetail
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
			WHERE  o.[ID] IN (SELECT [OrderID] FROM @Orders) AND
				   (@orderid = 0 OR o.[ID] = @orderid)
		)
	SELECT * FROM OrderDetails --WHERE ID > @StartOffset
	
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
														  ((@P_SelectedDate1 IS NULL AND @P_SelectedDate2 IS NULL) OR (od.[SheduledDate] BETWEEN @P_SelectedDate1 AND @P_SelectedDate2))) ord
		END
	ELSE
		BEGIN
			SET @P_RecCount = 0
		END			
END

GO

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**
/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 10/16/2013 13:59:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyFirmOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 10/16/2013 13:59:31 ******/
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
		
		WITH Orders AS
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
										  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') 
								      GROUP BY o.[ID]
		 )
	
	INSERT INTO @Orders ([OrderID]) 
	SELECT  ID FROM Orders WHERE Number > @StartOffset;	
	
													
	
	WITH OrderDetails AS
		(
			SELECT 			
				CONVERT(int, ROW_NUMBER() OVER (
				ORDER BY 
					CASE 
						WHEN (@p_Sort = 0 AND @p_OrderBy = 0) THEN o.[CreatedDate]
					END ASC,
					CASE						
						WHEN (@p_Sort = 0 AND @p_OrderBy = 1) THEN o.[CreatedDate]
					END DESC,
					CASE 
						WHEN (@p_Sort = 1 AND @p_OrderBy = 0) THEN vl.[NamePrefix]
					END ASC,
					CASE						
						WHEN (@p_Sort = 1 AND @p_OrderBy = 1) THEN vl.[NamePrefix]
					END DESC,
					CASE 
						WHEN (@p_Sort = 2 AND @p_OrderBy = 0) THEN p.[Number]
					END ASC,
					CASE						
						WHEN (@p_Sort = 2 AND @p_OrderBy = 1) THEN p.[Number]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 3 AND @p_OrderBy = 0) THEN ot.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 3 AND @p_OrderBy = 1) THEN ot.[Name]
					END DESC,
					CASE 
						WHEN (@p_Sort = 4 AND @p_OrderBy = 0) THEN ods.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 4 AND @p_OrderBy = 1) THEN ods.[Name]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 5 AND @p_OrderBy = 0) THEN o.[OldPONo]
					END ASC,
					CASE						
						WHEN (@p_Sort = 5 AND @p_OrderBy = 1) THEN o.[OldPONo]
					END DESC,
					CASE 
						WHEN (@p_Sort = 6 AND @p_OrderBy = 0) THEN u.[GivenName]
					END ASC,
					CASE						
						WHEN (@p_Sort = 6 AND @p_OrderBy = 1) THEN u.[GivenName]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 7 AND @p_OrderBy = 0) THEN c.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 7 AND @p_OrderBy = 1) THEN c.[Name]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 8 AND @p_OrderBy = 0) THEN cl.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 8 AND @p_OrderBy = 1) THEN cl.[Name]
					END DESC,
					CASE 
						WHEN (@p_Sort = 9 AND @p_OrderBy = 0) THEN os.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 9 AND @p_OrderBy = 1) THEN os.[Name]
					END DESC			
					)) AS ID
				  , od.[ID] AS OrderDetail
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
			WHERE  o.[ID] IN (SELECT [OrderID] FROM @Orders) AND
				   (@orderid = 0 OR o.[ID] = @orderid)
							
		)
	SELECT * FROM OrderDetails --WHERE ID > @StartOffset
	
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
														  (@P_OrderStatus = '' OR os.[Name] LIKE '%' + @P_OrderStatus + '%') AND
												          (o.[Reservation] IS NULL) AND
												          (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)AND
														  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
														  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
														  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%')) ord
		END
	ELSE
		BEGIN
			SET @P_RecCount = 0
		END	
		
END
GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 10/16/2013 14:06:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyJacketOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyJacketOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 10/16/2013 14:06:26 ******/
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
		
		WITH Orders AS
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
						  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%')
					GROUP BY  o.[ID]
		 )
	
		INSERT INTO @Orders ([OrderID]) 
		SELECT  ID FROM Orders WHERE Number > @StartOffset;	
	
	WITH OrderDetails AS
		(
			SELECT 			
				CONVERT(int, ROW_NUMBER() OVER (
				ORDER BY 
					CASE 
						WHEN (@p_Sort = 0 AND @p_OrderBy = 0) THEN o.[CreatedDate]
					END ASC,
					CASE						
						WHEN (@p_Sort = 0 AND @p_OrderBy = 1) THEN o.[CreatedDate]
					END DESC,
					CASE 
						WHEN (@p_Sort = 1 AND @p_OrderBy = 0) THEN vl.[NamePrefix]
					END ASC,
					CASE						
						WHEN (@p_Sort = 1 AND @p_OrderBy = 1) THEN vl.[NamePrefix]
					END DESC,
					CASE 
						WHEN (@p_Sort = 2 AND @p_OrderBy = 0) THEN p.[Number]
					END ASC,
					CASE						
						WHEN (@p_Sort = 2 AND @p_OrderBy = 1) THEN p.[Number]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 3 AND @p_OrderBy = 0) THEN ot.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 3 AND @p_OrderBy = 1) THEN ot.[Name]
					END DESC,
					CASE 
						WHEN (@p_Sort = 4 AND @p_OrderBy = 0) THEN ods.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 4 AND @p_OrderBy = 1) THEN ods.[Name]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 5 AND @p_OrderBy = 0) THEN o.[OldPONo]
					END ASC,
					CASE						
						WHEN (@p_Sort = 5 AND @p_OrderBy = 1) THEN o.[OldPONo]
					END DESC,
					CASE 
						WHEN (@p_Sort = 6 AND @p_OrderBy = 0) THEN u.[GivenName]
					END ASC,
					CASE						
						WHEN (@p_Sort = 6 AND @p_OrderBy = 1) THEN u.[GivenName]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 7 AND @p_OrderBy = 0) THEN c.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 7 AND @p_OrderBy = 1) THEN c.[Name]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 8 AND @p_OrderBy = 0) THEN cl.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 8 AND @p_OrderBy = 1) THEN cl.[Name]
					END DESC,
					CASE 
						WHEN (@p_Sort = 9 AND @p_OrderBy = 0) THEN os.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 9 AND @p_OrderBy = 1) THEN os.[Name]
					END DESC			
					)) AS ID
				  , od.[ID] AS OrderDetail
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
			WHERE  o.[ID] IN (SELECT [OrderID] FROM @Orders) AND
				   (@orderid = 0 OR o.[ID] = @orderid) AND
				   (p.[Item] = (SELECT i.[ID] FROM [Indico].[dbo].[Item] i WHERE i.[Name] = 'JACKET' AND i.[Parent] IS NULL))					
		)
	SELECT * FROM OrderDetails --WHERE ID > @StartOffset
	
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
														  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%'))ord
		END
	ELSE
		BEGIN
			SET @P_RecCount = 0
		END					
END 
GO

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 10/16/2013 15:11:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyLessFiveItemOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyLessFiveItemOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 10/16/2013 15:11:59 ******/
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
		
		WITH Orders AS
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
							(@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%')
						GROUP BY  o.[ID]
			)
			
		INSERT INTO @Orders ([OrderID]) 
		SELECT  ID FROM Orders WHERE Number > @StartOffset;	
	
	
	WITH OrderDetails AS
		(
			SELECT 			
				CONVERT(int, ROW_NUMBER() OVER (
				ORDER BY 
					CASE 
						WHEN (@p_Sort = 0 AND @p_OrderBy = 0) THEN o.[CreatedDate]
					END ASC,
					CASE						
						WHEN (@p_Sort = 0 AND @p_OrderBy = 1) THEN o.[CreatedDate]
					END DESC,
					CASE 
						WHEN (@p_Sort = 1 AND @p_OrderBy = 0) THEN vl.[NamePrefix]
					END ASC,
					CASE						
						WHEN (@p_Sort = 1 AND @p_OrderBy = 1) THEN vl.[NamePrefix]
					END DESC,
					CASE 
						WHEN (@p_Sort = 2 AND @p_OrderBy = 0) THEN p.[Number]
					END ASC,
					CASE						
						WHEN (@p_Sort = 2 AND @p_OrderBy = 1) THEN p.[Number]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 3 AND @p_OrderBy = 0) THEN ot.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 3 AND @p_OrderBy = 1) THEN ot.[Name]
					END DESC,
					CASE 
						WHEN (@p_Sort = 4 AND @p_OrderBy = 0) THEN ods.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 4 AND @p_OrderBy = 1) THEN ods.[Name]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 5 AND @p_OrderBy = 0) THEN o.[OldPONo]
					END ASC,
					CASE						
						WHEN (@p_Sort = 5 AND @p_OrderBy = 1) THEN o.[OldPONo]
					END DESC,
					CASE 
						WHEN (@p_Sort = 6 AND @p_OrderBy = 0) THEN u.[GivenName]
					END ASC,
					CASE						
						WHEN (@p_Sort = 6 AND @p_OrderBy = 1) THEN u.[GivenName]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 7 AND @p_OrderBy = 0) THEN c.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 7 AND @p_OrderBy = 1) THEN c.[Name]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 8 AND @p_OrderBy = 0) THEN cl.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 8 AND @p_OrderBy = 1) THEN cl.[Name]
					END DESC,
					CASE 
						WHEN (@p_Sort = 9 AND @p_OrderBy = 0) THEN os.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 9 AND @p_OrderBy = 1) THEN os.[Name]
					END DESC			
					)) AS ID
				  , od.[ID] AS OrderDetail
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
			WHERE  o.[ID] IN (SELECT [OrderID] FROM @Orders) AND
				   (@orderid = 0 OR od.[ID] = @orderid)
		)
	SELECT * FROM OrderDetails --WHERE ID > @StartOffset
	
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
														(@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%')) ord
		END
	ELSE
		BEGIN
			SET @P_RecCount = 0
		END	
END
GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**
/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 10/16/2013 15:23:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyReservationOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders]
GO
/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 10/16/2013 15:23:23 ******/
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
		
		WITH Orders AS
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
										  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%')
										  
									GROUP BY o.[ID]
			)
	
		INSERT INTO @Orders ([OrderID]) 
		SELECT  ID FROM Orders WHERE Number > @StartOffset;	
	
	WITH OrderDetails AS
		(
			SELECT 			
				CONVERT(int, ROW_NUMBER() OVER (
				ORDER BY 
					CASE 
						WHEN (@p_Sort = 0 AND @p_OrderBy = 0) THEN o.[CreatedDate]
					END ASC,
					CASE						
						WHEN (@p_Sort = 0 AND @p_OrderBy = 1) THEN o.[CreatedDate]
					END DESC,
					CASE 
						WHEN (@p_Sort = 1 AND @p_OrderBy = 0) THEN vl.[NamePrefix]
					END ASC,
					CASE						
						WHEN (@p_Sort = 1 AND @p_OrderBy = 1) THEN vl.[NamePrefix]
					END DESC,
					CASE 
						WHEN (@p_Sort = 2 AND @p_OrderBy = 0) THEN p.[Number]
					END ASC,
					CASE						
						WHEN (@p_Sort = 2 AND @p_OrderBy = 1) THEN p.[Number]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 3 AND @p_OrderBy = 0) THEN ot.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 3 AND @p_OrderBy = 1) THEN ot.[Name]
					END DESC,
					CASE 
						WHEN (@p_Sort = 4 AND @p_OrderBy = 0) THEN ods.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 4 AND @p_OrderBy = 1) THEN ods.[Name]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 5 AND @p_OrderBy = 0) THEN o.[OldPONo]
					END ASC,
					CASE						
						WHEN (@p_Sort = 5 AND @p_OrderBy = 1) THEN o.[OldPONo]
					END DESC,
					CASE 
						WHEN (@p_Sort = 6 AND @p_OrderBy = 0) THEN u.[GivenName]
					END ASC,
					CASE						
						WHEN (@p_Sort = 6 AND @p_OrderBy = 1) THEN u.[GivenName]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 7 AND @p_OrderBy = 0) THEN c.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 7 AND @p_OrderBy = 1) THEN c.[Name]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 8 AND @p_OrderBy = 0) THEN cl.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 8 AND @p_OrderBy = 1) THEN cl.[Name]
					END DESC,
					CASE 
						WHEN (@p_Sort = 9 AND @p_OrderBy = 0) THEN os.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 9 AND @p_OrderBy = 1) THEN os.[Name]
					END DESC			
					)) AS ID
				  , od.[ID] AS OrderDetail
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
				JOIN [Reservation] r
					ON o.[Reservation] = r.[ID]
			WHERE  o.[ID] IN (SELECT [OrderID] FROM @Orders) AND				   
				   (@orderid = 0 OR od.[ID] = @orderid )
		
		)
	SELECT * FROM OrderDetails --WHERE ID > @StartOffset
	
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
														  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%')) ord
		END
	ELSE
		BEGIN
			SET @P_RecCount = 0
		END	
END
GO

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**
/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 10/16/2013 15:33:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklySampleOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklySampleOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 10/16/2013 15:33:46 ******/
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
		
		WITH Orders AS
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
				  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') 											           
			GROUP BY o.[ID] 
		)
	INSERT INTO @Orders ([OrderID]) 
	SELECT  ID FROM Orders WHERE Number > @StartOffset;		
	
	WITH OrderDetails AS
		(
			SELECT 			
				CONVERT(int, ROW_NUMBER() OVER (
				ORDER BY 
					CASE 
						WHEN (@p_Sort = 0 AND @p_OrderBy = 0) THEN o.[CreatedDate]
					END ASC,
					CASE						
						WHEN (@p_Sort = 0 AND @p_OrderBy = 1) THEN o.[CreatedDate]
					END DESC,
					CASE 
						WHEN (@p_Sort = 1 AND @p_OrderBy = 0) THEN vl.[NamePrefix]
					END ASC,
					CASE						
						WHEN (@p_Sort = 1 AND @p_OrderBy = 1) THEN vl.[NamePrefix]
					END DESC,
					CASE 
						WHEN (@p_Sort = 2 AND @p_OrderBy = 0) THEN p.[Number]
					END ASC,
					CASE						
						WHEN (@p_Sort = 2 AND @p_OrderBy = 1) THEN p.[Number]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 3 AND @p_OrderBy = 0) THEN ot.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 3 AND @p_OrderBy = 1) THEN ot.[Name]
					END DESC,
					CASE 
						WHEN (@p_Sort = 4 AND @p_OrderBy = 0) THEN ods.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 4 AND @p_OrderBy = 1) THEN ods.[Name]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 5 AND @p_OrderBy = 0) THEN o.[OldPONo]
					END ASC,
					CASE						
						WHEN (@p_Sort = 5 AND @p_OrderBy = 1) THEN o.[OldPONo]
					END DESC,
					CASE 
						WHEN (@p_Sort = 6 AND @p_OrderBy = 0) THEN u.[GivenName]
					END ASC,
					CASE						
						WHEN (@p_Sort = 6 AND @p_OrderBy = 1) THEN u.[GivenName]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 7 AND @p_OrderBy = 0) THEN c.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 7 AND @p_OrderBy = 1) THEN c.[Name]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 8 AND @p_OrderBy = 0) THEN cl.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 8 AND @p_OrderBy = 1) THEN cl.[Name]
					END DESC,
					CASE 
						WHEN (@p_Sort = 9 AND @p_OrderBy = 0) THEN os.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 9 AND @p_OrderBy = 1) THEN os.[Name]
					END DESC			
					)) AS ID
				  , od.[ID] AS OrderDetail
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
			WHERE  o.[ID] IN (SELECT [OrderID] FROM @Orders) AND
				   (@orderid = 0 OR od.[ID] = @orderid ) AND
				   (od.[OrderType] = (SELECT odt.[ID] FROM [Indico].[dbo].[OrderType] odt WHERE odt.[Name] = 'SAMPLE'))										
		)
	SELECT * FROM OrderDetails-- WHERE ID > @StartOffset
	
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
														   (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%')) ord
		END
	ELSE
		BEGIN
			SET @P_RecCount = 0
		END			

END
GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderDetailIndicoPrice]    Script Date: 10/23/2013 09:53:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetOrderDetailIndicoPrice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetOrderDetailIndicoPrice]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderDetailIndicoPrice]    Script Date: 10/23/2013 09:53:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SPC_GetOrderDetailIndicoPrice]
(
	@P_Order AS int,
	@P_PriceTerm AS int	
)
AS 

BEGIN

DECLARE @j int
SET @j = 0
DECLARE @TempOrderDetail TABLE 
(
	ID int NOT NULL,
	[OrderDetail] [int] NOT NULL,
	[OrderType] [nvarchar] (255) NOT NULL,
	[VisualLayout] [nvarchar] (255) NOT NULL ,
	[VisualLayoutID] [int] NOT NULL,
	[Pattern] [nvarchar] (255) NOT NULL,
	[PatternID] [int] NOT NULL,
	[FabricID] [int] NOT NULL,
	[Distributor] [int] NOT NULL,
	[Fabric] [nvarchar] (255) NOT NULL,
	[VisualLayoutNotes] [nvarchar] (255) NULL,
	[Order] [int] NOT NULL,
	[Label] [int] NULL,
	[Status] [nvarchar] (255) NULL,
	[StatusID] [int] NULL,
	[ShipmentDate] [datetime2](7) NOT NULL,
	[SheduledDate] [datetime2](7) NOT NULL,	
	[IsRepeat] [bit] NOT NULL,
	[RequestedDate] [datetime2](7) NOT NULL,
	[EditedPrice] [decimal](8, 2) NULL,
	[EditedPriceRemarks] [nvarchar](255) NULL,
	[Quantity] [int] NULL,
	[EditedIndicoPrice] [decimal](8, 2) NULL,	
	[TotalIndicoPrice] [decimal](8, 2) NULL	
)


	INSERT INTO @TempOrderDetail (ID, [OrderDetail], [OrderType],  [VisualLayout], [VisualLayoutID], [Pattern], [PatternID], [FabricID], [Distributor],  [Fabric], [VisualLayoutNotes] , [Order], [Label], [Status], 
							  [StatusID], [ShipmentDate], [SheduledDate], [IsRepeat], [RequestedDate], [EditedPrice], [EditedPriceRemarks], [Quantity], [EditedIndicoPrice], [TotalIndicoPrice])
	SELECT CONVERT(int, ROW_NUMBER() OVER (ORDER BY od.ID)) AS ID
		  ,od.[ID] AS OrderDetail
		  ,ot.[Name] AS OrderType
		  ,vl.[NamePrefix] + ''+ ISNULL(CAST(vl.[NameSuffix] AS NVARCHAR(64)), '') AS VisualLayout
		  ,od.[VisualLayout] AS VisualLayoutID
		  ,p.[Number] AS Pattern
		  ,od.[Pattern] AS PatternID
		  ,od.[FabricCode] AS FabricID
		  ,o.[Distributor] AS Distributor
		  ,fc.[Name] AS Fabric
		  ,od.[VisualLayoutNotes] AS VisualLayoutNotes
		  ,od.[Order] AS 'Order'
		  ,ISNULL(od.[Label],0) AS Label
		  ,ISNULL(ods.[Name], 'New') AS 'Status'
		  ,ISNULL(od.[Status],0) AS StatusID 
		  ,od.[ShipmentDate] AS ShipmentDate
		  ,od.[SheduledDate] AS SheduledDate
		  ,od.[IsRepeat] AS IsRepeat
		  ,od.[RequestedDate] AS RequestedDate
		  ,ISNULL(od.[EditedPrice], 0.00) AS DistributoEditedPrice
		  ,ISNULL(od.[EditedPriceRemarks], '') AS DistributorEditedPriceComments
		  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]), 0) AS Quantity
		  ,NULL
		  ,NULL
	FROM [dbo].[OrderDetail] od
		JOIN [dbo].[OrderType] ot 
			ON od.[OrderType] = ot.[ID]
		JOIN [dbo].[VisualLayout] vl 
			ON od.[VisualLayout] =  vl.[ID]
		JOIN [dbo].[Pattern] p
			ON od.[Pattern] = p.[ID]
		JOIN [dbo].[FabricCode] fc
			ON od.[FabricCode] = fc.[ID]
		JOIN [dbo].[Order] o
			ON od.[Order] = o.[ID]
		LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
			ON ods.[ID] = od.[Status]	
	WHERE od.[Order] = @P_Order	
	
		
		DECLARE @i int
		DECLARE @LevelID AS int
		DECLARE @Quantity AS decimal(8,2)
		DECLARE @Pattern AS int		
		DECLARE @Fabric AS int
		DECLARE @Distributor AS int
		DECLARE @Price AS decimal(8,2)
		DECLARE @OrderDetail AS int
		DECLARE @TotalPrice AS decimal(8,2)
		DECLARE @HasDistributor AS int
		
		SET @i = 1
		
		DECLARE @Count int
		SELECT @Count = COUNT(ID) FROM @TempOrderDetail 
		
		WHILE (@i <= @Count)
		BEGIN
		
		SET @Quantity = (SELECT CAST(tod.[Quantity] AS INT) FROM @TempOrderDetail tod WHERE tod.[ID] = @i)
		SET @Pattern = (SELECT tod.[PatternID] FROM @TempOrderDetail tod WHERE tod.[ID] = @i)
		SET @Fabric = (SELECT tod.[FabricID] FROM @TempOrderDetail tod WHERE tod.[ID] = @i)
		SET @Distributor = (SELECT tod.[Distributor] FROM @TempOrderDetail tod WHERE tod.[ID] = @i)
		SET @OrderDetail = (SELECT tod.[OrderDetail] FROM @TempOrderDetail tod WHERE tod.[ID] = @i)
		SET @HasDistributor = (SELECT COUNT(*) FROM [dbo].[DistributorPriceLevelCost] WHERE [Distributor] = @Distributor)
						
				IF (@Quantity < 6)
				 BEGIN  
					SET @LevelID =  1					
				 END
				ELSE IF (@Quantity > 5 AND @Quantity < 10)
				 BEGIN
					 SET @LevelID = 2 					
				 END
				ELSE IF (@Quantity > 9 AND @Quantity < 20)
				 BEGIN 
					SET @LevelID = 3 					
				 END
				ELSE IF (@Quantity > 19 AND @Quantity < 50)
				 BEGIN
				 	SET @LevelID = 4				 
				 END
					ELSE IF (@Quantity > 49 AND @Quantity < 100)
				 BEGIN
					SET @LevelID = 5
				 END
				ELSE IF (@Quantity > 99 AND @Quantity < 250)
				 BEGIN	
					SET @LevelID = 6
				 END
				ELSE IF (@Quantity > 249 AND @Quantity < 500)
				 BEGIN
					 SET @LevelID = 7
				 END
				ELSE IF (@Quantity > 499)
				 BEGIN	
					SET @LevelID = 8
				 END	 

			SET @i = @i + 1	
			
			
			SET	@Price = (SELECT ISNULL(dplc.[IndicoCost], NULL)
																			  
							FROM [Indico].[dbo].[DistributorPriceLevelCost] dplc
								JOIN [dbo].[PriceLevelCost] plc  
									ON dplc.[PriceLevelCost] = plc.[ID]
								JOIN [dbo].[Price] pr 
									ON plc.[Price] = pr.[ID]
								JOIN [dbo].[PriceLevel] pl
									ON plc.[PriceLevel] = pl.[ID]							
							WHERE pr.[Pattern] = @Pattern AND 
							  pr.[FabricCode] = @Fabric AND 
							  ((@HasDistributor =0 AND dplc.[Distributor] IS NULL) OR dplc.[Distributor] = @Distributor ) AND 
							  dplc.[PriceTerm] = @P_PriceTerm AND
							  pl.[ID] = @LevelID)
							  
			
			IF (@Price IS NUll)
				BEGIN
					
					IF (@P_PriceTerm = 1)
						BEGIN													
						
							 SET @Price = (SELECT ISNULL(((ISNULL(plc.[IndimanCost],0.00) * 100) / (100 - (SELECT dpm.[Markup] 
																							  FROM [dbo].[DistributorPriceMarkup] dpm 
																							  WHERE  ((@HasDistributor = 0 AND dpm.[Distributor] IS NULL) OR dpm.[Distributor] = @Distributor ) 
																							  AND dpm.[PriceLevel] = @LevelID))), 0.00)
											FROM  [dbo].[PriceLevelCost] plc  
													JOIN [dbo].[Price] pr 
															ON plc.[Price] = pr.[ID]
													JOIN [dbo].[PriceLevel] pl
															ON plc.[PriceLevel] = pl.[ID]							
											WHERE pr.[Pattern] = @Pattern AND 
												  pr.[FabricCode] = @Fabric AND 						  
												  pl.[ID] = @LevelID)
						END
					ELSE 
						BEGIN
							SET @Price = (SELECT ISNULL(((ISNULL((plc.[IndimanCost] - p.[ConvertionFactor]) ,0.00)) / (1 - ((SELECT dpm.[Markup] 
																														    FROM [dbo].[DistributorPriceMarkup] dpm 
																															WHERE  ((@HasDistributor = 0 AND dpm.[Distributor] IS NULL) OR dpm.[Distributor] = @Distributor) 
																															AND dpm.[PriceLevel] = @LevelID)/100))), 0.00)
											FROM  [dbo].[PriceLevelCost] plc  
													JOIN [dbo].[Price] pr 
															ON plc.[Price] = pr.[ID]
													JOIN [dbo].[PriceLevel] pl
															ON plc.[PriceLevel] = pl.[ID]
													JOIN [dbo].[Pattern] p
															ON pr.[Pattern] = p.[ID]							
											WHERE pr.[Pattern] = @Pattern AND 
												  pr.[FabricCode] = @Fabric AND 						  
												  pl.[ID] = @LevelID)
						END							  
								 
				END							  
			
							  
			SET @TotalPrice = (@Price *	@Quantity)			
												 
			UPDATE @TempOrderDetail SET [EditedIndicoPrice] = ISNULL(@Price, 0.00),
										[TotalIndicoPrice] = ISNULL(@TotalPrice, 0.00) WHERE [OrderDetail] = @OrderDetail
				
		END		
	
	SELECT * FROM @TempOrderDetail
END 

GO

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 10/23/2013 10:09:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ProductionCapacities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ProductionCapacities]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 10/23/2013 10:09:23 ******/
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
						WHERE od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate
						AND o.[Reservation] IS NULL),
		-- Resevation order quantities
		(	SELECT ISNULL(SUM(odq.Qty),0) AS ResevationOrders
			FROM [Order] o
				JOIN OrderDetail od
					ON o.ID = od.[Order]  
				JOIN OrderDetailQty odq 
					ON od.ID = odq.OrderDetail
				JOIN Reservation r
					ON o.Reservation = r.ID 
			WHERE od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate),
		-- Resevation quantities
		(	SELECT DISTINCT ISNULL(SUM(r.Qty), 0) AS Resevations 
			FROM [Order] o
				JOIN [OrderDetail] od
					on o.[ID] = od.[Order]
				JOIN Reservation r
					ON o.Reservation = r.ID 
			WHERE od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate),
		-- Hold
		0,
		-- Less5Items
		(SELECT DISTINCT ISNULL(COUNT(o.ID),0) AS Less5Items 
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
						HAVING SUM(odq.Qty) <= 5)AND od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) 
												AND od.[SheduledDate] <= @P_WeekEndDate),

		-- JacketsOrders
		(	SELECT  ISNULL(COUNT(o.ID), 0) AS Jackets  
			FROM [Order] o
				JOIN OrderDetail od
					ON o.ID = od.[Order]  
				JOIN Pattern p
					ON p.ID = od.Pattern
				JOIN Item i
					ON i.ID = p.Item
			WHERE i.Name IN('JACKET')AND i.Parent IS NULL
				AND  od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate
				AND p.IsActive = 1),
				
		-- SampleOrders
		(  SELECT ISNULL(COUNT(*), 0) AS Samples 
	       FROM dbo.[Order] o
                JOIN OrderDetail od
					ON o.ID =od.[Order]
				LEFT OUTER JOIN  Reservation res
					ON o.Reservation=res.ID
		   WHERE od.OrderType = (SELECT [ID] FROM [Indico].[dbo].[OrderType] WHERE [Name] = 'SAMPLE')
				AND od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)

	)
	
	SELECT * FROM @Capacities

END
GO

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

--**-**--**-**--**-**--**-**--**-**--**-**--**-** DELETE Pattern Support Accessory Duplicate Records --**-**--**-**--**-**--**-**--**-**--**-**

DECLARE @Accessory AS int
DECLARE @Pattern AS int
DECLARE @Count AS int
DECLARE @Number AS int 
DECLARE @ID AS int 
SET @Number = 0


DECLARE DeletePatternSupportAccessoryCursor CURSOR FAST_FORWARD FOR
 
SELECT [Accessory]     
      ,[Pattern]
      ,COUNT([Accessory]) AS 'Count'
FROM [Indico].[dbo].[PatternSupportAccessory]
GROUP BY [Accessory], [Pattern]
HAVING COUNT([Accessory]) > 1
ORDER BY [Pattern]
  
OPEN DeletePatternSupportAccessoryCursor 
	FETCH NEXT FROM DeletePatternSupportAccessoryCursor INTO @Accessory, @Pattern, @Count  
	WHILE @@FETCH_STATUS = 0 
	BEGIN 

	
					DECLARE DeleteSupportAccessoryCursor CURSOR FAST_FORWARD FOR
 
						SELECT [ID]  
						FROM [Indico].[dbo].[PatternSupportAccessory]
						WHERE [Pattern] = @Pattern AND [Accessory] = @Accessory
						  
						OPEN DeleteSupportAccessoryCursor 
							FETCH NEXT FROM DeleteSupportAccessoryCursor INTO @ID
							WHILE @@FETCH_STATUS = 0 
							BEGIN 
										IF (@Number > 0)
											BEGIN	
												--PRINT @ID
												DELETE FROM [Indico].[dbo].[PatternSupportAccessory] WHERE [ID] = @ID
											END
											
										SET @Number = @Number + 1
											
								FETCH NEXT FROM DeleteSupportAccessoryCursor INTO @ID
							END
					CLOSE DeleteSupportAccessoryCursor 
					DEALLOCATE DeleteSupportAccessoryCursor
		--PRINT 	@Number
		
	SET @Number = 0
	--PRINT @Number
	--PRINT '------------------------------------'

		FETCH NEXT FROM DeletePatternSupportAccessoryCursor INTO  @Accessory, @Pattern, @Count  
	END
CLOSE DeletePatternSupportAccessoryCursor 
DEALLOCATE DeletePatternSupportAccessoryCursor
-----/--------
GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

--**-**--**-**--**-**--**-**--**-**--**-**--**-** Update AccessoryCostTotal Column in Cost Sheet --**-**--**-**--**-**--**-**--**-**--**-**


DECLARE @ID AS int
DECLARE @Pattern AS int
DECLARE @Accessory AS int 
DECLARE @Const AS decimal(8,2)
DECLARE @AccPattern AS int
DECLARE @Fabric AS int
DECLARE @FabConstant AS decimal(8,2)
DECLARE @CostSheet AS int
DECLARE @AccessoryCost AS decimal(8,2)
DECLARE @AccessoryTotal AS decimal(8,2)
DECLARE @ACCCOST AS decimal(8,2)
SET @AccessoryCost = 0
SET @AccessoryTotal = 0

DECLARE CostSheetCursor CURSOR FAST_FORWARD FOR
 
SELECT [ID]
      ,[Pattern]      
  FROM [Indico].[dbo].[CostSheet]
  
OPEN CostSheetCursor 
	FETCH NEXT FROM CostSheetCursor INTO @ID, @Pattern
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
				DECLARE AccessoryCursor CURSOR FAST_FORWARD FOR
				 
				SELECT [Accessory]
					  ,[AccConstant]
					  ,[Pattern]
				FROM [Indico].[dbo].[PatternSupportAccessory]
				WHERE [Pattern] = @Pattern
				  
				OPEN AccessoryCursor 
					FETCH NEXT FROM AccessoryCursor INTO @Accessory, @Const, @AccPattern
					WHILE @@FETCH_STATUS = 0 
					BEGIN 
						
						SET @ACCCOST =  (SELECT SUM(a.[Cost]) FROM [dbo].[Accessory] a WHERE a.[ID] = @Accessory)
						
						SET @AccessoryCost = (@Const * @ACCCOST)			
						
						SET @AccessoryTotal = ROUND((@AccessoryTotal+@AccessoryCost), 2)
							
							
							
						FETCH NEXT FROM AccessoryCursor INTO  @Accessory, @Const, @AccPattern
					END
				CLOSE AccessoryCursor 
				DEALLOCATE AccessoryCursor	
				
				
				--PRINT @AccessoryTotal
				--PRINT @Pattern
				--PRINT '----------------------------'
				UPDATE [dbo].[CostSheet] SET [TotalAccessoriesCost] = @AccessoryTotal WHERE [ID] = @ID
				
				
				
	SET @AccessoryCost = 0			
	SET @AccessoryTotal = 0	
			
		FETCH NEXT FROM CostSheetCursor INTO  @ID, @Pattern
	END
CLOSE CostSheetCursor 
DEALLOCATE CostSheetCursor
-----/--------
GO

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

--**-**--**-**--**-**--**-**--**-**--**-**--**-** Update Cost Sheet --**-**--**-**--**-**--**-**--**-**--**-**

DECLARE @ID AS int
DECLARE @Pattern AS int
DECLARE @TotalFabricCost AS decimal(8,2)
DECLARE @TotalAccessoriesCost AS decimal(8,2)
DECLARE @HPCost AS decimal(8,2)
DECLARE @LabelCost AS decimal(8,2)
DECLARE @Other AS decimal(8,2) 
DECLARE @Finance AS decimal(8,2)
DECLARE @Wastage AS decimal(8,2)
DECLARE @CM AS decimal(8,2)
DECLARE @DutyRate AS decimal(8,2)
DECLARE @MarginRate AS decimal(8,2)
DECLARE @Accessory AS int 
DECLARE @Const AS decimal(8,2)
DECLARE @AccPattern AS int
DECLARE @Fabric AS int
DECLARE @FabConstant AS decimal(8,2)
DECLARE @CostSheet AS int
DECLARE @AccessoryCost AS decimal(8,2)
DECLARE @AccessoryTotal AS decimal(8,2)
DECLARE @ACCCOST AS decimal(8,2)
DECLARE @FabricPrice AS decimal(8,2)
DECLARE @FabricCost AS decimal(8,2)
DECLARE @FabricTotal AS decimal(8,2)
DECLARE @SubWastage AS decimal(8,2)
DECLARE @SubFinance AS decimal(8,2)
DECLARE @FOBCost AS decimal(8,2)
DECLARE @CalWastage AS decimal(8,2)
DECLARE @CalFinance AS decimal(8,2)
DECLARE @CalDuty AS decimal(8,2)
DECLARE @CalMarginRate AS decimal(8,2)
SET @AccessoryCost = 0
SET @AccessoryTotal = 0
SET @FabricCost = 0
SET @FabricTotal = 0 
SET @SubWastage = 0
SET @SubFinance = 0
SET @FOBCost = 0


DECLARE CostSheetCursor CURSOR FAST_FORWARD FOR
 
SELECT [ID]
      ,[Pattern]
      ,[TotalFabricCost]
      ,[TotalAccessoriesCost]
      ,[HPCost]
      ,[LabelCost]
      ,[Other]
      ,[Finance]
      ,[Wastage]
      ,[CM]
      ,[DutyRate]
      ,[MarginRate]
  FROM [Indico].[dbo].[CostSheet]
  
OPEN CostSheetCursor 
	FETCH NEXT FROM CostSheetCursor INTO @ID, @Pattern, @TotalFabricCost, @TotalAccessoriesCost, @HPCost, @LabelCost, @Other, @Finance, @Wastage, @CM, @DutyRate, @MarginRate 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
				
				SET @SubWastage  = ROUND((((@TotalAccessoriesCost + @HPCost + @LabelCost + @Other) * @Wastage)/100) , 2, 1)
				SET @SubFinance  = ROUND(((( @TotalFabricCost + @TotalAccessoriesCost + @HPCost + @LabelCost + @Other) * @Finance)/100) , 2, 1)
				SET @FOBCost =  ROUND((@TotalFabricCost + @TotalAccessoriesCost + @HPCost + @LabelCost + @Other + @SubFinance + @SubWastage + @CM) , 2, 1)
				
				
				
				  UPDATE [dbo].[CostSheet] SET [SubWastage] = @SubWastage,
											   [SubFinance] = @SubFinance,											  										  
											   [JKFOBCost] = @FOBCost
										 WHERE [ID] = @ID
					/*PRINT @TotalFabricCost
					PRINT @TotalFabricCost
					PRINT @SubWastage
					PRINT @SubFinance
					PRINT '-------------------------------------'*/
									
	SET @AccessoryCost = 0			
	SET @AccessoryTotal = 0
	SET @FabricCost = 0			
	SET @FabricTotal = 0
	SET @SubWastage = 0			
	SET @SubFinance = 0
	SET @FOBCost = 0
			
		FETCH NEXT FROM CostSheetCursor INTO  @ID, @Pattern, @TotalFabricCost, @TotalAccessoriesCost, @HPCost, @LabelCost, @Other, @Finance, @Wastage, @CM, @DutyRate, @MarginRate 
	END
CLOSE CostSheetCursor 
DEALLOCATE CostSheetCursor
-----/--------
GO

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

/****** Object:  View [dbo].[PackingListView]    Script Date: 10/23/2013 11:44:07 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[PackingListView]'))
DROP VIEW [dbo].[PackingListView]
GO

/****** Object:  View [dbo].[PackingListView]    Script Date: 10/23/2013 09:35:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PackingListView]
AS
	SELECT --DISTINCT TOP 100 PERCENT
		pl.ID,
		wpc.ID AS WeeklyProductionCapacity,
		pl.CartonNo,
		o.ID AS OrderNumber,		
		od.[ID] AS OrderDetailId,
		vl.NamePrefix  + CAST(ISNULL(vl.NameSuffix,'') AS VarChar) AS VLName,
		p.NickName,
		d.Name AS Distributor,
		c.Name AS Client,
		wpc.WeekendDate,
		(SELECT SUM(QTY) FROM [dbo].[PackingListSizeQty] WHERE PackingList = pl.ID) AS PackingTotal,
		(SELECT SUM([Count]) FROM [dbo].[PackingListCartonItem] WHERE PackingList = pl.ID) AS ScannedTotal				
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
GO



