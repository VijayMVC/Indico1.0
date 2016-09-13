USE [Indico]
GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySummariesForPieces]    Script Date: 2016-06-08 06:05:56 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklySummariesForPieces]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetWeeklySummariesForPieces]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SPC_GetWeeklySummariesForPieces]
	@P_StartMonth int,
	@P_StartYear int
	
AS
BEGIN

	IF OBJECT_ID('tempdb..#data1') IS NOT NULL
		DROP TABLE #data1
	IF OBJECT_ID('tempdb..#data2') IS NOT NULL
		DROP TABLE #data2

	DECLARE @StartDate datetime2(7)

	SELECT TOP 1  @StartDate = DATEADD(DAY,-6,wpc.WeekendDate)
	FROM WeeklyProductionCapacity wpc
	WHERE MONTH(wpc.WeekendDate) >= @P_StartMonth
				AND YEAR(wpc.WeekEndDate) >= @P_StartYear
	ORDER BY wpc.ID

	SELECT  o.ID AS ID1,
			odq.Qty,
			os.Name AS OrderStatusName,
			ods.Name AS OrderDetailStatusName,
			i.ItemType,
			ot.ID AS OrderTypeID,
			ot.Name AS OrderTypeName,
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
	WHERE od.ShipmentDate >= @StartDate

	SELECT	r.[Qty],
			i.ItemType,
			r.ShipmentDate INTO #data2
	FROM [dbo].[Reservation] r
		INNER JOIN [dbo].[Pattern] p
			ON p.ID = r.Pattern
		INNER JOIN [dbo].[Item] i
			ON p.Item = i.ID
	WHERE  r.ShipmentDate >= @StartDate

	SELECT	DISTINCT wpc.WeekNo AS WeekNumber,
			--YEAR(wpc.WeekEndDate) AS [Year],
			wpc.WeekEndDate, 
			wpc.OrderCutOffDate,
			wpc.EstimatedDateOfDespatch,
			wpc.EstimatedDateOfArrival,
			wpc.Capacity,
			wpc.NoOfHolidays AS NumberOfHoliDays,
			--wpcd1.ItemType,
			wpcd1.TotalCapacity AS PoloCapacity,
			wpcd1.FivePcsCapacity AS PoloFivePcsCapacity,
			wpcd1.SampleCapacity AS PoloSampleCapacity,
			wpcd1.Workers AS PoloWorkers,
			wpcd1.Efficiency AS PoloEfficiency ,
			(SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 1 AND (OrderTypeName = 'ORDER' OR OrderTypeName = 'GUARANTEED')) AS PoloFirms,
			(SELECT SUM(Qty) FROM #data2 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 1) AS PoloReservations,
			(SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) 
				AND ShipmentDate <= wpc.WeekendDate AND (OrderStatusName = 'Indico Hold' OR OrderStatusName = 'Indiman Hold' 
					OR OrderStatusName = 'Factory Hold' OR OrderDetailStatusName = 'On Hold') AND ItemType = 1) AS PoloHolds,
			(SELECT SUM(t.Qty) FROM (SELECT ID1, SUM(Qty) AS Qty FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 1 GROUP BY ID1 HAVING SUM(Qty) <= 5) t) AS PoloUptoFiveItems,
			(SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) 
				AND ShipmentDate <= wpc.WeekendDate AND OrderTypeName LIKE '%SAMPLE%' AND ItemType = 1) AS [PoloSamples],
			--wpcd2.ItemType,
			wpcd2.TotalCapacity AS OuterwareCapacity,
			wpcd2.FivePcsCapacity AS OuterwareFivePcsCapacity,
			wpcd2.SampleCapacity AS OuterwareSampleCapacity,
			wpcd2.Workers AS OuterwareWorkers,
			wpcd2.Efficiency AS OuterwareEfficiency,
			(SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 2 AND (OrderTypeName = 'ORDER' OR OrderTypeName = 'GUARANTEED')) AS OuterWareFirms,
			(SELECT SUM(Qty) FROM #data2 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 2) AS OuterwareReservations,
			(SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) 
				AND ShipmentDate <= wpc.WeekendDate AND (OrderStatusName = 'Indico Hold' OR OrderStatusName = 'Indiman Hold' 
					OR OrderStatusName = 'Factory Hold' OR OrderDetailStatusName = 'On Hold') AND ItemType = 2) AS OuterwareHolds,
			(SELECT SUM(t.Qty) FROM (SELECT ID1, SUM(Qty) AS Qty FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 2 GROUP BY ID1 HAVING SUM(Qty) <= 5) t) AS OuterwareUptoFiveItems,
			(SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) 
				AND ShipmentDate <= wpc.WeekendDate AND OrderTypeName LIKE '%SAMPLE%' AND ItemType = 2) AS OuterwareSamples
	FROM WeeklyProductionCapacity wpc
		INNER JOIN WeeklyProductionCapacityDetails wpcd1
			ON wpcd1.WeeklyProductionCapacity = wpc.ID
				AND wpcd1.ItemType = 1
		INNER JOIN WeeklyProductionCapacityDetails wpcd2
			ON wpcd2.WeeklyProductionCapacity = wpc.ID
				AND wpcd2.ItemType = 2
	WHERE MONTH(wpc.WeekendDate) >= @P_StartMonth
				AND YEAR(wpc.WeekEndDate) >= @P_StartYear
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySummariesForSMV]    Script Date: 2016-06-08 06:06:38 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklySummariesForSMV]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetWeeklySummariesForSMV]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[SPC_GetWeeklySummariesForSMV]
	@P_StartMonth int,
	@P_StartYear int
	
