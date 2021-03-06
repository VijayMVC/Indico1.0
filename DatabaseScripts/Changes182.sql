USE [Indico]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

UPDATE [dbo].OrderDetail 
SET VisualLayout = 49297
WHERE VisualLayout = 49565
GO

DELETE FROM [dbo].[Image] 
WHERE [VisualLayout] = 49565
GO

DELETE FROM [dbo].[VisualLayoutAccessory]
WHERE [VisualLayout] = 49565
GO

DELETE FROM [dbo].[VisualLayout] 
WHERE ID = 49565
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

-- Sales Report page

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
     VALUES ('/SalesReport.aspx','Sales Reports','Sales Reports')	 
SET @PageId = SCOPE_IDENTITY()

-- Parent Menu Item
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Reports', 'Reports', 1, NULL, 13, 1)
SET @MenuItemMenuId = SCOPE_IDENTITY()

--Menu Item					
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Sales Report', 'Sales Report', 1, @MenuItemMenuId, 1, 1)
SET @MenuItemId = SCOPE_IDENTITY()

-- Menu Item Role
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @IndimanAdministrator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @IndicoCoordinator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemMenuId, @IndicoAdministrator)

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoCoordinator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoAdministrator)

GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
-- exec [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange] '20160101', '20160310', '', 1
/****** Object:  StoredProcedure [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange]    Script Date: 03-Mar-16 9:40:29 AM ******/
DROP PROCEDURE [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange]    Script Date: 03-Mar-16 9:35:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange](
	@P_StartDate AS datetime2(7) = '20160101',
	@P_EndDate AS datetime2(7) = '20160301',
	--@P_Distributor AS int,
	@P_DistributorName AS nvarchar(128),
	@P_DistributorType AS int
)
AS
BEGIN

	IF OBJECT_ID('tempdb..#data') IS NOT NULL 
		DROP TABLE #data

	SELECT MONTH(o.[Date]) AS 'Month', YEAR(o.[Date]) AS 'Year', c.Name, SUM(odq.Qty) AS 'Quantity', SUM(odq.Qty * od.EditedPrice) AS 'Value' INTO #data
	FROM [dbo].[Company] c
		JOIN [dbo].[Order] o
			ON c.ID = o.Distributor
		JOIN [dbo].[OrderDetail] od
			ON o.ID = od.[Order]
		JOIN [dbo].[OrderDetailQty] odq
			ON od.ID = odq.OrderDetail
	WHERE IsDistributor = 1 and DistributorType = @P_DistributorType AND o.[Date] >= @P_StartDate AND o.[Date] <= @P_EndDate AND (@P_DistributorName = '' OR c.Name LIKE '%' + @P_DistributorName + '%')--AND (@P_Distributor = 0 OR c.ID = @P_Distributor)
	GROUP BY MONTH(o.[Date]), YEAR(o.[Date]), c.Name
	
	--SELECT DATENAME( MONTH , DATEADD(MONTH , d.[Month] , -1)) + '-' + CAST(d.[Year] AS nvarchar(4)) AS 'MonthAndYear', 
	SELECT (SELECT RIGHT('0' + CONVERT(VARCHAR(2), d.[Month]), 2)),
			CAST(d.[Year] AS nvarchar(4)) + (SELECT RIGHT('0' + CONVERT(VARCHAR(2), d.[Month]), 2)) AS 'MonthAndYear', 
			d.Name AS 'Name', 
			d.Quantity AS 'Quantity', 
			CAST((CAST(d.quantity AS float))/(SELECT SUM(Quantity) FROM #data d1 WHERE d1.[Month] = d.[Month] AND d1.[Year] = d.[Year]) AS decimal(7,5)) AS 'QuantityPercentage',
			d.Value AS 'Value',
			CASE WHEN (SELECT SUM(Value) FROM #data d1 WHERE d1.[Month] = d.[Month] AND d1.[Year] = d.[Year]) > 0 THEN
				CAST((CAST(d.Value AS float))/(SELECT SUM(Value) FROM #data d1 WHERE d1.[Month] = d.[Month] AND d1.[Year] = d.[Year]) AS decimal(9,5))
			ELSE
				CAST('0.00' AS decimal(5,2))
			END AS 'ValuePercentage',
			CASE WHEN d.Quantity > 0 THEN
				CAST(CAST(d.Value AS float)/(d.Quantity) AS decimal(9,5))
			ELSE
				CAST('0.00' AS decimal(5,2))
			END AS 'AvgPrice'
	FROM #data d
	ORDER BY d.[Year], d.[Month]

END

GO 

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  View [dbo].[ReturnOrderQuantitiesAndAmount]    Script Date: 3/7/2016 5:05:24 PM ******/
DROP VIEW [dbo].[ReturnOrderQuantitiesAndAmount]
GO

/****** Object:  View [dbo].[ReturnOrderQuantitiesAndAmount]    Script Date: 3/7/2016 5:05:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnOrderQuantitiesAndAmount]
AS

SELECT '' AS MonthAndYear,
      '' AS Name,       
      0 AS Quantity,
	  0.0 AS QuantityPercentage,
	  0.0 AS Value,
	  0.0 AS ValuePercentage,
	  0.0 AS AvgPrice
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[Client]
	ADD [FOCPenalty] bit NOT NULL DEFAULT(0)
GO

UPDATE [dbo].[Client]
	SET [FOCPenalty] = 1
FROM [dbo].[Client]
WHERE Name = 'SFNL'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 08-Mar-16 3:58:35 PM ******/
DROP PROCEDURE [dbo].[SPC_ViewOrderDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 08-Mar-16 3:55:49 PM ******/
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
		  ,cl.[Name] AS Client
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

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 08-Mar-16 4:01:00 PM ******/
DROP VIEW [dbo].[OrderDetailsView]
GO

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 08-Mar-16 3:51:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OrderDetailsView]
AS
			SELECT
				  0 AS OrderDetail,
				  0.0 AS EditedPrice,
				  '' AS OrderType,
				  '' AS VisualLayout,
				  0 AS VisualLayoutID,
				  0 AS PatternID,
				  '' AS Pattern,
				  0 AS FabricID,
				  '' AS Fabric,
				  '' AS VisualLayoutNotes,      
				  0 AS 'Order',
				  --0 AS Label,
				  '' AS OrderDetailStatus,
				  0 AS OrderDetailStatusID,
				  GETDATE() AS ShipmentDate,
				  GETDATE() AS SheduledDate,
				  GETDATE() AS RequestedDate,
				  0 AS Quantity,
				  0 AS 'DateDiffrence',
				  '' AS 'PurONo',
				  '' AS Distributor,
				  '' AS Coordinator,
				  '' AS Client,
				  '' AS OrderStatus,
				  0 AS OrderStatusID,
				  '' AS Creator,
				  0 AS CreatorID,
				  GETDATE() AS CreatedDate,
				  '' AS Modifier,
				  GETDATE() AS ModifiedDate,
				  '' AS PaymentMethod,
				  '' AS ShipmentMethod,
				  CONVERT(bit,0) AS WeeklyShiment,
				  CONVERT(bit,0) AS CourierDelivery,
				  CONVERT(bit,0) AS AdelaideWareHouse,
				  CONVERT(bit,0) AS FollowingAddress,
				  '' AS BillingAddress,
				  '' AS ShippingAddress,
				  '' AS DestinationPort,
				  0 AS ResolutionProfile,
				  CONVERT(bit,0) AS IsAcceptedTermsAndConditions,
				  0.00 AS Surcharge,
				  CONVERT(bit,0) AS FOCPenalty
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

