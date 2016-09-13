USE [Indico]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/ViewDrillDown.aspx','Order Drill Down','Order Drill Down')	 
SET @PageId = SCOPE_IDENTITY()

 SET @MenuItemMenuId =(SELECT TOP 1 mi.ID FROM [dbo].[MenuItem] mi
				INNER JOIN [dbo].[Page] p
					ON mi.[Page] = p.ID
				 WHERE mi.Name = 'Orders' AND mi.Parent IS NULL AND p.Name = '/ViewOrders.aspx' )
			
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Order Drill Down', 'Order Drill Down', 1, @MenuItemMenuId, 145, 0)
SET @MenuItemId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 1)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 2)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 3)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 5)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 6)

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/ViewWeeklySummaryBackOrders.aspx','Weekly Summary (Backorders)','Weekly Summary (Backorders)')	 
SET @PageId = SCOPE_IDENTITY()

--SELECT TOP 1 @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Dashboard' AND Parent IS NULL

 SET @MenuItemMenuId =(SELECT TOP 1 mi.ID FROM [dbo].[MenuItem] mi
				INNER JOIN [dbo].[Page] p
					ON mi.[Page] = p.ID
				 WHERE mi.Name = 'Dashboard' AND mi.Parent IS NULL AND p.Name = '/Home.aspx' )			

INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Weekly Summary (Backorders)', 'Weekly Summary (Backorders)', 1, @MenuItemMenuId, 8, 1)
SET @MenuItemId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 1)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 2)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 3)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 5)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 6)

GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetShipmentsForGivenWeek]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetShipmentsForGivenWeek]
GO

CREATE PROC [dbo].[SPC_GetShipmentsForGivenWeek]
	@P_WeekStartDate datetime2(7),
	@P_WeekEndDate datetime2(7)
AS
BEGIN
	DECLARE @WeekStartDate datetime2(7)
	DECLARE @WeekEndDate datetime2(7)

	SET @WeekEndDate = @P_WeekEndDate
	SET @WeekStartDate = @P_WeekStartDate

	SELECT COALESCE(dca.CompanyName,'') AS ShipTo,
		COALESCE(dp.Name, '') AS Port,
		COALESCE(sm.Name,'') AS Mode,
		COALESCE(pm.Name,'') AS Terms,
		od.ShipmentDate AS ETD,
		SUM(odq.Qty) AS Qty,
		SUM(odq.Qty) AS ShipQty
		FROM
		[dbo].[Order] o
		INNER JOIN [dbo].[OrderDetail] od
			ON od.[Order] = o.ID
		INNER JOIN [dbo].[OrderDetailQty] odq
			ON odq.OrderDetail = od.ID
		INNER JOIN [dbo].[DistributorClientAddress] dca
			ON od.DespatchTo = dca.ID
		LEFT OUTER JOIN [dbo].[DestinationPort] dp
			ON dca.Port= dp.ID
		LEFT OUTER JOIN [dbo].[ShipmentMode] sm
			ON od.ShipmentMode = sm.ID
		INNER JOIN [dbo].[OrderStatus] os
			ON o.[Status] = os.ID
		LEFT OUTER JOIN [dbo].[PaymentMethod] pm
			ON od.PaymentMethod = pm.ID
		WHERE  od.ShipmentDate >= @WeekStartDate AND od.ShipmentDate <= @WeekEndDate  AND os.ID != 28 AND os.ID != 18
		GROUP BY dca.ID,
				 dca.CompanyName,
				 dp.Name,
				 sm.Name,
				 pm.Name,
				 od.ShipmentDate
		ORDER BY od.ShipmentDate
END

GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetPoloOrdersForGivenWeek]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetPoloOrdersForGivenWeek]
GO

CREATE PROC [dbo].[SPC_GetPoloOrdersForGivenWeek]
	@P_Year int,
	@P_WeekNumber int,
	@P_type int = 1