AS
BEGIN

	IF OBJECT_ID('tempdb..#data1') IS NOT NULL
		DROP TABLE #data1
	IF OBJECT_ID('tempdb..#data2') IS NOT NULL
		DROP TABLE #data2

	DECLARE @StartDate datetime2(7)

	SELECT TOP 1  @StartDate = DATEADD(DAY,-6,wpc.WeekendDate)
	FROM WeeklyProductionCapacity wpc
	WHERE MONTH(wpc.WeekendDate) >= @P_StartMonth
				AND YEAR(wpc.WeekEndDate) >= @P_StartYear
	ORDER BY wpc.ID

	SELECT  o.ID AS ID1,
			odq.Qty,
			os.Name AS OrderStatusName,
			ods.Name AS OrderDetailStatusName,
			i.ItemType,
			ot.ID AS OrderTypeID,
			ot.Name AS OrderTypeName,
			od.ShipmentDate,
			p.SMV INTO #data1
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
	WHERE od.ShipmentDate >= @StartDate

	SELECT	r.[Qty],
			i.ItemType,
			r.ShipmentDate, 
			p.SMV INTO #data2
	FROM [dbo].[Reservation] r
		INNER JOIN [dbo].[Pattern] p
			ON p.ID = r.Pattern
		INNER JOIN [dbo].[Item] i
			ON p.Item = i.ID
	WHERE  r.ShipmentDate >= @StartDate

	SELECT	DISTINCT wpc.WeekNo AS WeekNumber,
			--YEAR(wpc.WeekEndDate) AS [Year],
			wpc.WeekEndDate, 
			wpc.OrderCutOffDate,
			wpc.EstimatedDateOfDespatch,
			wpc.EstimatedDateOfArrival,
			wpc.Capacity,
			wpc.NoOfHolidays AS NumberOfHoliDays,
			--wpcd1.ItemType,
			wpcd1.TotalCapacity AS PoloCapacity,
			wpcd1.FivePcsCapacity AS PoloFivePcsCapacity,
			wpcd1.SampleCapacity AS PoloSampleCapacity,
			wpcd1.Workers AS PoloWorkers,
			wpcd1.Efficiency AS PoloEfficiency ,
			(SELECT SUM(Qty * SMV) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 1 AND (OrderTypeName = 'ORDER' OR OrderTypeName = 'GUARANTEED')) AS PoloFirms,
			(SELECT SUM(Qty * SMV) FROM #data2 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 1) AS PoloReservations,
			(SELECT SUM(Qty * SMV) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) 
				AND ShipmentDate <= wpc.WeekendDate AND (OrderStatusName = 'Indico Hold' OR OrderStatusName = 'Indiman Hold' 
					OR OrderStatusName = 'Factory Hold' OR OrderDetailStatusName = 'On Hold') AND ItemType = 1) AS PoloHolds,
			(SELECT SUM(t.Qty) FROM (SELECT ID1, SUM(Qty * SMV) AS Qty FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 1 GROUP BY ID1 HAVING SUM(Qty) <= 5) t) AS PoloUptoFiveItems,
			(SELECT SUM(Qty * SMV) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) 
				AND ShipmentDate <= wpc.WeekendDate AND OrderTypeName LIKE '%SAMPLE%' AND ItemType = 1) AS [PoloSamples],
			--wpcd2.ItemType,
			wpcd2.TotalCapacity AS OuterwareCapacity,
			wpcd2.FivePcsCapacity AS OuterwareFivePcsCapacity,
			wpcd2.SampleCapacity AS OuterwareSampleCapacity,
			wpcd2.Workers AS OuterwareWorkers,
			wpcd2.Efficiency AS OuterwareEfficiency,
			(SELECT SUM(Qty * SMV) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 2 AND (OrderTypeName = 'ORDER' OR OrderTypeName = 'GUARANTEED')) AS OuterWareFirms,
			(SELECT SUM(Qty * SMV) FROM #data2 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 2) AS OuterwareReservations,
			(SELECT SUM(Qty * SMV) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) 
				AND ShipmentDate <= wpc.WeekendDate AND (OrderStatusName = 'Indico Hold' OR OrderStatusName = 'Indiman Hold' 
					OR OrderStatusName = 'Factory Hold' OR OrderDetailStatusName = 'On Hold') AND ItemType = 2) AS OuterwareHolds,
			(SELECT SUM(t.Qty) FROM (SELECT ID1, SUM(Qty * SMV) AS Qty FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 2 GROUP BY ID1 HAVING SUM(Qty) <= 5) t) AS OuterwareUptoFiveItems,
			(SELECT SUM(Qty * SMV) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) 
				AND ShipmentDate <= wpc.WeekendDate AND OrderTypeName LIKE '%SAMPLE%' AND ItemType = 2) AS OuterwareSamples
	FROM WeeklyProductionCapacity wpc
		INNER JOIN WeeklyProductionCapacityDetails wpcd1
			ON wpcd1.WeeklyProductionCapacity = wpc.ID
				AND wpcd1.ItemType = 1
		INNER JOIN WeeklyProductionCapacityDetails wpcd2
			ON wpcd2.WeeklyProductionCapacity = wpc.ID
				AND wpcd2.ItemType = 2
	WHERE MONTH(wpc.WeekendDate) >= @P_StartMonth
				AND YEAR(wpc.WeekEndDate) >= @P_StartYear
