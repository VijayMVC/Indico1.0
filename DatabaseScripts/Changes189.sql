USE [Indico]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderClients]    Script Date: 5/27/2016 5:51:51 PM ******/
DROP PROCEDURE [dbo].[SPC_GetOrderClients]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderClients]    Script Date: 5/27/2016 5:51:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SPC_GetOrderClients](
@P_Distributor AS int 
)

AS
BEGIN

	SELECT  DISTINCT c.[ID]
					,c.[Name] AS Name 
			--FROM [dbo].[Order] o
			-- JOIN [dbo].[Client] c
			--	ON o.[Client] = c.[ID]
			FROM [dbo].[Order] o
			 JOIN [dbo].[JobName] j
				ON o.[Client] = j.[ID]
			JOIN [dbo].[Client] c
				ON j.[Client] = c.ID
			WHERE (@P_Distributor = 0 OR o.[Distributor] = @P_Distributor)
			ORDER BY c.Name
END


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 5/27/2016 6:00:49 PM ******/
DROP PROCEDURE [dbo].[SPC_ViewOrderDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 5/27/2016 6:00:49 PM ******/
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
		  ,ISNULL (cl.Name, '') AS Client
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
		--LEFT OUTER JOIN [dbo].[Company] c
		--	ON o.[Distributor] = c.[ID]
		--LEFT OUTER JOIN [dbo].[User] u
		--	ON c.[Coordinator] = u.[ID]	
		--LEFT OUTER JOIN [dbo].[JobName] j
		--	ON o.[Client] = j.[ID]
		--LEFT OUTER JOIN [dbo].[Client] cl
		--	ON j.[Client] = cl.[ID]					
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
		INNER JOIN [dbo].[JobName] j
			ON vl.[Client] = j.[ID]
		INNER JOIN [dbo].[Client] cl
			ON j.[Client] = cl.[ID]	
		INNER JOIN [dbo].[Company] c
			ON cl.Distributor = c.[ID]
		LEFT OUTER JOIN [dbo].[User] u
			ON c.[Coordinator] = u.[ID]
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
		  (@P_Distributor = 0 OR cl.Distributor = @P_Distributor)	AND
		  (@P_Client = 0 OR cl.[ID] = @P_Client) AND				  
		  (@P_DistributorClientAddress = 0 OR o.[BillingAddress] = @P_DistributorClientAddress) AND
		  ((@P_SelectedDate1 IS NULL AND @P_SelectedDate2 IS NULL) OR (o.[Date] BETWEEN @P_SelectedDate1 AND @P_SelectedDate2))
	--ORDER BY o.[ID] DESC			
END
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