AS
BEGIN 
	DECLARE @Year int
	DECLARE @WeekNumber int
	DECLARE @Type int
	SET @Year = @P_Year
	SET @WeekNumber = @P_WeekNumber
	SET @Type = @P_Type
	DECLARE @WeekEndDate datetime2(7)
	SET @WeekEndDate = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE DATEPART(YEAR,WeekendDate) = @Year AND WeekNo = @WeekNumber)
	DECLARE @WeekStartDate datetime2(7)
	SET @WeekStartDate = DATEADD(DAY, -6, @WeekEndDate)

	IF @Type = 7  -- Reservations 
		BEGIN
			IF OBJECT_ID('tempdb..#res1') IS NOT NULL
			BEGIN
				DROP TABLE #res1
			END

			SELECT	CONVERT(nvarchar(4),@Year) + '/' + CONVERT(nvarchar(2),@WeekNumber) AS [Week],
			('PO-'+CAST(o.ID as nvarchar(47))) AS PurchaseOrderNumber,
			o.ID AS [Order],
			p.Number+' - '+p.NickName AS Pattern,
			p.ID AS PatternID,
			o.[Date] AS OrderDate,
			r.ShipmentDate AS ETD,
			coo.GivenName + ' '+ coo.FamilyName AS Coodinator,
			ot.Name AS OrderType,
			d.Name AS Distributor,
			r.Client,
			r.[Qty] AS OrgQty,
			(SELECT ISNULL(SUM(odq.Qty),0)
				FROM [OrderDetail] od				
					JOIN OrderDetailQty odq 
						ON od.ID = odq.OrderDetail
					JOIN Reservation r
						ON od.Reservation = r.ID ) AS UsedQty,
			 pt.Name AS PrintType,
			 rs.Name AS [Status],
			 p.SMV AS SMV,
			 ISNULL((p.SMV * odq.Qty), 0) AS TotalSMV INTO #res1
		FROM [dbo].[Reservation] r
			LEFT OUTER JOIN [dbo].[Order] o
				ON o.Reservation = r.ID
			LEFT OUTER JOIN [dbo].[Pattern] p
				ON p.ID = r.Pattern
			INNER JOIN [dbo].[User] coo
				ON r.Coordinator = coo.ID
			INNER JOIN [dbo].[Company] d
				ON r.Distributor = d.ID
			INNER JOIN [dbo].[PrinterType] pt
				ON p.PrinterType = pt.ID
			INNER JOIN [dbo].[ReservationStatus] rs
				ON r.[Status] = rs.ID
			LEFT OUTER JOIN [dbo].[OrderDetail] od
				ON od.Reservation = r.ID
			LEFT OUTER JOIN [dbo].[OrderType] ot
				ON od.OrderType = ot.ID
			LEFT OUTER JOIN [dbo].[OrderDetailQty] odq
				ON odq.OrderDetail = od.ID
		WHERE  r.ShipmentDate >= @WeekStartDate AND r.ShipmentDate <= @WeekEndDate 

		SELECT d.*,(d.OrgQty-d.UsedQty) AS BalQty FROM #res1 d 
	
	END
	ELSE IF @type = 3 -- firm orders and reservations
	BEGIN
		IF OBJECT_ID('tempdb..#firm') IS NOT NULL
		BEGIN
			DROP TABLE #firm
		END
		SELECT	CONVERT(nvarchar(4),@Year) + '/' + CONVERT(nvarchar(2),@WeekNumber) AS [Week],
			o.ID AS [Order],
			('PO-'+CAST(o.ID as nvarchar(47))) AS PurchaseOrderNumber,
			vl.NamePrefix AS Product,
			vl.ID AS ProductID,
			p.Number+' - '+p.NickName AS Pattern,
			p.ID AS PatternID,
			fc.Code + ' - '+fc.Name AS Fabric,
			fc.ID AS FabricID ,
			o.[Date] AS OrderDate,
			od.ShipmentDate AS ETD,
			coo.GivenName + ' '+ coo.FamilyName AS Coodinator,
			ot.Name AS OrderType,
			d.Name AS Distributor,
			c.Name AS Client,
			ISNULL(SUM(odq.Qty), 0) AS Qty,
			pl.Name AS ProductionLine,
			COALESCE(i.Name,'') AS ItemSubCat,
			pt.Name AS PrintType,
			COALESCE(dca.CompanyName,'') AS ShipTo,
			COALESCE(dp.Name, '') AS Port,
			COALESCE(sm.Name,'') AS Mode,
			COALESCE(os.Name, '') AS [Status],
			p.SMV,
			(p.SMV * odq.Qty) AS TotalSMV INTO #firm
		FROM [dbo].[Order] o
			INNER JOIN [dbo].[OrderDetail] od
				ON od.[Order] = o.ID
			INNER JOIN [dbo].[OrderStatus] os
				ON o.[Status] = os.ID
			INNER JOIN [dbo].[VisualLayout] vl
				ON od.VisualLayout = vl.ID 
			INNER JOIN [dbo].[Pattern] p
				ON vl.Pattern = p.ID
			INNER JOIN [dbo].[Item] it
				ON p.Item = it.ID
			LEFT OUTER JOIN [dbo].[FabricCode] fc
				ON vl.FabricCode = fc.ID
			INNER JOIN [dbo].[Company] d
				ON o.Distributor = d.ID
			LEFT OUTER JOIN [dbo].[User] coo
				ON d.Coordinator = coo.ID
			INNER JOIN [dbo].[OrderType] ot
				ON od.OrderType = ot.ID
			INNER JOIN [dbo].[JobName] c
				ON o.Client = c.ID
			INNER JOIN [dbo].[OrderDetailQty] odq
				ON odq.OrderDetail = od.ID
			LEFT OUTER JOIN [dbo].[ProductionLine] pl
				ON p.ProductionLine = pl.ID
			LEFT OUTER JOIN [dbo].[Item] i
				ON p.SubItem = i.ID
			INNER JOIN [dbo].[PrinterType] pt
				ON p.PrinterType = pt.ID
			LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
				ON od.DespatchTo = dca.ID
			LEFT OUTER JOIN [dbo].[DestinationPort] dp
				ON dca.Port= dp.ID
			LEFT OUTER JOIN [dbo].[ShipmentMode] sm
				ON o.ShipmentMode = sm.ID
			LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
				ON od.[Status] = ods.ID
			WHERE od.ShipmentDate >= @WeekStartDate AND od.ShipmentDate <= @WeekEndDate AND it.ItemType = 1 AND os.ID != 28 AND os.ID != 18  AND ( ot.Name = 'ORDER' OR ot.Name = 'GUARANTEED')

			GROUP BY vl.NamePrefix,
			p.Number,p.NickName,fc.Code,fc.Name,o.[Date],od.ShipmentDate,coo.GivenName,coo.FamilyName ,ot.Name,
			d.Name, c.Name,odq.Qty,pl.Name,i.Name,pt.Name,dca.CompanyName,dp.Name,sm.Name,ods.Name,os.Name,it.ItemType,p.SMV,o.PurchaseOrderNo,o.ID,vl.ID,p.ID,fc.ID
			
			IF OBJECT_ID('tempdb..#resTemp') IS NOT NULL
				DROP TABLE #resTemp

			SELECT	CONVERT(nvarchar(4),@Year) + '/' + CONVERT(nvarchar(2),@WeekNumber) AS [Week],
			('PO-'+CAST(o.ID as nvarchar(47))) AS PurchaseOrderNumber,
			o.ID AS [Order],
			p.Number+' - '+p.NickName AS Pattern,
			p.ID AS PatternID,
			o.[Date] AS OrderDate,
			r.ShipmentDate AS ETD,
			coo.GivenName + ' '+ coo.FamilyName AS Coodinator,
			ot.Name AS OrderType,
			d.Name AS Distributor,
			r.Client,
			r.[Qty] AS OrgQty,
			(SELECT ISNULL(SUM(odq.Qty),0)
				FROM [OrderDetail] od				
					JOIN OrderDetailQty odq 
						ON od.ID = odq.OrderDetail
					JOIN Reservation r
						ON od.Reservation = r.ID ) AS UsedQty,
				pt.Name AS PrintType,
				rs.Name AS [Status],
				p.SMV AS SMV,
				ISNULL((p.SMV * odq.Qty), 0) AS TotalSMV INTO #resTemp
		FROM [dbo].[Reservation] r
			LEFT OUTER JOIN [dbo].[Order] o
				ON o.Reservation = r.ID
			LEFT OUTER JOIN [dbo].[Pattern] p
				ON p.ID = r.Pattern
			--INNER JOIN [dbo].[Item] i
			--	ON p.Item = i.ID
			INNER JOIN [dbo].[User] coo
				ON r.Coordinator = coo.ID
			INNER JOIN [dbo].[Company] d
				ON r.Distributor = d.ID
			INNER JOIN [dbo].[PrinterType] pt
				ON p.PrinterType = pt.ID
			INNER JOIN [dbo].[ReservationStatus] rs
				ON r.[Status] = rs.ID
			LEFT OUTER JOIN [dbo].[OrderDetail] od
				ON od.Reservation = r.ID
			LEFT OUTER JOIN [dbo].[OrderType] ot
				ON od.OrderType = ot.ID
			LEFT OUTER JOIN [dbo].[OrderDetailQty] odq
				ON odq.OrderDetail = od.ID
		WHERE  r.ShipmentDate >= @WeekStartDate AND r.ShipmentDate <= @WeekEndDate 

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res
		SELECT d.*,(d.OrgQty-d.UsedQty) AS BalQty INTO #res FROM #resTemp d

		INSERT INTO #firm ([Week],[Order],PurchaseOrderNumber,Product,ProductID,Pattern,PatternID,Fabric,FabricID,OrderDate,ETD,Coodinator,OrderType,Distributor,
					Client,Qty,ProductionLine,ItemSubCat,PrintType,ShipTo,Port,Mode,[Status],SMV,TotalSMV)
			SELECT 
				d.[Week],ISNULL(d.[Order], 0),ISNULL(d.PurchaseOrderNumber,''),'',0,d.Pattern,d.PatternID,'',0,ISNULL(d.OrderDate,''),ISNULL(d.ETD,''),ISNULL(d.Coodinator,''),ISNULL(d.OrderType,''),d.Distributor
					,d.Client,d.OrgQty,'','',ISNULL(d.PrintType,''),'','','',ISNULL(d.[Status],''),ISNULL(d.SMV,0.0),ISNULL(d.TotalSMV,0.0)
			FROM #res d
		SELECT * FROM #firm
	END
	ELSE IF @Type = 8
	BEGIN
		EXEC [dbo].[SPC_GetShipmentsForGivenWeek] @WeekStartDate,@WeekEndDate
	END
	ELSE
	BEGIN
		IF OBJECT_ID('tempdb..#data') IS NOT NULL
			DROP TABLE #data
		SELECT
			CONVERT(nvarchar(4),@Year) + '/' + CONVERT(nvarchar(2),@WeekNumber) AS [Week],
			o.ID AS [Order],
			('PO-'+CAST(o.ID as nvarchar(47))) AS PurchaseOrderNumber,
			vl.NamePrefix AS Product,
			vl.ID AS ProductID,
			p.Number+' - '+p.NickName AS Pattern,
			p.ID AS PatternID,
			fc.Code + ' - '+fc.Name AS Fabric,
			fc.ID AS FabricID ,
			o.[Date] AS OrderDate,
			od.ShipmentDate AS ETD,
			coo.GivenName + ' '+ coo.FamilyName AS Coodinator,
			ot.Name AS OrderType,
			d.Name AS Distributor,
			c.Name AS Client,
			ISNULL(SUM(odq.Qty), 0) AS Qty,
			pl.Name AS ProductionLine,
			COALESCE(i.Name,'') AS ItemSubCat,
			pt.Name AS PrintType,
			COALESCE(dca.CompanyName,'') AS ShipTo,
			COALESCE(dp.Name, '') AS Port,
			COALESCE(sm.Name,'') AS Mode,
			COALESCE(os.Name, '') AS [Status],
			it.ItemType AS ItemType,
			p.SMV,
			(p.SMV * odq.Qty) AS TotalSMV INTO #data
		FROM [dbo].[Order] o
			INNER JOIN [dbo].[OrderDetail] od
				ON od.[Order] = o.ID
			INNER JOIN [dbo].[OrderStatus] os
				ON o.[Status] = os.ID
			INNER JOIN [dbo].[VisualLayout] vl
				ON od.VisualLayout = vl.ID 
			INNER JOIN [dbo].[Pattern] p
				ON vl.Pattern = p.ID
			INNER JOIN [dbo].[Item] it
				ON p.Item = it.ID
			LEFT OUTER JOIN [dbo].[FabricCode] fc
				ON vl.FabricCode = fc.ID
			INNER JOIN [dbo].[Company] d
				ON o.Distributor = d.ID
			LEFT OUTER JOIN [dbo].[User] coo
				ON d.Coordinator = coo.ID
			INNER JOIN [dbo].[OrderType] ot
				ON od.OrderType = ot.ID
			INNER JOIN [dbo].[JobName] c
				ON o.Client = c.ID
			INNER JOIN [dbo].[OrderDetailQty] odq
				ON odq.OrderDetail = od.ID
			LEFT OUTER JOIN [dbo].[ProductionLine] pl
				ON p.ProductionLine = pl.ID
			LEFT OUTER JOIN [dbo].[Item] i
				ON p.SubItem = i.ID
			INNER JOIN [dbo].[PrinterType] pt
				ON p.PrinterType = pt.ID
			LEFT OUTER JOIN [dbo].[Company] st
				ON o.ShipTo = st.ID
			LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
				ON od.DespatchTo = dca.ID
			LEFT OUTER JOIN [dbo].[DestinationPort] dp
				ON dca.Port= dp.ID
			LEFT OUTER JOIN [dbo].[ShipmentMode] sm
				ON o.ShipmentMode = sm.ID
			LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
				ON od.[Status] = ods.ID
			WHERE od.ShipmentDate >= @WeekStartDate AND od.ShipmentDate <= @WeekEndDate AND os.ID != 28 AND os.ID != 18
			GROUP BY vl.NamePrefix,
			p.Number,p.NickName,fc.Code,fc.Name,o.[Date],od.ShipmentDate,coo.GivenName,coo.FamilyName ,ot.Name,
			d.Name, c.Name,odq.Qty,pl.Name,i.Name,pt.Name,dca.CompanyName,dp.Name,sm.Name,ods.Name,os.Name,it.ItemType,p.SMV,o.PurchaseOrderNo,o.ID,vl.ID,p.ID,fc.ID

			SELECT * FROM #data
			WHERE 
				(@Type = 1 AND ( OrderType = 'ORDER' OR OrderType = 'GUARANTEED') AND ItemType = 1 AND ItemType = 1 AND ([Status]  != 'Indico Hold' AND [Status] != 'Indiman Hold' 
					AND [Status] != 'Factory Hold' AND [Status] != 'On Hold'))
				OR
				(@Type = 2 AND ([Status]  = 'Indico Hold' OR [Status] = 'Indiman Hold' 
					OR [Status] = 'Factory Hold' OR [Status] = 'On Hold') AND ItemType = 1)
				OR
				(@Type = 4 AND (OrderType = 'ORDER' OR OrderType = 'GUARANTEED') AND ItemType = 2)
				OR
				(@Type = 5 AND Qty<=5)
				OR
				(@Type = 6 AND OrderType LIKE '%SAMPLE%')
				
	END
