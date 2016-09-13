USE [Indico]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 6/15/2016 2:37:49 PM ******/
DROP PROCEDURE [dbo].[SPC_ViewOrderDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 6/15/2016 2:37:49 PM ******/
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
		  ,(ISNULL(od.EditedPrice, 0)  + ( od.Surcharge  * ISNULL(od.EditedPrice, 0) / 100  ) ) AS EditedPrice
		  ,ot.[Name] AS OrderType		  
		  ,(vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),'') ) AS VisualLayout		  
		  ,ISNULL(od.[VisualLayout],0) AS VisualLayoutID		  
		   ,vl.Pattern AS PatternID		  
		   ,p.Number + ' - ' + p.NickName AS Pattern		  
		  ,vl.FabricCode AS FabricID
		   , f.[Code] + ' - ' + f.[Name] AS Fabric		  
		    ,CASE WHEN	(ISNULL(od.[VisualLayoutNotes],'') = '') AND
						(ISNULL(o.[Notes],'') = '')
			THEN 0	
			ELSE 1 
			END
			AS HasNotes
		  ,o.[ID] AS 'Order'
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
		  ,ISNULL (cl.Name, '') AS Client
		  ,ISNULL (j.Name, '') AS JobName		  
		  ,os.[Name] AS OrderStatus
		  ,o.[Status] AS OrderStatusID
		  ,urc.[GivenName] + ' ' + urc.[FamilyName] AS Creator
		  ,o.[Creator] AS CreatorID
		  ,o.[CreatedDate] AS CreatedDate
		  ,urm.[GivenName] + ' ' + urm.[FamilyName] AS Modifier
		  ,o.[ModifiedDate] AS ModifiedDate
		  ,ISNULL(pm.[Name], '') AS PaymentMethod
		  ,ISNULL(sm.[Name], '') AS ShipmentMethod
		  ,od.[IsWeeklyShipment]  AS WeeklyShipment
		  --,od.[IsCourierDelivery]  AS CourierDelivery
		  --,od.[IsAdelaideWareHouse] AS AdelaideWareHouse
		  --,od.[IsFollowingAddress] AS FollowingAddress
		  ,ISNULL(bdca.[CompanyName], '') AS BillingAddress
		  ,ISNULL(ddca.[CompanyName] , '') AS ShippingAddress
		  ,ISNULL(ddp.[Name], '') AS DestinationPort
		  ,ISNULL(vl.[ResolutionProfile], 0 ) AS ResolutionProfile
		  ,o.[IsAcceptedTermsAndConditions] AS IsAcceptedTermsAndConditions
		  --,od.Surcharge
		  ,cl.FOCPenalty 
	  FROM [dbo].[OrderDetail] od	
		INNER JOIN [dbo].[PaymentMethod] pm
			ON od.[PaymentMethod] = pm.[ID]
		INNER JOIN [dbo].[ShipmentMode] sm
			ON od.[ShipmentMode] = sm.[ID]					
		INNER JOIN [dbo].[VisualLayout] vl
			ON od.[VisualLayout] = vl.[ID]	
		INNER JOIN [dbo].[OrderType] ot
			ON od.[OrderType] = ot.[ID]		
		LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
			ON od.[Status] = ods.[ID]

		INNER JOIN  [dbo].[Order] o	
			ON o.[ID] = od.[Order]			
		INNER JOIN [dbo].[OrderStatus] os
			ON o.[Status] = os.[ID]					
		INNER JOIN [dbo].[User] urc
			ON o.[Creator] = urc.[ID]
		INNER JOIN [dbo].[User] urm
			ON o.[Modifier] = urm.[ID]	
				
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] bdca
			ON o.[BillingAddress] = bdca.[ID]

		LEFT OUTER JOIN [dbo].[DistributorClientAddress] ddca
			ON o.[DespatchToAddress] = ddca.[ID]
		LEFT OUTER JOIN [dbo].[DestinationPort] ddp
			ON ddca.[Port] = ddp.[ID] 	
			
		INNER JOIN [dbo].[Pattern] p
			ON vl.[Pattern] = p.[ID]
		INNER JOIN [dbo].[FabricCode] f
			ON vl.FabricCode = f.[ID]
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
		   vl.[NamePrefix] LIKE '%' + @P_SearchText + '%' OR 
		   vl.[NameSuffix] LIKE '%' + @P_SearchText + '%' OR 
		   ods.[Name] LIKE '%' + @P_SearchText + '%' OR 
		   ot.[Name] LIKE '%' + @P_SearchText + '%' OR
		   c.[Name] LIKE '%' + @P_SearchText + '%' OR 
		   cl.[Name] LIKE '%' + @P_SearchText + '%'   
			) AND
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

