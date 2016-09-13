USE[Indico] 
GO
/********* ALTER VIEW [PendingPricesView] *************/
ALTER VIEW [dbo].[PendingPricesView] 
AS 
	SELECT pt.ID,
		   pt.Number AS PatternNumber,
		   pt.NickName AS NickName,
		   g.Name AS Gender,
		   i.Name AS SubItemName,		  
		   ag.Name AS AgeGroup,
		   c.Name AS CoreCategory,
		   pt.CorePattern
	FROM [Indico].[dbo].[Pattern] pt
		LEFT OUTER JOIN [Indico].[dbo].[Price] pr
			ON pt.ID = pr.Pattern
		JOIN [Indico].[dbo].[Item] i
			ON pt.SubItem = i.ID
		JOIN [Indico].[dbo].[Gender] g
			ON pt.Gender = g.ID
		JOIN [Indico].[dbo].[Category] c
			ON pt.CoreCategory = c.ID
		JOIN [Indico].[dbo].[AgeGroup] ag
			ON pt.AgeGroup = ag.ID
	WHERE	pr.Pattern IS NULL 
			AND pt.IsActive = 1	
GO

/********* ALTER VIEW [PriceLevelCostView] *************/
ALTER VIEW [dbo].[PriceLevelCostView]
AS
	SELECT	p.ID,
			p.[Pattern],
			p.[FabricCode],
			pt.[Number],
			pt.[NickName],
			pt.[Item],
			pt.[SubItem],
			pt.[CoreCategory],
			fc.[Name] AS FabricCodeName,
			i.Name AS ItemSubCategory,
			(	SELECT c.Name + ',' AS [text()] 
				FROM Pattern p WITH (NOLOCK)
					JOIN PatternOtherCategory poc 
						ON poc.Pattern = p.ID 
					JOIN Category c WITH (NOLOCK)
						ON poc.Category = c.ID	
				WHERE Number = pt.Number FOR XML PATH('')) AS OtherCategories,
			pt.ConvertionFactor	
	FROM	Indico.dbo.Price p WITH (NOLOCK)
			JOIN Indico.dbo.Pattern pt WITH (NOLOCK)
				ON p.Pattern = pt.ID
			JOIN Indico.dbo.FabricCode fc WITH (NOLOCK)
				ON p.FabricCode = fc.ID
			JOIN Indico.dbo.Item i WITH (NOLOCK)
				ON i.ID = pt.[SubItem]	
	INNER JOIN (
		SELECT p.[Pattern] AS PatternId,
				p.[FabricCode] AS FaricCodeId
		FROM	Indico.dbo.Price p WITH (NOLOCK)
				JOIN Indico.dbo.PriceLevelCost plc WITH (NOLOCK)
					ON p.ID	= plc.Price
				JOIN dbo.Pattern pt WITH (NOLOCK)
					ON p.Pattern = pt.ID 
		WHERE pt.IsActive = 1
		GROUP BY p.[Pattern], p.[FabricCode]) G			
			ON p.[Pattern] = G.PatternId
			AND p.[FabricCode] = G.FaricCodeId		
		

GO

/********* ALTER VIEW [PatternCoreCategoriesView] *************/
ALTER VIEW [dbo].[PatternCoreCategoriesView]
AS
	SELECT DISTINCT c.[ID], p.[CoreCategory], c1.[Name]
	FROM Category c
		JOIN PatternOtherCategory poc WITH (NOLOCK)
			ON poc.Category = c.ID
		JOIN Pattern p WITH (NOLOCK)
			ON poc.Pattern = p.ID
		JOIN Price pr WITH (NOLOCK)
			ON p.ID = pr.Pattern
		JOIN Category c1 WITH (NOLOCK)
			ON c1.ID = p.CoreCategory
	WHERE p.IsActive = 1

GO

/********* ALTER VIEW [ExcelPriceLevelCostView] *************/
ALTER VIEW [dbo].[ExcelPriceLevelCostView]
AS

SELECT		p.ID AS 'PriceID',
			c.Name AS 'SportsCategory',
			(	SELECT c.Name + ',' AS [text()] 
				FROM Pattern p
					JOIN PatternOtherCategory poc 
						ON poc.Pattern = p.ID 
					JOIN Category c
						ON poc.Category = c.ID	
				WHERE Number = pt.Number FOR XML PATH('')) AS 'OtherCategories',
			p.[Pattern] AS 'PatternID',
			(	SELECT  i.Name
				FROM Item i  
				WHERE i.ID = SubItem) AS ItemSubCategoris,
			pt.[NickName],
			fc.[Name] AS FabricCodeName,	
			fc.[NickName] AS FabricCodenNickName,
			pt.[Number],	
			pt.ConvertionFactor	
	FROM	Indico.dbo.Price p
			JOIN Indico.dbo.Pattern pt
				ON p.Pattern = pt.ID
			JOIN Indico.dbo.FabricCode fc
				ON p.FabricCode = fc.ID
			JOIN Indico.dbo.Item i
				ON i.ID = pt.[SubItem]
			JOIN Indico.dbo.Category c
				ON pt.CoreCategory = C.ID
	INNER JOIN (
		SELECT p.[Pattern] AS PatternId,
				p.[FabricCode] AS FaricCodeId
		FROM	Indico.dbo.Price p
				JOIN Indico.dbo.PriceLevelCost plc
					ON p.ID	= plc.Price
				JOIN Indico.dbo.Pattern pt 
					ON p.Pattern = pt.ID 
		WHERE pt.IsActive = 1
		GROUP BY p.[Pattern], p.[FabricCode]) G			
			ON p.[Pattern] = G.PatternId
			AND p.[FabricCode] = G.FaricCodeId	
		--ORDER BY C.Name		

