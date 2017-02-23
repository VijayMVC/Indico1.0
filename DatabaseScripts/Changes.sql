USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
/****** Object:  StoredProcedure [dbo].[SPC_GetDetailReportByDistributor]    Script Date: 2/23/2017 5:30:56 PM ******/
DROP PROCEDURE [dbo].[SPC_GetDetailReportByDistributor]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetDetailReportByDistributor]    Script Date: 2/23/2017 5:30:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SPC_GetDetailReportByDistributor](
	@P_StartDate AS datetime2(7) = '20160101',
	@P_EndDate AS datetime2(7) = '20160301',
	@P_Distributor AS int
)
AS
BEGIN

	IF OBJECT_ID('tempdb..#data') IS NOT NULL 
		DROP TABLE #data

	SELECT MONTH(o.[Date]) AS [Month],
		YEAR(o.[Date]) AS [Year],
		cl.ID, 
		cl.Name AS Client, 
		SUM(odq.Qty) AS Quantity, 
		ISNULL(SUM(odq.Qty * (cs.QuotedCIF+ ISNULL(od.Surcharge,0))), 0.0) AS IndimanPrice,
		SUM(odq.Qty * od.EditedPrice * (1 + (od.[DistributorSurcharge] / 100))) AS IndicoPrice INTO #data
	FROM [dbo].[Company] c
		JOIN [dbo].[Order] o
			ON c.ID = o.Distributor
		JOIN [dbo].[OrderDetail] od
			ON o.ID = od.[Order]
		JOIN [dbo].[VisualLayout] vl
			ON od.VisualLayout = vl.ID
		JOIN [dbo].[JobName] j
			ON vl.Client = j.ID
		JOIN [dbo].[OrderDetailQty] odq
			ON od.ID = odq.OrderDetail
		JOIN [dbo].[Client] cl
			ON cl.ID = j.Client
		LEFT OUTER JOIN CostSheet cs
			ON od.Pattern = cs.Pattern
				AND od.FabricCode = cs.Fabric
	WHERE IsDistributor = 1 AND o.[Date] >= @P_StartDate AND o.[Date] <= @P_EndDate AND c.ID = @P_Distributor AND o.[Status] != 28
	GROUP BY MONTH(o.[Date]), YEAR(o.[Date]), cl.ID, cl.Name

	SELECT	--DATENAME( MONTH , DATEADD(MONTH , d.[Month] , -1)) + '-' + CAST(d.[Year] AS nvarchar(4)) AS MonthAndYear, 
			(SELECT RIGHT('0' + CONVERT(VARCHAR(2), d.[Month]), 2)),
			CAST(d.[Year] AS nvarchar(4)) + (SELECT RIGHT('0' + CONVERT(VARCHAR(2), d.[Month]), 2)) AS MonthAndYear, 
			d.ID,
			d.Client,
			d.Quantity AS Quantity, 
			CAST((CAST(d.quantity AS float))/(SELECT SUM(Quantity) FROM #data d1 WHERE d1.[Month] = d.[Month] AND d1.[Year] = d.[Year]) AS decimal(7,5)) AS QuantityPercentage,
			d.IndicoPrice AS Value,
			CASE WHEN (SELECT SUM(IndicoPrice) FROM #data d1 WHERE d1.[Month] = d.[Month] AND d1.[Year] = d.[Year]) > 0 THEN
				CAST((CAST(d.IndicoPrice AS float))/(SELECT SUM(IndicoPrice) FROM #data d1 WHERE d1.[Month] = d.[Month] AND d1.[Year] = d.[Year]) AS decimal(9,5))
			ELSE
				CAST('0.00' AS decimal(5,2))
			END AS ValuePercentage,
			CASE WHEN d.Quantity > 0 THEN
				CAST(CAST(d.IndicoPrice AS float)/(d.Quantity) AS decimal(9,5))
			ELSE
				CAST('0.00' AS decimal(5,2))
			END AS AvgPrice,
			d.IndimanPrice AS PurchasePrice,
			d.IndicoPrice - d.IndimanPrice AS GrossProfit,
			CASE WHEN d.IndicoPrice != 0 THEN
				(d.IndicoPrice - d.IndimanPrice)/d.IndicoPrice
			ELSE
				CAST('0.00' AS decimal(5,2))
			END AS GrossMargin
	FROM #data d
	ORDER BY d.[Year], d.[Month], d.Client, Value DESC

END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange]    Script Date: 2/23/2017 5:50:56 PM ******/
DROP PROCEDURE [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange]    Script Date: 2/23/2017 5:50:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange](
	@P_StartDate AS datetime2(7) = '20160101',
	@P_EndDate AS datetime2(7) = '20160301',
	@P_DistributorName AS nvarchar(128),
	@P_DistributorType AS int
)
AS
BEGIN

	IF OBJECT_ID('tempdb..#data') IS NOT NULL 
		DROP TABLE #data

	SELECT	MONTH(o.[Date]) AS [Month], 
			YEAR(o.[Date]) AS [Year], 
			c.ID, 
			c.Name, 
			SUM(odq.Qty) AS Quantity, 
			SUM(odq.Qty * cs.QuotedCIF + ISNULL(od.Surcharge,0)) AS IndimanPrice,
			SUM(odq.Qty * od.EditedPrice * (1 + (od.[DistributorSurcharge] / 100))) AS IndicoPrice INTO #data
	FROM [dbo].[Company] c
		JOIN [dbo].[Order] o
			ON c.ID = o.Distributor
		JOIN [dbo].[OrderDetail] od
			ON o.ID = od.[Order]
		JOIN [dbo].[OrderDetailQty] odq
			ON od.ID = odq.OrderDetail
		LEFT OUTER JOIN CostSheet cs
			ON od.Pattern = cs.Pattern
				AND od.FabricCode = cs.Fabric
	WHERE IsDistributor = 1 and DistributorType = @P_DistributorType AND o.[Date] >= @P_StartDate AND o.[Date] <= @P_EndDate AND (@P_DistributorName = '' OR c.Name LIKE '%' + @P_DistributorName + '%') AND o.[Status] != 28--AND (@P_Distributor = 0 OR c.ID = @P_Distributor)
	GROUP BY MONTH(o.[Date]), YEAR(o.[Date]), c.ID, c.Name
	
	--SELECT DATENAME( MONTH , DATEADD(MONTH , d.[Month] , -1)) + '-' + CAST(d.[Year] AS nvarchar(4)) AS 'MonthAndYear', 
	SELECT (SELECT RIGHT('0' + CONVERT(VARCHAR(2), d.[Month]), 2)),
			CAST(d.[Year] AS nvarchar(4)) + (SELECT RIGHT('0' + CONVERT(VARCHAR(2), d.[Month]), 2)) AS MonthAndYear, 
			d.ID,
			d.Name AS Name, 
			d.Quantity AS Quantity, 
			CAST((CAST(d.quantity AS float))/(SELECT SUM(Quantity) FROM #data d1 WHERE d1.[Month] = d.[Month] AND d1.[Year] = d.[Year]) AS decimal(7,5)) AS QuantityPercentage,
			d.IndicoPrice AS Value,
			d.IndimanPrice AS PurchasePrice,
			CASE WHEN (SELECT SUM(IndicoPrice) FROM #data d1 WHERE d1.[Month] = d.[Month] AND d1.[Year] = d.[Year]) > 0 THEN
				CAST((CAST(d.IndicoPrice AS float))/(SELECT SUM(IndicoPrice) FROM #data d1 WHERE d1.[Month] = d.[Month] AND d1.[Year] = d.[Year]) AS decimal(9,5))
			ELSE
				CAST('0.00' AS decimal(5,2))
			END AS ValuePercentage,
			CASE WHEN d.Quantity > 0 THEN
				CAST(CAST(d.IndicoPrice AS float)/(d.Quantity) AS decimal(9,5))
			ELSE
				CAST('0.00' AS decimal(5,2))
			END AS AvgPrice,
			d.IndicoPrice - d.IndimanPrice AS GrossProfit,
			(((d.IndicoPrice - d.IndimanPrice)/d.IndicoPrice) * 100) AS GrossMargin
	FROM #data d
	ORDER BY d.[Year], d.[Month], Value DESC

END

GO