END


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetFirmOrdersForGivenWeekForPieces]    Script Date: 2016-06-08 06:00:17 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetFirmOrdersForGivenWeekForPieces]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetFirmOrdersForGivenWeekForPieces]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SPC_GetFirmOrdersForGivenWeekForPieces]
	@P_WeekEndDate date	
AS
BEGIN
	SELECT DISTINCT 
		CAST((YEAR(@P_WeekEndDate) % 100) AS nvarchar(4)) + '/' + CAST(DATEPART(WK,@P_WeekEndDate) AS nvarchar(2) ) AS [Week] ,
		o.PurchaseOrderNo AS PurchaseOrderNumber,
		vl.NamePrefix AS VlName,
		CAST(p.Number AS nvarchar(4)) + ' - ' + p.NickName AS Pattern,
		fc.Code + '-' + fc.Name AS Fabric,
		o.[Date] AS OrderDate,
		od.ShipmentDate AS ETD,
		c.GivenName + ' ' + c.FamilyName AS Coodinator,
		ot.Name AS OrderType,
		d.Name AS Distributor,
		cl.Name AS Client,
		SUM(odq.Qty) AS Quantity,
		pl.Name AS ProductionLine,
		i.Name AS SubItemName,
		pt.Name AS PrintType,
		st.Name AS ShipTo,
		dp.Name AS Port,
		sm.Name AS Mode,
		os.Name AS [Status],
		p.SMV AS SMV,
		SUM(odq.Qty * p.SMV) AS TotalSMV
	FROM [dbo].[OrderDetail] od
		INNER JOIN [dbo].[Order] o
			ON od.[Order] = o.ID
		INNER JOIN [dbo].VisualLayout vl
			ON od.VisualLayout = vl.ID 
		INNER JOIN [dbo].OrderDetailQty odq
			ON odq.OrderDetail = od.ID
		INNER JOIN [dbo].Pattern p
			ON vl.Pattern = p.ID
		INNER JOIN [dbo].[OrderType] ot
			ON od.OrderType = ot.ID
		INNER JOIN [dbo].[Company] d
			ON o.Distributor = d.ID
		LEFT OUTER JOIN [dbo].[User] c
			ON c.ID = d.Coordinator
		INNER JOIN [dbo].[Client] cl
			ON cl.ID = o.Client
		LEFT OUTER JOIN [dbo].[Company] st
			ON o.ShipTo = st.ID
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
			ON dca.Client = cl.ID
		LEFT OUTER JOIN [dbo].[DestinationPort] dp
			ON dca.Port = dp.ID
		INNER JOIN [dbo].[OrderStatus] os
			ON os.ID = o.[Status]
		LEFT OUTER JOIN [dbo].[Item] i
			ON p.SubItem = i.ID
		LEFT OUTER JOIN [dbo].[Item] itm
			ON p.Item = itm.ID
		LEFT OUTER JOIN [dbo].[FabricCode] fc
			ON vl.FabricCode = fc.ID
		LEFT OUTER JOIN [dbo].[ProductionLine] pl
			ON pl.ID =  p.ProductionLine
		LEFT OUTER JOIN [dbo].[PrinterType] pt
			ON p.PrinterType = pt.ID
		LEFT OUTER JOIN [dbo].[ShipmentMode] sm
			ON o.ShipmentMode = sm.ID
	WHERE	(od.ShipmentDate BETWEEN DATEADD(DAY, -6, @P_WeekEndDate) AND @P_WeekEndDate)
			AND (ot.Name = 'ORDER' OR ot.Name = 'GUARANTEED')
			AND itm.ItemType = 1
			AND (os.ID NOT IN (28, 23, 25, 27))
	GROUP BY  --CAST(@P_Year AS nvarchar(4)) + '/' + CAST(@P_WeekNo AS nvarchar(2) ),
		o.PurchaseOrderNo,
		vl.NamePrefix,
		CAST(p.Number AS nvarchar(4)) + ' - ' + p.NickName,
		fc.Code + '-' + fc.Name,
		o.[Date],
		od.ShipmentDate,
		c.GivenName + ' ' + c.FamilyName,
		ot.Name,
		d.Name,
		cl.Name,
		pl.Name,
		i.Name,
		pt.Name,
		st.Name,
		dp.Name,
		sm.Name,
		os.Name,
		p.SMV
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetHoldItemsForGivenWeekForPieces]    Script Date: 2016-06-08 06:01:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetHoldItemsForGivenWeekForPieces]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetHoldItemsForGivenWeekForPieces]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SPC_GetHoldItemsForGivenWeekForPieces]
	@P_WeekEndDate date	
