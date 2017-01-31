USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

-- Cost sheet inserts

  INSERT INTO [dbo].PatternSupportFabric (Fabric, FabConstant, CostSheet)
  VALUES (167, 0.20, 458)
  GO

  INSERT INTO [dbo].PatternSupportFabric (Fabric, FabConstant, CostSheet)
  VALUES (3, 1.40, 458)
  GO

  INSERT INTO [dbo].PatternSupportAccessory (Accessory, AccConstant, Pattern, CostSheet)
  VALUES (68, 4.00, 290, 458)
  GO

  INSERT INTO [dbo].PatternSupportAccessory (Accessory, AccConstant, Pattern, CostSheet)
  VALUES (83, 0.65, 290, 458)
  GO

  INSERT INTO [dbo].PatternSupportAccessory (Accessory, AccConstant, Pattern, CostSheet)
  VALUES (115, 0.65, 290, 458)
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
	DECLARE @now datetime2(7) = GETDATE()
	SET @StartDate = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE WeekendDate > @now AND DATEADD(day,-6,WeekendDate)< @now)
	DECLARE @StartId int
	SET @StartId = (SELECT TOP 1 ID FROM [dbo].[WeeklyProductionCapacity] WHERE WeekendDate = @StartDate)
	SET @EndDate = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE ID = @StartId+4)  -- get record from table

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
	WHERE od.ShipmentDate >= @StartDate AND od.ShipmentDate <= @EndDate AND os.ID NOT IN (18,22,23,24,28,31) AND ((@P_ItemType = 2 AND i.ItemType = 2) OR (@P_ItemType = 1 AND (i.ItemType = 1 OR i.ItemType = 2)))
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

