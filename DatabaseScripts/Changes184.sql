USE [Indico]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

-- Sales Grid Report

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
     VALUES ('/SalesGridReport.aspx','Sales Grid Report','Sales Grid Report')	 
SET @PageId = SCOPE_IDENTITY()

-- Parent Menu Item
SELECT @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Reports'

--Menu Item					
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Sales Grid Report', 'Sales Grid Report', 1, @MenuItemMenuId, 3, 1)
SET @MenuItemId = SCOPE_IDENTITY()

-- Menu Item Role
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoCoordinator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoAdministrator)

-- Page
INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/DrillDownReport.aspx','Drill Down Report','Drill Down Report')	 
SET @PageId = SCOPE_IDENTITY()

-- Parent Menu Item
SELECT @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Reports'

--Menu Item					
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Drill Down Report', 'Drill Down Report', 1, @MenuItemMenuId, 4, 0)
SET @MenuItemId = SCOPE_IDENTITY()

-- Menu Item Role
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoCoordinator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoAdministrator)

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

-- Update weekend Date -----------

UPDATE [dbo].[WeeklyProductionCapacity]
SET WeekendDate = DATEADD(day, 4,WeekendDate)

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--


/****** Object:  Table [dbo].[ProductionPlanning]    Script Date: 3/14/2016 9:48:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProductionPlanning](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WeeklyProductionCapacity] [int] NOT NULL,
	[OrderDetail] [int] NOT NULL,
	[ProductionLine] [int] NULL,
	[SewingDate] [datetime] NULL,
 CONSTRAINT [PK_ProductionPlanning] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductionPlanning', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'WeeklyProductionCapacity ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductionPlanning', @level2type=N'COLUMN',@level2name=N'WeeklyProductionCapacity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'OrderDetail ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductionPlanning', @level2type=N'COLUMN',@level2name=N'OrderDetail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ProductionLine ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductionPlanning', @level2type=N'COLUMN',@level2name=N'ProductionLine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sewing Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductionPlanning', @level2type=N'COLUMN',@level2name=N'SewingDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductionPlanning'
GO

--ALTER TABLE [dbo].[ProductionPlanning]
--    ADD CONSTRAINT PK_WeeklyProductionCapacity_OrderDetail PRIMARY KEY ([WeeklyProductionCapacity],[OrderDetail])
--GO

ALTER TABLE [dbo].[ProductionPlanning]  WITH CHECK ADD  CONSTRAINT [FK_ProductionPlanning_WeeklyProductionCapacity] FOREIGN KEY([WeeklyProductionCapacity])
REFERENCES [dbo].[WeeklyProductionCapacity] ([ID])
GO

ALTER TABLE [dbo].[ProductionPlanning] CHECK CONSTRAINT [FK_ProductionPlanning_WeeklyProductionCapacity]
GO

ALTER TABLE [dbo].[ProductionPlanning]  WITH CHECK ADD  CONSTRAINT [FK_ProductionPlanning_OrderDetail] FOREIGN KEY([OrderDetail])
REFERENCES [dbo].[OrderDetail] ([ID])
GO

ALTER TABLE [dbo].[ProductionPlanning] CHECK CONSTRAINT [FK_ProductionPlanning_OrderDetail]
GO

ALTER TABLE [dbo].[ProductionPlanning]  WITH CHECK ADD  CONSTRAINT [FK_ProductionPlanning_ProductionLine] FOREIGN KEY([ProductionLine])
REFERENCES [dbo].[ProductionLine] ([ID])
GO

ALTER TABLE [dbo].[ProductionPlanning] CHECK CONSTRAINT [FK_ProductionPlanning_ProductionLine]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

ALTER TABLE [dbo].Pattern ADD [ProductionLine] int NULL
GO

ALTER TABLE [dbo].[Pattern]  WITH CHECK ADD  CONSTRAINT [FK_Pattern_ProductionLine] FOREIGN KEY([ProductionLine])
REFERENCES [dbo].[ProductionLine] ([ID])
GO

ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_ProductionLine]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--


/****** Object:  StoredProcedure [dbo].[SPC_GetProductionPlanningDetails]    Script Date: 3/11/2016 4:18:49 PM ******/
DROP PROCEDURE [dbo].[SPC_GetProductionPlanningDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetProductionPlanningDetails]    Script Date: 3/11/2016 4:18:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_GetProductionPlanningDetails]
(
	@P_Week AS int = 0,
	@P_Year AS Int = 0
)
AS
BEGIN

	SET NOCOUNT ON
	
	DECLARE @WeekEndDate Datetime 
	DECLARE @WeeklyProductionCapacity int

	SELECT @WeekEndDate = [WeekendDate],
		@WeeklyProductionCapacity = wpc.ID
	FROM  [dbo].[WeeklyProductionCapacity] wpc
	WHERE [WeekNo] = @P_Week AND  YEAR(CONVERT(datetime,[WeekendDate],103)) = @P_Year
	
	-- Take to a temporary variable
	SELECT @WeeklyProductionCapacity AS WeeklyProductionCapacity		   	 
		   ,od.[ID] AS OrderDetail
		   ,( SELECT CASE  WHEN p2.ID IS NOT NULL
			THEN p2.ProductionLine
			ELSE
				p1.ProductionLine
			END ) AS ProductionLine
			,( SELECT CASE  WHEN p2.ID IS NOT NULL
			THEN p2.Number
			ELSE
				p1.Number
			END ) AS Pattern
			,ISNULL(vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),''), '') AS Product
			,( SELECT CASE  WHEN p2.ID IS NOT NULL
			THEN p2.SMV
			ELSE
				p1.SMV
			END ) AS SMV
			--,pl.SewingDate			
			INTO #tempProductionPlanning		
	FROM	[dbo].[Order] o
	INNER JOIN [dbo].[OrderDetail] od
		ON o.ID = od.[Order]			 
	LEFT OUTER JOIN [dbo].Pattern p1
		ON p1.ID = od.Pattern
	LEFT OUTER JOIN [dbo].VisualLayout vl
		ON vl.ID = od.VisualLayout
	LEFT OUTER JOIN [dbo].Pattern p2
		ON p2.ID = vl.Pattern
	--LEFT OUTER JOIN [dbo].ProductionPlanning pl
	--	ON od.ID = pl.OrderDetail 
	--		AND pl.WeeklyProductionCapacity = @WeeklyProductionCapacity
	WHERE o.[Status] != 28
		AND od.[Status] != 15
		AND od.ShipmentDate <= @WeekEndDate 
		AND od.ShipmentDate > DATEADD(day, -7, @WeekEndDate)
			
