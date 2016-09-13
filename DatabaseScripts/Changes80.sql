USE [Indico]
Go


INSERT INTO [Indico].[dbo].[EmbroideryStatus] ([Name], [Description]) VALUES ('New', 'New')
GO

INSERT INTO [Indico].[dbo].[EmbroideryStatus] ([Name], [Description]) VALUES ('IN PROCESS - SENT TO EMRBOIDERER', 'IN PROCESS - SENT TO EMRBOIDERER')
GO

INSERT INTO [Indico].[dbo].[EmbroideryStatus] ([Name], [Description]) VALUES ('IN PROCESS - RE - SENT TO EMRBOIDERER FOR CORRECTION', 'IN PROCESS - RE - SENT TO EMRBOIDERER FOR CORRECTION')
GO

INSERT INTO [Indico].[dbo].[EmbroideryStatus] ([Name], [Description]) VALUES ('IN PROCESS - RECEIVED FROM EMRBOIDERER', 'IN PROCESS - RECEIVED FROM EMRBOIDERER')
GO

INSERT INTO [Indico].[dbo].[EmbroideryStatus] ([Name], [Description]) VALUES ('STRIKE OFFF PHOTO SENT TO COORDINATOR', 'STRIKE OFFF PHOTO SENT TO COORDINATOR')
GO

INSERT INTO [Indico].[dbo].[EmbroideryStatus] ([Name], [Description]) VALUES ('STRIKE OFFF SENT TO CUSTOMER FOR APPROVAL', 'STRIKE OFFF SENT TO CUSTOMER FOR APPROVAL')
GO

INSERT INTO [Indico].[dbo].[EmbroideryStatus] ([Name], [Description]) VALUES ('STRIKE OFFF APPROVED BY CUSTOMER', 'STRIKE OFFF APPROVED BY CUSTOMER')
GO

INSERT INTO [Indico].[dbo].[EmbroideryStatus] ([Name], [Description]) VALUES ('ORDER PLACED', 'ORDER PLACED')
GO

INSERT INTO [Indico].[dbo].[EmbroideryStatus] ([Name], [Description]) VALUES ('STRIKE OFF REJECTED BY CUSTOMER', 'STRIKE OFF REJECTED BY CUSTOMER')
GO

INSERT INTO [Indico].[dbo].[EmbroideryStatus] ([Name], [Description]) VALUES ('JOB ON HOLD', 'JOB ON HOLD')
GO

INSERT INTO [Indico].[dbo].[EmbroideryStatus] ([Name], [Description]) VALUES ('CANCELLED', 'CANCELLED')
GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

