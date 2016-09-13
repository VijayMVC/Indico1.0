USE [Indico]
GO

ALTER TABLE [dbo].[Pattern]
ADD [Unit] [int] NULL
GO

ALTER TABLE [dbo].[Pattern] WITH CHECK ADD CONSTRAINT [FK_Pattern_Unit] FOREIGN KEY ([Unit])
REFERENCES [dbo].[Unit] ([ID])
GO

ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_Unit]
GO

--NEW---
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  Table [dbo].[DistributorEmailAddress]    Script Date: 09/05/2014 12:02:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistributorEmailAddress]') AND type in (N'U'))
DROP TABLE [dbo].[DistributorEmailAddress]
GO

/****** Object:  Table [dbo].[DistributorEmailAddress]    Script Date: 09/05/2014 12:02:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DistributorEmailAddress](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Distributor] [int] NOT NULL,
	[EmailAddress] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_DistributorEmailAddress] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[DistributorEmailAddress] WITH CHECK ADD CONSTRAINT [FK_DistributorEmailAddress_Distributor] FOREIGN KEY ([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO

ALTER TABLE [dbo].[DistributorEmailAddress] CHECK CONSTRAINT [FK_DistributorEmailAddress_Distributor]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


/****** Object:  Table [dbo].[CoordinatorEmailAddress]    Script Date: 09/05/2014 12:06:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CoordinatorEmailAddress]') AND type in (N'U'))
DROP TABLE [dbo].[CoordinatorEmailAddress]
GO


/****** Object:  Table [dbo].[CoordinatorEmailAddress]    Script Date: 09/05/2014 12:06:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CoordinatorEmailAddress](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[User] [int] NOT NULL,
	[EmailAddress] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_CoordinatorEmailAddress] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[CoordinatorEmailAddress] WITH CHECK ADD CONSTRAINT [FK_CoordinatorEmailAddress_Distributor] FOREIGN KEY ([User])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[CoordinatorEmailAddress] CHECK CONSTRAINT [FK_CoordinatorEmailAddress_Distributor]
GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[Company] 
ADD [IsBackOrder] [bit] NULL
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
/****** Object:  StoredProcedure [dbo].[SPC_GetBackOrders]    Script Date: 09/05/2014 14:30:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetBackOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetBackOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetBackOrders]    Script Date: 09/05/2014 14:30:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_GetBackOrders] (	
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN
	SELECT d.[ID] AS DistributorID
		  ,d.[Name] AS Distributor
		  ,c.[GivenName] + ' ' + c.[FamilyName] AS Coordinator
		  ,c.[ID] AS CoordinatorID
		  ,ISNULL(d.[IsBackOrder], 0) AS BackOrder
		  ,SUM(odq.[Qty]) AS Qty
		  ,ISNULL((SELECT STUFF((SELECT ', ' + [EmailAddress] AS [text()] FROM (SELECT DISTINCT dea.[EmailAddress] FROM [DistributorEmailAddress] dea WHERE dea.[Distributor] = d.[ID] ) x FOR XML PATH('')), 1, 1, '')), u.[EmailAddress]) AS [DistributorEmailAddress]
		  ,ISNULL((SELECT STUFF((SELECT ', ' + [EmailAddress] AS [text()] FROM (SELECT DISTINCT cea.[EmailAddress] FROM [CoordinatorEmailAddress] cea WHERE cea.[User] = c.[ID] ) x FOR XML PATH('')), 1, 1, '')), c.[EmailAddress]) AS [CoordinatorEmailAddress]
		  ,ISNULL((SELECT [Count] FROM [dbo].[DistributorSendMailCount] WHERE [Distributor] = d.[ID] AND [WeeklyProductionCapacity]  = (SELECT [ID] FROM [dbo].[WeeklyProductionCapacity] WHERE [WeekendDate] = CAST(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 4) AS DATE))), 0) AS [Count]
	FROM [dbo].[Company] d
		LEFT OUTER JOIN [dbo].[User] c
			ON d.[Coordinator] = c.[ID]
		JOIN [dbo].[Order] o 
			ON o.[Distributor] = d.[ID]
		JOIN [dbo].[OrderDetail] od
			ON o.[ID] = od.[Order]
		JOIN [dbo].[OrderDetailQty] odq
			ON od.[ID] = odq.[OrderDetail]
		JOIN [dbo].[User] u
			ON d.[Owner] = u.[ID]
	WHERE d.[IsDistributor] = 1 AND
		  d.[IsBackOrder] = 1 AND
		 (od.[Status] IS NULL OR od.[Status] IN (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped')) AND
		 (od.[SheduledDate] >= CAST(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) AS DATE))
	GROUP BY d.[ID], d.[Name], c.[GivenName] + ' ' + c.[FamilyName], c.[ID], d.[IsBackOrder], u.[EmailAddress], c.[EmailAddress]
	ORDER BY d.[Name]
END

GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
/****** Object:  View [dbo].[ReturnBackOrdersView]    Script Date: 09/05/2014 14:51:04 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnBackOrdersView]'))
DROP VIEW [dbo].[ReturnBackOrdersView]
GO

/****** Object:  View [dbo].[ReturnBackOrdersView]    Script Date: 09/05/2014 14:51:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnBackOrdersView]
AS

SELECT	   0 AS DistributorID
		  ,'' AS Distributor
		  ,'' AS Coordinator
		  ,0 CoordinatorID
		  ,CONVERT(bit,0) AS BackOrder
		  ,0 AS Qty
		  ,'' AS [DistributorEmailAddress]
		  ,'' AS [CoordinatorEmailAddress]
		  ,0 AS [Count]

GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

DECLARE @Page AS int
DECLARE @Parent AS int 
DECLARE @MenuItem AS int
DECLARE @Role AS int
DECLARE @Position AS int


SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/Home.aspx')

SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)

SET @Position = (SELECT MAX([Position]) + 1 FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')


INSERT INTO [Indico].[dbo].[Page]([Name], [Title], [Heading]) VALUES ('/ViewBackOrders.aspx', 'Back Orders', 'Back Orders')

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])  VALUES (SCOPE_IDENTITY(), 'Back Orders', 'Back Orders', 1, @Parent, @Position, 1)

INSERT INTO [Indico].[dbo].[MenuItemRole]
           ([MenuItem], [Role]) VALUES (SCOPE_IDENTITY(), @Role)
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 09/10/2014 10:13:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyFirmOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders]
GO

USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 09/10/2014 10:13:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






/********* ALTER STORED PROCEDURE [SPC_GetWeeklyFirmOrders]*************/
CREATE PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders] (	
	@P_WeekEndDate datetime2(7),
	@P_SearchText AS NVARCHAR(255) = '',
	@P_OrderStatus AS NVARCHAR(255) = '',
	@P_Sort AS int = 0, --0 CreatedDate,--1 VL, --2 Pattern Number, --3 Order Detail Type, --4  Order Detail Status, --5 Old Po No, --6 Coordinator, --7 Distributor, --8 Client, --9 Order Status
	@P_OrderBy AS bit = 1,  -- 0 ASC , -- 1 DESC
	@P_Set AS int = 0,
	@P_MaxRows AS int = 20,
	@P_RecCount int OUTPUT,
	@P_Coordinator AS NVARCHAR(255) = '',
	@P_Distributor AS NVARCHAR(255) = '',
	@P_Clients AS NVARCHAR(255) = ''
)
AS
BEGIN

