USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewVisualLayoutDetails]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_ViewVisualLayoutDetails]
GO

CREATE PROCEDURE [dbo].[SPC_ViewVisualLayoutDetails]
(
 @P_SearchText AS NVARCHAR(255) = '',
 @P_Coordinator AS int = 0,
 @P_Distributor AS int = 0,
 @P_Client AS int = 0, 
 @P_Active AS bit = 1
)
AS
BEGIN 
 SET NOCOUNT ON 
  SELECT    
      v.[ID] AS VisualLayout,
      ISNULL(v.[NamePrefix] + '' + ISNULL(CAST(v.[NameSuffix] AS NVARCHAR(64)), ''), '') AS Name,
      ISNULL(v.[Description], '') AS 'Description',
      ISNULL(p.[Number] + ' - '+ p.[NickName], '') AS Pattern,
      ISNULL(f.[Name], '') AS Fabric,
      ISNULL(j.[Name], '') AS JobName,
      ISNULL(c.[Name], '') AS Client,
      ISNULL(d.[Name], '') AS Distributor,
      ISNULL(u.[GivenName] + ' '+ u.[FamilyName], '') AS Coordinator,
      ISNULL(v.[NNPFilePath], '') AS NNPFilePath,
      ISNULL(v.[CreatedDate], GETDATE()) AS CreatedDate,
      ISNULL(v.[IsCommonProduct], 0) AS IsCommonProduct,
      ISNULL(v.[ResolutionProfile], 0) AS ResolutionProfile,
      ISNULL(v.[Printer], 0) AS Printer,
      ss.[Name] AS SizeSet,
     CASE WHEN 
       --(EXISTS(SELECT TOP 1 ID FROM [dbo].[VisualLayoutAccessory] WHERE [VisualLayout] = v.[ID])) OR
       --(EXISTS(SELECT TOP 1 ID FROM [dbo].[Image] WHERE [VisualLayout] = v.[ID])) OR
       (EXISTS(SELECT TOP 1 ID FROM [dbo].[OrderDetail] WHERE [VisualLayout] = v.[ID])) 
    THEN 0 
    ELSE 1 
    END
    AS CanDelete,
     ISNULL(vli.[FileName], '') AS [FileName],
     ISNULL(vli.[Extension], '') AS Extension
  FROM [dbo].[VisualLayout] v WITH (NOLOCK)
   INNER JOIN [dbo].[Pattern] p WITH (NOLOCK)
    ON v.[Pattern] = p.[ID]
   INNER JOIN [dbo].[FabricCode] f WITH (NOLOCK)
    ON v.[FabricCode] = f.[ID]
   INNER JOIN [dbo].[JobName] j WITH (NOLOCK)
    ON v.[Client] = j.[ID]
   INNER JOIN [dbo].[Client] c WITH (NOLOCK)
    ON j.[Client] = c.[ID] 
   INNER JOIN [dbo].[Company] d WITH (NOLOCK)
    ON c.[Distributor] = d.[ID]
   LEFT OUTER JOIN [dbo].[User] u WITH (NOLOCK)
    ON d.[Coordinator] = u.[ID]
   INNER JOIN [dbo].[SizeSet] ss WITH (NOLOCK)
    ON p.[SizeSet] = ss.[ID]
   LEFT OUTER JOIN  [dbo].[Image] vli WITH (NOLOCK)
    ON v.ID = vli.VisualLayout AND vli.IsHero = 1 
  WHERE (@P_Coordinator = 0 OR u.[ID] = @P_Coordinator)
    AND  (@P_Distributor = 0 OR  d.ID = @P_Distributor )
    AND  (@P_SearchText = '' OR
        v.[NamePrefix]  LIKE '%' + @P_SearchText + '%' OR
        v.[NameSuffix]  LIKE '%' + @P_SearchText + '%' OR
        v.[Description] LIKE '%' + @P_SearchText + '%' OR
        p.[Number] LIKE '%' + @P_SearchText + '%' OR
        c.[Name] LIKE '%' + @P_SearchText + '%' OR
        d.[Name] LIKE '%' + @P_SearchText + '%' OR
        u.[GivenName] LIKE '%' + @P_SearchText + '%' OR
        u.[FamilyName] LIKE '%' + @P_SearchText + '%') 
	AND v.IsActive = @P_Active
  ORDER BY v.[CreatedDate] DESC
END


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnActiveVisualLayoutsView]'))
	DROP VIEW [dbo].[ReturnActiveVisualLayoutsView]
GO

CREATE VIEW [dbo].[ReturnActiveVisualLayoutsView]
AS
	SELECT 
		vl.ID AS VlID,
		vl.NamePrefix,
		vl.NameSuffix,
		vl.Client,
		p.Number AS PatternNumber,
		fc.NickName AS FabricCodeName
	FROM [dbo].[VisualLayout] vl
		INNER JOIN [dbo].[Pattern] p
			ON vl.Pattern = p.ID
		INNER JOIN [dbo].[FabricCode] fc
			ON vl.FabricCode = fc.ID
	WHERE vl.IsActive = 1

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--