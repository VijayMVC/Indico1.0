USE [Indico]
GO


/****** Object:  View [dbo].[ReturnPatternDetailsView]    Script Date: 02/20/2015 16:51:21 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnPatternDetailsView]'))
DROP VIEW [dbo].[ReturnPatternDetailsView]
GO


/****** Object:  View [dbo].[ReturnPatternDetailsView]    Script Date: 02/20/2015 16:51:21 ******/
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
		CONVERT(bit,0)AS IsCoreRange,		
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


/****** Object:  StoredProcedure [dbo].[SPC_ViewPatternDetails]    Script Date: 02/20/2015 16:50:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewPatternDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewPatternDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewPatternDetails]    Script Date: 02/20/2015 16:50:47 ******/
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
				p.[IsCoreRange] AS IsCoreRange,
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

