USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 05/25/2012 15:40:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ProductionCapacities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ProductionCapacities]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 05/25/2012 13:04:04 ******/
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
				AND  o.ShipmentDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.ShipmentDate <= @P_WeekEndDate),
				
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


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  View [dbo].[ReturnProductionCapacitiesView]    Script Date: 05/25/2012 15:44:53 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnProductionCapacitiesView]'))
DROP VIEW [dbo].[ReturnProductionCapacitiesView]
GO

/****** Object:  View [dbo].[ReturnProductionCapacitiesView]    Script Date: 05/25/2012 15:42:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnProductionCapacitiesView] 
AS 
	SELECT  0 AS Firms,
			0 AS ResevationOrders,
			0 AS Resevations,
			0 AS Holds,
			0 AS Less5Items,
			0 AS Jackets,
			0 AS Samples

GO