/****** Object:  Table [dbo].[FabricType]    Script Date: 12/04/2013 16:42:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FabricType]') AND type in (N'U'))
DROP TABLE [dbo].[FabricType]
GO

/****** Object:  Table [dbo].[FabricType]    Script Date: 12/04/2013 16:42:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FabricType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](255) NULL,
 CONSTRAINT [PK_FabricType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmbroideryDetails_Fabric]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmbroideryDetails]'))
ALTER TABLE [dbo].[EmbroideryDetails] DROP CONSTRAINT [FK_EmbroideryDetails_Fabric]
GO

SP_RENAME '[EmbroideryDetails].[Fabric]', 'FabricType', 'COLUMN'
GO


ALTER TABLE [dbo].[EmbroideryDetails]  WITH CHECK ADD  CONSTRAINT [FK_EmbroideryDetails_FabricType] FOREIGN KEY([FabricType])
REFERENCES [dbo].[FabricType] ([ID])
GO

ALTER TABLE [dbo].[EmbroideryDetails] CHECK CONSTRAINT [FK_EmbroideryDetails_FabricType]
GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

INSERT INTO [Indico].[dbo].[FabricType] ([Name], [Description]) VALUES ('COTTON:POLYESTER PIQUE' , 'COTTON:POLYESTER PIQUE')
GO

INSERT INTO [Indico].[dbo].[FabricType] ([Name], [Description]) VALUES ('FLEECE' , 'FLEECE')
GO

INSERT INTO [Indico].[dbo].[FabricType] ([Name], [Description]) VALUES ('INTERLOCK 250' , 'INTERLOCK 250')
GO

INSERT INTO [Indico].[dbo].[FabricType] ([Name], [Description]) VALUES ('MICRO POPLIN' , 'MICRO POPLIN')
GO

INSERT INTO [Indico].[dbo].[FabricType] ([Name], [Description]) VALUES ('MICROMESH' , 'MICROMESH')
GO

INSERT INTO [Indico].[dbo].[FabricType] ([Name], [Description]) VALUES ('NYLON TASLON' , 'NYLON TASLON')
GO

INSERT INTO [Indico].[dbo].[FabricType] ([Name], [Description]) VALUES ('POLAR FLEECE' , 'POLAR FLEECE')
GO

INSERT INTO [Indico].[dbo].[FabricType] ([Name], [Description]) VALUES ('POLY FLEECE' , 'POLY FLEECE')
GO

INSERT INTO [Indico].[dbo].[FabricType] ([Name], [Description]) VALUES ('POLY SPARTAN' , 'POLY SPARTAN')
GO

INSERT INTO [Indico].[dbo].[FabricType] ([Name], [Description]) VALUES ('POLY TASLON' , 'POLY TASLON')
GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ICostSheetImages_CostSheet]') AND parent_object_id = OBJECT_ID(N'[dbo].[CostSheetImages]'))
ALTER TABLE [dbo].[CostSheetImages] DROP CONSTRAINT [FK_ICostSheetImages_CostSheet]
GO

/****** Object:  Table [dbo].[CostSheetImages]    Script Date: 12/04/2013 17:10:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CostSheetImages]') AND type in (N'U'))
DROP TABLE [dbo].[CostSheetImages]
GO

/****** Object:  Table [dbo].[CostSheetImages]    Script Date: 12/04/2013 17:10:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO
--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmbroideryImage_EmbroideryDetails]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmbroideryImage]'))
ALTER TABLE [dbo].[EmbroideryImage] DROP CONSTRAINT [FK_EmbroideryImage_EmbroideryDetails]
GO

/****** Object:  Table [dbo].[EmbroideryImage]    Script Date: 12/06/2013 09:37:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmbroideryImage]') AND type in (N'U'))
DROP TABLE [dbo].[EmbroideryImage]
GO

/****** Object:  Table [dbo].[EmbroideryImage]    Script Date: 12/06/2013 09:37:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[EmbroideryImage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EmbroideryDetails] [int] NOT NULL,
	[Size] [int] NOT NULL,
	[Filename] [nvarchar](255) NULL,
	[Extension] [varchar](10) NULL,
	[IsRequested] [bit] NOT NULL,
 CONSTRAINT [PK_EmbroideryImage] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[EmbroideryImage]  WITH CHECK ADD  CONSTRAINT [FK_EmbroideryImage_EmbroideryDetails] FOREIGN KEY([EmbroideryDetails])
REFERENCES [dbo].[EmbroideryDetails] ([ID])
GO

ALTER TABLE [dbo].[EmbroideryImage] CHECK CONSTRAINT [FK_EmbroideryImage_EmbroideryDetails]
GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**
DECLARE @Page AS int
DECLARE @ParentPage As int
DECLARE @Parent AS int 
DECLARE @MenuItem AS int
DECLARE @Role AS int
DECLARE @Position AS int

INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/ViewFabricTypes.aspx', 'Fabric Types', 'Fabric Types')

SET @Page = SCOPE_IDENTITY()

SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAgeGroups.aspx')

SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)

SET @Position = (SELECT MAX([Position] + 1) FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [Indico].[dbo].[MenuItem] ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES( @Page, 'Fabric Types', 'Fabric Types', 1, @Parent ,@Position, 1)


SET @MenuItem = SCOPE_IDENTITY()
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')


INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role])  VALUES (@MenuItem, @Role)
GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**
DECLARE @Page AS int
DECLARE @ParentPage As int
DECLARE @Parent AS int 
DECLARE @MenuItem AS int
DECLARE @Role AS int
DECLARE @Position AS int
DECLARE @Child AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewFabricTypes.aspx')

SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAgeGroups.aspx')

SET @Position = (SELECT [Position] FROM [dbo].[MenuItem] WHERE [Parent] IS NULL AND [Page] = @ParentPage)

INSERT INTO [Indico].[dbo].[MenuItem] ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES( @Page, 'Master Data', 'Master Data', 1, NULL ,@Position, 1)

SET @MenuItem = SCOPE_IDENTITY()
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role])  VALUES (@MenuItem, @Role)


INSERT INTO [Indico].[dbo].[MenuItem] ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES( @Page, 'Fabric Types', 'Fabric Types', 1, @MenuItem ,1, 1)

SET @Child = SCOPE_IDENTITY()     

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role])  VALUES (@Child, @Role)
GO


--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

/****** Object:  StoredProcedure [dbo].[SPC_CreatePackingList]    Script Date: 12/10/2013 14:43:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_CreatePackingList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_CreatePackingList]
GO

/****** Object:  StoredProcedure [dbo].[SPC_CreatePackingList]    Script Date: 12/10/2013 14:43:06 ******/
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
						   (0
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

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

/****** Object:  View [dbo].[PackingListView]    Script Date: 12/12/2013 11:17:40 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[PackingListView]'))
DROP VIEW [dbo].[PackingListView]
GO

/****** Object:  View [dbo].[PackingListView]    Script Date: 12/12/2013 11:15:19 ******/
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
	   ,0 AS ScannedTotal,
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

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

/****** Object:  StoredProcedure [dbo].[SPC_GetPackingListDetails]    Script Date: 12/12/2013 11:40:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetPackingListDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetPackingListDetails]
GO


/****** Object:  StoredProcedure [dbo].[SPC_GetPackingListDetails]    Script Date: 12/12/2013 10:55:30 ******/
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
		   ISNULL((SELECT SUM([Count]) FROM [dbo].[PackingListCartonItem] WHERE PackingList = pl.ID),0) AS ScannedTotal,
		   ISNULL(o.[ShipmentMode], 0) AS ShimentModeID,
			ISNULL(shm.[Name], 'AIR') AS ShipmentMode,
			ISNULL(dca.[CompanyName], '') AS 'CompanyName',
			dca.[Address] AS 'Address',
			dca.[Suburb]  AS 'Suberb' ,
			ISNULL(dca.[State],'') AS 'State',
			dca.[PostCode]  AS 'PostCode',			 
			coun.[ShortName] AS 'Country',
			dca.[ContactName] + ' ' + dca.[ContactPhone] AS 'ContactDetails',
			o.[IsWeeklyShipment] AS 'IsWeeklyShipment',
			[IsAdelaideWareHouse] AS 'IsAdelaideWareHouse',
			ISNULL(o.[DespatchToExistingClient], 0) AS 'ShipTo'		
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
		JOIN [dbo].[ShipmentMode] shm
			ON o.[ShipmentMode] = shm.[ID] 	
		JOIN [dbo].[DistributorClientAddress] dca
			ON o.[DespatchToExistingClient] = dca.[ID]
		JOIN [dbo].[Country] coun
			ON dca.[Country] = coun.[ID]		
	WHERE od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate
	ORDER BY pl.[CartonNo] ASC
END



GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

DECLARE @Page As int 
DECLARE @ParentPage AS int 
DECLARE @Parent AS int 
DECLARE @MenuItem AS int 
DECLARE @Position AS int
DECLARE @Role AS int

INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/ViewCartons.aspx', 'Cartons', 'Cartons')

SET @Page = SCOPE_IDENTITY()


SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')

SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)

SET @Position = (SELECT MAX([Position]) + 1 FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [Indico].[dbo].[MenuItem] ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible]) VALUES (@Page, 'Cartons', 'Cartons', 1, @Parent, @Position, 0)

SET @MenuItem = SCOPE_IDENTITY()


SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')


INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role])  VALUES (@MenuItem, @Role)


SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')


INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role])  VALUES (@MenuItem, @Role)
GO

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

