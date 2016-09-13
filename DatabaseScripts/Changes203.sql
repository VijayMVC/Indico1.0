USE Indico
GO

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
	
	SELECT DISTINCT
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
			(p.SMV * SUM(odq.Qty)) AS TotalSMV 
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
			WHERE  os.ID != 28 AND os.ID != 18  AND dca.CompanyName = @P_ShipTo AND od.ShipmentDate = @ETD AND odq.Qty>0-- AND  os.Name = @P_Status

			GROUP BY vl.NamePrefix,o.ID,vl.ID,p.Number,p.NickName,p.ID,fc.Code,fc.Name,fc.ID,o.[Date],od.ShipmentDate,coo.GivenName,coo.FamilyName ,ot.Name,
			d.Name, c.Name,pl.Name,i.Name,pt.Name,dp.Name,sm.Name,ods.Name,os.Name,it.ItemType,p.SMV,o.ID,vl.ID,p.ID,fc.ID,dca.CompanyName

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
			ISNULL(SUM(odq.Qty), 0) AS Qty,
			pl.Name AS ProductionLine,
			COALESCE(i.Name,'') AS ItemSubCat,
			pt.Name AS PrintType,
			COALESCE(dca.CompanyName,'') AS ShipTo,
			COALESCE(dp.Name, '') AS Port,
			COALESCE(sm.Name,'') AS Mode,
			COALESCE(os.Name, '') AS [Status],
			p.SMV,
			(p.SMV * ISNULL(SUM(odq.Qty), 0)) AS TotalSMV INTO #firm
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

			GROUP BY vl.NamePrefix,o.ID,vl.ID,p.Number,p.NickName,p.ID,fc.Code,fc.Name,fc.ID,o.[Date],od.ShipmentDate,coo.GivenName,coo.FamilyName ,ot.Name,
			d.Name, c.Name,pl.Name,i.Name,pt.Name,dp.Name,sm.Name,ods.Name,os.Name,it.ItemType,p.SMV,o.ID,vl.ID,p.ID,fc.ID,dca.CompanyName
			
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
			(p.SMV * ISNULL(SUM(odq.Qty), 0)) AS TotalSMV INTO #data
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
			GROUP BY vl.NamePrefix,o.ID,vl.ID,p.Number,p.NickName,p.ID,fc.Code,fc.Name,fc.ID,o.[Date],od.ShipmentDate,coo.GivenName,coo.FamilyName ,ot.Name,
			d.Name, c.Name,pl.Name,i.Name,pt.Name,dp.Name,sm.Name,ods.Name,os.Name,it.ItemType,p.SMV,o.ID,vl.ID,p.ID,fc.ID,dca.CompanyName

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
UPDATE wpc
   SET wpc.EstimatedDateOfDespatch = wpc.WeekendDate,
   wpc.[HoursPerDay] = 10.0,
   wpc.NoOfHolidays = 6
 FROM [dbo].[WeeklyProductionCapacity]  wpc
WHERE wpc.WeekendDate IS NOT NULL

UPDATE wpc
   SET wpc.OrderCutOffDate = DATEADD(DAY,-18,wpc.EstimatedDateOfDespatch),
   wpc.EstimatedDateOfArrival = DATEADD(DAY,3,wpc.WeekendDate)
 FROM [dbo].[WeeklyProductionCapacity]  wpc
WHERE wpc.EstimatedDateOfDespatch IS NOT NULL

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

INSERT INTO [dbo].[WeeklyProductionCapacityDetails] ([WeeklyProductionCapacity],[ItemType],[TotalCapacity],[FivePcsCapacity],[SampleCapacity],[Workers],[Efficiency])
	SELECT wpc.ID,
		1,
		5850,
		100,
		200,
		65,
		0.45
	FROM [dbo].[WeeklyProductionCapacity] wpc
		LEFT OUTER JOIN [dbo].[WeeklyProductionCapacityDetails] wpcd
			ON wpcd.WeeklyProductionCapacity = wpc.ID AND wpcd.ItemType = 1
	WHERE wpcd.ID IS NULL

GO


INSERT INTO [dbo].[WeeklyProductionCapacityDetails] ([WeeklyProductionCapacity],[ItemType],[TotalCapacity],[FivePcsCapacity],[SampleCapacity],[Workers],[Efficiency])
	SELECT wpc.ID,
		2,
		450,
		10,
		20,
		15,
		0.25
	FROM [dbo].[WeeklyProductionCapacity] wpc
		LEFT OUTER JOIN [dbo].[WeeklyProductionCapacityDetails] wpcd
			ON wpcd.WeeklyProductionCapacity = wpc.ID AND wpcd.ItemType = 2
	WHERE wpcd.ID IS NULL

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


