USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewPatternDetails]    Script Date: 05/23/2013 12:48:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewPatternDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewPatternDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewPatternDetails]    Script Date: 05/23/2013 12:48:44 ******/
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
	    
	WITH Patterns AS 
	(
		SELECT  
			DISTINCT TOP (@P_Set * @P_MaxRows)
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
	)
	
	SELECT * FROM Patterns WHERE ID > @StartOffset
	
	IF @P_Set = 1
	BEGIN	
		SELECT @P_RecCount = COUNT (pa.ID)
		FROM (
			SELECT DISTINCT	p.ID
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
			)pa			
	END
	ELSE
	BEGIN
		SET @P_RecCount = 0
	END	
END
GO

/****** Object:  View [dbo].[ReturnPatternDetailsView]    Script Date: 05/23/2013 14:24:15 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnPatternDetailsView]'))
DROP VIEW [dbo].[ReturnPatternDetailsView]
GO

/****** Object:  View [dbo].[ReturnPatternDetailsView]    Script Date: 05/23/2013 14:24:15 ******/
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
		CONVERT(bit,0)AS PatternParent,		
		CONVERT(bit,0)AS Reservation,		
		CONVERT(bit,0)AS Price,		
		CONVERT(bit,0)AS PatternTemplateImage,	
		CONVERT(bit,0)AS Product,	
		CONVERT(bit,0)AS OrderDetail,
		CONVERT(bit,0)AS VisualLayout
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewVisualLayoutDetails]    Script Date: 05/30/2013 09:44:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewVisualLayoutDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewVisualLayoutDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewVisualLayoutDetails]    Script Date: 05/30/2013 09:44:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_ViewVisualLayoutDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',
	@P_MaxRows AS int = 20,
	@P_Set AS int = 0,
	@P_Sort AS int = 0, --0 CreatedDate,--1 Name, --2 Pattern, --3 Fabric, --4 Client, --5 Distributor, --6 Coordinator
	@P_OrderBy AS bit = 1,  -- 0 ASC , -- 1 DESC
	@P_RecCount int OUTPUT,
	@P_Coordinator AS NVARCHAR(255) = '',
	@P_Distributor AS NVARCHAR(255) = '',
	@P_Client AS NVARCHAR(255) = '',
	@P_IsCommon AS int = 2
)
AS
BEGIN
	-- Get the patterns	
	SET NOCOUNT ON
	DECLARE @StartOffset int;
	SET @StartOffset = (@P_Set - 1) * @P_MaxRows;
	
	WITH VisualLayout AS
	(
		SELECT 
			DISTINCT TOP (@P_Set * @P_MaxRows)
			CONVERT(int, ROW_NUMBER() OVER (
			ORDER BY 
				CASE 
					WHEN (@p_Sort = 0 AND @p_OrderBy = 0) THEN v.[CreatedDate]
				END ASC,
				CASE						
					WHEN (@p_Sort = 0 AND @p_OrderBy = 1) THEN v.[CreatedDate]
				END DESC,
				CASE 
					WHEN (@p_Sort = 1 AND @p_OrderBy = 0) THEN v.[NamePrefix]
				END ASC,
				CASE						
					WHEN (@p_Sort = 1 AND @p_OrderBy = 1) THEN v.[NamePrefix]
				END DESC,
				CASE 
					WHEN (@p_Sort = 2 AND @p_OrderBy = 0) THEN p.[Number]
				END ASC,
				CASE						
					WHEN (@p_Sort = 2 AND @p_OrderBy = 1) THEN p.[Number]
				END DESC,	
				CASE 
					WHEN (@p_Sort = 3 AND @p_OrderBy = 0) THEN f.[Name]
				END ASC,
				CASE						
					WHEN (@p_Sort = 3 AND @p_OrderBy = 1) THEN f.[Name]
				END DESC,
				CASE 
					WHEN (@p_Sort = 4 AND @p_OrderBy = 0) THEN c.[Name]
				END ASC,
				CASE						
					WHEN (@p_Sort = 4 AND @p_OrderBy = 1) THEN c.[Name]
				END DESC,	
				CASE 
					WHEN (@p_Sort = 5 AND @p_OrderBy = 0) THEN d.[Name]
				END ASC,
				CASE						
					WHEN (@p_Sort = 5 AND @p_OrderBy = 1) THEN d.[Name]
				END DESC,
				CASE 
					WHEN (@p_Sort = 6 AND @p_OrderBy = 0) THEN u.[GivenName]
				END ASC,
				CASE						
					WHEN (@p_Sort = 6 AND @p_OrderBy = 1) THEN u.[GivenName]
				END DESC					
				)) AS ID,
			   v.[ID] AS VisualLayout,
			   v.[NamePrefix] + '' + ISNULL(CAST(v.[NameSuffix] AS NVARCHAR(64)), '') AS Name,
			   ISNULL(v.[Description], '') AS 'Description',
			   p.[Number] AS Pattern,
			   f.[Name] AS Fabric,
			   ISNULL(c.[Name], '') AS Client,
			   ISNULL(d.[Name], '') AS Distributor,
			   ISNULL(u.[GivenName] + ' '+ u.[FamilyName], '') AS Coordinator,
			   ISNULL(v.[NNPFilePath], '') AS NNPFilePath,
			   v.[CreatedDate] AS CreatedDate,
			   v.[IsCommonProduct] AS IsCommonProduct,
			  CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (od.[VisualLayout]) FROM [dbo].[OrderDetail] od WHERE od.[VisualLayout] = v.[ID])) THEN 1 ELSE 0 END)) AS OrderDetails
		FROM [dbo].[VisualLayout] v
			JOIN [dbo].[Pattern] p
				ON v.[Pattern] = p.[ID]
			JOIN [dbo].[FabricCode] f
				ON v.[FabricCode] = f.[ID]
			LEFT OUTER JOIN [dbo].[Client] c
				ON v.[Client] = c.[ID]
			LEFT OUTER JOIN [dbo].[Company] d
				ON c.[Distributor] = d.[ID]
			LEFT OUTER JOIN [dbo].[User] u
				ON d.[Coordinator] = u.[ID]
		WHERE (@P_SearchText = '' OR
			   v.[NamePrefix]  LIKE '%' + @P_SearchText + '%' OR
			   v.[NameSuffix]  LIKE '%' + @P_SearchText + '%' OR
			   v.[Description] LIKE '%' + @P_SearchText + '%' OR
			   p.[Number] LIKE '%' + @P_SearchText + '%' OR
			   c.[Name] LIKE '%' + @P_SearchText + '%' OR
			   d.[Name] LIKE '%' + @P_SearchText + '%' OR
			   u.[GivenName] LIKE '%' + @P_SearchText + '%' OR
			   u.[FamilyName] LIKE '%' + @P_SearchText + '%')
			   AND (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName])  LIKE + '%' + @P_Coordinator + '%')
			   AND(@P_Distributor = '' OR  d.[Name] LIKE '%' + @P_Distributor + '%')
			   AND(@P_Client = '' OR c.[Name] LIKE '%' + @P_SearchText + '%')
			   AND(@P_IsCommon = 2 OR v.[IsCommonProduct] = CONVERT(bit,@P_IsCommon))			   
		)
	SELECT * FROM VisualLayout WHERE ID > @StartOffset
	
	IF @P_Set = 1
	BEGIN	
		SELECT @P_RecCount = COUNT (vl.ID)
		FROM (
			SELECT DISTINCT	v.ID
		FROM [dbo].[VisualLayout] v
			JOIN [dbo].[Pattern] p
				ON v.[Pattern] = p.[ID]
			JOIN [dbo].[FabricCode] f
				ON v.[FabricCode] = f.[ID]
			LEFT OUTER JOIN [dbo].[Client] c
				ON v.[Client] = c.[ID]
			LEFT OUTER JOIN [dbo].[Company] d
				ON c.[Distributor] = d.[ID]
			LEFT OUTER JOIN [dbo].[User] u
				ON d.[Coordinator] = u.[ID]
		WHERE (@P_SearchText = '' OR
			   v.[NamePrefix]  LIKE '%' + @P_SearchText + '%' OR
			   v.[NameSuffix]  LIKE '%' + @P_SearchText + '%' OR
			   v.[Description] LIKE '%' + @P_SearchText + '%' OR
			   p.[Number] LIKE '%' + @P_SearchText + '%' OR
			   c.[Name] LIKE '%' + @P_SearchText + '%' OR
			   d.[Name] LIKE '%' + @P_SearchText + '%' OR
			   u.[GivenName] LIKE '%' + @P_SearchText + '%' OR
			   u.[FamilyName] LIKE '%' + @P_SearchText + '%')
			   AND (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE + '%' + @P_Coordinator + '%')
			   AND(@P_Distributor = '' OR  d.[Name] LIKE +'%' + @P_Distributor + '%')
			   AND(@P_Client = '' OR c.[Name] LIKE +'%' + @P_SearchText + '%')
			   AND(@P_IsCommon = 2 OR v.[IsCommonProduct] = CONVERT(bit,@P_IsCommon))	
		)vl
	END
	ELSE
	BEGIN
		SET @P_RecCount = 0
	END
