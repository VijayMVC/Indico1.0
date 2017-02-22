USE Indico
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
	WHERE od.ShipmentDate >= DATEADD(DAY,-6,@StartETD) AND od.ShipmentDate <= @EndETD AND os.ID NOT IN (18,22,23,24,28,31)

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
		(CONVERT(nvarchar(2), ((YEAR( wpc.WeekendDate ) % 100 ))) + '/' + CONVERT(nvarchar(3), wpc.WeekNo)) AS WeekNumber,
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
	WHERE wpc.WeekendDate >= @StartETD AND wpc.WeekendDate <= @EndETD
	ORDER BY wpc.WeekendDate
END


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

UPDATE wpc
SET wpc.WeekNo = wpc.WeekNo + 1
FROM [dbo].[WeeklyProductionCapacity] wpc
WHERE  wpc.WeekendDate > '20170101'
  
DECLARE @Id int
INSERT INTO [dbo].[WeeklyProductionCapacity] (WeekNo,WeekendDate,Capacity,Notes,SalesTarget,HoursPerDay,NoOfHolidays,OrderCutOffDate,EstimatedDateOfArrival,EstimatedDateOfDespatch)
VALUES(1,'2017-01-03 00:00:00.0000000','0',NULL,NULL,10.00,6,'2016-12-16 00:00:00.000','2017-01-03 00:00:00.000','2017-01-06 00:00:00.000')
SET @Id = SCOPE_IDENTITY()


INSERT INTO [dbo].[WeeklyProductionCapacityDetails] (WeeklyProductionCapacity,ItemType,TotalCapacity,FivePcsCapacity,SampleCapacity,Workers,Efficiency)
VALUES (@Id,1,5850.00,100.00,200.00,65,0.45)
	

INSERT INTO [dbo].[WeeklyProductionCapacityDetails] (WeeklyProductionCapacity,ItemType,TotalCapacity,FivePcsCapacity,SampleCapacity,Workers,Efficiency)
VALUES (@Id,2,450.00,10.00,20.00,15,0.25)

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

-- Pattern Sizes corrections --

DELETE FROM [dbo].SizeChart
WHERE Pattern = 2407 AND  ID > 125270

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--