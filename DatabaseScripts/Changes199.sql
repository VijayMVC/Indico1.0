USE [Indico]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  View [dbo].[GetOrderDetaildForGivenWeekView]    Script Date: 2016-06-20 06:19:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
ALTER VIEW [dbo].[GetOrderDetaildForGivenWeekView]
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
					FROM [Indico].[dbo].[PatternTemplateImage] pti WHERE p.ID = pti.Pattern AND pti.IsHero = 1
					), '' 
				) AS PatternImagePath,
				COALESCE(
					(SELECT TOP 1 
						'http://gw.indiman.net/IndicoData/VisualLayout/' + CAST(vl.ID AS nvarchar(8)) + '/' + im.[Filename] + im.Extension
					FROM [Indico].[dbo].[Image] im WHERE vl.ID = im.VisualLayout AND im.IsHero = 1
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
									ELSE (CAST((SELECT TOP 1 hsc.[Code] FROM [Indico].[dbo].[HSCode] hsc WHERE hsc.[ItemSubCategory] = p.[SubItem] AND hsc.[Gender] = p.[Gender]) AS nvarchar(64)))
							END) AS nvarchar (64)), '') AS HSCode,
				ISNULL(CAST((SELECT CASE
									WHEN (p.[SubItem] IS NULL)
										THEN  	('')
									ELSE (CAST((SELECT it.[Name] FROM [Indico].[dbo].[Item] it WHERE it.[ID] = i.[Parent]) AS nvarchar(64)))
							END) AS nvarchar (64)), '') AS ItemName,
				o.PurchaseOrderNo,
				dca.ID AS DistributorClientAddressID, --new
				dca.CompanyName AS DistributorClientAddressName,
				COALESCE(dp.Name, '') AS DestinationPort,
			    COALESCE(sm.Name, '') AS ShipmentMode,
			    COALESCE(pm.Name,'') AS PaymentMethod 
	FROM [Indico].[dbo].[OrderDetail] od
		INNER JOIN [Indico].[dbo].[Order] o
			ON od.[Order] = o.ID
		INNER JOIN [Indico].[dbo].[OrderStatus] os
			ON o.[Status] = os.ID
		INNER JOIN [Indico].[dbo].[Company] dis
			ON dis.[ID] = o.[Distributor]		
		INNER JOIN [Indico].[dbo].[OrderType] ot
			ON od.[OrderType] = ot.[ID]
		INNER JOIN [Indico].[dbo].[VisualLayout] vl
			ON od.[VisualLayout] = vl.ID	
		INNER JOIN [Indico].[dbo].[Pattern] p
			ON od.Pattern = p.ID
		INNER JOIN [Indico].[dbo].[SizeSet] ss
			ON p.SizeSet = ss.ID
		INNER JOIN [Indico].[dbo].[Size] s
			ON s.SizeSet = ss.ID
		INNER JOIN [Indico].[dbo].[FabricCode] fc
			ON od.FabricCode = fc.ID
		LEFT OUTER JOIN [Indico].[dbo].[Gender] g
			ON p.Gender = g.ID
		LEFT OUTER JOIN [Indico].[dbo].[AgeGroup] ag
			ON p.AgeGroup = ag.ID
		LEFT OUTER JOIN [Indico].[dbo].[Item] i
			ON p.[SubItem] = i.ID
		INNER JOIN [Indico].[dbo].[Client] c
			ON o.Client = c.ID	
		LEFT OUTER JOIN [Indico].[dbo].[CostSheet] cs	
			ON p.ID = cs.Pattern
				AND fc.ID = cs.Fabric
		INNER JOIN [Indico].[dbo].[OrderDetailQty] odq
			ON od.ID = odq.OrderDetail
				AND odq.Size = s.ID
		INNER JOIN [Indico].[dbo].[DistributorClientAddress] dca
			ON od.[DespatchTo] = dca.[ID]
		LEFT OUTER JOIN [Indico].[dbo].[DestinationPort] dp
			ON dca.[Port] = dp.[ID]
		LEFT OUTER JOIN [Indico].[dbo].[ShipmentMode] sm
			ON od.[ShipmentMode] = sm.[ID] 
		LEFT OUTER JOIN [Indico].[dbo].[PaymentMethod] pm
			ON od.[PaymentMethod] = pm.[ID]
