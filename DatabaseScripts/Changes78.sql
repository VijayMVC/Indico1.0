USE [Indico]
GO

--**-**-**/**--**-**-**/**--**-**-**/** ALTER COLUMN Ink Cons in CostSheet --**-**-**/**--**-**-**/**--**-**-**/**

ALTER TABLE [dbo].[CostSheet]
ALTER COLUMN [InkCons] decimal(8,3) NULL
GO
--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**


--**-**-**/**--**-**-**/**--**-**-**/** ALTER COLUMN Ink Cons in CostSheet --**-**-**/**--**-**-**/**--**-**-**/**
/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 12/03/2013 09:41:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ProductionCapacities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ProductionCapacities]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 12/03/2013 09:41:44 ******/
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
		0,
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

--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/** 


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 12/03/2013 10:59:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyFirmOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 12/03/2013 10:59:06 ******/
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
										  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
										  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))
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
				   (@orderid = 0 OR o.[ID] = @orderid) AND
				   (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))
							
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
														  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
														  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))) ord
		END
	ELSE
		BEGIN
			SET @P_RecCount = 0
		END	
		
END

GO

--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/** 



/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 12/03/2013 11:12:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyJacketOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyJacketOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 12/03/2013 11:12:57 ******/
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
						  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
						  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))
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
				   (p.[Item] = (SELECT i.[ID] FROM [Indico].[dbo].[Item] i WHERE i.[Name] = 'JACKET' AND i.[Parent] IS NULL)) AND
				   (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))					
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
														  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
														  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled'))))ord
		END
	ELSE
		BEGIN
			SET @P_RecCount = 0
		END					
END 

GO

--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/**  

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 12/03/2013 11:15:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyLessFiveItemOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyLessFiveItemOrders]
GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 12/03/2013 11:15:59 ******/
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
							(@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
							(od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))
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
				   (@orderid = 0 OR od.[ID] = @orderid) AND
				   (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))
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
														(@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
														(od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))) ord
		END
	ELSE
		BEGIN
			SET @P_RecCount = 0
		END	
END

GO

--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/**  

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 12/03/2013 11:19:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyReservationOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 12/03/2013 11:19:40 ******/
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
										  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
										  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))
										  
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
				   (@orderid = 0 OR od.[ID] = @orderid ) AND
				   (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))
		
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
														  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
														  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))) ord
		END
	ELSE
		BEGIN
			SET @P_RecCount = 0
		END	
END

GO

--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/**  

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 12/03/2013 11:22:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklySampleOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklySampleOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySampleOrders]    Script Date: 12/03/2013 11:22:53 ******/
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
				  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
				  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))											           
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
				   (od.[OrderType] = (SELECT odt.[ID] FROM [Indico].[dbo].[OrderType] odt WHERE odt.[Name] = 'SAMPLE')) AND
				   (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))										
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
														   (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
														   (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))) ord
		END
	ELSE
		BEGIN
			SET @P_RecCount = 0
		END			

END

GO

--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/**--**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/** --**-**-**/**  

 IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Embroidery_Assigned]') AND parent_object_id = OBJECT_ID(N'[dbo].[Embroidery]'))
ALTER TABLE [dbo].[Embroidery] DROP CONSTRAINT [FK_Embroidery_Assigned]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Embroidery_Coordinator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Embroidery]'))
ALTER TABLE [dbo].[Embroidery] DROP CONSTRAINT [FK_Embroidery_Coordinator]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Embroidery_Creator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Embroidery]'))
ALTER TABLE [dbo].[Embroidery] DROP CONSTRAINT [FK_Embroidery_Creator]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Embroidery_Distributor]') AND parent_object_id = OBJECT_ID(N'[dbo].[Embroidery]'))
ALTER TABLE [dbo].[Embroidery] DROP CONSTRAINT [FK_Embroidery_Distributor]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Embroidery_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[Embroidery]'))
ALTER TABLE [dbo].[Embroidery] DROP CONSTRAINT [FK_Embroidery_Modifier]
GO

