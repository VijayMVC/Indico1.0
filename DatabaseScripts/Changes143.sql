USE [Indico]
GO

------------------------  Adding Client to [DistributorClientAddressDetailsView] ------------------------ 

/****** Object:  View [dbo].[DistributorClientAddressDetailsView]    Script Date: 07/10/2015 11:07:41 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DistributorClientAddressDetailsView]'))
DROP VIEW [dbo].[DistributorClientAddressDetailsView]
GO

/****** Object:  View [dbo].[DistributorClientAddressDetailsView]    Script Date: 07/10/2015 11:07:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DistributorClientAddressDetailsView]
AS

	SELECT dca.[ID]
		  ,dca.[Address]
		  ,dca.[Suburb]
		  ,dca.[PostCode]
		  ,c.[ID] AS CountryID
		  ,c.[ShortName] AS Country
		  ,dca.[ContactName]
		  ,dca.[EmailAddress]
		  ,dca.[ContactPhone]
		  ,dca.[CompanyName]
		  ,dca.[AddressType]
		  ,ISNULL(dca.[State], '') AS [State]
		  ,ISNULL(dp.[Name], '') AS Port
		  ,ISNULL(dp.[ID], 0) AS PortID
		  ,ISNULL(dca.[Client], 0) AS ClientID
		  ,ISNULL(cl.[Name], '') AS Client		  
	  FROM [Indico].[dbo].[DistributorClientAddress] dca
		JOIN [dbo].[Country] c
			ON dca.[Country] = c.[ID]
		LEFT OUTER JOIN [dbo].[DestinationPort] dp
			ON dca.[Port] = dp.[ID]
		LEFT OUTER JOIN [dbo].[Client] cl
			ON dca.[Client] = cl.[ID]
		
GO

------------------------  Changing Addresses on [SPC_ViewOrderDetails] ------------------------ 

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 07/10/2015 11:21:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewOrderDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewOrderDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 07/10/2015 11:21:42 ******/
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
		  ,ot.[Name] AS OrderType
		  --,ISNULL(vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),''),'') AS VisualLayout		  
		  ,(SELECT CASE 
			 WHEN od.VisualLayout IS NOT NULL THEN ISNULL(vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),''),'') 			 
			 ELSE ISNULL(aw.ReferenceNo ,'')
			END)
		  AS VisualLayout		  
		  ,ISNULL(od.[VisualLayout],0) AS VisualLayoutID
		  ,od.[Pattern] AS PatternID
		  ,p.[Number] + ' - ' + p.[NickName] AS Pattern
		  ,od.[FabricCode] AS FabricID
		  ,fc.[Code] + ' - ' + fc.[Name] AS Fabric
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
		  ,ISNULL(ddca.[CompanyName] + ' ' + ddca.[Address] + ' ' + ddca.[Suburb] + ' ' + ISNULL(ddca.[State], '') + ' ' + dco.[ShortName] + ' ' + ddca.[PostCode], '') 
		  AS ShippingAddress
		  ,ISNULL(ddp.[Name], '') AS DestinationPort
		  ,ISNULL(vl.[ResolutionProfile], 0 ) AS ResolutionProfile
		  ,o.[IsAcceptedTermsAndConditions] AS IsAcceptedTermsAndConditions
	  FROM [dbo].[Order] o				
		LEFT OUTER JOIN [dbo].[OrderStatus] os
			ON o.[Status] = os.[ID]
		LEFT OUTER JOIN [dbo].[Company] c
			ON o.[Distributor] = c.[ID]
		LEFT OUTER JOIN [dbo].[User] u
			ON c.[Coordinator] = u.[ID]		
		LEFT OUTER JOIN [dbo].[PaymentMethod] pm
			ON o.[PaymentMethod] = pm.[ID]
		LEFT OUTER JOIN [dbo].[ShipmentMode] sm
			ON o.[ShipmentMode] = sm.[ID]					
		LEFT OUTER JOIN [dbo].[Client] cl
			ON o.[Client] = cl.[ID]				
		LEFT OUTER JOIN [dbo].[User] urc
			ON o.[Creator] = urc.[ID]
		LEFT OUTER JOIN [dbo].[User] urm
			ON o.[Modifier] = urm.[ID]
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] ddca
			ON o.[DespatchToAddress] = ddca.[ID]
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] bdca
			ON o.[BillingAddress] = bdca.[ID]
		LEFT OUTER JOIN [dbo].[Country] dco
			ON ddca.[Country] = dco.[ID]
		LEFT OUTER JOIN [dbo].[Country] bco
			ON bdca.[Country] = bco.[ID]
		LEFT OUTER JOIN [dbo].[DestinationPort] ddp
			ON ddca.[Port] = ddp.[ID] 
		LEFT OUTER JOIN [dbo].[DestinationPort] bdp
			ON bdca.[Port] = bdp.[ID] 			
		INNER JOIN [dbo].[OrderDetail] od				
			ON o.[ID] = od.[Order]				
		LEFT OUTER JOIN [dbo].[VisualLayout] vl
			ON od.[VisualLayout] = vl.[ID]
		LEFT OUTER JOIN [dbo].[ArtWork] aw
			ON od.[ArtWork] = aw.[ID]
		LEFT OUTER JOIN [dbo].[Pattern] p 
			ON od.[Pattern] = p.[ID]
		LEFT OUTER JOIN [dbo].[FabricCode] fc
			ON od.[FabricCode] = fc.[ID]
		LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
			ON od.[Status] = ods.[ID]
		LEFT OUTER JOIN [dbo].[OrderType] ot
			ON od.[OrderType] = ot.[ID]
	WHERE (@P_SearchText = '' OR
			o.[ID] = @orderid OR
		   o.[OldPONo] LIKE '%' + @P_SearchText + '%' OR
		   u.[GivenName]  LIKE '%' + @P_SearchText + '%' OR
		   u.[FamilyName] LIKE '%' + @P_SearchText + '%' OR
		   p.[Number] LIKE '%' + @P_SearchText + '%' OR 
		   p.[NickName] LIKE '%' + @P_SearchText + '%' OR
		   vl.[NamePrefix] LIKE '%' + @P_SearchText + '%' OR 
		   vl.[NameSuffix] LIKE '%' + @P_SearchText + '%' OR 
		   ods.[Name] LIKE '%' + @P_SearchText + '%' OR 
		   ot.[Name] LIKE '%' + @P_SearchText + '%' OR
		   c.[Name] LIKE '%' + @P_SearchText + '%' OR 
		   cl.[Name] LIKE '%' + @P_SearchText + '%' OR					
		   fc.[Code] LIKE '%' + @P_SearchText + '%' OR 
		   fc.[Name] LIKE '%' + @P_SearchText + '%'  
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

------------------------  Changing Addresses on [SPC_ViewOrderDetails] ------------------------ 

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 07/10/2015 11:26:52 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetailsView]'))
DROP VIEW [dbo].[OrderDetailsView]
GO

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 07/10/2015 11:26:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OrderDetailsView]
AS
			SELECT
				  0 AS OrderDetail,
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
				  CONVERT(bit,0) AS IsAcceptedTermsAndConditions