SET NOCOUNT ON
	DECLARE @Orders TABLE
	(
    OrderID int NOT NULL
	);
	DECLARE @StartOffset AS int;
	DECLARE @orderid AS int;
	SET @StartOffset = (@P_Set - 1) * @P_MaxRows;
	
	
	IF (ISNUMERIC(@P_SearchText) = 1 )
		BEGIN
			SET @orderid = CONVERT(int, @P_SearchText)		
		END
	ELSE
		BEGIN
			SET @orderid = 0
		END;
		
		/*WITH Orders AS
		(
		SELECT DISTINCT TOP (@P_Set * @P_MaxRows)
		CONVERT(int, ROW_NUMBER() OVER ( ORDER BY o.[ID] DESC))
		AS Number,
		 o.[ID]
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
										JOIN [dbo].[User] urc
											ON o.[Creator] = urc.[ID]
										JOIN [dbo].[User] urm
											ON o.[Modifier] = urm.[ID] 
									WHERE (@P_SearchText = '' OR
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
										   fc.[Name] LIKE '%' + @P_SearchText + '%'  OR
										   o.[ID] = @orderid )AND
										  (@P_OrderStatus = '' OR os.[Name] LIKE '%' + @P_OrderStatus + '%') AND
								          (o.[Reservation] IS NULL) AND
								          (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)AND
										  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
										  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
										  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
										  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))
								      GROUP BY o.[ID]
		 )
	
	INSERT INTO @Orders ([OrderID]) 
	SELECT  ID FROM Orders WHERE Number > @StartOffset;	
	*/
													
	
	--WITH OrderDetails AS
	--	(
			SELECT 			
				   od.[ID] AS OrderDetail
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
				  ,ISNULL(dca.[CompanyName] + ' ' + dca.[Address] + ' ' + dca.[Suburb] + ' ' + ISNULL(dca.[State], '') + ' ' + co.[ShortName] + ' ' + dca.[PostCode], '') AS ShippingAddress
				  ,ISNULL(dp.[Name], '') AS DestinationPort
				  ,ISNULL(vl.[ResolutionProfile], 0 ) AS ResolutionProfile
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
				JOIN [dbo].[User] urc
					ON o.[Creator] = urc.[ID]
				JOIN [dbo].[User] urm
					ON o.[Modifier] = urm.[ID] 
				LEFT OUTER JOIN [dbo].[PaymentMethod] pm
					ON o.[PaymentMethod] = pm.[ID]
				LEFT OUTER JOIN [dbo].[ShipmentMode] sm
					ON o.[ShipmentMode] = sm.[ID]
				LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
					ON o.[DespatchToExistingClient] = dca.[ID]
				LEFT OUTER JOIN [dbo].[Country] co
					ON dca.[Country] = co.[ID]
				LEFT OUTER JOIN [dbo].[DestinationPort] dp
					ON dca.[Port] = dp.[ID]
			WHERE (@P_SearchText = '' OR
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
				   fc.[Name] LIKE '%' + @P_SearchText + '%'  OR
				   o.[ID] = @orderid )AND
				  (@P_OrderStatus = '' OR os.[Name] LIKE '%' + @P_OrderStatus + '%') AND
		          (o.[Reservation] IS NULL) AND
		          (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))AND
				  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
				  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
				  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
				  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Pre Shipped')))
							
	--	)
	--SELECT * FROM OrderDetails --WHERE ID > @StartOffset
	
	/*IF (@P_Set = 1)	
		BEGIN 
			SELECT  @P_RecCount = COUNT(ord.[ID]) 
			FROM (SELECT DISTINCT o.[ID] FROM [Indico].[dbo].[OrderDetail] od
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
														JOIN [dbo].[User] urc
															ON o.[Creator] = urc.[ID]
														JOIN [dbo].[User] urm
															ON o.[Modifier] = urm.[ID] 
													WHERE (@P_SearchText = '' OR
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
														   fc.[Name] LIKE '%' + @P_SearchText + '%'  OR
														   o.[ID] = @orderid )AND
														  (@P_OrderStatus = '' OR os.[Name] LIKE '%' + @P_OrderStatus + '%') AND
												          (o.[Reservation] IS NULL) AND
												          (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)AND
														  (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE '%' + @P_Coordinator + '%') AND
														  (@P_Distributor = '' OR c.[Name] LIKE '%' + @P_Distributor + '%')	AND
														  (@P_Clients = '' OR cl.[Name] LIKE '%' + @P_Clients + '%') AND
														  (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold' OR [Name] = 'Cancelled')))) ord
		END
	ELSE
		BEGIN*/
			SET @P_RecCount = 0
		--END	
		