AS
BEGIN
	SELECT DISTINCT 
		CAST((YEAR(@P_WeekEndDate) % 100) AS nvarchar(4)) + '/' + CAST(DATEPART(WK,@P_WeekEndDate) AS nvarchar(2) ) AS [Week] ,
		o.PurchaseOrderNo AS PurchaseOrderNumber,
		vl.NamePrefix AS VlName,
		CAST(p.Number AS nvarchar(4)) + ' - ' + p.NickName AS Pattern,
		fc.Code + '-' + fc.Name AS Fabric,
		o.[Date] AS OrderDate,
		od.ShipmentDate AS ETD,
		c.GivenName + ' ' + c.FamilyName AS Coodinator,
		ot.Name AS OrderType,
		d.Name AS Distributor,
		cl.Name AS Client,
		SUM(odq.Qty) AS Quantity,
		pl.Name AS ProductionLine,
		i.Name AS SubItemName,
		pt.Name AS PrintType,
		st.Name AS ShipTo,
		dp.Name AS Port,
		sm.Name AS Mode,
		os.Name AS [Status],
		p.SMV AS SMV,
		SUM(odq.Qty * p.SMV) AS TotalSMV
	FROM [dbo].[OrderDetail] od
		INNER JOIN [dbo].[Order] o
			ON od.[Order] = o.ID
		INNER JOIN [dbo].VisualLayout vl
			ON od.VisualLayout = vl.ID 
		INNER JOIN [dbo].OrderDetailQty odq
			ON odq.OrderDetail = od.ID
		INNER JOIN [dbo].Pattern p
			ON vl.Pattern = p.ID
		INNER JOIN [dbo].[OrderType] ot
			ON od.OrderType = ot.ID
		INNER JOIN [dbo].[Company] d
			ON o.Distributor = d.ID
		LEFT OUTER JOIN [dbo].[User] c
			ON c.ID = d.Coordinator
		INNER JOIN [dbo].[Client] cl
			ON cl.ID = o.Client
		LEFT OUTER JOIN [dbo].[Company] st
			ON o.ShipTo = st.ID
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
			ON dca.Client = cl.ID
		LEFT OUTER JOIN [dbo].[DestinationPort] dp
			ON dca.Port = dp.ID
		INNER JOIN [dbo].[OrderStatus] os
			ON os.ID = o.[Status]
		LEFT OUTER JOIN [dbo].[Item] i
			ON p.SubItem = i.ID
		LEFT OUTER JOIN [dbo].[Item] itm
			ON p.Item = itm.ID
		LEFT OUTER JOIN [dbo].[FabricCode] fc
			ON vl.FabricCode = fc.ID
		LEFT OUTER JOIN [dbo].[ProductionLine] pl
			ON pl.ID =  p.ProductionLine
		LEFT OUTER JOIN [dbo].[PrinterType] pt
			ON p.PrinterType = pt.ID
		LEFT OUTER JOIN [dbo].[ShipmentMode] sm
			ON o.ShipmentMode = sm.ID
	WHERE	(od.ShipmentDate BETWEEN DATEADD(DAY, -6, @P_WeekEndDate) AND @P_WeekEndDate)
			--AND (ot.Name = 'ORDER' OR ot.Name = 'GUARANTEED')
			AND itm.ItemType = 1
			AND (os.ID IN ( 23, 25, 27))
			AND (os.ID != 28)
	GROUP BY  --CAST(@P_Year AS nvarchar(4)) + '/' + CAST(@P_WeekNo AS nvarchar(2) ),
		o.PurchaseOrderNo,
		vl.NamePrefix,
		CAST(p.Number AS nvarchar(4)) + ' - ' + p.NickName,
		fc.Code + '-' + fc.Name,
		o.[Date],
		od.ShipmentDate,
		c.GivenName + ' ' + c.FamilyName,
		ot.Name,
		d.Name,
		cl.Name,
		pl.Name,
		i.Name,
		pt.Name,
		st.Name,
		dp.Name,
		sm.Name,
		os.Name,
		p.SMV
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetReservationsForGivenWeekForPieces]    Script Date: 2016-06-08 06:03:13 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetReservationsForGivenWeekForPieces]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetReservationsForGivenWeekForPieces]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SPC_GetReservationsForGivenWeekForPieces]
	@P_WeekEndDate date	
