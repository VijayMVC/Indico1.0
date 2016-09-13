USE [Indico]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 6/10/2016 2:08:23 PM ******/
DROP PROCEDURE [dbo].[SPC_ViewOrderDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 6/10/2016 2:08:23 PM ******/
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
		  ,o.[IsWeeklyShipment]  AS WeeklyShiment
		  ,o.[IsCourierDelivery]  AS CourierDelivery
		  ,o.[IsAdelaideWareHouse] AS AdelaideWareHouse
		  ,o.[IsFollowingAddress] AS FollowingAddress
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

/****** Object:  StoredProcedure [dbo].[SPC_ViewVisualLayoutDetails]    Script Date: 6/10/2016 5:54:10 PM ******/
DROP PROCEDURE [dbo].[SPC_ViewVisualLayoutDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewVisualLayoutDetails]    Script Date: 6/10/2016 5:54:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_ViewVisualLayoutDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',
	@P_Coordinator AS int = 0,
	@P_Distributor AS int = 0,
	@P_Client AS int = 0	
)
AS
BEGIN	
	SET NOCOUNT ON	
		SELECT 			
			   v.[ID] AS VisualLayout,
			   ISNULL(v.[NamePrefix] + '' + ISNULL(CAST(v.[NameSuffix] AS NVARCHAR(64)), ''), '') AS Name,
			   ISNULL(v.[Description], '') AS 'Description',
			   ISNULL(p.[Number] + ' - '+ p.[NickName], '') AS Pattern,
			   ISNULL(f.[Name], '') AS Fabric,
			   ISNULL(j.[Name], '') AS JobName,
			   ISNULL(c.[Name], '') AS Client,
			   ISNULL(d.[Name], '') AS Distributor,
			   ISNULL(u.[GivenName] + ' '+ u.[FamilyName], '') AS Coordinator,
			   ISNULL(v.[NNPFilePath], '') AS NNPFilePath,
			   ISNULL(v.[CreatedDate], GETDATE()) AS CreatedDate,
			   ISNULL(v.[IsCommonProduct], 0) AS IsCommonProduct,
			   ISNULL(v.[ResolutionProfile], 0) AS ResolutionProfile,
			   ISNULL(v.[Printer], 0) AS Printer,
			   ss.[Name] AS SizeSet,
			 	CASE WHEN	(EXISTS(SELECT TOP 1 ID FROM [dbo].[VisualLayoutAccessory] WHERE [VisualLayout] = v.[ID])) OR
							(EXISTS(SELECT TOP 1 ID FROM [dbo].[Image] WHERE [VisualLayout] = v.[ID])) OR
							(EXISTS(SELECT TOP 1 ID FROM [dbo].[OrderDetail] WHERE [VisualLayout] = v.[ID])) 
				THEN 0	
				ELSE 1 
				END
				AS CanDelete,
			  ISNULL(vli.[FileName], '') AS [FileName],
			  ISNULL(vli.[Extension], '') AS Extension
		FROM [dbo].[VisualLayout] v
			INNER JOIN [dbo].[Pattern] p
				ON v.[Pattern] = p.[ID]
			INNER JOIN [dbo].[FabricCode] f
				ON v.[FabricCode] = f.[ID]
			INNER JOIN [dbo].[JobName] j
				ON v.[Client] = j.[ID]
			INNER JOIN [dbo].[Client] c
				ON j.[Client] = c.[ID]	
			INNER JOIN [dbo].[Company] d
				ON c.[Distributor] = d.[ID]
			LEFT OUTER JOIN [dbo].[User] u
				ON d.[Coordinator] = u.[ID]
			INNER JOIN [dbo].[SizeSet] ss
				ON p.[SizeSet] = ss.[ID]
			LEFT OUTER JOIN  [dbo].[Image] vli
				ON v.ID = vli.VisualLayout AND vli.IsHero = 1 
		WHERE	(@P_Coordinator = 0 OR u.[ID] = @P_Coordinator)
				AND		(@P_Distributor = 0 OR  d.ID = @P_Distributor )
				AND		(@P_SearchText = '' OR
					   v.[NamePrefix]  LIKE '%' + @P_SearchText + '%' OR
					   v.[NameSuffix]  LIKE '%' + @P_SearchText + '%' OR
					   v.[Description] LIKE '%' + @P_SearchText + '%' OR
					   p.[Number] LIKE '%' + @P_SearchText + '%' OR
					   c.[Name] LIKE '%' + @P_SearchText + '%' OR
					   d.[Name] LIKE '%' + @P_SearchText + '%' OR
					   u.[GivenName] LIKE '%' + @P_SearchText + '%' OR
					   u.[FamilyName] LIKE '%' + @P_SearchText + '%') 
END

GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewPatternDetails]    Script Date: 6/11/2016 12:14:24 PM ******/
DROP PROCEDURE [dbo].[SPC_ViewPatternDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewPatternDetails]    Script Date: 6/11/2016 12:14:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_ViewPatternDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',	
	@P_Blackchrome AS int =  2,
	@P_GarmentStatus AS NVARCHAR(255) = '',
	@P_PatternStatus AS int = 2
)
AS
BEGIN
	SET NOCOUNT ON	
		SELECT  
				p.[ID] AS Pattern,
				i.[Name] AS Item,
				ISNULL(si.[Name], '') AS SubItem,
				g.[Name] AS Gender,
				ISNULL(ag.[Name], '') AS AgeGroup,
				ss.[Name] AS SizeSet,
				c.[Name] AS CoreCategory,
				pt.[Name] AS PrinterType,
				p.[Number] AS Number,
				ISNULL(p.[OriginRef], '') AS OriginRef,
				p.[NickName] AS NickName,
				ISNULL(p.[Keywords], '') AS Keywords,
				ISNULL(p.[CorePattern], '') AS CorePattern,
				ISNULL(p.[FactoryDescription], '') AS FactoryDescription,
				ISNULL(p.[Consumption], '') AS Consumption,
				p.[ConvertionFactor] AS ConvertionFactor,
				ISNULL(p.[SpecialAttributes], '') AS SpecialAttributes,
				ISNULL(p.[PatternNotes], '') AS PatternNotes,
				ISNULL(p.[PriceRemarks], '') AS PriceRemarks,
				p.[IsActive] AS IsActive,
				p.[Creator] AS Creator,
				p.[CreatedDate] AS CreatedDate,
				p.[Modifier] AS Modifier,
				p.[ModifiedDate] AS ModifiedDate,
				ISNULL(p.[Remarks], '') AS Remarks,
				p.[IsTemplate] AS IsTemplate,
				ISNULL(p.[Parent], 0) AS Parent,
				p.[GarmentSpecStatus] AS GarmentSpecStatus,
				p.[IsActiveWS] AS IsActiveWS,
				p.[IsCoreRange] AS IsCoreRange,
				ISNULL(p.[HTSCode], '') AS HTSCode,
				ISNULL(p.[SMV], 0.00) AS SMV,
				ISNULL(p.[Description], '') AS MarketingDescription,
				CASE WHEN	(EXISTS(SELECT TOP 1 ID FROM [dbo].[CostSheet] WHERE Pattern = p.[ID])) OR
							(EXISTS(SELECT TOP 1 ID FROM [dbo].[VisualLayout] WHERE Pattern = p.[ID])) OR
							(EXISTS(SELECT TOP 1 ID FROM [dbo].[SizeChart]  WHERE Pattern = p.[ID])) 
				THEN 0	
				ELSE 1 
				END
				AS CanDelete
			    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (pat.[Parent]) FROM [dbo].[Pattern] pat WHERE pat.[Parent] = p.[ID])) THEN 1 ELSE 0 END)) AS PatternParent,
			    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (r.[Pattern]) FROM [dbo].[Reservation] r WHERE r.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS Reservation,
			    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (pr.[Pattern]) FROM [dbo].[Price] pr WHERE pr.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS Price,
			    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (pti.[Pattern]) FROM [dbo].[PatternTemplateImage] pti WHERE pti.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS PatternTemplateImage,
			    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (prod.[Pattern]) FROM [dbo].[Product] prod WHERE prod.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS Product,
			    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (od.[Pattern]) FROM [dbo].[OrderDetail] od WHERE od.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS OrderDetail,
			    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (v.[Pattern]) FROM [dbo].[VisualLayout] v WHERE v.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS VisualLayout
		 FROM [dbo].[Pattern] p
			INNER JOIN [dbo].[Item] i
				ON p.[Item]= i.[ID]
			INNER JOIN [dbo].[Item] si
				ON p.[SubItem] = si.[ID]
			INNER JOIN [dbo].[Gender] g
				ON p.[Gender] = g.[ID]
			INNER JOIN [dbo].[AgeGroup] ag
				ON p.[AgeGroup] = ag.[ID]
			INNER JOIN [dbo].[SizeSet] ss
				ON p.[SizeSet] = ss.[ID]
			INNER JOIN [dbo].[Category] c
				ON p.[CoreCategory] = c.[ID]
			INNER JOIN [dbo].[PrinterType] pt
				ON p.[PrinterType] = pt.[ID]
		WHERE (@P_SearchText = '' OR
				i.[Name] LIKE '%' + @P_SearchText + '%' OR
				si.[Name] LIKE '%' + @P_SearchText + '%' OR
				g.[Name] LIKE '%' + @P_SearchText + '%' OR
				ag.[Name] LIKE '%' + @P_SearchText + '%' OR
				ss.[Name] LIKE '%' + @P_SearchText + '%' OR
				c.[Name] LIKE '%' + @P_SearchText + '%' OR
				pt.[Name] LIKE '%' + @P_SearchText + '%' OR
				p.[Number] LIKE '%' + @P_SearchText + '%' OR
				p.[NickName] LIKE '%' + @P_SearchText + '%' OR 
				p.[GarmentSpecStatus] LIKE '%' + @P_SearchText + '%' OR
				p.[CorePattern] LIKE '%' + (@P_SearchText) + '%' )
				AND( @P_Blackchrome = 2  OR p.[IsActiveWS] = CONVERT(bit,@P_Blackchrome)) 
				AND (@P_GarmentStatus = '' OR p.[GarmentSpecStatus] LIKE '%' + @P_GarmentStatus + '%') 
				AND (@P_PatternStatus = 2 OR p.[IsActive] = CONVERT(bit, @P_PatternStatus))					
END

GO



--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

