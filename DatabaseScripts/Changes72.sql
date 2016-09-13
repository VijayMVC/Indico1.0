USE [Indico] 
GO

/****** Object:  View [dbo].[PackingListView]    Script Date: 10/23/2013 11:44:07 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[PackingListView]'))
DROP VIEW [dbo].[PackingListView]
GO

/****** Object:  View [dbo].[PackingListView]    Script Date: 10/23/2013 09:35:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PackingListView]
AS
 SELECT	
		0 AS PackingList
	   ,0 AS WeeklyProductionCapacity
	   ,0 AS CartonNo
	   ,0 AS OrderNumber
	   ,0 AS OrderDetail
	   ,'' AS VLName
	   ,'' AS Pattern
	   ,'' AS Distributor
	   ,'' AS Client
	   ,GETDATE() AS WeekendDate
	   ,0 AS PackingTotal
	   ,0 AS ScannedTotal
GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**
/****** Object:  StoredProcedure [dbo].[SPC_GetPackingListDetails]    Script Date: 10/29/2013 10:37:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetPackingListDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetPackingListDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetPackingListDetails]    Script Date: 10/29/2013 10:37:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_GetPackingListDetails] (	
@P_WeekEndDate datetime2(7)
)	
AS 
BEGIN	
	SELECT pl.ID AS PackingList,
		   wpc.ID AS WeeklyProductionCapacity,
		   pl.CartonNo,
		   o.ID AS OrderNumber,		
		   od.[ID] AS OrderDetail,
		   vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),'') AS VLName,
		   p.[Number] + ' ' + p.[NickName] AS Pattern,
		   d.Name AS Distributor,
		   c.Name AS Client,
		   wpc.WeekendDate AS WeekendDate,
		   ISNULL((SELECT SUM(QTY) FROM [dbo].[PackingListSizeQty] WHERE PackingList = pl.ID),0) AS PackingTotal,
		   ISNULL((SELECT SUM([Count]) FROM [dbo].[PackingListCartonItem] WHERE PackingList = pl.ID),0) AS ScannedTotal				
	FROM  dbo.[PackingList] pl
		INNER JOIN dbo.[OrderDetail] od
			ON pl.OrderDetail = od.ID
		INNER JOIN dbo.[Order] o
			ON od.[Order] = o.ID
		INNER JOIN dbo.[VisualLayout] vl
			ON od.[VisualLayout] = vl.ID	
		INNER JOIN dbo.Pattern p
			ON od.Pattern = p.ID
		INNER JOIN dbo.Client c
			ON o.Client = c.ID
		INNER JOIN dbo.Company d
			ON o.Distributor = d.ID	
		INNER JOIN dbo.WeeklyProductionCapacity wpc
			ON pl.WeeklyProductionCapacity = wpc.ID	
	WHERE od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate
	ORDER BY pl.[CartonNo] ASC
END


GO
--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

/****** Object:  StoredProcedure [dbo].[SPC_CreatePackingList]    Script Date: 10/28/2013 15:53:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_CreatePackingList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_CreatePackingList]
GO

/****** Object:  StoredProcedure [dbo].[SPC_CreatePackingList]    Script Date: 10/28/2013 15:53:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_CreatePackingList]
(
	@P_WeekEndDate Datetime,
	@P_Creator INT
)
AS BEGIN
	
	DECLARE @RetVal int
	DECLARE @OrderDetailID INT
	DECLARE @PackingListID INT
	DECLARE @WeeklyProductionCapacityID INT
	DECLARE @CartonNo INT	
	DECLARE @TempOrderDetail TABLE 
	(
		ID INT NOT NULL
	)
	
	DECLARE @TempOrderDetailQty TABLE 
	(
		ID INT NOT NULL,
		Size INT NOT NULL,
		Qty INT NOT NULL
	)
	
	BEGIN TRY
		
		SET @CartonNo = 0
	
		INSERT INTO @TempOrderDetail (ID)
		SELECT ID FROM [dbo].[OrderDetail] od
		WHERE od.SheduledDate > DATEADD(DD,-7,@P_WeekendDate)
		AND od.SheduledDate <= @P_WeekendDate
	
		WHILE EXISTS(SELECT * FROM @TempOrderDetail )
			BEGIN	
				
				SET @CartonNo = @CartonNo + 1
				SET @OrderDetailID = (SELECT TOP 1 ID FROM @TempOrderDetail)				
				
				DELETE FROM @TempOrderDetailQty
				
				INSERT INTO @TempOrderDetailQty (ID, Size, Qty)
				SELECT ID, Size, Qty FROM [dbo].OrderDetailQty 
				WHERE OrderDetail = @OrderDetailID AND Qty > 0
				
				IF ((SELECT COUNT(ID) FROM @TempOrderDetailQty)> 0)
					BEGIN					
						SET @WeeklyProductionCapacityID = (SELECT ID FROM [dbo].WeeklyProductionCapacity WHERE WeekendDate = @P_WeekendDate)
					
						INSERT INTO [dbo].[PackingList]
								   ([CartonNo]
								   ,[WeeklyProductionCapacity]
								   ,[OrderDetail]
								   ,[PackingQty]
								   ,[Carton]
								   ,[Remarks]
								   ,[Creator]
								   ,[CreatedDate]
								   ,[Modifier]
								   ,[ModifiedDate])
						VALUES
						   (@CartonNo
						   ,@WeeklyProductionCapacityID
						   ,@OrderDetailID
						   ,0
						   ,1
						   ,''
						   ,@P_Creator
						   , (SELECT (GETDATE()))
						   ,@P_Creator
						   , (SELECT (GETDATE())))						   					
						
						SET @PackingListID = SCOPE_IDENTITY()
						
						WHILE EXISTS(SELECT * FROM @TempOrderDetailQty )
							BEGIN	
								
								INSERT INTO [Indico].[dbo].[PackingListSizeQty]
									   ([PackingList]
									   ,[Size]
									   ,[Qty])
								 VALUES
									    (@PackingListID
									   ,(SELECT TOP 1 Size FROM @TempOrderDetailQty)
									   ,(SELECT TOP 1 Qty FROM @TempOrderDetailQty))
																							
								DELETE TOP(1) FROM @TempOrderDetailQty				
							END							
				END				
				
			DELETE TOP(1) FROM @TempOrderDetail
		END	
			
		SET @RetVal = 1	
	END TRY
	BEGIN CATCH
		SET @RetVal = 0
	END CATCH
	
	SELECT @RetVal AS RetVal
END


GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyOrderDetailQtys]    Script Date: 10/23/2013 12:41:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyOrderDetailQtys]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyOrderDetailQtys]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyOrderDetailQtys]    Script Date: 10/23/2013 12:41:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/********* CREATE STORED PROCEDURE [SPC_GetWeeklyOrderDetailQtys]*************/
CREATE PROCEDURE [dbo].[SPC_GetWeeklyOrderDetailQtys] (	
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN
		SELECT	 od.[ID] AS OrderDetail
				,odq.[Size] AS SizeID
				,odq.[Qty] AS Quantity				 
			  FROM [Indico].[dbo].[OrderDetail] od				
				INNER JOIN [dbo].[OrderDetailQty] odq
					ON odq.[OrderDetail] = od.[ID]				
			WHERE (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate) AND
				   odq.[Qty] > 0
	
END

GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

/****** Object:  View [dbo].[ReturnWeeklyOrderDetailQtysView]    Script Date: 10/30/2013 10:42:56 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnWeeklyOrderDetailQtysView]'))
DROP VIEW [dbo].[ReturnWeeklyOrderDetailQtysView]
GO

/****** Object:  View [dbo].[ReturnWeeklyOrderDetailQtysView]    Script Date: 10/30/2013 10:42:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnWeeklyOrderDetailQtysView]
AS
 SELECT	
		0 AS OrderDetail
	   ,0 AS SizeID
	   ,0 AS Quantity	 

GO

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**



DECLARE @Fabric AS int 
DECLARE @Pattern AS int 
DECLARE @CostSheet AS int 
DECLARE @NewFabric AS int

SET @Fabric  = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F021F')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '058')
SET @CostSheet = (SELECT [ID] FROM [dbo].[CostSheet] WHERE [Pattern] = @Pattern AND [Fabric] = @Fabric) 
SET @NewFabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F021')

UPDATE [dbo].[CostSheet] SET [Fabric] = @NewFabric WHERE [ID] = @CostSheet
GO

DECLARE @Fabric AS int 
DECLARE @Pattern AS int 
DECLARE @CostSheet AS int 

SET @Fabric  = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F021')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '058')
SET @CostSheet = (SELECT [ID] FROM [dbo].[CostSheet] WHERE [Pattern] = @Pattern AND [Fabric] = @Fabric) 


INSERT INTO [Indico].[dbo].[PatternSupportFabric] ([Fabric], [FabConstant], [CostSheet]) VALUES (@Fabric, 2.66, @CostSheet)
GO

DECLARE @Fabric AS int 
DECLARE @Pattern AS int 
DECLARE @CostSheet AS int 
DECLARE @NewFabric AS int

SET @Fabric  = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F021')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '058')
SET @CostSheet = (SELECT [ID] FROM [dbo].[CostSheet] WHERE [Pattern] = @Pattern AND [Fabric] = @Fabric) 
SET @NewFabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F094')


INSERT INTO [Indico].[dbo].[PatternSupportFabric] ([Fabric], [FabConstant], [CostSheet]) VALUES (@NewFabric, 1.00, @CostSheet)
GO


DECLARE @Fabric AS int 
DECLARE @Pattern AS int 
DECLARE @CostSheet AS int 
DECLARE @NewFabric AS int

SET @Fabric  = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F021')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '058')
SET @CostSheet = (SELECT [ID] FROM [dbo].[CostSheet] WHERE [Pattern] = @Pattern AND [Fabric] = @Fabric) 
SET @NewFabric = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F092')


INSERT INTO [Indico].[dbo].[PatternSupportFabric] ([Fabric], [FabConstant], [CostSheet]) VALUES (@NewFabric, 1.00, @CostSheet)
GO


DECLARE @Fabric AS int 
DECLARE @Pattern AS int 
DECLARE @CostSheet AS int 

SET @Fabric  = (SELECT [ID] FROM [dbo].[FabricCode] WHERE [Code] = 'F021')
SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '058')
SET @CostSheet = (SELECT [ID] FROM [dbo].[CostSheet] WHERE [Pattern] = @Pattern AND [Fabric] = @Fabric) 


UPDATE [dbo].[CostSheet] SET [TotalAccessoriesCost] = 6.39  WHERE [ID] = @CostSheet
GO



--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

DECLARE @ID AS int
DECLARE @Landed AS decimal(8, 2)
DECLARE @IndimanCIF AS decimal(8, 2)
DECLARE @QuotedCIF AS decimal(8, 2)
DECLARE @CALMP AS decimal(8, 2)
DECLARE @CALQuotedMP AS decimal (8, 2)

DECLARE CostSheetCursor CURSOR FAST_FORWARD FOR
 
SELECT [ID]      
	  ,[Landed]  
	  ,[IndimanCIF]
	  ,[QuotedCIF]
  FROM [Indico].[dbo].[CostSheet]
  WHERE [Pattern] ! = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '058') AND
	   [Landed] IS NOT NULL AND
	   [IndimanCIF] IS NOT NULL AND
	   [Landed] ! = 0.00
  
OPEN CostSheetCursor 
	FETCH NEXT FROM CostSheetCursor INTO @ID, @Landed, @IndimanCIF, @QuotedCIF
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
				
				
				
				SET @CALMP =  ROUND((1-(@Landed / @IndimanCIF))*100 , 2, 1)
				SET @CALQuotedMP =  ROUND((1-(@Landed /ISNULL(@QuotedCIF, @IndimanCIF)))* 100 , 2, 1)
				
								
				UPDATE [dbo].[CostSheet] SET  [MP] = @CALMP,
											   [QuotedMP] = @CALQuotedMP											  
										 WHERE [ID] = @ID
				
	SET @CALMP = 0			
	SET @CALQuotedMP = 0	
			
		FETCH NEXT FROM CostSheetCursor INTO  @ID, @Landed, @IndimanCIF, @QuotedCIF
	END
CLOSE CostSheetCursor 
DEALLOCATE CostSheetCursor
-----/--------
GO

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-** Add Weekdetails Page --**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/ViewWeekDetails.aspx', 'Week Details' , 'Week Details')
GO

DECLARE @Page AS int
DECLARE @ParentPage As int
DECLARE @Parent AS int 
DECLARE @Postion AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewWeekDetails.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @Postion = (SELECT (MAX([Position]) + 1) FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)


INSERT INTO [Indico].[dbo].[MenuItem] ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES(@Page ,'Week Details', 'Week Details', 1, @Parent, @Postion , 0)
GO



DECLARE @Page AS int
DECLARE @ParentPage As int
DECLARE @Parent AS int 
DECLARE @MenuItem AS int 
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewWeekDetails.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole]([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**
/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyAddressDetails]    Script Date: 10/31/2013 14:36:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyAddressDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyAddressDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyAddressDetails]    Script Date: 10/31/2013 14:36:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_GetWeeklyAddressDetails] (	
@P_WeekEndDate datetime2(7) 
)	
AS 
BEGIN
	
		SELECT	   od.[ID] AS OrderDetail
				  ,ot.[Name] AS OrderType
				  ,vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),'') AS VisualLayout
				  ,od.[VisualLayout] AS VisualLayoutID
				  ,od.[Pattern] AS PatternID
				  ,p.[Number] + ' - ' + p.[NickName] AS Pattern
				  ,od.[FabricCode] AS FabricID
				  ,fc.[Code] + ' - ' + fc.[Name] AS Fabric
				  ,od.[VisualLayoutNotes] AS VisualLayoutNotes      
				  ,od.[Order] AS 'Order'
				  ,ISNULL(od.[Label], 0) AS Label
				  ,ISNULL(ods.[Name], 'New') AS OrderDetailStatus
				  ,ISNULL(od.[Status], 0) AS OrderDetailStatusID
				  ,od.[ShipmentDate] AS ShipmentDate
				  ,od.[SheduledDate] AS SheduledDate      
				  ,od.[RequestedDate] AS RequestedDate
				  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]),0) AS Quantity       
				  ,ISNULL(o.[OldPONo], '') AS 'PurONo'
				  ,c.[Name] AS Distributor
				  ,u.[GivenName] + ' ' + u.[FamilyName] AS Coordinator
				  ,cl.[Name] AS Client
				  ,os.[Name] AS OrderStatus
				  ,o.[Status] AS OrderStatusID				  
				  ,ISNULL(o.[ShipmentMode], 0) AS ShimentModeID
				  ,ISNULL(shm.[Name], 'Air') AS ShipmentMode
				  ,dca.[Address] AS 'Address'
				  ,dca.[Suburb]  AS 'Suberb' 
				  ,dca.[PostCode]  AS 'PostCode'
				  ,coun.[ShortName] AS 'Country'
				  ,dca.[ContactName] + ' ' + dca.[ContactPhone] AS 'ContactDetails'
				  ,o.[IsWeeklyShipment] AS 'IsWeeklyShipment'
				  ,[IsAdelaideWareHouse] AS 'IsAdelaideWareHouse'
			  FROM [Indico].[dbo].[OrderDetail] od
				JOIN [dbo].[Order] o
					ON od.[Order] = o.[ID]
				JOIN [dbo].[VisualLayout] vl
					ON od.[VisualLayout] = vl.[ID]
				JOIN [dbo].[Pattern] p 
					ON od.[Pattern] = p.[ID]
				JOIN [dbo].[FabricCode] fc
					ON od.[FabricCode] = fc.[ID]
				LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
					ON od.[Status] = ods.[ID]
				JOIN [dbo].[OrderType] ot
					ON od.[OrderType] = ot.[ID]
				JOIN [dbo].[Company] c
					ON c.[ID] = o.[Distributor]
				JOIN [dbo].[User] u
					ON c.[Coordinator] = u.[ID]
				JOIN [dbo].[Client] cl
					ON o.[Client] = cl.[ID]
				JOIN [dbo].[OrderStatus] os
					ON o.[Status] = os.[ID]				
				LEFT OUTER JOIN [dbo].[ShipmentMode] shm
					ON o.[ShipmentMode] = shm.[ID] 
				JOIN [dbo].[DistributorClientAddress] dca
					ON o.[DespatchToExistingClient] = dca.[ID]
				JOIN [dbo].[Country] coun
					ON dca.[Country] = coun.[ID]
			WHERE (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)
			
	UNION ALL
		SELECT	   od.[ID] AS OrderDetail
				  ,ot.[Name] AS OrderType
				  ,vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),'') AS VisualLayout
				  ,od.[VisualLayout] AS VisualLayoutID
				  ,od.[Pattern] AS PatternID
				  ,p.[Number] + ' - ' + p.[NickName] AS Pattern
				  ,od.[FabricCode] AS FabricID
				  ,fc.[Code] + ' - ' + fc.[Name] AS Fabric
				  ,od.[VisualLayoutNotes] AS VisualLayoutNotes      
				  ,od.[Order] AS 'Order'
				  ,ISNULL(od.[Label], 0) AS Label
				  ,ISNULL(ods.[Name], 'New') AS OrderDetailStatus
				  ,ISNULL(od.[Status], 0) AS OrderDetailStatusID
				  ,od.[ShipmentDate] AS ShipmentDate
				  ,od.[SheduledDate] AS SheduledDate      
				  ,od.[RequestedDate] AS RequestedDate
				  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]),0) AS Quantity      				  
				  ,ISNULL(o.[OldPONo], '') AS 'PurONo'
				  ,c.[Name] AS Distributor
				  ,u.[GivenName] + ' ' + u.[FamilyName] AS Coordinator
				  ,cl.[Name] AS Client
				  ,os.[Name] AS OrderStatus
				  ,o.[Status] AS OrderStatusID				 
				  ,ISNULL(o.[ShipmentMode], 0) AS ShimentModeID
				  ,ISNULL(shm.[Name], 'Air') AS ShipmentMode
				  ,'4/60 GROVE AVENUE' AS 'Address'
				  ,'Marleston'  AS 'Suberb' 
				  ,'South Australia 5033'  AS 'PostCode'
				  ,'Australia' AS 'Country'
				  ,' JENNA KING / MARK BASSETT Ph: (08) 8351 5955' AS 'ContactDetails'
				  ,o.[IsWeeklyShipment] AS 'IsWeeklyShipment'
				  ,[IsAdelaideWareHouse] AS 'IsAdelaideWareHouse'
			  FROM [Indico].[dbo].[OrderDetail] od
				JOIN [dbo].[Order] o
					ON od.[Order] = o.[ID]
				JOIN [dbo].[VisualLayout] vl
					ON od.[VisualLayout] = vl.[ID]
				JOIN [dbo].[Pattern] p 
					ON od.[Pattern] = p.[ID]
				JOIN [dbo].[FabricCode] fc
					ON od.[FabricCode] = fc.[ID]
				LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
					ON od.[Status] = ods.[ID]
				JOIN [dbo].[OrderType] ot
					ON od.[OrderType] = ot.[ID]
				JOIN [dbo].[Company] c
					ON c.[ID] = o.[Distributor]
				JOIN [dbo].[User] u
					ON c.[Coordinator] = u.[ID]
				JOIN [dbo].[Client] cl
					ON o.[Client] = cl.[ID]
				JOIN [dbo].[OrderStatus] os
					ON o.[Status] = os.[ID]				
				LEFT OUTER JOIN [dbo].[ShipmentMode] shm
					ON o.[ShipmentMode] = shm.[ID] 				
			WHERE (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate) AND
				   o.[IsWeeklyShipment] = 1 AND o.[IsAdelaideWareHouse] = 1
			ORDER BY Client

	END 

GO

--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**

/****** Object:  View [dbo].[ReturnWeeklyAddressDetails]    Script Date: 10/31/2013 15:09:04 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnWeeklyAddressDetails]'))
DROP VIEW [dbo].[ReturnWeeklyAddressDetails]
GO

/****** Object:  View [dbo].[ReturnWeeklyAddressDetails]    Script Date: 10/31/2013 15:09:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnWeeklyAddressDetails]
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
				  0 AS Label,
				  '' AS OrderDetailStatus,
				  0 AS OrderDetailStatusID,
				  GETDATE() AS ShipmentDate,
				  GETDATE() AS SheduledDate,
				  GETDATE() AS RequestedDate,
				  0 AS Quantity,				 
				  '' AS 'PurONo',
				  '' AS Distributor,
				  '' AS Coordinator,
				  '' AS Client,
				  '' AS OrderStatus,
				  0 AS OrderStatusID,				  
				  0 AS ShimentModeID,
				  '' AS ShipmentMode,
				  '' AS 'Address',
				  ''  AS 'Suberb',
				  ''  AS 'PostCode',
				  '' AS 'Country',
				  '' AS 'ContactDetails',
				  CONVERT(bit,0) AS 'IsWeeklyShipment',
				  CONVERT(bit,0) AS 'IsAdelaideWareHouse'

GO
--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**