--Object:  StoredProcedure [dbo].[SPC_ViewVisualLayoutDetails]    Script Date: 7/27/2016 4:06:09 PM /
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewVisualLayoutDetails]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_ViewVisualLayoutDetails]
GO

--Object:  StoredProcedure [dbo].[SPC_ViewVisualLayoutDetails]    Script Date: 7/27/2016 4:06:09 PM /
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_ViewVisualLayoutDetails]
(
 @P_SearchText AS NVARCHAR(255) = '',
 @P_Coordinator AS int = 0,
 @P_Distributor AS int = 0,
 @P_Client AS int = 0 
)
AS
BEGIN 
 SET NOCOUNT ON 
  SELECT    
      v.[ID] AS VisualLayout,
      ISNULL(v.[NamePrefix] + '' + ISNULL(CAST(v.[NameSuffix] AS NVARCHAR(64)), ''), '') AS Name,
      ISNULL(v.[Description], '') AS 'Description',
      ISNULL(p.[Number] + ' - '+ p.[NickName], '') AS Pattern,
      ISNULL(f.[Name], '') AS Fabric,
      ISNULL(j.[Name], '') AS JobName,
      ISNULL(c.[Name], '') AS Client,
      ISNULL(d.[Name], '') AS Distributor,
      ISNULL(u.[GivenName] + ' '+ u.[FamilyName], '') AS Coordinator,
      ISNULL(v.[NNPFilePath], '') AS NNPFilePath,
      ISNULL(v.[CreatedDate], GETDATE()) AS CreatedDate,
      ISNULL(v.[IsCommonProduct], 0) AS IsCommonProduct,
      ISNULL(v.[ResolutionProfile], 0) AS ResolutionProfile,
      ISNULL(v.[Printer], 0) AS Printer,
      ss.[Name] AS SizeSet,
     CASE WHEN 
       --(EXISTS(SELECT TOP 1 ID FROM [dbo].[VisualLayoutAccessory] WHERE [VisualLayout] = v.[ID])) OR
       --(EXISTS(SELECT TOP 1 ID FROM [dbo].[Image] WHERE [VisualLayout] = v.[ID])) OR
       (EXISTS(SELECT TOP 1 ID FROM [dbo].[OrderDetail] WHERE [VisualLayout] = v.[ID])) 
    THEN 0 
    ELSE 1 
    END
    AS CanDelete,
     ISNULL(vli.[FileName], '') AS [FileName],
     ISNULL(vli.[Extension], '') AS Extension
  FROM [dbo].[VisualLayout] v WITH (NOLOCK)
   INNER JOIN [dbo].[Pattern] p WITH (NOLOCK)
    ON v.[Pattern] = p.[ID]
   INNER JOIN [dbo].[FabricCode] f WITH (NOLOCK)
    ON v.[FabricCode] = f.[ID]
   INNER JOIN [dbo].[JobName] j WITH (NOLOCK)
    ON v.[Client] = j.[ID]
   INNER JOIN [dbo].[Client] c WITH (NOLOCK)
    ON j.[Client] = c.[ID] 
   INNER JOIN [dbo].[Company] d WITH (NOLOCK)
    ON c.[Distributor] = d.[ID]
   LEFT OUTER JOIN [dbo].[User] u WITH (NOLOCK)
    ON d.[Coordinator] = u.[ID]
   INNER JOIN [dbo].[SizeSet] ss WITH (NOLOCK)
    ON p.[SizeSet] = ss.[ID]
   LEFT OUTER JOIN  [dbo].[Image] vli WITH (NOLOCK)
    ON v.ID = vli.VisualLayout AND vli.IsHero = 1 
  WHERE (@P_Coordinator = 0 OR u.[ID] = @P_Coordinator)
    AND  (@P_Distributor = 0 OR  d.ID = @P_Distributor )
    AND  (@P_SearchText = '' OR
        v.[NamePrefix]  LIKE '%' + @P_SearchText + '%' OR
        v.[NameSuffix]  LIKE '%' + @P_SearchText + '%' OR
        v.[Description] LIKE '%' + @P_SearchText + '%' OR
        p.[Number] LIKE '%' + @P_SearchText + '%' OR
        c.[Name] LIKE '%' + @P_SearchText + '%' OR
        d.[Name] LIKE '%' + @P_SearchText + '%' OR
        u.[GivenName] LIKE '%' + @P_SearchText + '%' OR
        u.[FamilyName] LIKE '%' + @P_SearchText + '%') 
  ORDER BY v.[CreatedDate] DESC
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
