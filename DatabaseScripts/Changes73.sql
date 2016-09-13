USE [Indico]
GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-** DROP COLUMN Distributor From DistributorClientAddress --**-**-**--**-**-**--**-**-**--**-**-**
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DistributorAddress_Country]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorClientAddress]'))
ALTER TABLE [dbo].[DistributorClientAddress] DROP CONSTRAINT [FK_DistributorAddress_Country]
GO

ALTER TABLE [dbo].[DistributorClientAddress]
DROP COLUMN [Distributor]
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-** ADD COLUMN State For DistributorClientAddress--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

ALTER TABLE [dbo].[DistributorClientAddress]
ADD [CompanyName] NVARCHAR(255) NULL
GO

ALTER TABLE [dbo].[DistributorClientAddress]
ADD [State] NVARCHAR(255) NULL
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-** Add New Page to the System "ViewSummaryDetail"--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**


INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/ViewSummaryDetails.aspx', 'Week Summary' , 'Week Summary')
GO

DECLARE @Page AS int
DECLARE @ParentPage As int
DECLARE @Parent AS int 
DECLARE @Postion AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewSummaryDetails.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @Postion = (SELECT (MAX([Position]) + 1) FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)


INSERT INTO [Indico].[dbo].[MenuItem] ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES(@Page ,'Week Summary', 'Week Summary', 1, @Parent, @Postion , 0)
GO