AS
BEGIN
	SELECT DISTINCT 
		CAST((YEAR(@P_WeekEndDate) % 100) AS nvarchar(4)) + '/' + CAST(DATEPART(WK,@P_WeekEndDate) AS nvarchar(2) ) AS [Week] ,
		o.PurchaseOrderNo AS PurchaseOrderNumber,
		vl.NamePrefix AS VlName,
		CAST(p.Number AS nvarchar(4)) + ' - ' + p.NickName AS Pattern,
		fc.Code + '-' + fc.Name AS Fabric,
		o.[Date] AS OrderDate,
		od.ShipmentDate AS ETD,
		c.GivenName + ' ' + c.FamilyName AS Coodinator,
		ot.Name AS OrderType,
		d.Name AS Distributor,
		cl.Name AS Client,
		SUM(odq.Qty) AS Quantity,
		pl.Name AS ProductionLine,
		i.Name AS SubItemName,
		pt.Name AS PrintType,
		st.Name AS ShipTo,
		dp.Name AS Port,
		sm.Name AS Mode,
		os.Name AS [Status],
		p.SMV AS SMV,
		SUM(odq.Qty * p.SMV) AS TotalSMV
	FROM [dbo].[Reservation] r 
		INNER JOIN [dbo].[OrderDetail] od
			ON od.Reservation = r.ID 
		INNER JOIN [dbo].[Order] o
			ON od.[Order] = o.ID
		INNER JOIN [dbo].VisualLayout vl
			ON od.VisualLayout = vl.ID 
		INNER JOIN [dbo].OrderDetailQty odq
			ON odq.OrderDetail = od.ID
		INNER JOIN [dbo].Pattern p
			ON vl.Pattern = p.ID
		INNER JOIN [dbo].[OrderType] ot
			ON od.OrderType = ot.ID
		INNER JOIN [dbo].[Company] d
			ON o.Distributor = d.ID
		LEFT OUTER JOIN [dbo].[User] c
			ON c.ID = d.Coordinator
		INNER JOIN [dbo].[Client] cl
			ON cl.ID = o.Client
		LEFT OUTER JOIN [dbo].[Company] st
			ON o.ShipTo = st.ID
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
			ON dca.Client = cl.ID
		LEFT OUTER JOIN [dbo].[DestinationPort] dp
			ON dca.Port = dp.ID
		INNER JOIN [dbo].[OrderStatus] os
			ON os.ID = o.[Status]
		LEFT OUTER JOIN [dbo].[Item] i
			ON p.SubItem = i.ID
		LEFT OUTER JOIN [dbo].[Item] itm
			ON p.Item = itm.ID
		LEFT OUTER JOIN [dbo].[FabricCode] fc
			ON vl.FabricCode = fc.ID
		LEFT OUTER JOIN [dbo].[ProductionLine] pl
			ON pl.ID =  p.ProductionLine
		LEFT OUTER JOIN [dbo].[PrinterType] pt
			ON p.PrinterType = pt.ID
		LEFT OUTER JOIN [dbo].[ShipmentMode] sm
			ON o.ShipmentMode = sm.ID
	WHERE	(r.ShipmentDate BETWEEN DATEADD(DAY, -6, @P_WeekEndDate) AND @P_WeekEndDate)
			--AND (ot.Name = 'ORDER' OR ot.Name = 'GUARANTEED')
			AND itm.ItemType = 1
			AND (os.ID NOT IN (28, 23, 25, 27))
	GROUP BY  --CAST(@P_Year AS nvarchar(4)) + '/' + CAST(@P_WeekNo AS nvarchar(2) ),
		o.PurchaseOrderNo,
		vl.NamePrefix,
		CAST(p.Number AS nvarchar(4)) + ' - ' + p.NickName,
		fc.Code + '-' + fc.Name,
		o.[Date],
		od.ShipmentDate,
		c.GivenName + ' ' + c.FamilyName,
		ot.Name,
		d.Name,
		cl.Name,
		pl.Name,
		i.Name,
		pt.Name,
		st.Name,
		dp.Name,
		sm.Name,
		os.Name,
		p.SMV