-- Insert new ones
	INSERT INTO [dbo].ProductionPlanning (WeeklyProductionCapacity, OrderDetail, ProductionLine)
	SELECT	@WeeklyProductionCapacity AS WeeklyProductionCapacity,
			t.OrderDetail,
			t.ProductionLine
	FROM #tempProductionPlanning t
		LEFT OUTER JOIN [dbo].ProductionPlanning pl
			ON t.OrderDetail = pl.OrderDetail 
				AND pl.WeeklyProductionCapacity = @WeeklyProductionCapacity
	  WHERE pl.OrderDetail IS NULL

	-- Delete removed ones
	DELETE	[dbo].ProductionPlanning 
	FROM	[dbo].ProductionPlanning pl				
			LEFT OUTER JOIN #tempProductionPlanning t 
		ON pl.OrderDetail = t.OrderDetail 
			AND pl.WeeklyProductionCapacity = @WeeklyProductionCapacity
	WHERE t.OrderDetail IS NULL	
			AND pl.WeeklyProductionCapacity = @WeeklyProductionCapacity 
	
	SELECT	t.WeeklyProductionCapacity,			
			CONVERT(nvarchar(255), @P_Year) + '/' +  CONVERT(nvarchar(255),@P_Week) AS [Week],
			od.[ID] AS OrderDetail,
			t.Pattern,
			ot.[Name] AS OrderType,
			ISNULL(o.[OldPONo], '') AS 'PurchaseOrder',	  		  
			t.Product,	
			(SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]) AS Quantity,
			t.SMV,  
			(		(	SELECT SUM(odq.[Qty]) 
							FROM [dbo].[OrderDetailQty] odq 
							WHERE odq.[OrderDetail] = od.[ID]) * 
						(t.SMV)
			) AS 'TotalSMV',
			cl.[Name] AS Client,		 		  
			ISNULL(sm.[Name], '') AS Mode,		 		  
			ISNULL(ddca.[CompanyName], '') AS ShipTo,
			ISNULL(ddp.[Name], '') AS Port,
			ISNULL(dco.ShortName, '') AS Country,
			ISNULL(pl.ProductionLine,0) AS ProductionLine,
			ISNULL(pl.SewingDate, '19000101') AS SewingDate,
			cl.FOCPenalty
	  FROM [dbo].[OrderDetail] od
		INNER JOIN #tempProductionPlanning t
			ON t.OrderDetail = od.ID
		INNER JOIN [dbo].[Productionplanning] pl
			ON t.OrderDetail = pl.OrderDetail
				AND t.WeeklyProductionCapacity = pl.WeeklyProductionCapacity
		INNER JOIN [dbo].[Order] o
			ON od.[Order] = o.ID
		LEFT OUTER JOIN [dbo].[JobName] j
			ON o.[Client] = j.[ID]
		LEFT OUTER JOIN [dbo].[Client] cl
			ON j.[Client] = cl.[ID]
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] ddca
			ON od.[DespatchTo] = ddca.[ID]
		LEFT OUTER JOIN [dbo].[Country] dco
			ON ddca.[Country] = dco.[ID]
		LEFT OUTER JOIN [dbo].[DestinationPort] ddp
			ON ddca.[Port] = ddp.[ID] 						
		LEFT OUTER JOIN [dbo].[ShipmentMode] sm
			ON od.[ShipmentMode] = sm.[ID]
		LEFT OUTER JOIN [dbo].[OrderType] ot
			ON od.[OrderType] = ot.[ID]	  
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  View [dbo].[ReturnProductionPlanningDetailsView]    Script Date: 3/11/2016 5:24:16 PM ******/
DROP VIEW [dbo].[ReturnProductionPlanningDetailsView]
GO

