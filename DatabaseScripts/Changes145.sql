USE [Indico]
GO

INSERT INTO [dbo].[MenuItemRole]
           ([MenuItem],[Role])
     VALUES
           (	(SELECT TOP 1 ID FROM [dbo].[MenuItem] WHERE [Name]='Manage' AND [Parent] IS NULL),
				(SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
			)
GO

INSERT INTO [dbo].[MenuItemRole]
           ([MenuItem],[Role])
     VALUES
           (	(SELECT ID FROM [dbo].[MenuItem] WHERE [Page]=(SELECT ID FROM [dbo].[Page] WHERE [Name] = '/ViewDistributors.aspx')),
				(SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
			)
GO

INSERT INTO [dbo].[MenuItemRole]
           ([MenuItem],[Role])
     VALUES
           (	(SELECT ID FROM [dbo].[MenuItem] WHERE [Page]=(SELECT ID FROM [dbo].[Page] WHERE [Name] = '/AddEditDistributor.aspx')),
				(SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
			)
GO

INSERT INTO [dbo].[MenuItemRole]
           ([MenuItem],[Role])
     VALUES
           (	(SELECT ID FROM [dbo].[MenuItem] WHERE [Page]=(SELECT ID FROM [dbo].[Page] WHERE [Name] = '/ViewClients.aspx')),
				(SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
			)
GO

INSERT INTO [dbo].[MenuItemRole]
           ([MenuItem],[Role])
     VALUES
           (	(SELECT ID FROM [dbo].[MenuItem] WHERE [Page]=(SELECT ID FROM [dbo].[Page] WHERE [Name] = '/AddEditClient.aspx')),
				(SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
			)
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewClientsDetails]    Script Date: 07/17/2015 12:41:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewClientsDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewClientsDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewClientsDetails]    Script Date: 07/17/2015 12:41:30 ******/
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
	DECLARE @Is_Distributor bit;
	DECLARE @Distributor_ID int;
	
	IF @P_Distributor LIKE '%DIS%'
		BEGIN
		SET @Is_Distributor = 1
		SET @Distributor_ID = CONVERT(INT, REPLACE(@P_Distributor,'DIS','' ))	
		END
	ELSE 
		BEGIN 
			IF(@P_Distributor LIKE '%COD%')
			SET @Is_Distributor = 0
			SET @Distributor_ID = CONVERT(INT, REPLACE(@P_Distributor,'COD','' ))
		END

	--SET @StartOffset = (@P_Set - 1) * @P_MaxRows;
	-- Get Clients Details	
	 --WITH Clients AS
	-- (
		SELECT 
			--DISTINCT TOP (@P_Set * @P_MaxRows)
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
			   ISNULL(c.[Address], '') AS 'Address',
			   ISNULL(c.[Name], '') AS NickName,
			   ISNULL(c.[City], '') AS City,
			   ISNULL(c.[State], '') AS 'State',
			   ISNULL(c.[PostalCode], '') AS PostalCode,			   
			   ISNULL(c.[Country], 'Australia')AS Country,			     
			   ISNULL(c.[Phone], '') AS Phone,
			   ISNULL(c.[Email], '') AS Email,
			   u.[GivenName] + ' ' + u.[FamilyName] AS Creator,
			   c.[CreatedDate] AS CreatedDate  ,
			   um.[GivenName] + ' ' + um.[FamilyName] AS Modifier,
			   c.[ModifiedDate] AS ModifiedDate,
			   CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (v.[Client]) FROM [dbo].[VisualLayout] v WHERE v.[Client] = c.[ID])) THEN 1 ELSE 0 END)) AS VisualLayouts,
			   CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (o.[Client]) FROM [dbo].[Order] o WHERE o.[Client] = c.[ID])) THEN 1 ELSE 0 END)) AS 'Order'			  
		FROM [dbo].[Client] c
		LEFT OUTER JOIN [dbo].[Company] d
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
				AND (@P_Distributor = '' OR ( 
										(@Is_Distributor = 1 AND d.[ID] = @Distributor_ID ) OR
										(@Is_Distributor = 0 AND d.[Coordinator] = @Distributor_ID)
										)
					 )
	--)
	--SELECT * FROM Clients WHERE ID > @StartOffset
	
	/*IF @P_Set = 1
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
	BEGIN*/
		SET @P_RecCount = 0
	--END
END



GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewDistributorsDetails]    Script Date: 07/17/2015 13:57:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewDistributorsDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewDistributorsDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewDistributorsDetails]    Script Date: 07/17/2015 13:57:49 ******/
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
	--SET @StartOffset = (@P_Set - 1) * @P_MaxRows;
 -- Get Distributor Details	
	--WITH Distributors AS
	--(
			SELECT 
				--DISTINCT TOP (@P_Set * @P_MaxRows)
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
				   AND (@P_PCoordinator = '' OR u.[ID] = @P_PCoordinator)
				   AND (@P_SCoordinator = '' OR sc.[ID] = @P_SCoordinator)
				   
	--)
	--SELECT * FROM Distributors WHERE ID > @StartOffset
	
	---- Send the total
	/*IF @P_Set = 1
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
	BEGIN*/
		SET @P_RecCount = 0
	--END
	
END

GO

