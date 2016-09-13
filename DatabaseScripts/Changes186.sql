USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange]    Script Date: 01-Apr-16 1:44:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange](
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

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetDetailReportByDistributor]    Script Date: 01-Apr-16 10:12:06 AM ******/
DROP PROCEDURE [dbo].[SPC_GetDetailReportByDistributor]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetDetailReportByDistributor]    Script Date: 01-Apr-16 10:12:06 AM ******/
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

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  View [dbo].[ReturnDetailReportByDistributor]    Script Date: 23-Mar-16 10:56:34 AM ******/
DROP VIEW [dbo].[ReturnDetailReportByDistributor]
GO

/****** Object:  View [dbo].[ReturnDetailReportByDistributor]    Script Date: 23-Mar-16 10:53:39 AM ******/
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
	  0.0 AS GrossProfit,
	  0.0 AS GrossMargin  

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetDetailReportByClient]    Script Date: 01-Apr-16 2:07:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROC [dbo].[SPC_GetDetailReportByClient](
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
			CAST('0.00' AS decimal(5,2)) AS GrossMargin
			/*CASE WHEN (odq.Qty * (1+ (od.SurCharge/100)) * od.EditedPrice) != 0 THEN
				SUM((odq.Qty * (1+ (od.SurCharge/100)) * od.EditedPrice - odq.Qty * cs.QuotedCIF)/(odq.Qty * (1+ (od.SurCharge/100)) * od.EditedPrice))
			ELSE
				CAST('0.00' AS decimal(5,2))
			END AS GrossMargin*/
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
	WHERE IsDistributor = 1 AND o.[Date] >= @P_StartDate AND o.[Date] <= @P_EndDate AND c.ID = @P_Distributor AND cl.ID = @P_Client
	GROUP BY MONTH(o.[Date]), YEAR(o.[Date]), vl.NamePrefix, i.Name, od.SurCharge, od.EditedPrice, odq.Qty
	ORDER BY Value DESC

END


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  View [dbo].[ReturnDetailReportByClient]    Script Date: 01-Apr-16 2:33:37 PM ******/
DROP VIEW [dbo].[ReturnDetailReportByClient]
GO

/****** Object:  View [dbo].[ReturnDetailReportByClient]    Script Date: 01-Apr-16 2:33:37 PM ******/
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


/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 5/3/2016 5:18:34 PM ******/
DROP PROCEDURE [dbo].[SPC_ViewOrderDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 5/3/2016 5:18:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_ViewOrderDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',
	@P_LogCompanyID AS int = 0,
	@P_Status AS nvarchar(255),
	@P_Coordinator AS int = 0,
	@P_Distributor AS int = 0,
	@P_Client AS int = 0,
	@P_SelectedDate1 AS datetime2(7) = NULL,
	@P_SelectedDate2 AS datetime2(7) = NULL,
	@P_DistributorClientAddress AS int = 0	 
)
AS
BEGIN

	SET NOCOUNT ON
	DECLARE @orderid AS int;
	DECLARE @status AS TABLE ( ID int )
	
	IF (ISNUMERIC(@P_SearchText) = 1) 
		BEGIN
			SET @orderid = CONVERT(INT, @P_SearchText)		
		END
	ELSE
		BEGIN	
			SET @orderid = 0
		END;
	
	INSERT INTO @status (ID) SELECT DATA FROM [dbo].Split(@P_Status,',');
	
	SELECT 			
		   od.[ID] AS OrderDetail
		  ,ISNULL(od.EditedPrice, 0) AS EditedPrice
		  ,ot.[Name] AS OrderType
		  --,ISNULL(vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),''),'') AS VisualLayout		  
		  ,(SELECT CASE 
			 WHEN od.VisualLayout IS NOT NULL THEN ISNULL(vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),''),'') 			 
			 ELSE ISNULL(aw.ReferenceNo ,'')
			END)
		  AS VisualLayout		  
		  ,ISNULL(od.[VisualLayout],0) AS VisualLayoutID
		  --,od.[Pattern] AS PatternID
		   ,(SELECT CASE 
			WHEN  (ISNULL(od.[VisualLayout],0)>0) 
			THEN vl.Pattern
			ELSE od.Pattern
			END ) AS PatternID
		  --,p.[Number] + ' - ' + p.[NickName] AS Pattern
		   ,(SELECT CASE 
			WHEN  (ISNULL(od.[VisualLayout],0)>0) 
			THEN ( SELECT ( Number + ' - ' + NickName) FROM [dbo].Pattern WHERE ID = vl.Pattern )
			ELSE  ( SELECT ( Number + ' - ' + NickName) FROM [dbo].Pattern WHERE ID = od.Pattern )
			END ) AS Pattern
		  --,od.[FabricCode] AS FabricID
		  ,(SELECT CASE 
			WHEN  (ISNULL(od.[VisualLayout],0)>0) 
			THEN vl.FabricCode
			ELSE od.FabricCode
			END ) AS FabricID
		  --,fc.[Code] + ' - ' + fc.[Name] AS Fabric
		   ,(SELECT CASE 
			WHEN  (ISNULL(od.[VisualLayout],0)>0) 
			THEN ( SELECT ( [Code] + ' - ' + [Name]) FROM [dbo].FabricCode WHERE ID = vl.FabricCode )
			ELSE  ( SELECT ( [Code] + ' - ' + [Name]) FROM [dbo].FabricCode WHERE ID = od.FabricCode )
			END ) AS Fabric
		  ,ISNULL(od.[VisualLayoutNotes],'') AS VisualLayoutNotes      
		  ,od.[Order] AS 'Order'
		  --,ISNULL(o.[Label], 0) AS Label
		  ,ISNULL(ods.[Name], 'New') AS OrderDetailStatus
		  ,ISNULL(od.[Status], 0) AS OrderDetailStatusID
		  ,od.[ShipmentDate] AS ShipmentDate
		  ,od.[SheduledDate] AS SheduledDate      
		  ,od.[RequestedDate] AS RequestedDate
		  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]),0) AS Quantity      
		  ,(SELECT DATEDIFF(day, od.[RequestedDate], od.[SheduledDate])) AS 'DateDiffrence'
		  ,ISNULL(o.[OldPONo], '') AS 'PurONo'
		  ,c.[Name] AS Distributor
		  ,u.[GivenName] + ' ' + u.[FamilyName] AS Coordinator
		  --,cl.[Name] AS Client
		  ,ISNULL ( (SELECT cl.Name From [dbo].JobName j
			INNER JOIN [dbo].Client cl
				ON j.Client = cl.ID
			WHERE j.ID = vl.Client), '') AS Client
		  ,os.[Name] AS OrderStatus
		  ,o.[Status] AS OrderStatusID
		  ,urc.[GivenName] + ' ' + urc.[FamilyName] AS Creator
		  ,o.[Creator] AS CreatorID
		  ,o.[CreatedDate] AS CreatedDate
		  ,urm.[GivenName] + ' ' + urm.[FamilyName] AS Modifier
		  ,o.[ModifiedDate] AS ModifiedDate
		  ,ISNULL(pm.[Name], '') AS PaymentMethod
		  ,ISNULL(sm.[Name], '') AS ShipmentMethod
		  ,o.[IsWeeklyShipment]  AS WeeklyShiment
		  ,o.[IsCourierDelivery]  AS CourierDelivery
		  ,o.[IsAdelaideWareHouse] AS AdelaideWareHouse
		  ,o.[IsFollowingAddress] AS FollowingAddress
		  ,ISNULL(bdca.[CompanyName] + ' ' + bdca.[Address] + ' ' + bdca.[Suburb] + ' ' + ISNULL(bdca.[State], '') + ' ' + bco.[ShortName] + ' ' + bdca.[PostCode], '') 
		  AS BillingAddress
		  ,ISNULL(ddca.[CompanyName] 
		  --+ ' ' + ddca.[Address] + ' ' + ddca.[Suburb] + ' ' + ISNULL(ddca.[State], '') + ' ' + dco.[ShortName] + ' ' + ddca.[PostCode]
		  , '') 
		  AS ShippingAddress
		  ,ISNULL(ddp.[Name], '') AS DestinationPort
		  ,ISNULL(vl.[ResolutionProfile], 0 ) AS ResolutionProfile
		  ,o.[IsAcceptedTermsAndConditions] AS IsAcceptedTermsAndConditions
		  ,od.Surcharge
		  ,cl.FOCPenalty 
	  FROM [dbo].[Order] o				
		LEFT OUTER JOIN [dbo].[OrderStatus] os
			ON o.[Status] = os.[ID]
		LEFT OUTER JOIN [dbo].[Company] c
			ON o.[Distributor] = c.[ID]
		LEFT OUTER JOIN [dbo].[User] u
			ON c.[Coordinator] = u.[ID]	
		LEFT OUTER JOIN [dbo].[JobName] j
			ON o.[Client] = j.[ID]
		LEFT OUTER JOIN [dbo].[Client] cl
			ON j.[Client] = cl.[ID]					
		LEFT OUTER JOIN [dbo].[User] urc
			ON o.[Creator] = urc.[ID]
		LEFT OUTER JOIN [dbo].[User] urm
			ON o.[Modifier] = urm.[ID]		
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] bdca
			ON o.[BillingAddress] = bdca.[ID]		
		LEFT OUTER JOIN [dbo].[Country] bco
			ON bdca.[Country] = bco.[ID]		
		LEFT OUTER JOIN [dbo].[DestinationPort] bdp
			ON bdca.[Port] = bdp.[ID] 			
		INNER JOIN [dbo].[OrderDetail] od				
			ON o.[ID] = od.[Order]
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] ddca
			ON od.[DespatchTo] = ddca.[ID]
		LEFT OUTER JOIN [dbo].[Country] dco
			ON ddca.[Country] = dco.[ID]
		LEFT OUTER JOIN [dbo].[DestinationPort] ddp
			ON ddca.[Port] = ddp.[ID] 				
		LEFT OUTER JOIN [dbo].[PaymentMethod] pm
			ON od.[PaymentMethod] = pm.[ID]
		LEFT OUTER JOIN [dbo].[ShipmentMode] sm
			ON od.[ShipmentMode] = sm.[ID]					
		LEFT OUTER JOIN [dbo].[VisualLayout] vl
			ON od.[VisualLayout] = vl.[ID]
		LEFT OUTER JOIN [dbo].[ArtWork] aw
			ON od.[ArtWork] = aw.[ID]
		--LEFT OUTER JOIN [dbo].[Pattern] p 
		--	ON od.[Pattern] = p.[ID]
		--LEFT OUTER JOIN [dbo].[FabricCode] fc
		--	ON od.[FabricCode] = fc.[ID]
		LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
			ON od.[Status] = ods.[ID]
		LEFT OUTER JOIN [dbo].[OrderType] ot
			ON od.[OrderType] = ot.[ID]
	WHERE (@P_SearchText = '' OR
			o.[ID] = @orderid OR
		   o.[OldPONo] LIKE '%' + @P_SearchText + '%' OR
		   u.[GivenName]  LIKE '%' + @P_SearchText + '%' OR
		   u.[FamilyName] LIKE '%' + @P_SearchText + '%' OR
		   --p.[Number] LIKE '%' + @P_SearchText + '%' OR 
		   --p.[NickName] LIKE '%' + @P_SearchText + '%' OR
		   vl.[NamePrefix] LIKE '%' + @P_SearchText + '%' OR 
		   vl.[NameSuffix] LIKE '%' + @P_SearchText + '%' OR 
		   ods.[Name] LIKE '%' + @P_SearchText + '%' OR 
		   ot.[Name] LIKE '%' + @P_SearchText + '%' OR
		   c.[Name] LIKE '%' + @P_SearchText + '%' OR 
		   cl.[Name] LIKE '%' + @P_SearchText + '%' --OR					
		   --fc.[Code] LIKE '%' + @P_SearchText + '%' OR 
		   --fc.[Name] LIKE '%' + @P_SearchText + '%'  
			)AND
		   (@P_Status = '' OR  (os.[ID] IN (SELECT ID FROM @status)) )  AND											   
		  (@P_LogCompanyID = 0 OR c.[ID] = @P_LogCompanyID)	AND
		  (@P_Coordinator = 0 OR c.[Coordinator] = @P_Coordinator ) AND				  
		  (@P_Distributor = 0 OR o.Distributor = @P_Distributor)	AND
		  (@P_Client = 0 OR o.[Client] = @P_Client) AND				  
		  (@P_DistributorClientAddress = 0 OR o.[BillingAddress] = @P_DistributorClientAddress) AND
		  ((@P_SelectedDate1 IS NULL AND @P_SelectedDate2 IS NULL) OR (o.[Date] BETWEEN @P_SelectedDate1 AND @P_SelectedDate2))
	--ORDER BY o.[ID] DESC			
END


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

-- Update Order detail status to Senanayake..

  UPDATE [dbo].[OrderDetail]
  SET [Status] = 1
  WHERE ShipmentDate < '2016-05-03' AND [Status] IS NULL

  GO

  --**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

  UPDATE [dbo].Pattern SET SizeSet = '56'
  WHERE ID = '2195'

  DELETE FROM [dbo].[orderdetailQty]
  WHERE [Orderdetail] = '53795'

  INSERT INTO [dbo].[orderdetailQty] 
			([Orderdetail],[Size],[Qty])
	 VALUES ('53795', '318', '50')