/****** Object:  View [dbo].[ReturnProductionPlanningDetailsView]    Script Date: 3/11/2016 5:20:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ReturnProductionPlanningDetailsView]
AS
			SELECT
					0 AS WeeklyProductionCapacity,
					'' AS [Week],
					0 AS OrderDetail,				 
					'' AS Pattern,
					'' AS OrderType,
					'' AS PurchaseOrder,
					'' AS Product,
					0 AS Quantity,
					0.0 AS SMV,
					0.0 AS TotalSMV,
					'' AS Client,      
					'' AS Mode,
					'' AS ShipTo,
					'' AS Port,
					'' Country,
					0 AS ProductionLine,
					GETDATE() AS SewingDate,
					CONVERT(bit,0) AS FOCPenalty
GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

-- Production planning page

DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

DECLARE @IndimanAdministrator int
DECLARE @FactoryAdministrator int
DECLARE @FactoryCoordinator int

SET @IndimanAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @FactoryAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')
SET @FactoryCoordinator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Factory Coordinator')

-- Page
INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/ViewProductionPlanningDetails.aspx','Production Planning Details','Production Planning Details')	 
SET @PageId = SCOPE_IDENTITY()

-- Parent Menu Item
SELECT @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Dashboard' AND Parent IS NULL

--Menu Item					
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Production Planning', 'Production Planning', 1, @MenuItemMenuId, 7, 1)
SET @MenuItemId = SCOPE_IDENTITY()

-- Menu Item Role
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @FactoryAdministrator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @FactoryCoordinator)
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_UpdateProductionPlanning]    Script Date: 3/14/2016 4:33:16 PM ******/
DROP PROCEDURE [dbo].[SPC_UpdateProductionPlanning]
GO