DECLARE @Page AS int
DECLARE @ParentPage As int
DECLARE @Parent AS int 
DECLARE @MenuItem AS int 
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewSummaryDetails.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole]([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

--**-**-**--**-**-**--**-**-**--**-**-** Change the Order Table DATA--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

DECLARE @ID AS int
DECLARE @ShipToExistingClien AS int
DECLARE @DespatchToExistingClient AS int

DECLARE OrderCursor CURSOR FAST_FORWARD FOR
 
SELECT [ID]      
      ,[ShipToExistingClient]
      ,[DespatchToExistingClient]      
  FROM [Indico].[dbo].[Order]
  
OPEN OrderCursor 
	FETCH NEXT FROM OrderCursor INTO @ID, @ShipToExistingClien, @DespatchToExistingClient
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
			UPDATE [dbo].[Order] SET [DespatchToExistingClient] = @ShipToExistingClien	WHERE [ID] = @ID

			
		FETCH NEXT FROM OrderCursor INTO  @ID, @ShipToExistingClien, @DespatchToExistingClient
	END
CLOSE OrderCursor 
DEALLOCATE OrderCursor
GO
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

--**-**-**--**-**-**--**-**-**--**-**-** Change the Distributor Client Address Details--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
UPDATE [dbo].[Order] SET [ShipToExistingClient] = NULL


DECLARE @ContactName AS NVARCHAR(255)
DECLARE @ID AS int 
DECLARE @Count AS int
DECLARE @SELECTEDID AS int  
SET @Count = 0

DECLARE DistributorClientAddress CURSOR FAST_FORWARD FOR
 
SELECT [ContactName]     
FROM [dbo].[DistributorClientAddress]
GROUP BY [ContactName]
  
OPEN DistributorClientAddress 
	FETCH NEXT FROM DistributorClientAddress INTO @ContactName
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		SET @Count = @Count + 1
				
				DECLARE DeleteDuplicateRecords CURSOR FAST_FORWARD FOR
 
						SELECT [ID]								  
						FROM [Indico].[dbo].[DistributorClientAddress]
						WHERE [ContactName] = @ContactName
						  
						OPEN DeleteDuplicateRecords 
							FETCH NEXT FROM DeleteDuplicateRecords INTO @ID
							WHILE @@FETCH_STATUS = 0 
							BEGIN 
							
									IF(@Count = 1)
										BEGIN
										
										SET @SELECTEDID = @ID
										
										END
									
								UPDATE [dbo].[Order] SET [DespatchToExistingClient] = @SELECTEDID  WHERE [DespatchToExistingClient] = @ID
								SET @Count = @Count + 1
								
							FETCH NEXT FROM DeleteDuplicateRecords INTO  @ID
						END
				CLOSE DeleteDuplicateRecords 
				DEALLOCATE DeleteDuplicateRecords
			
			SET @Count = 0
			
		FETCH NEXT FROM DistributorClientAddress INTO  @ContactName
	END
CLOSE DistributorClientAddress 
DEALLOCATE DistributorClientAddress
GO


DECLARE @ContactName AS NVARCHAR(255)
DECLARE @ID AS int 
DECLARE @Count AS int
DECLARE @SELECTEDID AS int  
SET @Count = 0

DECLARE DeleteDistributorClientAddress CURSOR FAST_FORWARD FOR
 
SELECT [ContactName]     
FROM [dbo].[DistributorClientAddress]
GROUP BY [ContactName]
  
OPEN DeleteDistributorClientAddress 
	FETCH NEXT FROM DeleteDistributorClientAddress INTO @ContactName
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		SET @Count = @Count + 1
				
				DECLARE DeleteDuplicates CURSOR FAST_FORWARD FOR
 
						SELECT [ID]								  
						FROM [Indico].[dbo].[DistributorClientAddress]
						WHERE [ContactName] = @ContactName
						  
						OPEN DeleteDuplicates 
							FETCH NEXT FROM DeleteDuplicates INTO @ID
							WHILE @@FETCH_STATUS = 0 
							BEGIN 
							
									IF(@Count = 1)
										BEGIN
										
										SET @SELECTEDID = @ID
										
										END
									ELSE
										BEGIN 
											DELETE FROM [dbo].[DistributorClientAddress] WHERE [ID] = @ID											
										END		
										
										SET @Count = @Count + 1							
							
							
							FETCH NEXT FROM DeleteDuplicates INTO  @ID
						END
				CLOSE DeleteDuplicates 
				DEALLOCATE DeleteDuplicates
			
			SET @Count = 0
			
		FETCH NEXT FROM DeleteDistributorClientAddress INTO  @ContactName
	END
CLOSE DeleteDistributorClientAddress 
DEALLOCATE DeleteDistributorClientAddress
GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

--**-**-**--**-**-**--**-**-**--**-**-** Alter GetWeeklyAddressDetails SP--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyAddressDetails]    Script Date: 11/07/2013 11:00:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyAddressDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyAddressDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyAddressDetails]    Script Date: 11/07/2013 11:00:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_GetWeeklyAddressDetails] (	
@P_WeekEndDate datetime2(7),
@P_CompanyName NVARCHAR(255) = '',
@P_ShipmentMode int = 0 
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
				  ,ISNULL(shm.[Name], 'AIR') AS ShipmentMode
				  ,ISNULL(dca.[CompanyName], '') AS 'CompanyName'
				  ,dca.[Address] AS 'Address'
				  ,dca.[Suburb]  AS 'Suberb' 
				  ,ISNULL(dca.[State],'') AS 'State'
				  ,dca.[PostCode]  AS 'PostCode'				 
				  ,coun.[ShortName] AS 'Country'
				  ,dca.[ContactName] + ' ' + dca.[ContactPhone] AS 'ContactDetails'
				  ,o.[IsWeeklyShipment] AS 'IsWeeklyShipment'
				  ,[IsAdelaideWareHouse] AS 'IsAdelaideWareHouse'
				  ,ISNULL(o.[DespatchToExistingClient], 0) AS 'ShipTo'
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
				JOIN [dbo].[ShipmentMode] shm
					ON o.[ShipmentMode] = shm.[ID] 
				JOIN [dbo].[DistributorClientAddress] dca
					ON o.[DespatchToExistingClient] = dca.[ID]
				JOIN [dbo].[Country] coun
					ON dca.[Country] = coun.[ID]
			WHERE (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate) AND
				  (@P_CompanyName = '' OR dca.[CompanyName] = @P_CompanyName ) AND
				  (@P_ShipmentMode = 0 OR shm.[ID] = @P_ShipmentMode)
			ORDER BY cl.[Name]

	END 

GO
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

--**-**-**--**-**-**--**-**-**--**-**-** Return [ReturnWeeklyAddressDetails] View--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

/****** Object:  View [dbo].[ReturnWeeklyAddressDetails]    Script Date: 11/07/2013 11:18:18 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnWeeklyAddressDetails]'))
DROP VIEW [dbo].[ReturnWeeklyAddressDetails]
GO

/****** Object:  View [dbo].[ReturnWeeklyAddressDetails]    Script Date: 11/07/2013 11:18:19 ******/
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
				  '' AS 'CompanyName',
				  '' AS 'Address',
				  '' AS 'Suberb',
				  '' AS 'State',
				  '' AS 'PostCode',
				  '' AS 'Country',
				  '' AS 'ContactDetails',
				  CONVERT(bit,0) AS 'IsWeeklyShipment',
				  CONVERT(bit,0) AS 'IsAdelaideWareHouse',
				  0 AS 'ShipTo'


GO
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-** Change the Company Name Field--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

DECLARE @ID AS int
DECLARE @ContactName AS NVARCHAR(255)
DECLARE @CompanyName AS NVARCHAR(255)

DECLARE DistributorClientAddress CURSOR FAST_FORWARD FOR

SELECT [ID]     
      ,[ContactName]     
      ,[CompanyName]    
  FROM [Indico].[dbo].[DistributorClientAddress]
  
OPEN DistributorClientAddress 
	FETCH NEXT FROM DistributorClientAddress INTO @ID, @ContactName, @CompanyName
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
			UPDATE [dbo].[DistributorClientAddress] SET [CompanyName] = @ContactName	WHERE [ID] = @ID

			
		FETCH NEXT FROM DistributorClientAddress INTO  @ID, @ContactName, @CompanyName
	END
CLOSE DistributorClientAddress 
DEALLOCATE DistributorClientAddress
GO


ALTER TABLE [dbo].[DistributorClientAddress]
ALTER COLUMN [CompanyName] NVARCHAR(255) NOT NULL 
GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

DECLARE @ID AS int

INSERT INTO [Indico].[dbo].[DistributorClientAddress] ([Address], [Suburb], [PostCode], [Country], [ContactName], [ContactPhone], [CompanyName], [State])
     VALUES('4/60 GROVE AVENUE', 'MARLESTON', '5033', 14, 'JENNA KING / MARK BASSETT', '(08) 8351 5955', 'INDICO ADELAIDE', 'SOUTH AUSTRALIA')
     
 SET @ID = SCOPE_IDENTITY()
 
 
UPDATE [dbo].[Order] SET [DespatchToExistingClient] = @ID WHERE [IsWeeklyShipment] = 1 AND [IsAdelaideWareHouse] = 1
GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySummary]    Script Date: 11/07/2013 13:23:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklySummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklySummary]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklySummary]    Script Date: 11/07/2013 13:23:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_GetWeeklySummary] (	
@P_WeekEndDate datetime2(7) 
)	
AS 
BEGIN
		SELECT 
				ISNULL(dca.CompanyName, '') AS 'CompanyName', 
				ISNULL(SUM(odq.Qty), 0) AS  'Qty' , 
				ISNULL(sm.[Name], 'AIR') AS 'ShipmentMode',
				ISNULL(sm.[ID], 0) AS 'ShipmentModeID'
		  FROM [Indico].[dbo].[DistributorClientAddress] dca
		 JOIN [dbo].[ORDER] o
			ON o.[DespatchToExistingClient] = dca.ID
		 JOIN [dbo].[OrderDetail] od
			ON od.[Order] = o.ID
		 JOIN [dbo].[OrderDetailQty] odq
			ON odq.[OrderDetail] = od.ID
		 JOIN [dbo].[ShipmentMode] sm
			ON o.[ShipmentMode] = sm.[ID]
		WHERE (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate)
		GROUP BY dca.CompanyName, sm.[Name], sm.[ID]
END


GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**


/****** Object:  View [dbo].[ReturnWeeklySummaryView]    Script Date: 11/07/2013 13:28:26 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnWeeklySummaryView]'))
DROP VIEW [dbo].[ReturnWeeklySummaryView]
GO

/****** Object:  View [dbo].[ReturnWeeklySummaryView]    Script Date: 11/07/2013 13:28:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnWeeklySummaryView]
AS
			SELECT			  
				  '' AS 'CompanyName',				  
				  0 AS 'Qty',
				  '' AS 'ShipmentMode',
				  0 AS 'ShipmentModeID'				 

GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-** DELETE [PatternItemAttributeSub]--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**
DELETE [dbo].[PatternItemAttributeSub]
FROM [dbo].[PatternItemAttributeSub] pias
			INNER JOIN  [dbo].[Pattern] p
				ON pias.Pattern = p.ID
WHERE p.Item NOT IN (SELECT ia.Item FROM [dbo].[ItemAttribute] ia WHERE ia.ID = pias.[ItemAttribute])
GO
--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**