END

GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetBackOrdersWeeklySummary]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetBackOrdersWeeklySummary]
GO

CREATE PROC [dbo].[SPC_GetBackOrdersWeeklySummary]
    @P_FromETD datetime2(7) = NULL,
	@P_ToETD datetime2(7) = NULL
AS
BEGIN
	DECLARE @StartETD datetime2(7)
	DECLARE @EndETD datetime2(7)

	IF (@P_FromETD IS NULL)
		SET @StartETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE WeekendDate >= GETDATE())
	ELSE
		SET @StartETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE WeekendDate >= @P_FromETD)
	 
	IF (@P_ToEtd IS NULL)
		SET @EndETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE WeekendDate >= DATEADD(MONTH,2,@StartETD))
	ELSE
		SET @EndETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE WeekendDate >= @P_ToETD)

	IF OBJECT_ID('tempdb..#data1') IS NOT NULL
			DROP TABLE #data1
	SELECT  o.ID AS ID1,
			odq.Qty,
			od.ID AS OrderDetail,
			os.Name AS OrderStatusName,
			ods.Name AS OrderDetailStatusName,
			i.ItemType,
			ot.ID AS OrderTypeID,
			ot.Name AS OrderTypeName,
			--SUM(odq.Qty) AS QtySum,
			od.ShipmentDate INTO #data1
	FROM [dbo].[Order] o
		INNER JOIN [dbo].[OrderDetail] od
			ON o.ID = od.[Order]
		INNER JOIN [dbo].[OrderDetailQty] odq
			ON  odq.OrderDetail = od.ID
		INNER JOIN [dbo].[OrderType] ot
			ON od.OrderType = ot.ID
		INNER JOIN [dbo].[Pattern] p
			ON p.ID = od.Pattern
		INNER JOIN [dbo].[Item] i
			ON p.Item = i.ID
		INNER JOIN [OrderStatus] os
			ON o.[Status] = os.ID
		LEFT OUTER JOIN [OrderDetailStatus] ods
			ON od.[Status] = ods.ID
	WHERE od.ShipmentDate >= DATEADD(DAY,-6,@StartETD) AND od.ShipmentDate <= @EndETD AND  os.ID != 28 AND os.ID != 18

	IF OBJECT_ID('tempdb..#data2') IS NOT NULL
			DROP TABLE #data2
	SELECT	r.[Qty],
		i.ItemType,
		r.ShipmentDate INTO #data2
	FROM [dbo].[Reservation] r
		INNER JOIN [dbo].[Pattern] p
			ON p.ID = r.Pattern
		INNER JOIN [dbo].[Item] i
			ON p.Item = i.ID
	WHERE  r.ShipmentDate >= DATEADD(DAY,-6,@StartETD)
		AND r.ShipmentDate <= @EndETD

	SELECT 
		(CONVERT(nvarchar(2), ((YEAR( GETDATE() ) % 100 ))) + '/' + CONVERT(nvarchar(3), wpc.WeekNo)) AS WeekNumber,
		wpc.WeekNo ,
		wpc.WeekendDate,
		wpc.OrderCutOffDate,
		wpc.EstimatedDateOfDespatch,
		wpc.EstimatedDateOfArrival,
		ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND (OrderTypeName = 'ORDER' OR OrderTypeName = 'GUARANTEED') AND ItemType = 1),0) AS PoloFirms,
		ISNULL((SELECT SUM(Qty) FROM #data2 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 1), 0) AS PoloReservations,
		ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) 
				AND ShipmentDate <= wpc.WeekendDate AND (OrderStatusName = 'Indico Hold' OR OrderStatusName = 'Indiman Hold' 
					OR OrderStatusName = 'Factory Hold' OR OrderDetailStatusName = 'On Hold') AND ItemType = 1), 0) AS PoloHolds,
		ISNULL(wpcd1.TotalCapacity, 0) AS PoloCapacity,
		ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 2 AND (OrderTypeName = 'ORDER' OR OrderTypeName = 'GUARANTEED')), 0) AS OuterWareFirms,
		ISNULL(wpcd2.TotalCapacity,0) AS OuterwareCapacity,
		ISNULL((SELECT SUM(t.Qty) FROM (SELECT Qty FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate  GROUP BY Qty,#data1.ID1 HAVING SUM(Qty) <= 5) t), 0) AS UptoFiveItems,
		ISNULL((wpcd1.FivePcsCapacity + wpcd2.FivePcsCapacity), 0) AS UptoFiveItemsCapacity,
		ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) 
				AND ShipmentDate <= wpc.WeekendDate AND OrderTypeName LIKE '%SAMPLE%'), 0) AS [Samples],
		ISNULL((wpcd1.SampleCapacity +  wpcd2.SampleCapacity), 0) AS SampleCapacity,
		ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 1 AND ( OrderTypeName = 'ORDER' OR OrderTypeName = 'GUARANTEED')), 0) AS TotalPolo
	FROM WeeklyProductionCapacity wpc
		LEFT OUTER JOIN WeeklyProductionCapacityDetails wpcd1
			ON wpcd1.WeeklyProductionCapacity = wpc.ID AND wpcd1.ItemType = 1
		LEFT OUTER JOIN WeeklyProductionCapacityDetails wpcd2
			ON wpcd2.WeeklyProductionCapacity = wpc.ID AND wpcd2.ItemType = 2
	WHERE DATEPART(WEEK,wpc.WeekendDate) >= DATEPART(WEEK,@StartETD) AND DATEPART(YEAR,wpc.WeekendDate) >= DATEPART(YEAR,@StartETD)
		AND DATEPART(WEEK,wpc.WeekendDate) <= DATEPART(WEEK,@EndETD) AND DATEPART(YEAR,wpc.WeekendDate) <= DATEPART(YEAR,@EndETD)
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetFiveWeekDetails]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetFiveWeekDetails]
GO