GO

------------------------  Set Order detail Label on [SPC_GetOrderDetailIndicoPrice] ------------------------ 

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderDetailIndicoPrice]    Script Date: 07/10/2015 15:57:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetOrderDetailIndicoPrice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetOrderDetailIndicoPrice]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderDetailIndicoPrice]    Script Date: 07/10/2015 15:57:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SPC_GetOrderDetailIndicoPrice]
(
	@P_Order AS int,
	@P_PriceTerm AS int	
)
AS 

BEGIN

DECLARE @j int
SET @j = 0
DECLARE @TempOrderDetail TABLE 
(
	ID int NOT NULL,
	[OrderDetail] [int] NOT NULL,
	[OrderType] [nvarchar] (255) NOT NULL,
	[VisualLayout] [nvarchar] (255),
	[VisualLayoutID] [int]  NULL,
	[ArtWorkID] [int]  NULL,
	[Pattern] [nvarchar] (255) NOT NULL,
	[PatternID] [int] NOT NULL,
	[FabricID] [int] NOT NULL,
	[Distributor] [int] NOT NULL,
	[Fabric] [nvarchar] (255) NOT NULL,
	[VisualLayoutNotes] [nvarchar] (255) NULL,
	[Order] [int] NOT NULL,
	[Label] [int] NULL,
	[Status] [nvarchar] (255) NULL,
	[StatusID] [int] NULL,
	[ShipmentDate] [datetime2](7) NOT NULL,
	[SheduledDate] [datetime2](7) NOT NULL,	
	[IsRepeat] [bit] NOT NULL,
	[RequestedDate] [datetime2](7) NOT NULL,
	[EditedPrice] [decimal](8, 2) NULL,
	[EditedPriceRemarks] [nvarchar](255) NULL,
	[Quantity] [int] NULL,
	[EditedIndicoPrice] [decimal](8, 2) NULL,	
	[TotalIndicoPrice] [decimal](8, 2) NULL	
)

	INSERT INTO @TempOrderDetail (ID, [OrderDetail], [OrderType],  [VisualLayout], [VisualLayoutID],[ArtWorkID], [Pattern], [PatternID], [FabricID], [Distributor],  [Fabric], [VisualLayoutNotes] , [Order], [Label], [Status], 
							  [StatusID], [ShipmentDate], [SheduledDate], [IsRepeat], [RequestedDate], [EditedPrice], [EditedPriceRemarks], [Quantity], [EditedIndicoPrice], [TotalIndicoPrice])
	SELECT CONVERT(int, ROW_NUMBER() OVER (ORDER BY od.ID)) AS ID
		  ,od.[ID] AS OrderDetail
		  ,ot.[Name] AS OrderType
		  ,ISNULL(vl.[NamePrefix] + ''+ ISNULL(CAST(vl.[NameSuffix] AS NVARCHAR(64)), ''),'') AS VisualLayout
		  ,ISNULL(od.[VisualLayout],0) AS VisualLayoutID
		  ,ISNULL(od.[ArtWork],0) AS ArtWorkID
		  ,p.[Number] AS Pattern
		  ,od.[Pattern] AS PatternID
		  ,od.[FabricCode] AS FabricID
		  ,o.[Distributor] AS Distributor
		  ,fc.[Name] AS Fabric
		  ,od.[VisualLayoutNotes] AS VisualLayoutNotes
		  ,od.[Order] AS 'Order'
		  ,ISNULL(od.[Label],0) AS Label
		  ,ISNULL(ods.[Name], 'New') AS 'Status'
		  ,ISNULL(od.[Status],0) AS StatusID 
		  ,od.[ShipmentDate] AS ShipmentDate
		  ,od.[SheduledDate] AS SheduledDate
		  ,od.[IsRepeat] AS IsRepeat
		  ,od.[RequestedDate] AS RequestedDate
		  ,ISNULL(od.[EditedPrice], 0.00) AS DistributoEditedPrice
		  ,ISNULL(od.[EditedPriceRemarks], '') AS DistributorEditedPriceComments
		  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]), 0) AS Quantity
		  ,NULL
		  ,NULL
	FROM [dbo].[Order] o
		LEFT OUTER JOIN [dbo].[OrderDetail] od
		ON o.[ID] = od.[Order]
		LEFT OUTER JOIN [dbo].[OrderType] ot 
			ON od.[OrderType] = ot.[ID]		
		LEFT OUTER JOIN [dbo].[Pattern] p
			ON od.[Pattern] = p.[ID]
		LEFT OUTER JOIN [dbo].[FabricCode] fc
			ON od.[FabricCode] = fc.[ID]
		LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
			ON  od.[Status] = ods.[ID]		
		LEFT OUTER JOIN [dbo].[VisualLayout] vl 
			ON od.[VisualLayout] = vl.[ID]		
	WHERE od.[Order] = @P_Order	
	
		
		DECLARE @i int
		DECLARE @LevelID AS int
		DECLARE @Quantity AS decimal(8,2)
		DECLARE @Pattern AS int		
		DECLARE @Fabric AS int
		DECLARE @Distributor AS int
		DECLARE @Price AS decimal(8,2)
		DECLARE @OrderDetail AS int
		DECLARE @TotalPrice AS decimal(8,2)
		DECLARE @HasDistributor AS int
		
		SET @i = 1
		
		DECLARE @Count int
		SELECT @Count = COUNT(ID) FROM @TempOrderDetail 
		
		WHILE (@i <= @Count)
		BEGIN
		
		SET @Quantity = (SELECT CAST(tod.[Quantity] AS INT) FROM @TempOrderDetail tod WHERE tod.[ID] = @i)
		SET @Pattern = (SELECT tod.[PatternID] FROM @TempOrderDetail tod WHERE tod.[ID] = @i)
		SET @Fabric = (SELECT tod.[FabricID] FROM @TempOrderDetail tod WHERE tod.[ID] = @i)
		SET @Distributor = (SELECT tod.[Distributor] FROM @TempOrderDetail tod WHERE tod.[ID] = @i)
		SET @OrderDetail = (SELECT tod.[OrderDetail] FROM @TempOrderDetail tod WHERE tod.[ID] = @i)
		SET @HasDistributor = (SELECT COUNT(*) FROM [dbo].[DistributorPriceLevelCost] WHERE [Distributor] = @Distributor)
						
				IF (@Quantity < 6)
				 BEGIN  
					SET @LevelID =  1					
				 END
				ELSE IF (@Quantity > 5 AND @Quantity < 10)
				 BEGIN
					 SET @LevelID = 2 					
				 END
				ELSE IF (@Quantity > 9 AND @Quantity < 20)
				 BEGIN 
					SET @LevelID = 3 					
				 END
				ELSE IF (@Quantity > 19 AND @Quantity < 50)
				 BEGIN
				 	SET @LevelID = 4				 
				 END
					ELSE IF (@Quantity > 49 AND @Quantity < 100)
				 BEGIN
					SET @LevelID = 5
				 END
				ELSE IF (@Quantity > 99 AND @Quantity < 250)
				 BEGIN	
					SET @LevelID = 6
				 END
				ELSE IF (@Quantity > 249 AND @Quantity < 500)
				 BEGIN
					 SET @LevelID = 7
				 END
				ELSE IF (@Quantity > 499)
				 BEGIN	
					SET @LevelID = 8
				 END	 

			SET @i = @i + 1	
			
			
			SET	@Price = (SELECT ISNULL(dplc.[IndicoCost], NULL)
																			  
							FROM [Indico].[dbo].[DistributorPriceLevelCost] dplc
								JOIN [dbo].[PriceLevelCost] plc  
									ON dplc.[PriceLevelCost] = plc.[ID]
								JOIN [dbo].[Price] pr 
									ON plc.[Price] = pr.[ID]
								JOIN [dbo].[PriceLevel] pl
									ON plc.[PriceLevel] = pl.[ID]							
							WHERE pr.[Pattern] = @Pattern AND 
							  pr.[FabricCode] = @Fabric AND 
							  ((@HasDistributor =0 AND dplc.[Distributor] IS NULL) OR dplc.[Distributor] = @Distributor ) AND 
							  dplc.[PriceTerm] = @P_PriceTerm AND
							  pl.[ID] = @LevelID)
							  
			
			IF (@Price IS NUll)
				BEGIN
					
					IF (@P_PriceTerm = 1)
						BEGIN													
						
							 SET @Price = (SELECT ISNULL(((ISNULL(plc.[IndimanCost],0.00) * 100) / (100 - (SELECT dpm.[Markup] 
																							  FROM [dbo].[DistributorPriceMarkup] dpm 
																							  WHERE  ((@HasDistributor = 0 AND dpm.[Distributor] IS NULL) OR dpm.[Distributor] = @Distributor ) 
																							  AND dpm.[PriceLevel] = @LevelID))), 0.00)
											FROM  [dbo].[PriceLevelCost] plc  
													JOIN [dbo].[Price] pr 
															ON plc.[Price] = pr.[ID]
													JOIN [dbo].[PriceLevel] pl
															ON plc.[PriceLevel] = pl.[ID]							
											WHERE pr.[Pattern] = @Pattern AND 
												  pr.[FabricCode] = @Fabric AND 						  
												  pl.[ID] = @LevelID)
						END
					ELSE 
						BEGIN
							SET @Price = (SELECT ISNULL(((ISNULL((plc.[IndimanCost] - p.[ConvertionFactor]) ,0.00)) / (1 - ((SELECT dpm.[Markup] 
																														    FROM [dbo].[DistributorPriceMarkup] dpm 
																															WHERE  ((@HasDistributor = 0 AND dpm.[Distributor] IS NULL) OR dpm.[Distributor] = @Distributor) 
																															AND dpm.[PriceLevel] = @LevelID)/100))), 0.00)
											FROM  [dbo].[PriceLevelCost] plc  
													JOIN [dbo].[Price] pr 
															ON plc.[Price] = pr.[ID]
													JOIN [dbo].[PriceLevel] pl
															ON plc.[PriceLevel] = pl.[ID]
													JOIN [dbo].[Pattern] p
															ON pr.[Pattern] = p.[ID]							
											WHERE pr.[Pattern] = @Pattern AND 
												  pr.[FabricCode] = @Fabric AND 						  
												  pl.[ID] = @LevelID)
						END							  
								 
				END							  
			
							  
			SET @TotalPrice = (@Price *	@Quantity)			
												 
			UPDATE @TempOrderDetail SET [EditedIndicoPrice] = ISNULL(@Price, 0.00),
										[TotalIndicoPrice] = ISNULL(@TotalPrice, 0.00) WHERE [OrderDetail] = @OrderDetail
				
		END		
	
	SELECT * FROM @TempOrderDetail
END 

GO

------------- Updating menu item shipment addresses ----------------------

UPDATE [dbo].[MenuItem] 
SET [Name] = 'Addresses'
WHERE [Name]='Shipment Addresses'

UPDATE [dbo].[Page] 
SET [Title] = 'Addresses', [Heading] = 'Addresses'
WHERE [Name]='/ViewShipmentAddresses.aspx'

GO


