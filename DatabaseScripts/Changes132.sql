USE [Indico]
GO

/****** Object:  Table [dbo].[ItemType]    Script Date: 05/13/2015 15:03:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ItemType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](255) NULL,
 CONSTRAINT [PK_ItemType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

-------------------------------------------------------------------------------

INSERT INTO [Indico].[dbo].[ItemType] ([Name],[Description])
     VALUES ('Polos' ,'Polos')

INSERT INTO [Indico].[dbo].[ItemType] ([Name],[Description])
     VALUES ('Outerwear' ,'Outerwear')     
GO


-------------------------------------------------------------------------------

ALTER TABLE [dbo].[Item] ADD [ItemType] INT NULL
CONSTRAINT [FK_Item_ItemType] FOREIGN KEY ([ItemType]) REFERENCES [ItemType];

-------------------------------------SP Changes related to production capacities----------------------------

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 05/18/2015 09:21:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ProductionCapacities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ProductionCapacities]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 05/18/2015 09:21:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_ProductionCapacities] (	
	
	@P_WeekEndDate datetime2(7),
	@P_ItemType int
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
		--Jackets int,
		Samples int
	)
	
	INSERT INTO @Capacities
	VALUES
	(
		-- Firm Orders
		(	SELECT  ISNULL(SUM(odq.Qty),0) AS Firms  
			FROM [Order] o
				LEFT OUTER JOIN OrderDetail od
					ON o.ID = od.[Order]  
				LEFT OUTER JOIN OrderDetailQty odq 
					ON od.ID = odq.OrderDetail
				JOIN VisualLayout vl
					ON od.VisualLayout = vl.ID
				JOIN Pattern pt
					ON vl.Pattern = pt.ID
				JOIN Item it
					ON pt.Item = it.ID
						WHERE it.[ItemType] = @P_ItemType
						AND (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
						AND (o.[Reservation] IS NULL)
						AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped')))),
		
		
		-- Resevation order quantities
		(	 (SELECT ISNULL(SUM (r.[Qty]), 0)      
					FROM [dbo].[Reservation] r
					JOIN Pattern pt
						ON r.Pattern = pt.ID
					JOIN Item it
						ON pt.Item = it.ID
					WHERE it.[ItemType] = @P_ItemType 
					AND (r.[ShipmentDate] BETWEEN CAST(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate))))),
		
		
		-- Resevation quantities
		(	SELECT ISNULL(SUM(odq.Qty),0) 
							FROM [OrderDetail] od				
								LEFT OUTER JOIN OrderDetailQty odq 
									ON od.ID = odq.OrderDetail
								JOIN Reservation r
									ON od.Reservation = r.ID
								JOIN Pattern pt
									ON r.Pattern = pt.ID
								JOIN Item it
									ON pt.Item = it.ID	 
							WHERE it.[ItemType] = @P_ItemType 
							AND (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
							AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped')))),
		
		
		-- Hold
		(	SELECT ISNULL(SUM(odq.[Qty]), 0) AS Hold
			FROM [dbo].[Order] o 
				LEFT OUTER JOIN [dbo].[OrderDetail] od
					ON	o.[ID] = od.[Order]
				LEFT OUTER JOIN [dbo].[OrderDetailQty] odq
					ON od.[ID] = odq.[OrderDetail]	
				JOIN VisualLayout vl
					ON od.VisualLayout = vl.ID
				JOIN Pattern pt
					ON vl.Pattern = pt.ID
				JOIN Item it
					ON pt.Item = it.ID		
			 --FROM [dbo].[OrderDetailQty] odq 
				--JOIN [dbo].[OrderDetail] od
				--	ON	odq.[OrderDetail] = od.[ID]
				--JOIN [dbo].[Order] o
				--	ON od.[Order] = o.[ID]
			 WHERE it.[ItemType] = @P_ItemType  AND ((o.[Status] = (SELECT os.[ID] FROM [dbo].[OrderStatus] os WHERE os.[Name] = 'Indiman Hold')) OR
					((o.[Status] = (SELECT os.[ID] FROM [dbo].[OrderStatus] os WHERE os.[Name] = 'Indico Hold')))) AND
				   (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate) AND
				   (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped')))),
		
		
		-- Less5Items
		(SELECT ISNULL(SUM(odq.[Qty]), 0)  AS Less5Items				 
										FROM dbo.[Order] o
											LEFT OUTER JOIN [OrderDetail] od
												ON o.[ID] = od.[Order]
											LEFT OUTER JOIN [OrderDetailQty] odq
												ON od.[ID] = odq.[OrderDetail]											
										WHERE 
										o.ID IN (	 SELECT o.ID	
														 FROM dbo.[Order] o
															  LEFT OUTER JOIN OrderDetail od 
																   ON o.ID = od.[Order] 
															  LEFT OUTER JOIN OrderDetailQty odq
																   ON od.ID = odq.OrderDetail
															JOIN VisualLayout vl
																ON od.VisualLayout = vl.ID
															JOIN Pattern pt
																ON vl.Pattern = pt.ID
															JOIN Item it
																ON pt.Item = it.ID	
															WHERE it.[ItemType] = @P_ItemType	   
														GROUP BY o.ID
														--HAVING SUM(odq.Qty) <= 5
														--UNION
														--SELECT o.ID	
														--FROM dbo.[Order] o
														--	  LEFT OUTER JOIN OrderDetail od 
														--		   ON o.ID = od.[Order] 
														--	  LEFT OUTER JOIN OrderDetailQty odq
														--		   ON od.ID = odq.OrderDetail
														--	  JOIN Reservation res 
														--		   ON o.Reservation = res.ID
														--GROUP BY o.ID
														--HAVING SUM(odq.Qty) <= 5
														)
														AND (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
														AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped')))),

		---- JacketsOrders
		--(SELECT ISNULL(SUM(odq.[Qty]), 0) AS Jackets 				  
		--								FROM [Order] o
		--									JOIN OrderDetail od
		--										ON o.ID = od.[Order]
		--									JOIN [OrderDetailQty] odq
		--										ON od.[ID] = odq.[OrderDetail]
		--									JOIN Pattern p
		--										ON p.ID = od.Pattern
		--									JOIN Item i
		--										ON i.ID = p.Item
		--								WHERE i.Name LIKE '%JACKET%' AND i.Parent IS NULL
		--									AND  (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
		--									AND  (p.IsActive = 1)
		--									AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped')))),
		
		-- SampleOrders
		(SELECT ISNULL(SUM(odq.[Qty]), 0) AS Samples											 
							   FROM dbo.[Order] o
									LEFT OUTER JOIN OrderDetail od
										ON o.ID =od.[Order]
									LEFT OUTER JOIN [OrderDetailQty] odq
										ON od.[ID] = odq.[OrderDetail]
									JOIN  Reservation res
										ON o.Reservation=res.ID
									JOIN Pattern pt
										ON res.Pattern = pt.ID
									JOIN Item it
										ON pt.Item = it.ID		
							   WHERE it.[ItemType] = @P_ItemType	   
									AND od.OrderType IN( (SELECT [ID] FROM [Indico].[dbo].[OrderType] WHERE [Name] = 'SAMPLE' OR [Name]  = 'DEV SAMPLE'))
									AND (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
									AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped'))))

	)
	
	SELECT * FROM @Capacities

END

GO


/****** Object:  View [dbo].[ReturnProductionCapacitiesView]    Script Date: 05/18/2015 14:16:55 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnProductionCapacitiesView]'))
DROP VIEW [dbo].[ReturnProductionCapacitiesView]
GO


/****** Object:  View [dbo].[ReturnProductionCapacitiesView]    Script Date: 05/18/2015 14:16:55 ******/
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
			--0 AS Jackets,
			0 AS Samples


GO


-------------------------------------SP Changes related to production capacities - end ----------------------------



