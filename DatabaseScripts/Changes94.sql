USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySummary]    Script Date: 04/21/2014 11:29:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklySummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklySummary]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySummary]    Script Date: 04/21/2014 11:29:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SPC_GetWeeklySummary] (	
@P_WeekEndDate datetime2(7), --Shipment Date in OrderDetail Table
@P_IsShipmentDate AS bit = 1
)	
AS 
BEGIN

	IF(@P_IsShipmentDate = 1)
		BEGIN
				SELECT 
						ISNULL(dca.CompanyName, '') AS 'CompanyName', 
						ISNULL(SUM(odq.Qty), 0) AS  'Qty' , 
						ISNULL(sm.[Name], 'AIR') AS 'ShipmentMode',
						ISNULL(sm.[ID], 0) AS 'ShipmentModeID',
						ISNULL(dca.[ID], 0) AS 'DistributorClientAddress'
						  FROM [Indico].[dbo].[DistributorClientAddress] dca
						 JOIN [dbo].[ORDER] o
							ON o.[DespatchToExistingClient] = dca.ID
						 JOIN [dbo].[OrderDetail] od
							ON od.[Order] = o.ID
						 JOIN [dbo].[OrderDetailQty] odq
							ON odq.[OrderDetail] = od.ID
						 JOIN [dbo].[ShipmentMode] sm
							ON o.[ShipmentMode] = sm.[ID]
						WHERE (od.[ShipmentDate] = @P_WeekEndDate)
						GROUP BY dca.CompanyName, sm.[Name], sm.[ID],dca.[ID]
		END
	ELSE
		BEGIN
			SELECT 
							ISNULL(dca.CompanyName, '') AS 'CompanyName', 
							ISNULL(SUM(odq.Qty), 0) AS  'Qty' , 
							ISNULL(sm.[Name], 'AIR') AS 'ShipmentMode',
							ISNULL(sm.[ID], 0) AS 'ShipmentModeID',
							ISNULL(dca.[ID], 0) AS 'DistributorClientAddress'
							  FROM [Indico].[dbo].[DistributorClientAddress] dca
							 JOIN [dbo].[ORDER] o
								ON o.[DespatchToExistingClient] = dca.ID
							 JOIN [dbo].[OrderDetail] od
								ON od.[Order] = o.ID
							 JOIN [dbo].[OrderDetailQty] odq
								ON odq.[OrderDetail] = od.ID
							 JOIN [dbo].[ShipmentMode] sm
								ON o.[ShipmentMode] = sm.[ID]
							WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
							GROUP BY dca.CompanyName, sm.[Name], sm.[ID],dca.[ID]
		END
END



GO