WHERE odq.Qty != 0 AND o.[Status] != 28

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

ALTER TABLE [dbo].[Company]
	ADD [IncludeAsMYOBInvoice] bit NOT NULL DEFAULT (0)
GO

ALTER TABLE [dbo].[Company]
	ADD [JobName] nvarchar(128) NULL
GO

ALTER TABLE [dbo].[OrderDetail] 
	ADD DistributorSurcharge Decimal(5,2) NULL
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
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
-- changed for add new column (PatternNumber) to  ViewCostSheet by rusith
/****** Object:  StoredProcedure [dbo].[SPC_GetCostSheetDetails]    Script Date: 6/21/2016 6:22:17 PM ******/
DROP PROCEDURE [dbo].[SPC_GetCostSheetDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetCostSheetDetails]    Script Date: 2016-06-21 04:50:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_GetCostSheetDetails] (	
@P_SearchText nvarchar(max) 
)	
AS 
BEGIN
	
	DECLARE @CostSheets TABLE
	(
		CostSheet int,
		PatternID int,
		PatternNumber nvarchar(64),
		Pattern nvarchar(MAX),
		Fabric nvarchar(MAX),
		Category nvarchar(MAX),
		SMV decimal(8,2),
		SMVRate decimal(8,3),
		HPCost decimal(8,2),
		LabelCost decimal(8,2),
		Packing decimal(8,2),
		Wastage decimal(8,2),
		Finance decimal(8,2),
		QuotedFOBCost decimal(8,2),
		DutyRate decimal(8,2),
		CONS1 decimal(8,2),
		CONS2 decimal(8,2),
		CONS3 decimal(8,2),
		Rate1 decimal(8,2),
		Rate2 decimal(8,2),
		Rate3 decimal(8,2),
		ExchangeRate decimal(8,2),
		InkCons decimal(8,3),
		InkRate decimal(8,2),
		SubCons decimal(8,2),
		PaperRate decimal(8,2),
		AirFregiht decimal(8,2),
		ImpCharges decimal(8,2),
		MGTOH decimal(8,2),
		IndicoOH decimal(8,2),
		Depr decimal(8,2),
		MarginRate decimal(8,2),
		QuotedCIF decimal(8,2),
		IndimanCIF decimal(8,2),
		ShowToIndico bit NOT NULL,
		ModifiedDate datetime2 NULL, 
		IndimanModifiedDate datetime2 NULL
	)	
	
	DECLARE @CostSheetDetails TABLE
	(
		CostSheet int,
		PatternID int,
		PatternNumber nvarchar(64),
		Pattern nvarchar(MAX),
		Fabric nvarchar(MAX),
		QuotedFOBCost decimal(8,2),
		QuotedCIF decimal(8,2),
		QuotedMP decimal(8,2),
		ExchangeRate decimal(8,2),
		Category nvarchar(MAX),
		SMV decimal(8,2),
		SMVRate decimal(8,3),
		CalculateCM decimal(8,2),
		TotalFabricCost decimal(8,2),
		TotalAccessoriesCost decimal(8,2),
		HPCost decimal(8,2),		
		LabelCost decimal(8,2),
		CM decimal(8,2),
		JKFOBCost decimal(8,2),
		Roundup decimal(8,2),
		DutyRate decimal(8,2),
		SubCons decimal(8,2),
		MarginRate decimal(8,2),
		Duty decimal(8,2),
		FOBAUD decimal(8,2),
		AirFregiht decimal(8,2),
		ImpCharges decimal(8,2),
		Landed decimal(8,2),
		MGTOH decimal(8,2),
		IndicoOH decimal(8,2),
		InkCost decimal(8,2),
		PaperCost decimal(8,2),
		ShowToIndico bit NOT NULL,
		ModifiedDate datetime2 NULL, 
		IndimanModifiedDate datetime2 NULL				
	)
	
	INSERT INTO @CostSheets
		SELECT	ch.[ID] AS CostSheet
				,p.ID AS PatternID
				,p.[Number] AS PatternNumber
				,p.[NickName] AS Pattern
				,fc.[Code] + ' - ' + fc.[Name]  AS Fabric 
				,ISNULL(cat.[Name], '') AS Category,
				p.SMV ,
				SMVRate ,
				HPCost ,
				LabelCost ,
				Other AS Packing,
				Wastage ,
				Finance ,
				QuotedFOBCost ,
				DutyRate ,
				CONS1 ,
				CONS2 ,
				CONS3 ,
				Rate1 ,
				Rate2 ,
				Rate3 ,
				ExchangeRate ,
				InkCons ,
				InkRate ,
				SubCons ,
				PaperRate ,
				AirFregiht ,
				ImpCharges ,
				MGTOH ,
				IndicoOH ,
				Depr ,
				MarginRate ,
				QuotedCIF ,
				IndimanCIF,
				ch.ShowToIndico,
				ch.ModifiedDate, 
				ch.IndimanModifiedDate
		 FROM [dbo].[CostSheet] ch
			INNER JOIN [dbo].[Pattern] p
				ON ch.[Pattern] = p.[ID]
			INNER JOIN [dbo].[FabricCode] fc
				ON ch.[Fabric] = fc.[ID]
			INNER JOIN [dbo].[Category] cat
				ON p.[CoreCategory] = cat.[ID]
			WHERE p.[IsActive] = 1 AND (
										@P_SearchText = '' OR
											(
												p.[Number] LIKE '%' + @P_SearchText +'%' OR
												fc.[Code] LIKE '%' + @P_SearchText +'%' OR
												fc.[Name] LIKE '%' + @P_SearchText +'%' OR
												cat.[Name] LIKE '%' + @P_SearchText +'%'
											)
										)
	
	DECLARE db_cursor CURSOR LOCAL FAST_FORWARD
					FOR SELECT * FROM @CostSheets; 
	DECLARE @CostSheet INT;
	DECLARE @PatternID INT;
	DECLARE @PatternNumber NVARCHAR(64);
	DECLARE @Pattern NVARCHAR(MAX);
	DECLARE @Fabric NVARCHAR(MAX);
	DECLARE @Category NVARCHAR(MAX);
	DECLARE @SMV decimal(8,2);
	DECLARE @SMVRate decimal(8,3);
	DECLARE @HPCost decimal(8,2);
	DECLARE @LabelCost decimal(8,2);
	DECLARE @Packing decimal(8,2);
	DECLARE @Wastage decimal(8,2);
	DECLARE @Finance decimal(8,2);
	DECLARE @QuotedFOBCost decimal(8,2);
	DECLARE @DutyRate decimal(8,2);
	DECLARE @CONS1 decimal(8,2);
	DECLARE @CONS2 decimal(8,2);
	DECLARE @CONS3 decimal(8,2);
	DECLARE @Rate1 decimal(8,2);
	DECLARE @Rate2 decimal(8,2);
	DECLARE @Rate3 decimal(8,2);
	DECLARE @ExchangeRate decimal(8,2);
	DECLARE @InkCons decimal(8,3);
	DECLARE @InkRate decimal(8,2);
	DECLARE @SubCons decimal(8,2);
	DECLARE @PaperRate decimal(8,2);
	DECLARE @AirFregiht decimal(8,2);
	DECLARE @ImpCharges decimal(8,2);
	DECLARE @MGTOH decimal(8,2);
	DECLARE @IndicoOH decimal(8,2);
	DECLARE @Depr decimal(8,2);
	DECLARE @MarginRate decimal(8,2);
	DECLARE @QuotedCIF decimal(8,2);
	DECLARE @IndimanCIF decimal(8,2);
	DECLARE @ShowToIndico bit;
	DECLARE @ModifiedDate datetime2;
	DECLARE @IndimanModifiedDate datetime2;

	OPEN db_cursor;
	FETCH NEXT FROM db_cursor INTO @CostSheet, @PatternID, @PatternNumber, @Pattern, @Fabric, @Category, @SMV, @SMVRate, @HPCost, @LabelCost, @Packing, @Wastage, @Finance, @QuotedFOBCost
	, @DutyRate, @CONS1, @CONS2, @CONS3, @Rate1, @Rate2, @Rate3, @ExchangeRate, @InkCons, @InkRate, @SubCons, @PaperRate, @AirFregiht, @ImpCharges, @MGTOH
	, @IndicoOH, @Depr, @MarginRate, @QuotedCIF, @IndimanCIF, @ShowToIndico, @ModifiedDate, @IndimanModifiedDate;
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		 --Do stuff with scalar values
		DECLARE @calCM decimal(8,2)
		DECLARE @totalFabricCost decimal(8,2)
		DECLARE @totalAcccCost decimal(8,2)
				
		DECLARE @subWastage decimal(8,2)		
		DECLARE @subFinance decimal(8,2)
		DECLARE @fobCost decimal(8,2)
		DECLARE @quotedFOB decimal(8,2)
		
		DECLARE @roundUp decimal(8,2)
		DECLARE @cost1 decimal(8,2)
		DECLARE @cost2 decimal(8,2)
		DECLARE @cost3 decimal(8,2)
		
		DECLARE @fobAUD decimal(8,2)
		DECLARE @duty decimal(8,2)
		DECLARE @inkCost decimal(8,2)
		DECLARE @paperCost decimal(8,2)

		DECLARE @landed decimal(8,2)
		DECLARE @calMgn decimal(8,2)
		DECLARE @calMp decimal(8,2)		
		DECLARE @actMgn decimal(8,2)
		DECLARE @quotedMp decimal(8,2)
		   		
		SET @calCM = @SMV * @SMVRate
		SET @totalFabricCost = ( SELECT SUM( ROUND( psf.FabConstant * f.FabricPrice , 2) ) FROM PatternSupportFabric psf LEFT OUTER JOIN FabricCode f ON psf.Fabric = f.ID WHERE psf.CostSheet = @CostSheet )
		SET @totalAcccCost = ( SELECT SUM( ROUND( psa.AccConstant * a.Cost , 2) ) FROM PatternSupportAccessory psa LEFT OUTER JOIN Accessory a ON psa.Accessory = a.ID WHERE psa.CostSheet = @CostSheet )
		SET @subWastage = ( ( @totalAcccCost + @HPCost + @LabelCost + @Packing ) * 0.03 )
		SET @subFinance = ( ( @totalFabricCost + @totalAcccCost + @HPCost + @LabelCost + @Packing ) * 0.04 )
		SET @fobCost = @calCM + @totalFabricCost + @totalAcccCost + @HPCost + @LabelCost + @Packing + @subWastage + @subFinance
		SET @quotedFOB = ISNULL(@QuotedFOBCost, @fobCost)
		SET @roundUp = @quotedFOB - @fobCost
		SET @cost1 = @CONS1 * @Rate1
		SET @cost2 = @CONS2 * @Rate2
		SET @cost3 = @CONS3 * @Rate3
		SET @fobAUD = ( SELECT CASE WHEN (ISNULL(@ExchangeRate,0) > 0 ) THEN ( @quotedFOB / @ExchangeRate) ELSE 0 END )  -- ( @quotedFOB / @ExchangeRate)
		SET @duty = (@fobAUD * @DutyRate) / 100
		SET @inkCost = @InkCons * @InkRate * 1.02
		SET @paperCost = @SubCons * 1.1 * @PaperRate * 1.2
		SET @landed = @fobAUD + @duty + @cost1 + @cost2 + @cost3 + @inkCost + @paperCost + @AirFregiht + @ImpCharges + @MGTOH + @IndicoOH + @Depr
		SET @calMgn = @IndimanCIF - @landed
		SET @calMp = ( SELECT CASE WHEN (ISNULL(@IndimanCIF, 0)> 0 ) THEN (1 - (@landed / @IndimanCIF)) * 100 ELSE 0 END )		
		SET @actMgn = @QuotedCIF - @landed
		SET @quotedMp = ( SELECT CASE WHEN (ISNULL(@QuotedCIF, 0)>0 ) THEN (1 - (@landed / @QuotedCIF)) * 100 ELSE 0 END )
		
		INSERT INTO @CostSheetDetails
		VALUES
		(
			@CostSheet,
			@PatternID,
			@PatternNumber,
			@Pattern,
			@Fabric,
			ISNULL(@quotedFOB,0),
			ISNULL(@QuotedCIF,0),
			ISNULL(@quotedMp,0),
			ISNULL(@ExchangeRate,0),
			@Category,
			@SMV,
			ISNULL(@SMVRate,0),
			ISNULL(@calCM,0),
			ISNULL(@totalFabricCost,0),
			ISNULL(@totalAcccCost,0),
			@HPCost,
			@LabelCost,
			ISNULL(@calCM,0),
			ISNULL(@fobCost,0),
			ISNULL(@roundUp,0),
			@DutyRate,
			ISNULL(@SubCons,0),
			@MarginRate,
			ISNULL(@duty,0),
			ISNULL(@fobAUD,0),
			@AirFregiht,
			@ImpCharges,
			ISNULL(@landed,0),
			@MGTOH,
			@IndicoOH,
			@inkCost,
			ISNULL(@paperCost,0),
			@ShowToIndico,
			@ModifiedDate,
			@IndimanModifiedDate		
		)		   

		   FETCH NEXT FROM db_cursor INTO @CostSheet, @PatternID,@PatternNumber, @Pattern, @Fabric, @Category, @SMV, @SMVRate, @HPCost, @LabelCost, @Packing, @Wastage, @Finance, @QuotedFOBCost
	, @DutyRate, @CONS1, @CONS2, @CONS3, @Rate1, @Rate2, @Rate3, @ExchangeRate, @InkCons, @InkRate, @SubCons, @PaperRate, @AirFregiht, @ImpCharges, @MGTOH
	, @IndicoOH, @Depr, @MarginRate, @QuotedCIF, @IndimanCIF, @ShowToIndico, @ModifiedDate, @IndimanModifiedDate;
	END;
	CLOSE db_cursor;
	DEALLOCATE db_cursor;
	
	SELECT * FROM @CostSheetDetails ORDER BY CostSheet
		  
 END
GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
--added DespatchTo , Changed DestinationPort in the Select List  -- rusith
/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 6/21/2016 6:22:17 PM ******/
DROP PROCEDURE [dbo].[SPC_ViewOrderDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 2016-06-22 09:23:02 AM ******/
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
		  ,(ISNULL(od.EditedPrice, 0)  + ( od.DistributorSurcharge  * ISNULL(od.EditedPrice, 0) / 100  ) ) AS EditedPrice
		  ,ot.[Name] AS OrderType		  
		  ,(vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),'') ) AS VisualLayout		  
		  ,ISNULL(od.[VisualLayout],0) AS VisualLayoutID		  
		   ,vl.Pattern AS PatternID		  
		   ,p.Number + ' - ' + p.NickName AS Pattern		  
		  ,vl.FabricCode AS FabricID
		   , f.[Code] + ' - ' + f.[Name] AS Fabric		  
		    ,CASE WHEN	(ISNULL(od.[VisualLayoutNotes],'') = '') AND
						(ISNULL(o.[Notes],'') = '')
			THEN 0	
			ELSE 1 
			END
			AS HasNotes
		  ,o.[ID] AS 'Order'
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
		  ,ISNULL (cl.Name, '') AS Client
		  ,ISNULL (j.Name, '') AS JobName		  
		  ,os.[Name] AS OrderStatus
		  ,o.[Status] AS OrderStatusID
		  ,urc.[GivenName] + ' ' + urc.[FamilyName] AS Creator
		  ,o.[Creator] AS CreatorID
		  ,o.[CreatedDate] AS CreatedDate
		  ,urm.[GivenName] + ' ' + urm.[FamilyName] AS Modifier
		  ,o.[ModifiedDate] AS ModifiedDate
		  ,ISNULL(pm.[Name], '') AS PaymentMethod
		  ,ISNULL(sm.[Name], '') AS ShipmentMethod
		  ,od.[IsWeeklyShipment]  AS WeeklyShipment
		  --,od.[IsCourierDelivery]  AS CourierDelivery
		  --,od.[IsAdelaideWareHouse] AS AdelaideWareHouse
		  --,od.[IsFollowingAddress] AS FollowingAddress
		  ,ISNULL(bdca.[CompanyName], '') AS BillingAddress
		  ,ISNULL(ddca.[CompanyName] , '') AS ShippingAddress
		  ,ISNULL(CASE WHEN od.IsWeeklyShipment = 1 THEN 'ADELAIDE' ELSE ddp.[Name] END, '') AS DestinationPort
		  ,ISNULL(vl.[ResolutionProfile], 0 ) AS ResolutionProfile
		  ,o.[IsAcceptedTermsAndConditions] AS IsAcceptedTermsAndConditions
		  --,od.Surcharge
		  ,cl.FOCPenalty
		  ,ISNULL(dta.CompanyName, '') AS DespatchTo --newly added
	  FROM [dbo].[OrderDetail] od	
		INNER JOIN [dbo].[PaymentMethod] pm
			ON od.[PaymentMethod] = pm.[ID]
		INNER JOIN [dbo].[ShipmentMode] sm
			ON od.[ShipmentMode] = sm.[ID]					
		INNER JOIN [dbo].[VisualLayout] vl
			ON od.[VisualLayout] = vl.[ID]	
		INNER JOIN [dbo].[OrderType] ot
			ON od.[OrderType] = ot.[ID]		
		LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
			ON od.[Status] = ods.[ID]

		INNER JOIN  [dbo].[Order] o	
			ON o.[ID] = od.[Order]			
		INNER JOIN [dbo].[OrderStatus] os
			ON o.[Status] = os.[ID]					
		INNER JOIN [dbo].[User] urc
			ON o.[Creator] = urc.[ID]
		INNER JOIN [dbo].[User] urm
			ON o.[Modifier] = urm.[ID]	
				
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] bdca
			ON o.[BillingAddress] = bdca.[ID]

		LEFT OUTER JOIN [dbo].[DistributorClientAddress] ddca
			ON o.[DespatchToAddress] = ddca.[ID]
		LEFT OUTER JOIN [dbo].[DestinationPort] ddp
			ON ddca.[Port] = ddp.[ID] 	
			
		INNER JOIN [dbo].[Pattern] p
			ON vl.[Pattern] = p.[ID]
		INNER JOIN [dbo].[FabricCode] f
			ON vl.FabricCode = f.[ID]
		INNER JOIN [dbo].[JobName] j
			ON vl.[Client] = j.[ID]
		INNER JOIN [dbo].[Client] cl
			ON j.[Client] = cl.[ID]	
		INNER JOIN [dbo].[Company] c
			ON cl.Distributor = c.[ID]
		LEFT OUTER JOIN [dbo].[User] u
			ON c.[Coordinator] = u.[ID]
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] dta
			ON dta.ID = od.DespatchTo
	WHERE (@P_SearchText = '' OR
			o.[ID] = @orderid OR
		   o.[OldPONo] LIKE '%' + @P_SearchText + '%' OR
		   u.[GivenName]  LIKE '%' + @P_SearchText + '%' OR
		   u.[FamilyName] LIKE '%' + @P_SearchText + '%' OR		  
		   vl.[NamePrefix] LIKE '%' + @P_SearchText + '%' OR 
		   vl.[NameSuffix] LIKE '%' + @P_SearchText + '%' OR 
		   ods.[Name] LIKE '%' + @P_SearchText + '%' OR 
		   ot.[Name] LIKE '%' + @P_SearchText + '%' OR
		   c.[Name] LIKE '%' + @P_SearchText + '%' OR 
		   cl.[Name] LIKE '%' + @P_SearchText + '%'   
			) AND
		   (@P_Status = '' OR  (os.[ID] IN (SELECT ID FROM @status)) )  AND											   
		  (@P_LogCompanyID = 0 OR c.[ID] = @P_LogCompanyID)	AND
		  (@P_Coordinator = 0 OR c.[Coordinator] = @P_Coordinator ) AND				  
		  (@P_Distributor = 0 OR cl.Distributor = @P_Distributor)	AND
		  (@P_Client = 0 OR cl.[ID] = @P_Client) AND				  
		  (@P_DistributorClientAddress = 0 OR o.[BillingAddress] = @P_DistributorClientAddress) AND
		  ((@P_SelectedDate1 IS NULL AND @P_SelectedDate2 IS NULL) OR (o.[Date] BETWEEN @P_SelectedDate1 AND @P_SelectedDate2))	
	--ORDER BY o.[ID] DESC