CREATE PROC [dbo].[SPC_GetFiveWeekDetails]
	@P_ItemType int
AS
BEGIN
	DECLARE @StartDate datetime2(7)
	DECLARE @EndDate datetime2(7)
	SET @StartDate = DATEADD(dd, DATEPART(DW,GETDATE())*-1+4, GETDATE()) -- get this week wednesday wednesday 
	SET @EndDate = DATEADD(DAY,6,@StartDate)
	SET @StartDate = (SELECT TOP 1 WeekendDate FROM [dbo].WeeklyProductionCapacity WHERE WeekendDate >= @StartDate AND WeekendDate <= @EndDate ) -- Get record within this week
	SET @EndDate = DATEADD(DAY,(6*4),@StartDate) -- after 4 weeks
	SET @EndDate = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE WeekNo = DATEPART(WEEK, @EndDate) AND DATEPART(YEAR,WeekendDate) = DATEPART(YEAR,@EndDate))  -- get record from table


	IF OBJECT_ID('tempdb..#data') IS NOT NULL
				DROP TABLE #data
	SELECT  odq.Qty AS Quantity,
			i.ItemType,
			ot.Name AS OrderTypeName,
			od.ShipmentDate
			INTO #data
	FROM [dbo].[Order] o
		INNER JOIN [dbo].[OrderDetail] od
			ON o.ID = od.[Order]
		INNER JOIN [dbo].[OrderDetailQty] odq
			ON  odq.OrderDetail = od.ID
		INNER JOIN [dbo].[OrderType] ot
			ON od.OrderType = ot.ID
		INNER JOIN [dbo].[Pattern] p
			ON p.ID = od.Pattern
		INNER JOIN [dbo].[Item] i
			ON p.Item = i.ID
		INNER JOIN [OrderStatus] os
			ON o.[Status] = os.ID
		LEFT OUTER JOIN [OrderDetailStatus] ods
			ON od.[Status] = ods.ID
	WHERE od.ShipmentDate >= @StartDate AND od.ShipmentDate <= @EndDate AND i.ItemType = @P_ItemType  AND os.ID != 28 AND os.ID != 18

	SELECT
		wpc.WeekNo AS WeekNumber,
		wpc.WeekendDate AS WeekEndDate,
		ISNULL(wpcd.TotalCapacity,0) AS Capacity,
		CAST(wpc.WeekNo AS nvarchar) + '/' + CAST((( YEAR( wpc.WeekendDate ) % 100 )) AS nvarchar) +'  '+ FORMAT(wpc.WeekendDate, 'dddd, dd MMMM yyyy' ) AS [Week],
		(SELECT ISNULL(SUM(Quantity), 0) FROM #data  
				WHERE OrderTypeName 
					LIKE '%SAMPLE%' 
					AND (ShipmentDate >= DATEADD(DAY,-6,wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate)) AS Samples,
		(SELECT  ISNULL(SUM(Quantity), 0) FROM #data
				WHERE (OrderTypeName = 'ORDER' OR OrderTypeName = 'GUARANTEED')
				AND (ShipmentDate >= DATEADD(DAY,-6,wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate)) AS FirmOrders,
		(SELECT ISNULL(SUM(r.[Qty]), 0)
		 FROM [dbo].[Reservation] r
			INNER JOIN [dbo].[Pattern] p
				ON p.ID = r.Pattern
			INNER JOIN [dbo].[Item] i
				ON p.Item = i.ID
			WHERE r.ShipmentDate <= wpc.WeekendDate AND r.ShipmentDate >= DATEADD(DAY,-7,wpc.WeekendDate)
			AND i.ItemType = @P_ItemType) AS Reservations
	FROM [dbo].[WeeklyProductionCapacity] wpc
		LEFT OUTER JOIN [dbo].[WeeklyProductionCapacityDetails] wpcd
			ON wpcd.WeeklyProductionCapacity = wpc.ID AND wpcd.ItemType = @P_ItemType
	WHERE wpc.WeekendDate >= @StartDate AND wpc.WeekendDate <= @EndDate --AND wpcd.ItemType = @P_ItemType
	GROUP BY wpc.WeekendDate,wpc.WeekNo,wpcd.TotalCapacity

	DROP TABLE #data
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetShipmentDetails]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetShipmentDetails]
GO