GO
/********* UPDATE PATTERN TABLE [IsActive] COLUMN  *************/

--BEGIN TRAN

DECLARE @ID AS int
DECLARE PatternUpdateCursor CURSOR FAST_FORWARD FOR 
SELECT [ID]      
FROM [dbo].[Pattern]
WHERE [IsActive] = 0

OPEN PatternUpdateCursor 
	FETCH NEXT FROM PatternUpdateCursor INTO @ID
	WHILE @@FETCH_STATUS = 0 
	BEGIN 	
		UPDATE  [dbo].[Pattern] SET [IsActive] = 1 WHERE [ID]= @ID
		FETCH NEXT FROM PatternUpdateCursor INTO @ID
	END 
CLOSE PatternUpdateCursor 
DEALLOCATE PatternUpdateCursor

--ROLLBACK TRAN
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/********* ALTER STORED PROCEDURE [SPC_GetWeeklyFirmOrders]*************/
ALTER PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders] (	
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
			WHERE  o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate
		AND p.IsActive = 1

END


GO

/********* ALTER STORED PROCEDURE [SPC_GetWeeklyJacketOrders]*************/

ALTER PROCEDURE [dbo].[SPC_GetWeeklyJacketOrders] (	
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
				AND  o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate
				AND p.IsActive = 1
END 


GO

/********* ALTER STORED PROCEDURE [SPC_GetWeeklyLessFiveItemOrders]*************/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SPC_GetWeeklyLessFiveItemOrders] (		
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
				AND  o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate
				AND p.IsActive = 1
END


GO

/********* ALTER STORED PROCEDURE [SPC_GetWeeklyReservationOrders]*************/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders] (		
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
				WHERE  o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate
					AND p.IsActive = 1

END


GO

/********* ALTER STORED PROCEDURE [SPC_GetWeeklySampleOrders]*************/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SPC_GetWeeklySampleOrders] (	
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
				AND  o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate
				AND p.IsActive = 1
END


GO

/********* ALTER STORED PROCEDURE [SPC_ProductionCapacities] *************/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SPC_ProductionCapacities] (	
	
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
		(	SELECT  SUM(odq.Qty) AS Firms  
			FROM [Order] o
				JOIN OrderDetail od
					ON o.ID = od.[Order]  
				JOIN OrderDetailQty odq 
					ON od.ID = odq.OrderDetail 
						WHERE o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate),
		-- Resevation order quantities
		(	SELECT SUM(odq.Qty) AS ResevationOrders
			FROM [Order] o
				JOIN OrderDetail od
					ON o.ID = od.[Order]  
				JOIN OrderDetailQty odq 
					ON od.ID = odq.OrderDetail
				JOIN Reservation r
					ON o.Reservation = r.ID 
			WHERE o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate),
		-- Resevation quantities
		(	SELECT SUM(r.Qty) AS Resevations 
			FROM [Order] o
				JOIN Reservation r
					ON o.Reservation = r.ID 
			WHERE o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate),
		-- Hold
		0,
		-- Less5Items
		(SELECT COUNT(o.ID) AS Less5Items 
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
						HAVING SUM(odq.Qty) <= 5)AND o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) 
												AND o.ShipmentDate <= @P_WeekEndDate),

		-- JacketsOrders
		(	SELECT  COUNT(o.ID) AS Jackets  
			FROM [Order] o
				JOIN OrderDetail od
					ON o.ID = od.[Order]  
				JOIN Pattern p
					ON p.ID = od.Pattern
				JOIN Item i
					ON i.ID = p.Item
			WHERE i.Name IN('PANT','JACKET','WINDCHEATER')AND i.Parent IS NULL
				AND  o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate
				AND p.IsActive = 1),
				
		-- SampleOrders
		(  SELECT COUNT(*) AS Samples 
	       FROM dbo.[Order] o
                JOIN OrderDetail od
					ON o.ID =od.[Order]
				LEFT OUTER JOIN  Reservation res
					ON o.Reservation=res.ID
		   WHERE od.OrderType = 4 
				AND o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate)

	)
	
	SELECT * FROM @Capacities

END

GO




