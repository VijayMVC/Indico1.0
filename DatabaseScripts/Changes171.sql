USE [Indico]
GO

DECLARE @PageId int
DECLARE @MenuItemId int

SET @PageId = (SELECT ID FROM [dbo].[Page] WHERE NAME = '/ViewDistributorClients.aspx')
SET @MenuItemId = (SELECT ID FROM [dbo].[MenuItem] WHERE Page = @PageId)

DELETE FROM [dbo].[MenuItemRole]
WHERE [MenuItem] > @MenuItemId

DELETE FROM [dbo].[MenuItem]
WHERE Page > @PageId

DELETE FROM [dbo].[Page]
WHERE ID > @PageId

GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--------------------------- indico CIF/FOB Prices pages --------------------------------------

DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

DECLARE @IndimanAdministrator int
DECLARE @IndimanCoordinator int
DECLARE @IndicoAdministrator int
DECLARE @IndicoCoordinator int

SET @IndimanAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @IndimanCoordinator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Coordinator')
SET @IndicoAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Administrator')
SET @IndicoCoordinator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')

-- CIF --

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/EditIndicoCIFPriceLevel.aspx','Indico CIF Price','Indico CIF Price')	 
SET @PageId = SCOPE_IDENTITY()

SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/EditIndicoPrice.aspx')
						AND Parent IS NULL)
						)

INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indico CIF Price', 'Indico CIF Price', 1, @MenuItemMenuId, 4, 1)
SET @MenuItemId = SCOPE_IDENTITY()	


INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoAdministrator)  

SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/EditIndimanPrice.aspx')
						AND Parent IS NULL)
						)
						
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indico CIF Price', 'Indico CIF Price', 1, @MenuItemMenuId, 11, 1)
SET @MenuItemId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanCoordinator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoCoordinator)	 	 

-- FOB--	 						

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/EditIndicoFOBPriceLevel.aspx','Indico FOB Price','Indico FOB Price')     
SET @PageId = SCOPE_IDENTITY()     

SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/EditIndicoPrice.aspx')
						AND Parent IS NULL)
						)

INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indico FOB Price', 'Indico FOB Price', 1, @MenuItemMenuId, 5, 1)
SET @MenuItemId = SCOPE_IDENTITY()	

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoAdministrator)	
	 
SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/EditIndimanPrice.aspx')
						AND Parent IS NULL)
						)
						
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indico FOB Price', 'Indico FOB Price', 1, @MenuItemMenuId, 12, 1)
SET @MenuItemId = SCOPE_IDENTITY()	
						
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanCoordinator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoCoordinator)
	 	 	 
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

-- Indiman CIF/ FOB pages

DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

DECLARE @IndimanAdministrator int

SET @IndimanAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

-- CIF --

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/ViewIndimanCIFPrices.aspx','Indiman CIF Price','Indiman CIF Price')	 
SET @PageId = SCOPE_IDENTITY()

SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/EditIndimanPrice.aspx')
						AND Parent IS NULL)
						)
						
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indiman CIF Price', 'Indiman CIF Price', 1, @MenuItemMenuId, 11, 1)
SET @MenuItemId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)

-- FOB--	 						

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/ViewIndimanFOBPrices.aspx','Indiman FOB Price','Indiman FOB Price')     
SET @PageId = SCOPE_IDENTITY()     

SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/EditIndimanPrice.aspx')
						AND Parent IS NULL)
						)
						
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Indiman FOB Price', 'Indiman FOB Price', 1, @MenuItemMenuId, 12, 1)
SET @MenuItemId = SCOPE_IDENTITY()	
						
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
	 	 
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  View [dbo].[IndicoCIFPriceView]    Script Date: 12/16/2015 14:12:16 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IndicoCIFPriceView]'))
DROP VIEW [dbo].[IndicoCIFPriceView]
GO

/****** Object:  View [dbo].[IndicoCIFPriceView]    Script Date: 12/16/2015 14:12:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[IndicoCIFPriceView]
AS
	SELECT	c.ID AS CostSheetId,
			ca.Name AS CoreCategory,
			i.Name AS ItemCategory,
			p.ID AS PatternId,
			p.Number AS PatternCode,
			p.NickName AS PatternNickName,
			f.ID AS FabricId,
			f.Code AS FabricCode,
			f.Name AS FabricName,
			ISNULL(c.FOBFactor,0.0) AS ConversionFactor,
			ISNULL(c.QuotedCIF, 0.0) AS IndimanPrice,
			ISNULL(c.QuotedFOBCost, 0.0 ) AS QuotedFOBPrice,
			ISNULL((SELECT TOP 1 (u.GivenName + ' ' + u.FamilyName) As LastModifier
				FROM IndimanCostSheetRemarks ir
				JOIN [User] u
				ON ir.Modifier = u.ID
				WHERE CostSheet = c.ID ORDER BY ir.ID DESC), 
				(SELECT GivenName + ' ' + u.FamilyName AS LastModifier FROM [User] WHERE ID = c.Modifier)
				) AS LastModifier,
			ISNULL((SELECT TOP 1 ModifiedDate FROM IndimanCostSheetRemarks WHERE CostSheet = c.ID  ORDER BY ID DESC), c.CreatedDate) AS ModifiedDate,
			ISNULL((SELECT TOP 1 Remarks FROM IndimanCostSheetRemarks WHERE CostSheet = c.ID  ORDER BY ID DESC),'') AS Remarks						
	FROM CostSheet c
		JOIN Pattern p
			ON c.Pattern = p.ID
		JOIN FabricCode f
			ON c.Fabric = f.ID
		JOIN [User] u
			ON c.Modifier = u.ID	
		LEFT OUTER JOIN Category ca
			ON ca.ID = p.CoreCategory
		LEFT OUTER JOIN Item i
			ON i.ID = p.Item
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


/****** Object:  StoredProcedure [dbo].[SPC_GetOrderDetailIndicoPrice]    Script Date: 12/22/2015 14:17:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetOrderDetailIndicoPrice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetOrderDetailIndicoPrice]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderDetailIndicoPrice]    Script Date: 12/22/2015 13:32:48 ******/
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
		  --,p.[Number] AS Pattern
		  ,ISNULL(p.Number, (SELECT Number FROM Pattern WHERE ID = od.[Pattern])) AS Pattern 
		  --,od.[Pattern] AS PatternID
		  ,ISNULL(p.ID, od.[Pattern]) AS PatternID
		  --,od.[FabricCode] AS FabricID
		  ,ISNULL(fc.ID, od.FabricCode) AS FabricID
		  ,o.[Distributor] AS Distributor
		  --,fc.[Name] AS Fabric
		  ,ISNULL(fc.[Name], (SELECT Name FROM FabricCode WHERE ID = od.FabricCode)) AS Fabric 
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
		--LEFT OUTER JOIN [dbo].[Pattern] p
		--	ON od.[Pattern] = p.[ID]
		--LEFT OUTER JOIN [dbo].[FabricCode] fc
		--	ON od.[FabricCode] = fc.[ID]
		LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
			ON  od.[Status] = ods.[ID]		
		LEFT OUTER JOIN [dbo].[VisualLayout] vl 
			ON od.[VisualLayout] = vl.[ID]	
		LEFT OUTER JOIN [dbo].[Pattern] p
			ON vl.[Pattern] = p.[ID]
		LEFT OUTER JOIN [dbo].[FabricCode] fc
			ON vl.[FabricCode] = fc.[ID]			
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