CREATE PROC [dbo].[SPC_GetShipmentDetails]
	@P_ShipTo nvarchar(250),
	@P_ETD date
AS
BEGIN
	DECLARE @Week datetime2(7)
	DECLARE @WeekNumber int
	DECLARE @ShipTo nvarchar(250)
	SET @ShipTo = @P_ShipTo
	DECLARE @ETD datetime2(7)
	SET @ETD = @P_ETD
	SET @WeekNumber = (SELECT TOP 1 WeekNo FROM [dbo].[WeeklyProductionCapacity] WHERE WeekendDate >= @ETD);
	
	SELECT
			CONVERT(nvarchar(4),DATEPART(YEAR,@ETD)) + '/' + CONVERT(nvarchar(2),@WeekNumber) AS [Week],
			o.ID AS [Order],
			('PO-'+CAST(o.ID as nvarchar(47))) AS PurchaseOrderNumber,
			vl.NamePrefix AS Product,
			vl.ID AS ProductID,
			p.Number+' - '+p.NickName AS Pattern,
			p.ID AS PatternID,
			fc.Code + ' - '+fc.Name AS Fabric,
			fc.ID AS FabricID ,
			o.[Date] AS OrderDate,
			od.ShipmentDate AS ETD,
			coo.GivenName + ' '+ coo.FamilyName AS Coodinator,
			ot.Name AS OrderType,
			d.Name AS Distributor,
			c.Name AS Client,
			ISNULL(SUM(odq.Qty), 0) AS Qty,
			pl.Name AS ProductionLine,
			COALESCE(i.Name,'') AS ItemSubCat,
			pt.Name AS PrintType,
			COALESCE(dca.CompanyName,'') AS ShipTo,
			COALESCE(dp.Name, '') AS Port,
			COALESCE(sm.Name,'') AS Mode,
			COALESCE(os.Name, '') AS [Status],
			p.SMV,
			(p.SMV * odq.Qty) AS TotalSMV 
		FROM [dbo].[Order] o
			INNER JOIN [dbo].[OrderDetail] od
				ON od.[Order] = o.ID
			INNER JOIN [dbo].[OrderStatus] os
				ON o.[Status] = os.ID
			INNER JOIN [dbo].[VisualLayout] vl
				ON od.VisualLayout = vl.ID 
			INNER JOIN [dbo].[Pattern] p
				ON vl.Pattern = p.ID
			INNER JOIN [dbo].[Item] it
				ON p.Item = it.ID
			LEFT OUTER JOIN [dbo].[FabricCode] fc
				ON vl.FabricCode = fc.ID
			INNER JOIN [dbo].[Company] d
				ON o.Distributor = d.ID
			LEFT OUTER JOIN [dbo].[User] coo
				ON d.Coordinator = coo.ID
			INNER JOIN [dbo].[OrderType] ot
				ON od.OrderType = ot.ID
			INNER JOIN [dbo].[JobName] c
				ON o.Client = c.ID
			INNER JOIN [dbo].[OrderDetailQty] odq
				ON odq.OrderDetail = od.ID
			LEFT OUTER JOIN [dbo].[ProductionLine] pl
				ON p.ProductionLine = pl.ID
			LEFT OUTER JOIN [dbo].[Item] i
				ON p.SubItem = i.ID
			INNER JOIN [dbo].[PrinterType] pt
				ON p.PrinterType = pt.ID
			LEFT OUTER JOIN [dbo].[Company] st
				ON o.ShipTo = st.ID
			LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
				ON od.DespatchTo = dca.ID
			LEFT OUTER JOIN [dbo].[DestinationPort] dp
				ON dca.Port= dp.ID
			LEFT OUTER JOIN [dbo].[ShipmentMode] sm
				ON od.ShipmentMode = sm.ID
			LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
				ON od.[Status] = ods.ID
			WHERE  os.ID != 28 AND os.ID != 18  AND dca.CompanyName = @P_ShipTo AND od.ShipmentDate = @ETD -- AND  os.Name = @P_Status

			GROUP BY o.ID
			--p.Number,p.NickName,fc.Code,fc.Name,o.[Date],od.ShipmentDate,coo.GivenName,coo.FamilyName ,ot.Name,
			--d.Name, c.Name,pl.Name,i.Name,pt.Name,dp.Name,sm.Name,ods.Name,os.Name,it.ItemType,p.SMV,o.PurchaseOrderNo,o.ID,vl.ID,p.ID,fc.ID,dca.CompanyName

