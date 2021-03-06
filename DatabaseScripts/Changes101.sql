USE [Indico]
GO        
       
DECLARE @ID AS int
DECLARE @Distributor AS int 
DECLARE @PriceTerm AS int
DECLARE @PriceLevelCost AS int
DECLARE @IndicoCost AS decimal (8,2)
DECLARE @Modifier AS int 
DECLARE @Pattern AS int
DECLARE @FabricCode  AS int

DECLARE UpdateDistributorPriceLevelCost CURSOR FAST_FORWARD FOR 

SELECT dplc.[ID]
      ,dplc.[Distributor]
      ,dplc.[PriceTerm]
      ,dplc.[IndicoCost]      
      ,dplc.[Modifier] 
      ,pr.[Pattern]
      ,pr.[FabricCode]    
  FROM [Indico].[dbo].[DistributorPriceLevelCost] dplc
  JOIN [dbo].[PriceLevelCost] plc
	ON dplc.[PriceLevelCost] = plc.[ID]
  JOIN [dbo].[PriceLevel] pl
	ON plc.[PriceLevel] = pl.[ID]
  JOIN [dbo].[PriceTerm] pt
	ON dplc.[PriceTerm] = pt.[ID]  
  JOIN [dbo].[Price] pr
	ON plc.[Price] = pr.[ID]  
  WHERE dplc.[Distributor] IS NULL AND 
        pl.[Volume] = '6 - 9' AND 
        dplc.[Modifier] = 40 AND
        pt.[Name] = 'CIF' 
        
OPEN UpdateDistributorPriceLevelCost 
	FETCH NEXT FROM UpdateDistributorPriceLevelCost INTO @ID, @Distributor, @PriceTerm, @IndicoCost, @Modifier, @Pattern, @FabricCode
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
	
	
	
							DECLARE PriceLevelCost CURSOR FAST_FORWARD FOR 
								SELECT dplc.[ID]									 
								  FROM [Indico].[dbo].[DistributorPriceLevelCost] dplc
								  JOIN [dbo].[PriceLevelCost] plc
									ON dplc.[PriceLevelCost] = plc.[ID]
								  JOIN [dbo].[PriceLevel] pl
									ON plc.[PriceLevel] = pl.[ID]
								 JOIN [dbo].[Price] pr
									ON plc.[Price] = pr.[ID]  								  
								  WHERE dplc.[Distributor] IS NULL AND 
										pl.[Volume] = '1 - 5' AND 
										dplc.[Modifier] = @Modifier AND
										dplc.[PriceTerm] = @PriceTerm AND
										pr.[Pattern] = @Pattern AND
										pr.[FabricCode] = @FabricCode
								OPEN PriceLevelCost 
									FETCH NEXT FROM PriceLevelCost INTO @PriceLevelCost
									WHILE @@FETCH_STATUS = 0 
									BEGIN 
									
										UPDATE [dbo].[DistributorPriceLevelCost] SET [IndicoCost] = @IndicoCost WHERE [ID] = @PriceLevelCost
										
										--SELECT [ID] FROM [dbo].[DistributorPriceLevelCost] WHERE [ID] = @PriceLevelCost
										
									
										FETCH NEXT FROM PriceLevelCost INTO @PriceLevelCost
									END 

								CLOSE PriceLevelCost 
								DEALLOCATE PriceLevelCost
	

		FETCH NEXT FROM UpdateDistributorPriceLevelCost INTO @ID, @Distributor, @PriceTerm, @IndicoCost, @Modifier, @Pattern, @FabricCode
	END 

CLOSE UpdateDistributorPriceLevelCost 
DEALLOCATE UpdateDistributorPriceLevelCost		
-----/--------
GO


/****** Object:  StoredProcedure [dbo].[SPC_ViewVisualLayoutDetails]    Script Date: 06/26/2014 12:31:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewVisualLayoutDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewVisualLayoutDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewVisualLayoutDetails]    Script Date: 06/26/2014 12:31:10 ******/
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
	--SET @StartOffset = (@P_Set - 1) * @P_MaxRows;
	
	--WITH VisualLayout AS
	--(
		SELECT 
			--DISTINCT TOP (@P_Set * @P_MaxRows)
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
			   ISNULL(v.[NamePrefix] + '' + ISNULL(CAST(v.[NameSuffix] AS NVARCHAR(64)), ''), '') AS Name,
			   ISNULL(v.[Description], '') AS 'Description',
			   ISNULL(p.[Number] + ' - '+ p.[NickName], '') AS Pattern,
			   ISNULL(f.[Name], '') AS Fabric,
			   ISNULL(c.[Name], '') AS Client,
			   ISNULL(d.[Name], '') AS Distributor,
			   ISNULL(u.[GivenName] + ' '+ u.[FamilyName], '') AS Coordinator,
			   ISNULL(v.[NNPFilePath], '') AS NNPFilePath,
			   ISNULL(v.[CreatedDate], GETDATE()) AS CreatedDate,
			   ISNULL(v.[IsCommonProduct], 0) AS IsCommonProduct,
			   ISNULL(v.[ResolutionProfile], 0) AS ResolutionProfile,
			   ss.[Name] AS SizeSet,
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
			JOIN [dbo].[SizeSet] ss
				ON p.[SizeSet] = ss.[ID]
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
		--)
	--SELECT * FROM VisualLayout WHERE ID > @StartOffset
	
	/*IF @P_Set = 1
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
	ELSE*/
	--BEGIN
		SET @P_RecCount = 0
	--END
END



GO


/****** Object:  View [dbo].[ReturnVisualLayoutDetailsView]    Script Date: 06/26/2014 12:36:17 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnVisualLayoutDetailsView]'))
DROP VIEW [dbo].[ReturnVisualLayoutDetailsView]
GO

/****** Object:  View [dbo].[ReturnVisualLayoutDetailsView]    Script Date: 06/26/2014 12:36:17 ******/
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
		0 AS ResolutionProfile,
		'' AS SizeSet,
		CONVERT(bit,0)AS OrderDetails




GO


--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**--**-**--**