/****** Object:  Table [dbo].[Embroidery]    Script Date: 12/03/2013 12:15:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Embroidery]') AND type in (N'U'))
DROP TABLE [dbo].[Embroidery]
GO

/****** Object:  Table [dbo].[Embroidery]    Script Date: 12/03/2013 12:15:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Embroidery](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EmbStrikeOffDate] [datetime2](7) NOT NULL,
	[JobName] [nvarchar](255) NOT NULL,
	[Distributor] [int] NOT NULL,
	[Client] [nvarchar](255) NOT NULL,
	[Coordinator] [int] NOT NULL,
	[Product] [nvarchar](255) NULL,
	[PhotoRequiredBy] [datetime2](7) NOT NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[Modifier] [int] NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
	[Assigned] [int] NOT NULL,
 CONSTRAINT [PK_Embroidery] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Embroidery]  WITH CHECK ADD  CONSTRAINT [FK_Embroidery_Assigned] FOREIGN KEY([Assigned])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[Embroidery] CHECK CONSTRAINT [FK_Embroidery_Assigned]
GO

ALTER TABLE [dbo].[Embroidery]  WITH CHECK ADD  CONSTRAINT [FK_Embroidery_Coordinator] FOREIGN KEY([Coordinator])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[Embroidery] CHECK CONSTRAINT [FK_Embroidery_Coordinator]
GO

ALTER TABLE [dbo].[Embroidery]  WITH CHECK ADD  CONSTRAINT [FK_Embroidery_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[Embroidery] CHECK CONSTRAINT [FK_Embroidery_Creator]
GO

ALTER TABLE [dbo].[Embroidery]  WITH CHECK ADD  CONSTRAINT [FK_Embroidery_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO

ALTER TABLE [dbo].[Embroidery] CHECK CONSTRAINT [FK_Embroidery_Distributor]
GO

ALTER TABLE [dbo].[Embroidery]  WITH CHECK ADD  CONSTRAINT [FK_Embroidery_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[Embroidery] CHECK CONSTRAINT [FK_Embroidery_Modifier]
GO

--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**

/****** Object:  Table [dbo].[EmbroideryStatus]    Script Date: 12/03/2013 12:41:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmbroideryStatus]') AND type in (N'U'))
DROP TABLE [dbo].[EmbroideryStatus]
GO

/****** Object:  Table [dbo].[EmbroideryStatus]    Script Date: 12/03/2013 12:41:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EmbroideryStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](512) NULL,
 CONSTRAINT [PK_EmbroideryStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmbroideryDetails_Embroidery]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmbroideryDetails]'))
ALTER TABLE [dbo].[EmbroideryDetails] DROP CONSTRAINT [FK_EmbroideryDetails_Embroidery]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmbroideryDetails_Fabric]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmbroideryDetails]'))
ALTER TABLE [dbo].[EmbroideryDetails] DROP CONSTRAINT [FK_EmbroideryDetails_Fabric]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmbroideryDetails_FabricColor]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmbroideryDetails]'))
ALTER TABLE [dbo].[EmbroideryDetails] DROP CONSTRAINT [FK_EmbroideryDetails_FabricColor]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmbroideryDetails_Status]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmbroideryDetails]'))
ALTER TABLE [dbo].[EmbroideryDetails] DROP CONSTRAINT [FK_EmbroideryDetails_Status]
GO

/****** Object:  Table [dbo].[EmbroideryDetails]    Script Date: 12/03/2013 12:44:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmbroideryDetails]') AND type in (N'U'))
DROP TABLE [dbo].[EmbroideryDetails]
GO

/****** Object:  Table [dbo].[EmbroideryDetails]    Script Date: 12/03/2013 12:44:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EmbroideryDetails](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Location] [nvarchar](255) NOT NULL,
	[FabricColor] [int] NOT NULL,
	[Fabric] [int] NOT NULL,
	[Width] [decimal](8, 2) NULL,
	[Height] [decimal](8, 2) NULL,
	[Status] [int] NOT NULL,
	[Notes] [nvarchar](255) NULL,
	[Embroidery] [int] NOT NULL,
 CONSTRAINT [PK_EmbroideryDetails] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[EmbroideryDetails]  WITH CHECK ADD  CONSTRAINT [FK_EmbroideryDetails_Embroidery] FOREIGN KEY([Embroidery])
REFERENCES [dbo].[Embroidery] ([ID])
GO

ALTER TABLE [dbo].[EmbroideryDetails] CHECK CONSTRAINT [FK_EmbroideryDetails_Embroidery]
GO

ALTER TABLE [dbo].[EmbroideryDetails]  WITH CHECK ADD  CONSTRAINT [FK_EmbroideryDetails_Fabric] FOREIGN KEY([Fabric])
REFERENCES [dbo].[FabricCode] ([ID])
GO

ALTER TABLE [dbo].[EmbroideryDetails] CHECK CONSTRAINT [FK_EmbroideryDetails_Fabric]
GO

ALTER TABLE [dbo].[EmbroideryDetails]  WITH CHECK ADD  CONSTRAINT [FK_EmbroideryDetails_FabricColor] FOREIGN KEY([FabricColor])
REFERENCES [dbo].[AccessoryColor] ([ID])
GO

ALTER TABLE [dbo].[EmbroideryDetails] CHECK CONSTRAINT [FK_EmbroideryDetails_FabricColor]
GO

ALTER TABLE [dbo].[EmbroideryDetails]  WITH CHECK ADD  CONSTRAINT [FK_EmbroideryDetails_Status] FOREIGN KEY([Status])
REFERENCES [dbo].[AccessoryColor] ([ID])
GO

ALTER TABLE [dbo].[EmbroideryDetails] CHECK CONSTRAINT [FK_EmbroideryDetails_Status]
GO

--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**

DECLARE @New AS int 
DECLARE @IndimanSubmit AS int 

SET @New = (SELECT [ID] FROM [dbo].[OrderStatus] WHERE [Name] = 'New')
SET @IndimanSubmit = (SELECT [ID] FROM [dbo].[OrderStatus] WHERE [Name] = 'Indiman Submitted')

UPDATE [dbo].[Order] SET [Status] = @IndimanSubmit WHERE [Status] = @New
GO

--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**--**-**-**-**-**

--**--**--**--**--**--**--**--**--**--**--**--** Add New Page ViewEmbroideries Page--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/ViewEmbroideries.aspx', 'Embroideries', 'Embroideries')
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

DECLARE @Page AS int 
DECLARE @Position AS int
DECLARE @Parent AS int
DECLARE @RoleIndiman AS int
DECLARE @RoleFactory AS int
DECLARE @MenuItem AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewEmbroideries.aspx')
SET @Position = (SELECT Max([Position]) + 1 FROM [dbo].[MenuItem] WHERE [Parent] IS NULL)
SET @RoleIndiman = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @RoleFactory = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')


INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES(@Page, 'Embroidery', 'Embroidery', 1, NULL, @Position, 1)

SET @Parent = SCOPE_IDENTITY()


INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@Parent , @RoleIndiman)


INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@Parent , @RoleFactory)



INSERT INTO [Indico].[dbo].[MenuItem]([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible]) VALUES(@Page, 'Embroidery', 'Embroidery', 1, @Parent, 1, 1)

SET @MenuItem = SCOPE_IDENTITY()


INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem , @RoleIndiman)


INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem , @RoleFactory)
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