END 

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GetOrderDetaildForGivenWeekView]'))
	DROP VIEW [dbo].[GetOrderDetaildForGivenWeekView]
GO

CREATE VIEW [dbo].[GetOrderDetaildForGivenWeekView]
AS
SELECT			o.ID AS OrderId,
				od.ID AS OrderDetailId,
				o.ShipmentDate AS OrderShipmentDate,
				od.ShipmentDate AS OrderDetailShipmentDate,
				ot.[Name] AS OrderType,
				dis.[Name] AS Distributor,
				CASE 
					WHEN dis.IncludeAsMYOBInvoice = 1
						THEN ISNULL(dis.JobName, '')
						ELSE 'Wholesale'
				END AS JobName,
				c.[Name] AS Client,
				'PO-' + CAST(o.ID AS nvarchar(47)) AS PurchaseOrder,
				vl.[NamePrefix],
				p.[Number] + ' - ' + p.[NickName] AS Pattern,
				fc.[Code] + ' - ' + fc.[NickName] AS Fabric,
				fc.[Filaments] AS Material,
				g.Name AS Gender,
				ag.Name AS AgeGroup,
				'' AS SleeveShape,
				'' AS SleeveLength,
				COALESCE(i.[Name], '') AS ItemSubGroup,
				s.SizeName,
				odq.Qty AS Quentity,
				os.Name AS [Status],
				0 AS PrintedCount,
				COALESCE(
					(SELECT TOP 1 
						'http://gw.indiman.net/IndicoData/PatternTemplates/' + CAST(pti.Pattern AS nvarchar(8)) + '/' + pti.[Filename] + pti.Extension
					FROM [dbo].[PatternTemplateImage] pti WHERE p.ID = pti.Pattern AND pti.IsHero = 1
					), '' 
				) AS PatternImagePath,
				COALESCE(
					(SELECT TOP 1 
						'http://gw.indiman.net/IndicoData/VisualLayout/' + CAST(vl.ID AS nvarchar(8)) + '/' + im.[Filename] + im.Extension
					FROM [dbo].[Image] im WHERE vl.ID = im.VisualLayout AND im.IsHero = 1
					), '' 
				) AS VLImagePath,
				p.[Number],
				0.0 AS OtherCharges,
				'' AS Notes,
				'' AS PatternInvoiceNotes,
				'' AS ProductNotes,
				COALESCE(cs.QuotedFOBCost, 0.0) AS JKFOBCostSheetPrice,
				COALESCE(cs.QuotedCIF, 0.0) AS IndimanCIFCostSheetPrice,
				ISNULL(CAST((SELECT CASE
									WHEN (p.[SubItem] IS NULL)
										THEN  	('')
									ELSE (CAST((SELECT TOP 1 hsc.[Code] FROM [dbo].[HSCode] hsc WHERE hsc.[ItemSubCategory] = p.[SubItem] AND hsc.[Gender] = p.[Gender]) AS nvarchar(64)))
							END) AS nvarchar (64)), '') AS HSCode,
				ISNULL(CAST((SELECT CASE
									WHEN (p.[SubItem] IS NULL)
										THEN  	('')
									ELSE (CAST((SELECT it.[Name] FROM [dbo].[Item] it WHERE it.[ID] = i.[Parent]) AS nvarchar(64)))
							END) AS nvarchar (64)), '') AS ItemName,
				o.PurchaseOrderNo,
				dca.ID AS DistributorClientAddressID, --new
				dca.CompanyName AS DistributorClientAddressName,
				COALESCE(dp.Name, '') AS DestinationPort,
			    COALESCE(sm.Name, '') AS ShipmentMode,
			    COALESCE(pm.Name,'') AS PaymentMethod 
	FROM [dbo].[OrderDetail] od
		INNER JOIN [dbo].[Order] o
			ON od.[Order] = o.ID
		INNER JOIN [dbo].[OrderStatus] os
			ON o.[Status] = os.ID
		INNER JOIN [dbo].[Company] dis
			ON dis.[ID] = o.[Distributor]		
		INNER JOIN [dbo].[OrderType] ot
			ON od.[OrderType] = ot.[ID]
		INNER JOIN [dbo].[VisualLayout] vl
			ON od.[VisualLayout] = vl.ID	
		INNER JOIN [dbo].[Pattern] p
			ON od.Pattern = p.ID
		INNER JOIN [dbo].[SizeSet] ss
			ON p.SizeSet = ss.ID
		INNER JOIN [dbo].[Size] s
			ON s.SizeSet = ss.ID
		INNER JOIN [dbo].[FabricCode] fc
			ON od.FabricCode = fc.ID
		LEFT OUTER JOIN [dbo].[Gender] g
			ON p.Gender = g.ID
		LEFT OUTER JOIN [dbo].[AgeGroup] ag
			ON p.AgeGroup = ag.ID
		LEFT OUTER JOIN [dbo].[Item] i
			ON p.[SubItem] = i.ID
		INNER JOIN [dbo].[JobName] c
			ON o.Client = c.ID	
		LEFT OUTER JOIN [dbo].[CostSheet] cs	
			ON p.ID = cs.Pattern
				AND fc.ID = cs.Fabric
		INNER JOIN [dbo].[OrderDetailQty] odq
			ON od.ID = odq.OrderDetail
				AND odq.Size = s.ID
		INNER JOIN [dbo].[DistributorClientAddress] dca
			ON od.[DespatchTo] = dca.[ID]
		LEFT OUTER JOIN [dbo].[DestinationPort] dp
			ON dca.[Port] = dp.[ID]
		LEFT OUTER JOIN [dbo].[ShipmentMode] sm
			ON od.[ShipmentMode] = sm.[ID] 
		LEFT OUTER JOIN [dbo].[PaymentMethod] pm
			ON od.[PaymentMethod] = pm.[ID]
