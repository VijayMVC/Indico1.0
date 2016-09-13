USE [Indico]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetPatternDetails]    Script Date: 5/13/2016 1:49:03 PM ******/
DROP PROCEDURE [dbo].[SPC_GetPatternDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetPatternDetails]    Script Date: 5/13/2016 1:49:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_GetPatternDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',
	@P_MaxRows AS int = 20,
	@P_Set AS int = 1,
	@P_Sort AS int = 0, --0 corerange, --1 number, --2 Newest 	
	@P_CoreCategory AS int = 0, 
	@P_Category AS NVARCHAR(64) = '' -- mens, ladies, inisex, youth, other
	--@P_RecCount int OUTPUT
)
AS
BEGIN
	-- Get the patterns	
	SET NOCOUNT ON
	DECLARE @StartOffset int;
	SET @StartOffset = (@P_Set - 1) * @P_MaxRows;	    
	
	SELECT	p.[ID] AS Pattern,	
			p.[NickName] AS NickName,
			p.[Number] AS Number,			
			g.[Name] AS Gender,
			ISNULL(ag.[Name], '') AS AgeGroup,
			( SELECT TOP 1 SizeName FROM [dbo].Size WHERE SizeSet = p.Sizeset ) AS StartingSize,
			( SELECT TOP 1 SizeName FROM [dbo].Size WHERE SizeSet = p.Sizeset ORDER BY ID DESC ) AS EndingSize,
			ISNULL(pti.[Filename] + pti.Extension,'') AS [FileName]
	FROM [dbo].[Pattern] p
		INNER JOIN [dbo].[Gender] g
			ON p.[Gender] = g.[ID]
		INNER JOIN [dbo].[AgeGroup] ag
			ON p.[AgeGroup] = ag.[ID]
		INNER JOIN [dbo].[Category] c
			ON p.[CoreCategory] = c.[ID]
		INNER JOIN [dbo].PatternTemplateImage pti
			ON p.ID = pti.Pattern AND pti.IsHero = 1
	WHERE	p.IsActive = 1 AND 
			p.IsActiveWS = 1 AND 
			(	@P_CoreCategory = 0 OR p.CoreCategory = @P_CoreCategory ) AND 
			(	@P_SearchText = '' OR
				p.[Number] LIKE '%' + @P_SearchText + '%' OR
				p.[NickName] LIKE '%' + @P_SearchText + '%' OR
				p.[Keywords] LIKE '%' + @P_SearchText + '%' OR
				c.[Name] LIKE '%' + @P_SearchText + '%'
			)	AND
			( 
				@P_Category = '' OR
				(@P_Category = 'mens' AND p.Gender = 1 AND p.AgeGroup = 1) OR
				(@P_Category = 'ladies' AND p.Gender = 2 AND p.AgeGroup = 1) OR
				(@P_Category = 'unisex' AND p.Gender = 3) OR
				(@P_Category = 'youth' AND p.AgeGroup = 2) OR
				(@P_Category = 'other' AND ( p.Gender > 3 OR p.AgeGroup > 2) )
			)	
	ORDER BY 
		CASE WHEN (@p_Sort = 0 ) THEN p.[IsCoreRange] END ASC,
		CASE WHEN (@p_Sort = 1 ) THEN p.[Number] END ASC, 
		CASE WHEN (@p_Sort = 2 ) THEN p.[ID] END DESC
	OFFSET @StartOffset ROWS
	FETCH NEXT @P_MaxRows ROWS ONLY

	---- Send the total
	--IF @P_Set = 1
	--BEGIN	
	--	SELECT @P_RecCount = COUNT (a.ID)
	--	FROM (
	--		SELECT	p.[ID]			
	--		FROM [dbo].[Pattern] p								
	--			INNER JOIN [dbo].[Category] c
	--				ON p.[CoreCategory] = c.[ID]				
	--		WHERE	p.IsActive = 1 AND 
	--				p.IsActiveWS = 1 AND 
	--				(	@P_CoreCategory = 0 OR p.CoreCategory = @P_CoreCategory ) AND 
	--				(	@P_SearchText = '' OR
	--					p.[Number] LIKE '%' + @P_SearchText + '%' OR
	--					p.[NickName] LIKE '%' + @P_SearchText + '%' OR
	--					p.[Keywords] LIKE '%' + @P_SearchText + '%' OR
	--					c.[Name] LIKE '%' + @P_SearchText + '%'
	--				)	AND
	--				( 
	--					@P_Category = '' OR
	--					(@P_Category = 'mens' AND p.Gender = 1 AND p.AgeGroup = 1) OR
	--					(@P_Category = 'ladies' AND p.Gender = 2 AND p.AgeGroup = 1) OR
	--					(@P_Category = 'unisex' AND p.Gender = 3) OR
	--					(@P_Category = 'youth' AND p.AgeGroup = 2) OR
	--					(@P_Category = 'other' AND ( p.Gender > 3 OR p.AgeGroup > 2) )
	--				)
	--	)a
	--END
	--ELSE
	--BEGIN
	--	SET @P_RecCount = 0
	--END
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

