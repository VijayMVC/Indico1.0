USE [Indico]
GO

ALTER TABLE [dbo].[Pattern]
ALTER COLUMN [PatternNotes] [nvarchar](255) NULL
GO

ALTER TABLE [dbo].[Pattern]
ALTER COLUMN [Description] [nvarchar](1024) NULL
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

/****** Object:  StoredProcedure [dbo].[SPC_ViewPatternDetails]    Script Date: 10/23/2014 10:55:52 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewPatternDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewPatternDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewPatternDetails]    Script Date: 10/23/2014 10:55:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SPC_ViewPatternDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',
	@P_MaxRows AS int = 20,
	@P_Set AS int = 0,
	@P_Sort AS int = 0, --0 Number, --1 NickName, --2 Gender, --3 ItemName, --4 SubItem, --5 AgeGroup, --6 Category, --7 specstatus
	@P_OrderBy AS bit = 0,  -- 0 ASC , -- 1 DESC
	@P_RecCount int OUTPUT,
	@P_Blackchrome AS int =  2,
	@P_GarmentStatus AS NVARCHAR(255) = '',
	@P_PatternStatus AS int = 2
)
AS
BEGIN
	
	-- Get the patterns	
	SET NOCOUNT ON
	DECLARE @StartOffset int;
	SET @StartOffset = (@P_Set - 1) * @P_MaxRows;	    
	
		SELECT  
			
			CONVERT(int, ROW_NUMBER() OVER (
			ORDER BY 
				CASE 
					WHEN (@p_Sort = 0 AND @p_OrderBy = 0) THEN p.[Number]
				END ASC,
				CASE						
					WHEN (@p_Sort = 0 AND @p_OrderBy = 1) THEN p.[Number]
				END DESC,
				CASE 
					WHEN (@p_Sort = 1 AND @p_OrderBy = 0) THEN p.[NickName]
				END ASC,
				CASE						
					WHEN (@p_Sort = 1 AND @p_OrderBy = 1) THEN p.[NickName]
				END DESC,	
				CASE 
					WHEN (@p_Sort = 2 AND @p_OrderBy = 0) THEN g.[Name]
				END ASC,
				CASE						
					WHEN (@p_Sort = 2 AND @p_OrderBy = 1) THEN g.[Name]
				END DESC,
				CASE 
					WHEN (@p_Sort = 3 AND @p_OrderBy = 0) THEN i.[Name]
				END ASC,
				CASE						
					WHEN (@p_Sort = 3 AND @p_OrderBy = 1) THEN i.[Name]
				END DESC,	
				CASE 
					WHEN (@p_Sort = 4 AND @p_OrderBy = 0) THEN si.[Name]
				END ASC,
				CASE						
					WHEN (@p_Sort = 4 AND @p_OrderBy = 1) THEN si.[Name]
				END DESC,
				CASE 
					WHEN (@p_Sort = 5 AND @p_OrderBy = 0) THEN ag.[Name]
				END ASC,
				CASE						
					WHEN (@p_Sort = 5 AND @p_OrderBy = 1) THEN ag.[Name]
				END DESC,
				CASE 
					WHEN (@p_Sort = 6 AND @p_OrderBy = 0) THEN c.[Name]
				END ASC,
				CASE						
					WHEN (@p_Sort = 6 AND @p_OrderBy = 1) THEN c.[Name]
				END DESC,
				CASE 
					WHEN (@p_Sort = 7 AND @p_OrderBy = 0) THEN p.[GarmentSpecStatus]
				END ASC,
				CASE						
					WHEN (@p_Sort = 7 AND @p_OrderBy = 1) THEN p.[GarmentSpecStatus]
				END DESC		
				)) AS ID,
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
				ISNULL(p.[HTSCode], '') AS HTSCode,
				ISNULL(p.[SMV], 0.00) AS SMV,
				ISNULL(p.[Description], '') AS MarketingDescription,
			    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (pat.[Parent]) FROM [dbo].[Pattern] pat WHERE pat.[Parent] = p.[ID])) THEN 1 ELSE 0 END)) AS PatternParent,
			    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (r.[Pattern]) FROM [dbo].[Reservation] r WHERE r.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS Reservation,
			    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (pr.[Pattern]) FROM [dbo].[Price] pr WHERE pr.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS Price,
			    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (pti.[Pattern]) FROM [dbo].[PatternTemplateImage] pti WHERE pti.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS PatternTemplateImage,
			    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (prod.[Pattern]) FROM [dbo].[Product] prod WHERE prod.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS Product,
			    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (od.[Pattern]) FROM [dbo].[OrderDetail] od WHERE od.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS OrderDetail,
			    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (v.[Pattern]) FROM [dbo].[VisualLayout] v WHERE v.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS VisualLayout
		 FROM [dbo].[Pattern] p
			JOIN [dbo].[Item] i
				ON p.[Item]= i.[ID]
			LEFT OUTER JOIN [dbo].[Item] si
				ON p.[SubItem] = si.[ID]
			JOIN [dbo].[Gender] g
				ON p.[Gender] = g.[ID]
			LEFT OUTER JOIN [dbo].[AgeGroup] ag
				ON p.[AgeGroup] = ag.[ID]
			JOIN [dbo].[SizeSet] ss
				ON p.[SizeSet] = ss.[ID]
			JOIN [dbo].[Category] c
				ON p.[CoreCategory] = c.[ID]
			JOIN [dbo].[PrinterType] pt
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
	
		SET @P_RecCount = 0
	
END


GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

/****** Object:  View [dbo].[ReturnPatternDetailsView]    Script Date: 10/23/2014 11:04:28 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnPatternDetailsView]'))
DROP VIEW [dbo].[ReturnPatternDetailsView]
GO

/****** Object:  View [dbo].[ReturnPatternDetailsView]    Script Date: 10/23/2014 11:04:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[ReturnPatternDetailsView]
AS
	SELECT 
		0 AS Pattern,
		'' AS Item,
		'' AS SubItem,
		'' AS Gender,
		'' AS AgeGroup,
		'' AS SizeSet,
		'' AS CoreCategory,
		'' AS PrinterType,
		'' AS Number,
		'' AS OriginRef,
		'' AS NickName,
		'' AS Keywords,
		'' AS CorePattern,
		'' AS FactoryDescription,
		'' AS Consumption,
		0.0 AS ConvertionFactor,
		'' AS SpecialAttributes,
		'' AS PatternNotes,
		'' AS PriceRemarks,
		CONVERT(bit,0)AS IsActive,
		0 AS Creator,
		GETDATE() AS CreatedDate,
		0 AS Modifier,
		GETDATE() AS ModifiedDate,
		'' AS Remarks,
		CONVERT(bit,0)AS IsTemplate,
		0 AS Parent,
		'' AS GarmentSpecStatus,
		CONVERT(bit,0)AS IsActiveWS,		
		'' AS HTSCode,
		0.0 AS SMV,
		'' AS MarketingDescription,
		CONVERT(bit,0)AS PatternParent,		
		CONVERT(bit,0)AS Reservation,		
		CONVERT(bit,0)AS Price,		
		CONVERT(bit,0)AS PatternTemplateImage,	
		CONVERT(bit,0)AS Product,	
		CONVERT(bit,0)AS OrderDetail,
		CONVERT(bit,0)AS VisualLayout

GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

DECLARE @Page AS int
DECLARE @Parent AS int
DECLARE @Role AS int
DECLARE @Postion AS int


SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPatterns.aspx')

SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

SET @Postion = (SELECT MAX([Position]) + 1 FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)


INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/ViewDescriptionGrid.aspx', 'Pattern Descriptions Grid', 'Pattern Descriptions Grid')


INSERT INTO [Indico].[dbo].[MenuItem] ([Page],[Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES (SCOPE_IDENTITY(), 'Pattern Descriptions Grids', 'Pattern Descriptions Grid', 1, @Parent, @Postion, 1)

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (SCOPE_IDENTITY(),@Role)
GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
DECLARE @ParentPage AS int 
DECLARE @Page AS int
DECLARE @Parent AS int
DECLARE @Role AS int
DECLARE @MenuItem AS int

SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPatterns.aspx')

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewDescriptionGrid.aspx')

SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indico Pattern Developer')

SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent) 

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem,@Role)
GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

DECLARE @ParentPage AS int 
DECLARE @Page AS int
DECLARE @Parent AS int
DECLARE @Role AS int
DECLARE @MenuItem AS int

SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPatterns.aspx')

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewDescriptionGrid.aspx')

SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')

SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent) 

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem,@Role)
GO
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
/****** Object:  StoredProcedure [dbo].[SPC_GetPackingListDetails]    Script Date: 10/24/2014 11:11:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetPackingListDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetPackingListDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetPackingListDetails]    Script Date: 10/24/2014 11:11:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_GetPackingListDetails] (	
@P_WeekEndDate datetime2(7),
@P_ShipmentMode AS int = 0 ,
@P_ShipmentAddress AS int = 0
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
		   ISNULL((SELECT COUNT([Count]) FROM [dbo].[PackingListCartonItem] WHERE PackingList = pl.ID),0) AS ScannedTotal,
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
	WHERE (wpc.[WeekendDate] = @P_WeekEndDate) AND
		  (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate))) AND
		  (@P_ShipmentMode = 0 OR o.[ShipmentMode] = @P_ShipmentMode) AND 
		  (@P_ShipmentAddress = 0 OR o.[DespatchToExistingClient] = @P_ShipmentAddress)
	ORDER BY pl.[CartonNo] ASC
END
GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