WHERE odq.Qty != 0 AND o.[Status] != 28 AND o.[Status] != 18

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

INSERT INTO [dbo].[PatternDevelopment] (Pattern,Creator)
	SELECT 
		p.ID,
		1
	FROM [dbo].[Pattern] p
		LEFT OUTER JOIN [dbo].[PatternDevelopment] pd
			ON pd.Pattern = p.ID
	WHERE pd.ID IS NULL

GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

-- query for update WeeklyProductionCapacity
UPDATE wpc
   SET wpc.OrderCutOffDate = DATEADD(DAY,-25,wpc.WeekendDate),
   wpc.EstimatedDateOfDespatch = DATEADD(DAY,-10,wpc.WeekendDate),
   wpc.EstimatedDateOfArrival = DATEADD(DAY,-4,wpc.WeekendDate)
 FROM [dbo].[WeeklyProductionCapacity]  wpc
WHERE wpc.WeekendDate IS NOT NULL

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--


-- query for delete Duplicate CostSheets
DELETE FROM [dbo].[PatternSupportFabric]
WHERE CostSheet IN(
	5654,5550,4605,4581,5303,3712,4458,5506,5351,4896,4207,5922,5871,3890,4539,5802,4328,5181,5655,5803,3908,5815,5816,3728,5188,4119,3188,5172,5931,4530,4898,4757,4768,3547,4221,5072,4795,3642,5326,3543,3484,3858,4401,5288,4345,4531,3089,4697,4704,3210,3081,3454,4718,3347,5817,4903,1821,1820,5804,5708,5031,5175,4566,4396,5165,4185,1952,1955,1958,4721,4479,4179,3991,5343,4510,4986,3629,4488,3830,4320,5577,5189,5076,5436,5641,3797,5183,5685,4203,5366,5806,4533,5242,3665,5868,5893,5019,3998,4932,3780,5166,4218,4116,5050,2096,5316,3948,3648,5808,3863,5491,5698,3455,5464,5272,3943,4866,4108,4676,2675,2730,5500,4943,4763,5809,4936,4042,5053,4086,5571,5454,4468,5456,4753,3898,4350,5801,4895,5810
)