/****** Object:  StoredProcedure [dbo].[SPC_UpdateProductionPlanning]    Script Date: 3/14/2016 4:33:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_UpdateProductionPlanning]
(
	@P_WeeklyProductionCapacity int,
	@P_OrderDetail int,
	@P_ProductionLine int,
	@P_SewingDate datetime2(7)
)
AS 

BEGIN
	DECLARE @RetVal int
	
	BEGIN TRY

		IF (@P_ProductionLine>0)
		BEGIN
			UPDATE [dbo].ProductionPlanning
			SET ProductionLine = @P_ProductionLine
			WHERE WeeklyProductionCapacity = @P_WeeklyProductionCapacity AND OrderDetail = @P_OrderDetail
				
		END

		IF(@P_SewingDate != '00010101')
		BEGIN
			UPDATE [dbo].ProductionPlanning
			SET SewingDate = @P_SewingDate
			WHERE WeeklyProductionCapacity = @P_WeeklyProductionCapacity AND OrderDetail = @P_OrderDetail
		END
				
		SET @RetVal = 1
		
	END TRY
	BEGIN CATCH
	
		SET @RetVal = 0
		
	END CATCH
	SELECT @RetVal AS RetVal		
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange]    Script Date: 16-Mar-16 12:35:24 PM ******/
DROP PROCEDURE [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderQuantitiesAndAmountForDistributorsForGivenDateRange]    Script Date: 16-Mar-16 12:35:24 PM ******/
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

	SELECT MONTH(o.[Date]) AS 'Month', YEAR(o.[Date]) AS 'Year', c.ID, c.Name, SUM(odq.Qty) AS 'Quantity', SUM(odq.Qty * od.EditedPrice) AS 'Value' INTO #data
	FROM [dbo].[Company] c
		JOIN [dbo].[Order] o
			ON c.ID = o.Distributor
		JOIN [dbo].[OrderDetail] od
			ON o.ID = od.[Order]
		JOIN [dbo].[OrderDetailQty] odq
			ON od.ID = odq.OrderDetail
	WHERE IsDistributor = 1 and DistributorType = @P_DistributorType AND o.[Date] >= @P_StartDate AND o.[Date] <= @P_EndDate AND (@P_DistributorName = '' OR c.Name LIKE '%' + @P_DistributorName + '%')--AND (@P_Distributor = 0 OR c.ID = @P_Distributor)
	GROUP BY MONTH(o.[Date]), YEAR(o.[Date]), c.ID, c.Name
	
	--SELECT DATENAME( MONTH , DATEADD(MONTH , d.[Month] , -1)) + '-' + CAST(d.[Year] AS nvarchar(4)) AS 'MonthAndYear', 
	SELECT (SELECT RIGHT('0' + CONVERT(VARCHAR(2), d.[Month]), 2)),
			CAST(d.[Year] AS nvarchar(4)) + (SELECT RIGHT('0' + CONVERT(VARCHAR(2), d.[Month]), 2)) AS 'MonthAndYear', 
			d.ID,
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

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  View [dbo].[ReturnOrderQuantitiesAndAmount]    Script Date: 3/16/2016 6:11:28 PM ******/
DROP VIEW [dbo].[ReturnOrderQuantitiesAndAmount]
GO

/****** Object:  View [dbo].[ReturnOrderQuantitiesAndAmount]    Script Date: 3/16/2016 6:11:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ReturnOrderQuantitiesAndAmount]
AS

SELECT '' AS MonthAndYear,
	  0 AS ID,	
      '' AS Name,       
      0 AS Quantity,
	  0.0 AS QuantityPercentage,
	  0.0 AS Value,
	  0.0 AS ValuePercentage,
	  0.0 AS AvgPrice

GO