END


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetFiveWeekDetails]    Script Date: 2016-06-13 09:59:36 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetFiveWeekDetails]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetFiveWeekDetails]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[SPC_GetFiveWeekDetails]
	@P_ItemType int
AS
BEGIN

	SET DATEFIRST 7
	DECLARE @d datetime2(7)
	SET @d = GETDATE()
	DECLARE @NEXT_TUESDAY datetime2(7)
	DECLARE @START_WEDNESDAY datetime2(7)

	SELECT @NEXT_TUESDAY = DATEADD(day, (10  + @@DATEFIRST - DATEPART(dw, @d)) % 7, @d)
	SELECT @START_WEDNESDAY = DATEADD(day, -6, @NEXT_TUESDAY)

	IF OBJECT_ID('tempdb..#data1') IS NOT NULL
		DROP TABLE #data1

	SELECT  odq.Qty AS Quantity,
			i.ItemType,
			ot.Name AS OrderTypeName,
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
	WHERE o.ShipmentDate >= @START_WEDNESDAY AND o.ShipmentDate <= @NEXT_TUESDAY

	SELECT 
		wpc.WeekNo AS WeekNumber,
		wpc.WeekendDate AS WeekEndDate,
		CAST(wpc.WeekNo AS nvarchar) + '/' + CAST((( YEAR( wpc.WeekendDate ) % 100 )) AS nvarchar) +'  '+ FORMAT(wpc.WeekendDate, 'dddd, dd MMMM yyyy' ) AS [Week],
		wpcd.TotalCapacity AS Capacity,
		(  SELECT ISNULL(SUM(Quantity), 0) from #data1  
			WHERE OrderTypeName 
				LIKE '%SAMPLE%' 
				AND ItemType = @P_ItemType) AS Samples,
		(SELECT  ISNULL(SUM(Quantity), 0)
			FROM #data1
		  WHERE ItemType = @P_ItemType 
			AND (OrderTypeName = 'ORDER' OR OrderTypeName = 'GUARANTEED')) AS FirmOrders,
		(	SELECT ISNULL(SUM(r.[Qty]), 0)
			  FROM [dbo].[Reservation] r
				INNER JOIN [dbo].[Pattern] p
					ON p.ID = r.Pattern
				INNER JOIN [dbo].[Item] i
					ON p.Item = i.ID
			  WHERE ShipmentDate >= @START_WEDNESDAY AND @START_WEDNESDAY <= @NEXT_TUESDAY
					AND ItemType = @P_ItemType) AS Reservations
	FROM [dbo].WeeklyProductionCapacityDetails wpcd
		INNER JOIN [dbo].[WeeklyProductionCapacity] wpc
			ON wpcd.WeeklyProductionCapacity = wpc.ID
	WHERE wpc.WeekendDate = @NEXT_TUESDAY
			AND wpcd.ItemType = @P_ItemType