END





GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DistributorSendMailCount_Distributor]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorSendMailCount]'))
ALTER TABLE [dbo].[DistributorSendMailCount] DROP CONSTRAINT [FK_DistributorSendMailCount_Distributor]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DistributorSendMailCount_WeeklyProductionCapacity]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorSendMailCount]'))
ALTER TABLE [dbo].[DistributorSendMailCount] DROP CONSTRAINT [FK_DistributorSendMailCount_WeeklyProductionCapacity]
GO

/****** Object:  Table [dbo].[DistributorSendMailCount]    Script Date: 09/12/2014 13:15:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistributorSendMailCount]') AND type in (N'U'))
DROP TABLE [dbo].[DistributorSendMailCount]
GO

/****** Object:  Table [dbo].[DistributorSendMailCount]    Script Date: 09/12/2014 13:15:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DistributorSendMailCount](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Distributor] [int] NOT NULL,
	[WeeklyProductionCapacity] [int] NOT NULL,
	[Count] [int] NULL,
 CONSTRAINT [PK_DistributorSendMailCount] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[DistributorSendMailCount]  WITH CHECK ADD  CONSTRAINT [FK_DistributorSendMailCount_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Company] ([ID])
GO

ALTER TABLE [dbo].[DistributorSendMailCount] CHECK CONSTRAINT [FK_DistributorSendMailCount_Distributor]
GO

ALTER TABLE [dbo].[DistributorSendMailCount]  WITH CHECK ADD  CONSTRAINT [FK_DistributorSendMailCount_WeeklyProductionCapacity] FOREIGN KEY([WeeklyProductionCapacity])
REFERENCES [dbo].[WeeklyProductionCapacity] ([ID])
GO

ALTER TABLE [dbo].[DistributorSendMailCount] CHECK CONSTRAINT [FK_DistributorSendMailCount_WeeklyProductionCapacity]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**




