USE [Indico]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnDetailReportByClient]'))
DROP VIEW [dbo].[ReturnDetailReportByClient]
GO

/****** Object:  View [dbo].[ReturnDetailReportByClient]    Script Date: 10-May-16 5:52:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnDetailReportByClient]
AS

SELECT '' AS VLName,
	  '' AS SubItemName,
      0 AS Quantity,
	  0.0 AS Price,
	  0.0 AS Value,
	  0.0 AS GrossProfit,
	  0.0 AS GrossMargin


GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnDetailReportByDistributor]'))
DROP VIEW [dbo].[ReturnDetailReportByDistributor]
GO

/****** Object:  View [dbo].[ReturnDetailReportByDistributor]    Script Date: 10-May-16 5:52:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnDetailReportByDistributor]
AS

SELECT '' AS MonthAndYear,
	  0 AS ID,	
	  '' AS Client,
      0 AS Quantity,
	  0.0 AS QuantityPercentage,
	  0.0 AS Value,
	  0.0 AS ValuePercentage,
	  0.0 AS AvgPrice,
	  0.0 AS IndimanPrice,
	  0.0 AS GrossProfit,
	  0.0 AS GrossMargin  


GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnOrderQuantitiesAndAmount]'))
DROP VIEW [dbo].[ReturnOrderQuantitiesAndAmount]
GO

/****** Object:  View [dbo].[ReturnOrderQuantitiesAndAmount]    Script Date: 10-May-16 5:52:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnOrderQuantitiesAndAmount]
AS

SELECT '' AS MonthAndYear,
	  0 AS ID,	
      '' AS Name,       
      0 AS Quantity,
	  0.0 AS QuantityPercentage,
	  0.0 AS Value,
	  0.0 AS ValuePercentage,
	  0.0 AS AvgPrice,
	  0.0 AS GrossProfit,
	  0.0 AS GrossMargin


GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetDetailReportByClient]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetDetailReportByClient]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetDetailReportByClient]    Script Date: 10-May-16 5:53:17 PM ******/
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

	SELECT	vl.NamePrefix AS VLName, 
			i.Name AS SubItemName, 
			SUM(odq.Qty) AS Quantity, 
			((1+ (od.SurCharge/100)) * od.EditedPrice) AS Price, 
			SUM(odq.Qty * (1+ (od.SurCharge/100)) * od.EditedPrice) AS Value, 
			--SUM(odq.Qty * cs.QuotedCIF) AS IndimanPrice
			SUM(odq.Qty * (1+ (od.SurCharge/100)) * od.EditedPrice - odq.Qty * cs.QuotedCIF) AS GrossProfit,
			--(odq.Qty) AS GrossMargin
			--CAST('0.00' AS decimal(5,2)) AS GrossMargin
			CASE WHEN ((odq.Qty * (1+ (od.SurCharge/100)) * od.EditedPrice) > 0.0) THEN
				SUM((odq.Qty * (1+ (od.SurCharge/100)) * od.EditedPrice - odq.Qty * cs.QuotedCIF)/(odq.Qty * (1+ (od.SurCharge/100)) * od.EditedPrice))
			ELSE
				CAST('0.00' AS decimal(5,2))
			END AS GrossMargin
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
			ON o.Client = j.ID
		JOIN [dbo].[OrderDetailQty] odq
			ON od.ID = odq.OrderDetail
		JOIN [dbo].[Client] cl
			ON j.Client = cl.ID
		JOIN [dbo].[CostSheet] cs
			ON cs.Pattern = od.Pattern
				AND cs.Fabric = od.FabricCode 
	WHERE IsDistributor = 1 AND o.[Date] >= @P_StartDate AND o.[Date] <= @P_EndDate AND c.ID = @P_Distributor AND cl.ID = @P_Client AND odq.Qty != 0
	GROUP BY MONTH(o.[Date]), YEAR(o.[Date]), vl.NamePrefix, i.Name, od.SurCharge, od.EditedPrice, odq.Qty
	ORDER BY Value DESC

END

GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetDetailReportByDistributor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetDetailReportByDistributor]
GO


/****** Object:  StoredProcedure [dbo].[SPC_GetDetailReportByDistributor]    Script Date: 10-May-16 5:54:06 PM ******/
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
		ISNULL(SUM(odq.Qty * cs.QuotedCIF), 0.0) AS IndimanPrice,
		SUM(odq.Qty * od.EditedPrice * (1 + (od.Surcharge / 100))) AS IndicoPrice INTO #data
	FROM [dbo].[Company] c
		JOIN [dbo].[Order] o
			ON c.ID = o.Distributor
		JOIN [dbo].[OrderDetail] od
			ON o.ID = od.[Order]
		JOIN [dbo].[JobName] j
			ON o.Client = j.ID
		JOIN [dbo].[OrderDetailQty] odq
			ON od.ID = odq.OrderDetail
		JOIN [dbo].[Client] cl
			ON cl.ID = j.Client
		LEFT OUTER JOIN CostSheet cs
			ON od.Pattern = cs.Pattern
				AND od.FabricCode = cs.Fabric
	WHERE IsDistributor = 1 AND o.[Date] >= @P_StartDate AND o.[Date] <= @P_EndDate AND c.ID = @P_Distributor
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
			d.IndimanPrice AS IndimanPrice,
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

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange]    Script Date: 10-May-16 5:55:02 PM ******/
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
			SUM(odq.Qty * cs.QuotedCIF) AS IndimanPrice,
			SUM(odq.Qty * od.EditedPrice * (1 + (od.Surcharge / 100))) AS IndicoPrice INTO #data
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
	WHERE IsDistributor = 1 and DistributorType = @P_DistributorType AND o.[Date] >= @P_StartDate AND o.[Date] <= @P_EndDate AND (@P_DistributorName = '' OR c.Name LIKE '%' + @P_DistributorName + '%')--AND (@P_Distributor = 0 OR c.ID = @P_Distributor)
	GROUP BY MONTH(o.[Date]), YEAR(o.[Date]), c.ID, c.Name
	
	--SELECT DATENAME( MONTH , DATEADD(MONTH , d.[Month] , -1)) + '-' + CAST(d.[Year] AS nvarchar(4)) AS 'MonthAndYear', 
	SELECT (SELECT RIGHT('0' + CONVERT(VARCHAR(2), d.[Month]), 2)),
			CAST(d.[Year] AS nvarchar(4)) + (SELECT RIGHT('0' + CONVERT(VARCHAR(2), d.[Month]), 2)) AS MonthAndYear, 
			d.ID,
			d.Name AS Name, 
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
			d.IndicoPrice - d.IndimanPrice AS GrossProfit,
			(((d.IndicoPrice - d.IndimanPrice)/d.IndicoPrice) * 100) AS GrossMargin
	FROM #data d
	ORDER BY d.[Year], d.[Month]

END

GO

-- Menu item --

DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

DECLARE @IndimanAdministrator int
DECLARE @IndicoCoordinator int
DECLARE @IndicoAdministrator int

SET @IndimanAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @IndicoCoordinator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
SET @IndicoAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Administrator')

-- Page
INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/DrillDownReportByClient.aspx','Drill Down Report By Client','Drill Down Report By Client')	 
SET @PageId = SCOPE_IDENTITY()

-- Parent Menu Item
SELECT @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Reports'

--Menu Item					
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Drill Down Report By Client', 'Drill Down Report By Client', 1, @MenuItemMenuId, 5, 0)
SET @MenuItemId = SCOPE_IDENTITY()

-- Menu Item Role
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoCoordinator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoAdministrator)

GO