END


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

DECLARE @IndimanAdministrator int
DECLARE @IndicoCoordinator int
DECLARE @IndicoAdministrator int

SET @IndimanAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @IndicoCoordinator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
SET @IndicoAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Administrator')

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

-- Page
INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/ViewFiveWeekDetails.aspx','Current & Forthcomming Week Details','Current & Forthcomming Week Details')	 
SET @PageId = SCOPE_IDENTITY()

-- Parent Menu Item
SELECT TOP 1 @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE ID = 95

--Menu Item					
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Current & Forthcomming Week Details', 'Current & Forthcomming Week Details', 1, @MenuItemMenuId, 0, 1)
SET @MenuItemId = SCOPE_IDENTITY()

-- Menu Item Role
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoCoordinator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoAdministrator)

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

-- Page
INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/ViewWeeklyPiecesCapacities.aspx','Weekly Pieces Summaries','Weekly Pieces Summaries')	 
SET @PageId = SCOPE_IDENTITY()

-- Parent Menu Item
SELECT TOP 1 @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Dashboard'

--Menu Item					
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Weekly Summaries - Pieces', 'Weekly Summaries - Pieces', 1, @MenuItemMenuId, 1, 1)
SET @MenuItemId = SCOPE_IDENTITY()

-- Menu Item Role
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoCoordinator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoAdministrator)

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

-- Page
INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/OrderDrillDown.aspx','Order DrillDown','Order DrillDown')	 
SET @PageId = SCOPE_IDENTITY()

-- Parent Menu Item
SELECT TOP 1 @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Dashboard'

--Menu Item					
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Order DrillDown', 'Order DrillDown', 1, @MenuItemMenuId, 3, 0)
SET @MenuItemId = SCOPE_IDENTITY()

-- Menu Item Role
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoCoordinator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoAdministrator)

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

-- Page
INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/ViewWeeklySMVCapacities.aspx','Weekly SMV Summaries','Weekly SMV Summaries')	 
SET @PageId = SCOPE_IDENTITY()

-- Parent Menu Item
SELECT TOP 1 @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Dashboard'

--Menu Item					
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Weekly Summaries - SMV', 'Weekly Summaries - SMV', 1, @MenuItemMenuId, 2, 1)
SET @MenuItemId = SCOPE_IDENTITY()

-- Menu Item Role
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoCoordinator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoAdministrator)

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


GO