DELETE FROM [dbo].[PatternSupportAccessory]
WHERE CostSheet IN(
	5654,5550,4605,4581,5303,3712,4458,5506,5351,4896,4207,5922,5871,3890,4539,5802,4328,5181,5655,5803,3908,5815,5816,3728,5188,4119,3188,5172,5931,4530,4898,4757,4768,3547,4221,5072,4795,3642,5326,3543,3484,3858,4401,5288,4345,4531,3089,4697,4704,3210,3081,3454,4718,3347,5817,4903,1821,1820,5804,5708,5031,5175,4566,4396,5165,4185,1952,1955,1958,4721,4479,4179,3991,5343,4510,4986,3629,4488,3830,4320,5577,5189,5076,5436,5641,3797,5183,5685,4203,5366,5806,4533,5242,3665,5868,5893,5019,3998,4932,3780,5166,4218,4116,5050,2096,5316,3948,3648,5808,3863,5491,5698,3455,5464,5272,3943,4866,4108,4676,2675,2730,5500,4943,4763,5809,4936,4042,5053,4086,5571,5454,4468,5456,4753,3898,4350,5801,4895,5810
)

DELETE FROM [dbo].[CostSheetRemarks]
WHERE CostSheet IN(
	5654,5550,4605,4581,5303,3712,4458,5506,5351,4896,4207,5922,5871,3890,4539,5802,4328,5181,5655,5803,3908,5815,5816,3728,5188,4119,3188,5172,5931,4530,4898,4757,4768,3547,4221,5072,4795,3642,5326,3543,3484,3858,4401,5288,4345,4531,3089,4697,4704,3210,3081,3454,4718,3347,5817,4903,1821,1820,5804,5708,5031,5175,4566,4396,5165,4185,1952,1955,1958,4721,4479,4179,3991,5343,4510,4986,3629,4488,3830,4320,5577,5189,5076,5436,5641,3797,5183,5685,4203,5366,5806,4533,5242,3665,5868,5893,5019,3998,4932,3780,5166,4218,4116,5050,2096,5316,3948,3648,5808,3863,5491,5698,3455,5464,5272,3943,4866,4108,4676,2675,2730,5500,4943,4763,5809,4936,4042,5053,4086,5571,5454,4468,5456,4753,3898,4350,5801,4895,5810
)

DELETE FROM [dbo].[IndimanCostSheetRemarks]
WHERE CostSheet IN(
	5654,5550,4605,4581,5303,3712,4458,5506,5351,4896,4207,5922,5871,3890,4539,5802,4328,5181,5655,5803,3908,5815,5816,3728,5188,4119,3188,5172,5931,4530,4898,4757,4768,3547,4221,5072,4795,3642,5326,3543,3484,3858,4401,5288,4345,4531,3089,4697,4704,3210,3081,3454,4718,3347,5817,4903,1821,1820,5804,5708,5031,5175,4566,4396,5165,4185,1952,1955,1958,4721,4479,4179,3991,5343,4510,4986,3629,4488,3830,4320,5577,5189,5076,5436,5641,3797,5183,5685,4203,5366,5806,4533,5242,3665,5868,5893,5019,3998,4932,3780,5166,4218,4116,5050,2096,5316,3948,3648,5808,3863,5491,5698,3455,5464,5272,3943,4866,4108,4676,2675,2730,5500,4943,4763,5809,4936,4042,5053,4086,5571,5454,4468,5456,4753,3898,4350,5801,4895,5810
)

DELETE FROM [dbo].[CostSheet] WHERE ID 
IN(
	5654,5550,4605,4581,5303,3712,4458,5506,5351,4896,4207,5922,5871,3890,4539,5802,4328,5181,5655,5803,3908,5815,5816,3728,5188,4119,3188,5172,5931,4530,4898,4757,4768,3547,4221,5072,4795,3642,5326,3543,3484,3858,4401,5288,4345,4531,3089,4697,4704,3210,3081,3454,4718,3347,5817,4903,1821,1820,5804,5708,5031,5175,4566,4396,5165,4185,1952,1955,1958,4721,4479,4179,3991,5343,4510,4986,3629,4488,3830,4320,5577,5189,5076,5436,5641,3797,5183,5685,4203,5366,5806,4533,5242,3665,5868,5893,5019,3998,4932,3780,5166,4218,4116,5050,2096,5316,3948,3648,5808,3863,5491,5698,3455,5464,5272,3943,4866,4108,4676,2675,2730,5500,4943,4763,5809,4936,4042,5053,4086,5571,5454,4468,5456,4753,3898,4350,5801,4895,5810
)

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

