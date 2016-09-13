USE Indico
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
			 ISNULL((p.SMV * r.Qty), 0) AS TotalSMV INTO #res1
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
			jn.Name AS JobName,
			ISNULL(SUM(odq.Qty), 0) AS Qty,
			pl.Name AS ProductionLine,
			COALESCE(i.Name,'') AS ItemSubCat,
			pt.Name AS PrintType,
			COALESCE(dca.CompanyName,'') AS ShipTo,
			COALESCE(dp.Name, '') AS Port,
			COALESCE(sm.Name,'') AS Mode,
			COALESCE(os.Name, '') AS [Status],
			p.SMV,
			(p.SMV * ISNULL(SUM(odq.Qty), 0)) AS TotalSMV,
			vl.CreatedDate ProductCreatedDate INTO #firm
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
			INNER JOIN [dbo].[JobName] jn
				ON vl.Client = jn.ID
			LEFT OUTER JOIN [dbo].[Client] c
				ON jn.Client = c.ID
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
			WHERE od.ShipmentDate >= @WeekStartDate AND od.ShipmentDate <= @WeekEndDate AND it.ItemType = 1 AND os.ID != 28 AND os.ID != 18 

			GROUP BY vl.NamePrefix,o.ID,vl.ID,p.Number,p.NickName,p.ID,fc.Code,fc.Name,fc.ID,o.[Date],od.ShipmentDate,coo.GivenName,coo.FamilyName ,ot.Name,
			d.Name, c.Name,jn.Name,pl.Name,i.Name,pt.Name,dp.Name,sm.Name,ods.Name,os.Name,it.ItemType,p.SMV,o.ID,vl.ID,p.ID,fc.ID,dca.CompanyName,vl.CreatedDate

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
			jn.Name AS JobName,
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
			(p.SMV * ISNULL(SUM(odq.Qty), 0)) AS TotalSMV,
			vl.CreatedDate ProductCreatedDate INTO #data
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
			INNER JOIN [dbo].[JobName] jn
				ON vl.Client = jn.ID
			LEFT OUTER JOIN [dbo].[Client] c
				ON jn.Client = c.ID
			LEFT OUTER JOIN [dbo].[OrderDetailQty] odq
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
			GROUP BY vl.NamePrefix,o.ID,vl.ID,p.Number,p.NickName,p.ID,fc.Code,fc.Name,fc.ID,o.[Date],od.ShipmentDate,coo.GivenName,coo.FamilyName ,ot.Name,
			d.Name, c.Name,jn.Name,pl.Name,i.Name,pt.Name,dp.Name,sm.Name,ods.Name,os.Name,it.ItemType,p.SMV,o.ID,vl.ID,p.ID,fc.ID,dca.CompanyName,vl.CreatedDate

			SELECT * FROM #data
			WHERE 
				(@Type = 1 AND ([Status]  != 'Indico Hold' AND [Status] != 'Indiman Hold' 
					AND [Status] != 'Factory Hold' AND [Status] != 'On Hold'))
				OR
				(@Type = 2 AND ([Status]  = 'Indico Hold' OR [Status] = 'Indiman Hold' 
					OR [Status] = 'Factory Hold' OR [Status] = 'On Hold'))
				OR
				(@Type = 4  AND ItemType = 2)
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

	DECLARE @LastOD datetime2(7)
	SET @LastOD = (SELECT  TOP 1  od.ShipmentDate
							 FROM [dbo].[OrderDetail] od
								INNER JOIN [dbo].[Order] o
									ON od.[Order] = o.ID
								INNER JOIN [dbo].[OrderStatus] os
									ON o.[Status] = os.ID  
					WHERE os.ID != 28 AND os.ID != 18 
					ORDER BY od.ShipmentDate DESC)
	DECLARE @LastRes datetime2(7)
	SET @LastRes = (SELECT TOP 1  r.ShipmentDate FROM [dbo].[Reservation] r WHERE r.Qty >0 ORDER BY r.ShipmentDate DESC)
	
	IF (@P_FromETD IS NULL)
		SET @StartETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE CONVERT(date,WeekendDate) >= CONVERT(date,GETDATE()) ORDER BY WeekendDate)
	ELSE
		SET @StartETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE WeekendDate >= @P_FromETD ORDER BY WeekendDate)
	
	IF (@P_ToEtd IS NULL)
	BEGIN
		IF (@LastOD IS NOT NULL AND @LastOD > @StartETD)
		BEGIN
			SET @EndETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity]  WHERE WeekendDate >= @LastOD ORDER BY WeekendDate)
			IF (@LastRes IS NOT NULL AND @LastRes > @EndETD)
				SET @EndETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity]  WHERE WeekendDate >= @LastRes ORDER BY WeekendDate)
		END
		ELSE
			SET @EndETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity]  WHERE WeekendDate >= DATEADD(MONTH,2,@StartETD) ORDER BY WeekendDate)
	END
	ELSE
		SET @EndETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE WeekendDate >= @P_ToETD ORDER BY WeekendDate)
			
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
		ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND (OrderStatusName  != 'Indico Hold' AND OrderStatusName != 'Indiman Hold' 
					AND OrderStatusName != 'Factory Hold' AND OrderStatusName != 'On Hold')),0) AS PoloFirms,
		ISNULL((SELECT SUM(Qty) FROM #data2 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate), 0) AS PoloReservations,
		ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) 
				AND ShipmentDate <= wpc.WeekendDate AND (OrderStatusName = 'Indico Hold' OR OrderStatusName = 'Indiman Hold' 
					OR OrderStatusName = 'Factory Hold' OR OrderDetailStatusName = 'On Hold')), 0) AS PoloHolds,
		ISNULL(wpcd1.TotalCapacity, 0) AS PoloCapacity,
		ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 2), 0) AS OuterWareFirms,
		ISNULL(wpcd2.TotalCapacity,0) AS OuterwareCapacity,
		--ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND Qty <= 5),0) AS Qty,
		ISNULL((SELECT SUM(t.Qty) FROM (SELECT SUM(Qty) AS Qty FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate  GROUP BY #data1.OrderDetail HAVING SUM(Qty) <= 5) t), 0) AS UptoFiveItems,
		ISNULL((wpcd1.FivePcsCapacity + wpcd2.FivePcsCapacity), 0) AS UptoFiveItemsCapacity,
		ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) 
				AND ShipmentDate <= wpc.WeekendDate AND OrderTypeName LIKE '%SAMPLE%'), 0) AS [Samples],
		ISNULL((wpcd1.SampleCapacity +  wpcd2.SampleCapacity), 0) AS SampleCapacity
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
		SUM(odq.Qty) AS Qty
		FROM
		[dbo].[Order] o
		INNER JOIN [dbo].[OrderDetail] od
			ON od.[Order] = o.ID
		INNER JOIN [dbo].[VisualLayout] vl
			ON od.VisualLayout = vl.ID 
		INNER JOIN [dbo].[Pattern] p
			ON vl.Pattern = p.ID
		INNER JOIN [dbo].[Item] it
			ON p.Item = it.ID
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
		WHERE  od.ShipmentDate >= @WeekStartDate AND od.ShipmentDate <= @WeekEndDate  AND os.ID != 28 AND os.ID != 18 AND (os.Name  != 'Indico Hold' AND os.Name != 'Indiman Hold' 
					AND os.Name != 'Factory Hold' AND os.Name != 'On Hold')
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
	
	SELECT  CONVERT(nvarchar(4),DATEPART(YEAR,@ETD)) + '/' + CONVERT(nvarchar(2),@WeekNumber) AS [Week],
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
			jn.Name AS JobName,
			ISNULL(SUM(odq.Qty), 0) AS Qty,
			pl.Name AS ProductionLine,
			COALESCE(i.Name,'') AS ItemSubCat,
			pt.Name AS PrintType,
			COALESCE(dca.CompanyName,'') AS ShipTo,
			COALESCE(dp.Name, '') AS Port,
			COALESCE(sm.Name,'') AS Mode,
			COALESCE(os.Name, '') AS [Status],
			p.SMV,
			(p.SMV * SUM(odq.Qty)) AS TotalSMV,
			vl.CreatedDate ProductCreatedDate
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
			INNER JOIN [dbo].[JobName] jn
				ON vl.Client = jn.ID
			LEFT OUTER JOIN [dbo].[Client] c
				ON jn.Client = c.ID
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
			WHERE  os.ID != 28 AND os.ID != 18  AND dca.CompanyName = @P_ShipTo AND od.ShipmentDate = @ETD AND odq.Qty>0-- AND  os.Name = @P_Status

			GROUP BY vl.NamePrefix,o.ID,vl.ID,p.Number,p.NickName,p.ID,fc.Code,fc.Name,fc.ID,o.[Date],od.ShipmentDate,coo.GivenName,coo.FamilyName ,ot.Name,
			d.Name, c.Name,jn.Name,pl.Name,i.Name,pt.Name,dp.Name,sm.Name,ods.Name,os.Name,it.ItemType,p.SMV,o.ID,vl.ID,p.ID,fc.ID,dca.CompanyName,vl.CreatedDate

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
	SET @StartDate = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE CONVERT(date,WeekendDate) >= CONVERT(date,GETDATE()) ORDER BY WeekendDate)
	SET @StartDate = DATEADD(DAY,-6,@StartDate)
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
	WHERE od.ShipmentDate >= @StartDate AND od.ShipmentDate <= @EndDate AND os.ID != 28 AND os.ID != 18 AND ((@P_ItemType = 2 AND i.ItemType = 2) OR (@P_ItemType = 1 AND (i.ItemType = 1 OR i.ItemType = 2)))
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
				WHERE (ShipmentDate >= DATEADD(DAY,-6,wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate)) AS FirmOrders,
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