END
GO


/****** Object:  View [dbo].[ReturnVisualLayoutDetailsView]    Script Date: 05/30/2013 11:33:17 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnVisualLayoutDetailsView]'))
DROP VIEW [dbo].[ReturnVisualLayoutDetailsView]
GO

/****** Object:  View [dbo].[ReturnVisualLayoutDetailsView]    Script Date: 05/30/2013 11:33:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnVisualLayoutDetailsView]
AS
	SELECT 
		0 AS VisualLayout,
		'' AS Name,
		'' AS 'Description',
		'' AS Pattern,
		'' AS Fabric,
		'' AS Client,
		'' AS Distributor,
		'' AS Coordinator,
		'' AS NNPFilePath,
		GETDATE() AS CreatedDate,
		CONVERT(bit,0)AS IsCommonProduct,
		CONVERT(bit,0)AS OrderDetails

GO


/****** Object:  StoredProcedure [dbo].[SPC_ViewDistributorsDetails]    Script Date: 05/30/2013 15:50:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewDistributorsDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewDistributorsDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewDistributorDetails]    Script Date: 05/30/2013 13:07:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_ViewDistributorsDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',
	@P_MaxRows AS int = 20,
	@P_Set AS int = 0,
	@P_Sort AS int = 0, --0 Name, --1 NickName, --2 PrimaryCoordinator, --3 SecondaryCoordinator
	@P_OrderBy AS bit = 0,  -- 0 ASC , -- 1 DESC
	@P_RecCount int OUTPUT,
	@P_PCoordinator AS NVARCHAR(255) = '',
	@P_SCoordinator AS NVARCHAR(255) = ''
)
AS
BEGIN

	SET NOCOUNT ON
	DECLARE @StartOffset int;
	SET @StartOffset = (@P_Set - 1) * @P_MaxRows;
 -- Get Distributor Details	
	WITH Distributors AS
	(
			SELECT 
				DISTINCT TOP (@P_Set * @P_MaxRows)
				CONVERT(int, ROW_NUMBER() OVER (
				ORDER BY 
					CASE 
						WHEN (@p_Sort = 0 AND @p_OrderBy = 0) THEN d.[Name]
					END ASC,
					CASE						
						WHEN (@p_Sort = 0 AND @p_OrderBy = 1) THEN d.[Name]
					END DESC,
					CASE 
						WHEN (@p_Sort = 1 AND @p_OrderBy = 0) THEN d.[NickName]
					END ASC,
					CASE						
						WHEN (@p_Sort = 1 AND @p_OrderBy = 1) THEN d.[NickName]
					END DESC,
					CASE 
						WHEN (@p_Sort = 2 AND @p_OrderBy = 0) THEN u.[GivenName]
					END ASC,
					CASE						
						WHEN (@p_Sort = 2 AND @p_OrderBy = 1) THEN u.[GivenName]
					END DESC,	
					CASE 
						WHEN (@p_Sort = 3 AND @p_OrderBy = 0) THEN sc.[GivenName]
					END ASC,
					CASE						
						WHEN (@p_Sort = 3 AND @p_OrderBy = 1) THEN sc.[GivenName]
					END DESC		
					)) AS ID,
					d.[ID] AS Distributor,
					t.[Name] AS 'Type',
					d.[IsDistributor] AS IsDistributor,
					d.[Name] AS Name,					
					ISNULL(d.[Number],'') AS Number,
					ISNULL(d.[Address1], '') AS Address1,
					ISNULL(d.[Address2], '') AS Address2,
					ISNULL(d.[City], '') AS City,
					ISNULL(d.[State], '') AS 'State',
					ISNULL(d.[Postcode], '') AS Postcode,
					c.[ShortName] AS Country,
					ISNULL(d.[Phone1], '') AS Phone1,
					ISNULL(d.[Phone2], '') AS Phone2,
					ISNULL(d.[Fax], '') AS Fax,
					ISNULL(d.[NickName], '') AS NickName,
					ISNULL(u.[GivenName] +' '+ u.[FamilyName], 'No Coordinator') AS PrimaryCoordinator,
					ISNULL(ow.[GivenName] + ' ' + ow.[FamilyName], '') AS 'Owner',
					cr.[GivenName] + ' ' + cr.[FamilyName] AS 'Creator',
					cm.[GivenName] + ' ' + cm.[FamilyName] AS 'Modifier',
					d.[ModifiedDate] AS ModifiedDate, 
					d.[CreatedDate] AS CreatedDate,
					ISNULL(sc.[GivenName] +' '+ sc.[FamilyName], 'No Secondary Coordinator' ) AS SecondaryCoordinator,
					d.[IsActive] AS IsActive,
					d.[IsDelete] AS IsDelete,
				    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (cl.[Distributor]) FROM [dbo].[Client] cl WHERE cl.[Distributor] = d.[ID])) THEN 1 ELSE 0 END)) AS Clients,				   
				    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (dca.[Distributor]) FROM [dbo].[DistributorClientAddress] dca WHERE dca.[Distributor] = d.[ID])) THEN 1 ELSE 0 END)) AS DistributorClientAddresses,
				    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (dl.[Distributor]) FROM [dbo].[DistributorLabel] dl WHERE dl.[Distributor] = d.[ID])) THEN 1 ELSE 0 END)) AS DistributorLabels,
				    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (dplc.[ID]) FROM [dbo].[DistributorPriceLevelCost] dplc WHERE dplc.[Distributor] = d.[ID])) THEN 1 ELSE 0 END)) AS DistributorPriceLevelCosts,
				    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (dpm.[Distributor]) FROM [dbo].[DistributorPriceMarkup] dpm WHERE dpm.[Distributor] = d.[ID])) THEN 1 ELSE 0 END)) AS DistributorPriceMarkups,
				    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (od.[DespatchTo]) FROM [dbo].[Order] od WHERE od.[DespatchTo] = d.[ID])) THEN 1 ELSE 0 END)) AS DespatchTo,
				    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (o.[Distributor]) FROM [dbo].[Order] o WHERE o.[Distributor] = d.[ID])) THEN 1 ELSE 0 END)) AS 'Order',
				    CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (os.[ShipTo]) FROM [dbo].[Order] os WHERE os.[ShipTo] = d.[ID])) THEN 1 ELSE 0 END)) AS ShipTo			
			FROM [dbo].[Company] d
			LEFT OUTER JOIN [dbo].[User] u
				ON d.[Coordinator] = u.[ID]
			LEFT OUTER JOIN [dbo].[User] sc
				ON d.[SecondaryCoordinator] = sc.[ID]
			JOIN [dbo].[Country] c
				ON d.[Country] = c.[ID]
			JOIN [dbo].[CompanyType] t
				ON d.[Type] = t.[ID]
			LEFT OUTER JOIN [dbo].[User] ow
				ON d.[Owner] = ow.[ID]
			JOIN [dbo].[User] cr
				ON d.[Creator] = cr.[ID]
			JOIN [dbo].[User] cm
				ON d.[Modifier] = cm.[ID]			
			WHERE (d.[IsDistributor] = 1 AND
				   d.[IsActive] = 1 AND 
				   d.[IsDelete] = 0 AND (
				   @P_SearchText = '' OR
				   d.[Name] LIKE '%' + @P_SearchText + '%' OR
				   d.[NickName] LIKE '%' + @P_SearchText + '%' OR
				   (u.[GivenName] + ' ' + u.[FamilyName]) LIKE + '%' + @P_SearchText + '%' OR
				   (sc.[GivenName] + ' ' + sc.[FamilyName]) LIKE + '%' + @P_SearchText + '%'))
				   AND (@P_PCoordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE + '%' + @P_PCoordinator + '%' )
				   AND (@P_SCoordinator = '' OR (sc.[GivenName] + ' ' + sc.[FamilyName]) LIKE + '%' + @P_SCoordinator + '%')
				   
	)
	SELECT * FROM Distributors WHERE ID > @StartOffset
	
	---- Send the total
	IF @P_Set = 1
	BEGIN	
		SELECT @P_RecCount = COUNT (di.ID)
		FROM (
	SELECT 	d.[ID] AS ID						
			FROM [dbo].[Company] d
			LEFT OUTER JOIN [dbo].[User] u
				ON d.[Coordinator] = u.[ID]
			LEFT OUTER JOIN [dbo].[User] sc
				ON d.[SecondaryCoordinator] = sc.[ID]
			JOIN [dbo].[Country] c
				ON d.[Country] = c.[ID]
			JOIN [dbo].[CompanyType] t
				ON d.[Type] = t.[ID]
			LEFT OUTER JOIN [dbo].[User] ow
				ON d.[Owner] = ow.[ID]
			JOIN [dbo].[User] cr
				ON d.[Creator] = cr.[ID]
			JOIN [dbo].[User] cm
				ON d.[Modifier] = cm.[ID]			
			WHERE (d.[IsDistributor] = 1 AND
				   d.[IsActive] = 1 AND 
				   d.[IsDelete] = 0 AND (
				   @P_SearchText = '' OR
				   d.[Name] LIKE '%' + @P_SearchText + '%' OR
				   d.[NickName] LIKE '%' + @P_SearchText + '%' OR
				   (u.[GivenName] + ' ' + u.[FamilyName]) LIKE + '%' + @P_SearchText + '%' OR
				   (sc.[GivenName] + ' ' + sc.[FamilyName]) LIKE + '%' + @P_SearchText + '%'))
				    AND (@P_PCoordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE + '%' + @P_PCoordinator + '%' )
				    AND (@P_SCoordinator = '' OR (sc.[GivenName] + ' ' + sc.[FamilyName]) LIKE + '%' + @P_SCoordinator + '%')
				  )di
	END
	ELSE
	BEGIN
		SET @P_RecCount = 0
	END
	
END

GO

/****** Object:  View [dbo].[ReturnDistributorDetailsView]    Script Date: 05/30/2013 13:14:35 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnDistributorDetailsView]'))
DROP VIEW [dbo].[ReturnDistributorDetailsView]
GO

/****** Object:  View [dbo].[ReturnDistributorDetailsView]    Script Date: 05/30/2013 13:14:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ReturnDistributorDetailsView]
AS
	SELECT 
		0 AS Distributor,
		'' AS 'Type',
		CONVERT(bit,0)AS IsDistributor,		
		'' AS Name,		
		'' AS Number,
		'' AS Address1,
		'' AS Address2,
		'' AS City,
		'' AS 'State',
		'' AS PostCode,
		'' AS Country,
		'' AS Phone1,
		'' AS Phone2,
		'' AS Fax,
		'' AS NickName,
		'' AS PrimaryCoordinator,
		'' AS 'Owner',
		'' AS 'Creator',
		GETDATE() AS CreatedDate,
		'' AS Modifier,
		GETDATE() AS ModifiedDate,
		'' AS SecondaryCoordinator,
		CONVERT(bit,0)AS IsActive,
		CONVERT(bit,0)AS IsDelete,
		CONVERT(bit,0)AS Clients,
		CONVERT(bit,0)AS DistributorClientAddresses,
		CONVERT(bit,0)AS DistributorLabels,
		CONVERT(bit,0)AS DistributorPriceLevelCosts,
		CONVERT(bit,0)AS DistributorPriceMarkups,
		CONVERT(bit,0)AS DespatchTo,
		CONVERT(bit,0)AS 'Order',
		CONVERT(bit,0)AS ShipTo	
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewClientsDetails]    Script Date: 05/30/2013 15:30:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewClientsDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewClientsDetails]
GO
/****** Object:  StoredProcedure [dbo].[SPC_ViewClientsDetails]    Script Date: 05/30/2013 15:30:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_ViewClientsDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',
	@P_MaxRows AS int = 20,
	@P_Set AS int = 0,
	@P_Sort AS int = 0, --0 Name, --1 Distributor, --2 Country, --3 City, --4 Email, --5 Phone
	@P_OrderBy AS bit = 0,  -- 0 ASC , -- 1 DESC
	@P_RecCount int OUTPUT,
	@P_Distributor AS NVARCHAR(255) = ''
)
AS
BEGIN 
	SET NOCOUNT ON
	DECLARE @StartOffset int;
	SET @StartOffset = (@P_Set - 1) * @P_MaxRows;
	-- Get Clients Details	
	 WITH Clients AS
	 (
		SELECT 
			DISTINCT TOP (@P_Set * @P_MaxRows)
			CONVERT(int, ROW_NUMBER() OVER (
			ORDER BY 
				CASE 
					WHEN (@p_Sort = 0 AND @p_OrderBy = 0) THEN c.[Name]
				END ASC,
				CASE						
					WHEN (@p_Sort = 0 AND @p_OrderBy = 1) THEN c.[Name]
				END DESC,
				CASE 
					WHEN (@p_Sort = 1 AND @p_OrderBy = 0) THEN d.[Name]
				END ASC,
				CASE						
					WHEN (@p_Sort = 1 AND @p_OrderBy = 1) THEN d.[Name]
				END DESC,
				CASE 
					WHEN (@p_Sort = 2 AND @p_OrderBy = 0) THEN c.[Country]
				END ASC,
				CASE						
					WHEN (@p_Sort = 2 AND @p_OrderBy = 1) THEN c.[Country]
				END DESC,	
				CASE 
					WHEN (@p_Sort = 3 AND @p_OrderBy = 0) THEN c.[City]
				END ASC,
				CASE						
					WHEN (@p_Sort = 3 AND @p_OrderBy = 1) THEN c.[City]
				END DESC,
				CASE 
					WHEN (@p_Sort = 4 AND @p_OrderBy = 0) THEN c.[Email]
				END ASC,
				CASE						
					WHEN (@p_Sort = 4 AND @p_OrderBy = 1) THEN c.[Email]
				END DESC,	
				CASE 
					WHEN (@p_Sort = 5 AND @p_OrderBy = 0) THEN c.[Phone]
				END ASC,
				CASE						
					WHEN (@p_Sort = 5 AND @p_OrderBy = 1) THEN c.[Phone]
				END DESC		
				)) AS ID,
			   c.[ID] AS Client,
			   d.[Name] AS Distributor, 	   
			   c.[Name] AS Name	,
			   c.[Address] AS 'Address',
			   c.[Name] AS NickName,
			   c.[City] AS City,
			   c.[State] AS 'State',
			   c.[PostalCode] AS PostalCode,			   
			   ISNULL(c.[Country], 'Australia')AS Country,			     
			   c.[Phone] AS Phone,
			   c.[Email] AS Email,
			   u.[GivenName] + ' ' + u.[FamilyName] AS Creator,
			   c.[CreatedDate] AS CreatedDate  ,
			   um.[GivenName] + ' ' + um.[FamilyName] AS Modifier,
			   c.[ModifiedDate] AS ModifiedDate,
			   CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (v.[Client]) FROM [dbo].[VisualLayout] v WHERE v.[Client] = c.[ID])) THEN 1 ELSE 0 END)) AS VisualLayouts,
			   CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (o.[Client]) FROM [dbo].[Order] o WHERE o.[Client] = c.[ID])) THEN 1 ELSE 0 END)) AS 'Order',
			   CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (r.[Client]) FROM [dbo].[Reservation] r WHERE r.[Client] = c.[ID])) THEN 1 ELSE 0 END)) AS Reservation
		FROM [dbo].[Client] c
		JOIN [dbo].[Company] d
			ON c.[Distributor] = d.[ID]
		JOIN [dbo].[User] u
			ON c.[Creator] = u.[ID]
		JOIN [dbo].[User] um
			ON c.[Modifier] = um.[ID]
		WHERE (@P_SearchText = '' OR
				c.[Name] LIKE '%' + @P_SearchText + '%' OR
				d.[Name] LIKE '%' + @P_SearchText + '%' OR
				c.[Country] LIKE '%' + @P_SearchText + '%' OR
				c.[Phone] LIKE '%' + @P_SearchText + '%' OR
				c.[Email] LIKE '%' + @P_SearchText + '%' OR  
				c.[City] LIKE '%' + @P_SearchText + '%')
				AND (@P_Distributor = '' OR d.[Name] LIKE '%' + @P_Distributor + '%')
	)
	SELECT * FROM Clients WHERE ID > @StartOffset
	
	IF @P_Set = 1
	BEGIN	
		SELECT @P_RecCount = COUNT (cl.ID)
		FROM (
			SELECT DISTINCT	c.ID
			FROM [dbo].[Client] c
		JOIN [dbo].[Company] d
			ON c.[Distributor] = d.[ID]
		JOIN [dbo].[User] u
			ON c.[Creator] = u.[ID]
		JOIN [dbo].[User] um
			ON c.[Modifier] = um.[ID]
		WHERE (@P_SearchText = '' OR
				c.[Name] LIKE '%' + @P_SearchText + '%' OR
				d.[Name] LIKE '%' + @P_SearchText + '%' OR
				c.[Country] LIKE '%' + @P_SearchText + '%' OR
				c.[Phone] LIKE '%' + @P_SearchText + '%' OR
				c.[Email] LIKE '%' + @P_SearchText + '%' OR  
				c.[City] LIKE '%' + @P_SearchText + '%')
				AND (@P_Distributor = '' OR d.[Name] LIKE '%' + @P_Distributor + '%')			  
			  )cl
	END
	ELSE
	BEGIN
		SET @P_RecCount = 0
	END
END

GO

/****** Object:  View [dbo].[ReturnClientsDetailsView]    Script Date: 05/30/2013 15:43:08 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnClientsDetailsView]'))
DROP VIEW [dbo].[ReturnClientsDetailsView]
GO

/****** Object:  View [dbo].[ReturnClientsDetailsView]    Script Date: 05/30/2013 15:43:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ReturnClientsDetailsView]
AS
	SELECT 
		0 AS Client,	
		'' AS Distributor,		
		'' AS Name,
		'' AS 'Address',
		'' AS NickName,		
		'' AS City,
		'' AS 'State',
		'' AS PostalCode,		
		'' AS Country,
		'' AS Phone,		
		'' AS Email,		
		'' AS 'Creator',
		GETDATE() AS CreatedDate,
		'' AS Modifier,
		GETDATE() AS ModifiedDate,
		CONVERT(bit,0)AS VisualLayouts,
		CONVERT(bit,0)AS 'Order',
		CONVERT(bit,0)AS Reservation		
GO


/****** Object:  View [dbo].[ReturnDistributorPrimaryCoordinator]    Script Date: 06/04/2013 14:13:33 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnDistributorPrimaryCoordinator]'))
DROP VIEW [dbo].[ReturnDistributorPrimaryCoordinator]
GO

/****** Object:  View [dbo].[ReturnDistributorPrimaryCoordinator]   Script Date: 06/04/2013 14:13:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ReturnDistributorPrimaryCoordinator]
AS
SELECT  DISTINCT u.[ID],
		u.[GivenName] + ' ' + u.[FamilyName] AS Name 
FROM [dbo].[Company] c
	JOIN [dbo].[User] u
		ON c.[Coordinator] = u.[ID] 
		

GO

/****** Object:  View [dbo].[ReturnDistributorSecondaryCoordinator]    Script Date: 06/04/2013 14:14:08 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnDistributorSecondaryCoordinator]'))
DROP VIEW [dbo].[ReturnDistributorSecondaryCoordinator]
GO

/****** Object:  View [dbo].[ReturnDistributorSecondaryCoordinator]    Script Date: 06/04/2013 14:14:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReturnDistributorSecondaryCoordinator]
AS
SELECT  DISTINCT u.[ID],
		u.[GivenName] + ' ' + u.[FamilyName] AS Name 
FROM [dbo].[Company] c
	JOIN [dbo].[User] u
		ON c.[SecondaryCoordinator] = u.[ID] 
		

GO


--DELETE FROM [dbo].[OrderDetailQty]
--FROM [dbo].[OrderDetailQty] odq
--	JOIN [dbo].[OrderDetail] od
--		ON odq.[OrderDetail] = od.[ID]
--	JOIN [dbo].[Order] o
--		ON od.[Order] = o.[ID]
--GO

--DELETE FROM [dbo].[OrderDetail]
--FROM [dbo].[OrderDetail] od	
--	JOIN [dbo].[Order] o
--		ON od.[Order] = o.[ID]

--GO

--DELETE FROM [dbo].[Order]
--FROM [dbo].[Order] 

--GO

--DECLARE @nextID int
--SET @nextID = ISNULL((SELECT MAX(ID) FROM [dbo].[OrderDetailQty]), 0)
--DBCC CHECKIDENT('OrderDetailQty', RESEED, @nextID)
--GO

--DECLARE @nextID int
--SET @nextID = ISNULL((SELECT MAX(ID) FROM [dbo].[OrderDetail]), 0)
--DBCC CHECKIDENT('OrderDetail', RESEED, @nextID)
--GO

--DECLARE @nextID int
--SET @nextID = ISNULL((SELECT MAX(ID) FROM [dbo].[Order]), 0)
--DBCC CHECKIDENT('Order', RESEED, @nextID)
--GO

---***--**---***--**---***--**---***--** Add New Table Factory Order Detail ---***--**---***--**---***--**---***--**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FactoryOrderDetial_OrderDetail]') AND parent_object_id = OBJECT_ID(N'[dbo].[FactoryOrderDetial]'))
ALTER TABLE [dbo].[FactoryOrderDetial] DROP CONSTRAINT [FK_FactoryOrderDetial_OrderDetail]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FactoryOrderDetial_OrderDetailStatus]') AND parent_object_id = OBJECT_ID(N'[dbo].[FactoryOrderDetial]'))
ALTER TABLE [dbo].[FactoryOrderDetial] DROP CONSTRAINT [FK_FactoryOrderDetial_OrderDetailStatus]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FactoryOrderDetial_Size]') AND parent_object_id = OBJECT_ID(N'[dbo].[FactoryOrderDetial]'))
ALTER TABLE [dbo].[FactoryOrderDetial] DROP CONSTRAINT [FK_FactoryOrderDetial_Size]
GO

/****** Object:  Table [dbo].[FactoryOrderDetial]    Script Date: 06/10/2013 08:58:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FactoryOrderDetial]') AND type in (N'U'))
DROP TABLE [dbo].[FactoryOrderDetial]
GO

/****** Object:  Table [dbo].[FactoryOrderDetial]    Script Date: 06/10/2013 08:58:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FactoryOrderDetial](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderDetail] [int] NOT NULL,
	[OrderDetailStatus] [int] NOT NULL,
	[CompletedQty] [int] NULL,
	[StartedDate] [datetime2](7) NULL,
	[Size] [int] NOT NULL,
 CONSTRAINT [PK_FactoryOrderDetial] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FactoryOrderDetial]  WITH CHECK ADD  CONSTRAINT [FK_FactoryOrderDetial_OrderDetail] FOREIGN KEY([OrderDetail])
REFERENCES [dbo].[OrderDetail] ([ID])
GO

ALTER TABLE [dbo].[FactoryOrderDetial] CHECK CONSTRAINT [FK_FactoryOrderDetial_OrderDetail]
GO

ALTER TABLE [dbo].[FactoryOrderDetial]  WITH CHECK ADD  CONSTRAINT [FK_FactoryOrderDetial_OrderDetailStatus] FOREIGN KEY([OrderDetailStatus])
REFERENCES [dbo].[OrderDetailStatus] ([ID])
GO

ALTER TABLE [dbo].[FactoryOrderDetial] CHECK CONSTRAINT [FK_FactoryOrderDetial_OrderDetailStatus]
GO

ALTER TABLE [dbo].[FactoryOrderDetial]  WITH CHECK ADD  CONSTRAINT [FK_FactoryOrderDetial_Size] FOREIGN KEY([Size])
REFERENCES [dbo].[Size] ([ID])
GO

ALTER TABLE [dbo].[FactoryOrderDetial] CHECK CONSTRAINT [FK_FactoryOrderDetial_Size]
GO

---***--**---***--**---***--**---***--**---***--**---***--**---***--**---***--**---***--**---***--**---***--**


--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-** UPDATE OrderDetail Status Table --**-**-**-**--**-**-**-**--**-**-**-**
DECLARE @StatusID AS int

SET @StatusID = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Printing')

UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Start Printing', [Description] = 'Factory Start Printing' WHERE [ID] = @StatusID
GO

INSERT INTO [dbo].[OrderDetailStatus] ([Name], [Description], [Company], [Priority])
	 VALUES(
			'Print Completed',
			'Factory Printing Completed',
			2,
			3
		   )
GO	

DECLARE @StatusID AS int

SET @StatusID = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'HeatPress')

UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Start HeatPress', [Priority] = 4, [Description] = 'Factory Start HeatPress' WHERE [ID] = @StatusID
GO

INSERT INTO [dbo].[OrderDetailStatus] ([Name], [Description], [Company], [Priority])
	 VALUES(
			'HeatPress Completed',
			'Factory HeatPress Completed',
			2,
			5
		   )
GO

DECLARE @StatusID AS int

SET @StatusID = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Sewing')

UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Start Sewing', [Priority] = 6, [Description] = 'Factory Start Sewing' WHERE [ID] = @StatusID
GO

INSERT INTO [dbo].[OrderDetailStatus] ([Name], [Description], [Company], [Priority])
	 VALUES(
			'Sewing Completed',
			'Factory Sewing Completed',
			2,
			7
		   )
GO


DECLARE @StatusID AS int

SET @StatusID = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Packing')

UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Start Packing', [Description] = 'Factory Start Packing', [Priority] = 8 WHERE [ID] = @StatusID
GO

INSERT INTO [dbo].[OrderDetailStatus] ([Name], [Description], [Company], [Priority])
	 VALUES(
			'Packing Completed',
			'Factory Packing Completed',
			2,
			9
		   )
GO

DECLARE @StatusID AS int

SET @StatusID = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Shipped')

UPDATE [dbo].[OrderDetailStatus] SET [Name] = 'Start Shipping' , [Description] = 'Factory Shipping Start', [Priority] = 10 WHERE [ID] = @StatusID
GO

INSERT INTO [dbo].[OrderDetailStatus] ([Name], [Description], [Company], [Priority])
	 VALUES(
			'Shipping Completed',
			'Factory Shipping Completed',
			2,
			11
		   )
GO

DECLARE @StatusID AS int

SET @StatusID = (SELECT [ID] FROM [dbo].[OrderDetailStatus] WHERE [Name] = 'Completed')

UPDATE [dbo].[OrderDetailStatus] SET [Priority] = 12 WHERE [ID] = @StatusID
GO
 

--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**



