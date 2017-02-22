USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetDetailReportByClient]    Script Date: 2/22/2017 6:22:22 PM ******/
DROP PROCEDURE [dbo].[SPC_GetDetailReportByClient]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetDetailReportByClient]    Script Date: 2/22/2017 6:22:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SPC_GetDetailReportByClient](
	@P_StartDate AS datetime2(7) = '20160101',
	@P_EndDate AS datetime2(7) = '20160301',
	@P_Distributor AS int,
	@P_Client AS int
)
AS
BEGIN

	IF OBJECT_ID('tempdb..#data') IS NOT NULL 
		DROP TABLE #data

	SELECT	vl.NamePrefix AS VLName, 
			i.Name AS SubItemName, 
			(ISNULL(odq.Qty, 0)) AS Quantity, 
			((1+ (ISNULL(od.[DistributorSurcharge], 0)/100)) * ISNULL(od.EditedPrice, 0)) AS Price, 
			(odq.Qty * (1+ (ISNULl(od.[DistributorSurcharge], 0)/100)) * ISNULL(od.EditedPrice, 0)) AS Value, 
			(odq.Qty * (ISNULL(cs.QuotedCIF, 0) + ISNULL(od.Surcharge,0) )) AS PurchasePrice,
			(odq.Qty * (1+ (ISNULL(od.[DistributorSurcharge], 0)/100)) * ISNULL(od.EditedPrice, 0)) - (odq.Qty * ISNULL(cs.QuotedCIF, 0)) AS GrossProfit INTO #data
	FROM [dbo].[Company] c
		JOIN [dbo].[Order] o
			ON c.ID = o.Distributor
		JOIN [dbo].[OrderDetail] od
			ON o.ID = od.[Order]
		JOIN [dbo].[VisualLayout] vl
			ON od.VisualLayout = vl.ID
		JOIN [dbo].[Pattern] p
			ON vl.Pattern = p.ID
		LEFT OUTER JOIN [dbo].[Item] i
			ON p.SubItem = i.ID
		JOIN [dbo].[JobName] j
			ON vl.Client = j.ID
		JOIN [dbo].[OrderDetailQty] odq
			ON od.ID = odq.OrderDetail
		--JOIN [dbo].[Client] cl
		--	ON j.Client = cl.ID
		JOIN [dbo].[CostSheet] cs
			ON cs.Pattern = vl.Pattern
				AND cs.Fabric = vl.FabricCode 
	WHERE IsDistributor = 1 AND o.[Date] >= @P_StartDate AND o.[Date] <= @P_EndDate AND c.ID = @P_Distributor AND j.Client = @P_Client AND odq.Qty != 0  AND o.[Status] != 28

	SELECT	d.VLName, 
			d.SubItemName, 
			SUM(Quantity) AS Quantity, 
			Price, 
			SUM(Value) AS Value, 
			SUM(PurchasePrice) AS PurchasePrice,
			SUM(Value - PurchasePrice) AS GrossProfit,
			(CASE WHEN SUM(Value) = 0 THEN 0
			ELSE 
				SUM(Value - PurchasePrice)/SUM(Value)
			END) AS GrossMargin
	FROM #data d
	GROUP BY d.VLName, d.SubItemName, Price
	ORDER BY Value DESC
END

GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--