END
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderDetailIndicoPrice]    Script Date: 6/21/2016 6:22:17 PM ******/
DROP PROCEDURE [dbo].[SPC_GetOrderDetailIndicoPrice]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderDetailIndicoPrice]    Script Date: 6/21/2016 6:22:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_GetOrderDetailIndicoPrice]
(
	@P_Order AS int
)
AS 

BEGIN
	
	SELECT 	
		  od.[ID] AS OrderDetail
		  ,ot.[Name] AS OrderType
		  ,ISNULL(vl.[NamePrefix] + ''+ ISNULL(CAST(vl.[NameSuffix] AS NVARCHAR(64)), ''),'') AS VisualLayout
		  ,ISNULL(od.[VisualLayout],0) AS VisualLayoutID		  
		  ,ISNULL(p.Number, (SELECT Number FROM Pattern WHERE ID = od.[Pattern])) AS Pattern 
		  ,ISNULL(p.ID, od.[Pattern]) AS PatternID
		  ,ISNULL(fc.ID, od.FabricCode) AS FabricID
		  ,ISNULL(fc.[Name], (SELECT Name FROM FabricCode WHERE ID = od.FabricCode)) AS Fabric 		  
		  ,od.[Order] AS 'Order'
		  ,ISNULL(od.[Label],0) AS Label
		  ,ISNULL(ods.[Name], 'New') AS 'Status'
		  ,ISNULL(od.[Status],0) AS StatusID 
		  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]), 0) AS Quantity
		  ,ISNULL(od.[EditedPrice], 0.00) AS DistributorEditedPrice		 
		  ,od.Surcharge 
		  ,ISNULL(od.DistributorSurcharge,0) AS DistributorSurcharge
	FROM [dbo].[Order] o
		LEFT OUTER JOIN [dbo].[OrderDetail] od
		ON o.[ID] = od.[Order]
		LEFT OUTER JOIN [dbo].[OrderType] ot 
			ON od.[OrderType] = ot.[ID]	
		LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
			ON  od.[Status] = ods.[ID]		
		LEFT OUTER JOIN [dbo].[VisualLayout] vl 
			ON od.[VisualLayout] = vl.[ID]	
		LEFT OUTER JOIN [dbo].[Pattern] p
			ON vl.[Pattern] = p.[ID]
		LEFT OUTER JOIN [dbo].[FabricCode] fc
			ON vl.[FabricCode] = fc.[ID]			
	WHERE od.[Order] = @P_Order	
			
END 


GO
