USE [Indico]
GO

ALTER TABLE [dbo].[Order]
ADD [IsNew] [bit] NULL
GO

ALTER TABLE [dbo].[OrderDetail]
ADD [Reservation] [int] NULL
GO

ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetail_Reservation] FOREIGN KEY([Reservation])
REFERENCES [dbo].[Reservation] ([ID])
GO

ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_Reservation]
GO


ALTER TABLE [dbo].[Order]
DROP COLUMN [IsNew] 
GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-** Create A View For Embroideries--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

/****** Object:  View [dbo].[EmbroideryDetailsView]    Script Date: 02/20/2014 13:00:21 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[EmbroideryDetailsView]'))
DROP VIEW [dbo].[EmbroideryDetailsView]
GO

/****** Object:  View [dbo].[EmbroideryDetailsView]    Script Date: 02/20/2014 13:00:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[EmbroideryDetailsView]
AS

SELECT e.[ID] AS 'Embroidery'
      ,e.[EmbStrikeOffDate] AS 'EmbStrikeOffDate'
      ,e.[JobName] AS 'JobName'
      ,d.[Name] AS 'Distributor'
      ,e.[Client] AS 'Client'
      ,cu.[GivenName] + ' ' + cu.[FamilyName] AS 'Coordinator'
      ,ISNULL(e.[Product], '') AS 'Product'
      ,e.[PhotoRequiredBy]  AS 'PhotoRequiredBy'
      ,creu.[GivenName] + ' ' + creu.[FamilyName] AS 'Creator'
      ,e.[CreatedDate] AS 'CreatedDate'
      ,modu.[GivenName] + ' ' + modu.[FamilyName] AS 'Modifier'
      ,e.[ModifiedDate] AS 'ModifiedDate'
      ,assu.[GivenName] + ' ' + assu.[FamilyName] AS 'Assign'
  FROM [Indico].[dbo].[Embroidery] e
	  JOIN [dbo].[Company] d
		ON e.[Distributor] = d.[ID]
	  JOIN [dbo].[User] cu
		ON e.[Coordinator] = cu.[ID]
	  JOIN [dbo].[User] creu
		ON e.[Creator] = creu.[ID]	
	  JOIN [dbo].[User] modu
		ON e.[Modifier] = modu.[ID]
	  JOIN [dbo].[User] assu
		ON e.[Assigned] = assu.[ID]

GO  
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

/****** Object:  StoredProcedure [dbo].[SPC_ViewPatternDetails]    Script Date: 02/20/2014 16:57:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewPatternDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewPatternDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewPatternDetails]    Script Date: 02/20/2014 16:57:38 ******/
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
	    
	--WITH Patterns AS 
	--(
		SELECT  
			/*DISTINCT TOP (@P_Set * @P_MaxRows)*/
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
	--)
	
	/*SELECT * FROM Patterns WHERE ID > @StartOffset*/
	
	/*IF @P_Set = 1
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
	BEGIN*/
		SET @P_RecCount = 0
	--END	
END

GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
/****** Object:  StoredProcedure [dbo].[SPC_ViewClientsDetails]    Script Date: 02/21/2014 09:27:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewClientsDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewClientsDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewClientsDetails]    Script Date: 02/21/2014 09:27:09 ******/
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
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

/****** Object:  StoredProcedure [dbo].[SPC_ViewDistributorsDetails]    Script Date: 02/21/2014 10:13:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewDistributorsDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewDistributorsDetails]
GO
/****** Object:  StoredProcedure [dbo].[SPC_ViewDistributorsDetails]    Script Date: 02/21/2014 10:13:44 ******/
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
				   AND (@P_PCoordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE + '%' + @P_PCoordinator + '%' )
				   AND (@P_SCoordinator = '' OR (sc.[GivenName] + ' ' + sc.[FamilyName]) LIKE + '%' + @P_SCoordinator + '%')
				   
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

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

/****** Object:  StoredProcedure [dbo].[SPC_ViewVisualLayoutDetails]    Script Date: 02/21/2014 11:06:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewVisualLayoutDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewVisualLayoutDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewVisualLayoutDetails]    Script Date: 02/21/2014 11:06:31 ******/
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
			   v.[NamePrefix] + '' + ISNULL(CAST(v.[NameSuffix] AS NVARCHAR(64)), '') AS Name,
			   ISNULL(v.[Description], '') AS 'Description',
			   p.[Number] + ' - '+ p.[NickName] AS Pattern,
			   f.[Name] AS Fabric,
			   ISNULL(c.[Name], '') AS Client,
			   ISNULL(d.[Name], '') AS Distributor,
			   ISNULL(u.[GivenName] + ' '+ u.[FamilyName], '') AS Coordinator,
			   ISNULL(v.[NNPFilePath], '') AS NNPFilePath,
			   v.[CreatedDate] AS CreatedDate,
			   v.[IsCommonProduct] AS IsCommonProduct,
			   ISNULL(v.[ResolutionProfile], 0) AS ResolutionProfile,
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
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
/****** Object:  View [dbo].[UserDetailsView]    Script Date: 02/21/2014 13:19:44 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[UserDetailsView]'))
DROP VIEW [dbo].[UserDetailsView]
GO

/****** Object:  View [dbo].[UsersDetailsView]    Script Date: 02/24/2014 11:06:59 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[UsersDetailsView]'))
DROP VIEW [dbo].[UsersDetailsView]
GO

/****** Object:  View [dbo].[UsersDetailsView]    Script Date: 02/24/2014 11:06:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[UsersDetailsView]
AS

SELECT u.[ID] AS [User]
      ,c.[Name] AS Company
      ,u.[IsDistributor] AS IsDistributor
      ,us.[Name] AS [Status]
      ,u.[Status] AS StatusID
      ,u.[GivenName] + ' ' + u.[FamilyName] AS Name   
      ,u.[UserName] AS UserName       
      ,u.[EmailAddress] AS Email      
      ,u.[IsActive] AS IsActive
      ,u.[IsDeleted] AS IsDeleted      
      ,r.[ID] AS [Role]
      ,ct.[Name] AS CompanyType       
  FROM [Indico].[dbo].[User] u
	JOIN [dbo].[UserStatus] us
		ON u.[Status] = us.[ID]	
	JOIN [dbo].[Company] c
		ON u.[Company] = c.[ID]
	JOIN [dbo].[UserRole] ur
		ON u.[ID] = ur.[User]
	JOIN [dbo].[Role] r
		ON ur.[Role] = r.[ID]
	JOIN [dbo].[CompanyType] ct
		ON c.[Type] = ct.[ID]
  WHERE [u].[Status] NOT IN (4)



GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

/****** Object:  View [dbo].[QuotesDetailsView]    Script Date: 02/21/2014 14:46:10 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[QuotesDetailsView]'))
DROP VIEW [dbo].[QuotesDetailsView]
GO

/****** Object:  View [dbo].[QuotesDetailsView]    Script Date: 02/21/2014 14:46:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[QuotesDetailsView]
AS

SELECT q.[ID] AS Quote
      ,q.[DateQuoted] AS DateQuoted
      ,q.[QuoteExpiryDate] AS QuoteExpiryDate
      ,q.[ClientEmail] AS ClietEMail
      ,q.[JobName] AS JobName
      ,ISNULL(p.[Number] + ' - ' + p.[NickName], '') AS Pattern 
      ,ISNULL(f.[Code] + ' - ' + f.[Name], '') AS Fabric
      ,ISNULL(q.[Qty], 0) AS 'Qty'
      ,ISNULL(q.[DeliveryDate], GETDATE()) AS DeliveryDate
      ,ISNULL(pt.[Name], '') AS PriceTerm
      ,ISNULL(q.[IndimanPrice], 0.00) AS IndimanPrice
      ,ISNULL(q.[Notes], '') AS Notes
      ,qs.[Name] AS [Status]
      ,q.[ContactName] AS ContactName
      ,u.[GivenName] + ' ' + u.[FamilyName] AS Creator      
      ,ISNULL(c.[Name], '') AS Distributor
  FROM [Indico].[dbo].[Quote] q
	LEFT OUTER JOIN [dbo].[Pattern] p
		ON q.[Pattern] = p.[ID]	
	LEFT OUTER JOIN [dbo].[FabricCode] f
		ON q.[Fabric] = f.[ID]
	LEFT OUTER JOIN [dbo].[PriceTerm] pt
		ON q.[PriceTerm] = pt.[ID]
	JOIN [dbo].[QuoteStatus] qs
		ON q.[Status] = qs.[ID]
	JOIN [dbo].[User] u
		ON q.[Creator] = u.[ID] 
	LEFT OUTER JOIN [dbo].[Company] c
		ON q.[Distributor] = c.[ID]
		

GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

/****** Object:  View [dbo].[CostSheetDetailsView]    Script Date: 02/21/2014 17:11:23 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CostSheetDetailsView]'))
DROP VIEW [dbo].[CostSheetDetailsView]
GO

/****** Object:  View [dbo].[CostSheetDetailsView]    Script Date: 02/21/2014 17:11:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[CostSheetDetailsView]
AS
SELECT ch.[ID] AS CostSheet
      ,p.[Number] + ' - ' + p.[NickName] AS Pattern
      ,fc.[Code] + ' - ' + fc.[Name]  AS Fabric    
      ,ISNULL(ch.[QuotedFOBCost], ISNULL(ch.[JKFOBCost], 0.00)) QuotedFOBCost    
      ,ISNULL(ch.[QuotedCIF], 0.00) AS QuotedCIF     
      ,ISNULL(ch.[QuotedMP], 0.00) AS QuotedMP
      ,ISNULL(ch.[ExchangeRate], 0.00) AS ExchangeRate   
      ,ISNULL(cat.[Name], '') AS Category
  FROM [Indico].[dbo].[CostSheet] ch
	JOIN [dbo].[Pattern] p
		ON ch.[Pattern] = p.[ID]
	JOIN [dbo].[FabricCode] fc
		ON ch.[Fabric] = fc.[ID]
	JOIN [dbo].[Category] cat
		ON p.[CoreCategory] = cat.[ID]
	WHERE p.[IsActive] = 1
		

GO
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**


/****** Object:  View [dbo].[SupplierDetailsView]    Script Date: 02/24/2014 15:50:40 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SupplierDetailsView]'))
DROP VIEW [dbo].[SupplierDetailsView]
GO

/****** Object:  View [dbo].[SupplierDetailsView]    Script Date: 02/24/2014 15:50:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SupplierDetailsView]
AS

SELECT su.[ID] AS Supplier
      ,su.[Name] AS Name
      ,su.[Country]  AS CountryID
      ,co.[ShortName] AS Country  
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (acc.[Supplier]) FROM [dbo].[Accessory] acc WHERE acc.[Supplier] = su.[ID])) THEN 1 ELSE 0 END)) AS IsAccessoriesWherethisSupplier
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (fc.[Supplier]) FROM [dbo].[FabricCode] fc WHERE fc.[Supplier] = su.[ID])) THEN 1 ELSE 0 END)) AS IsFabricCodesWherethisSupplier
  FROM [Indico].[dbo].[Supplier] su
  JOIN [dbo].[Country] co
	ON su.[Country] = co.[ID]

GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
/****** Object:  View [dbo].[HSCodeDetails]    Script Date: 02/24/2014 16:31:51 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[HSCodeDetails]'))
DROP VIEW [dbo].[HSCodeDetails]
GO
/****** Object:  View [dbo].[HSCodeDetails]    Script Date: 02/24/2014 16:31:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[HSCodeDetails]
AS
SELECT hs.[ID] AS HSCode
      ,hs.[ItemSubCategory] AS ItemSubCategoryID
      ,i.[Name] AS ItemSubCategory
      ,hs.[Gender] AS GenderID
      ,g.[Name] AS Gender
      ,hs.[Code]
  FROM [Indico].[dbo].[HSCode] hs
	JOIN [dbo].[Item] i
		ON hs.[ItemSubCategory] = i.[ID]
	JOIN [dbo].[Gender] g
		ON hs.[Gender] = g.[ID]
  WHERE i.[Parent] IS NOT NULL
 

GO
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

/****** Object:  View [dbo].[FabricCodeDetailsView]    Script Date: 02/24/2014 17:04:25 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[FabricCodeDetailsView]'))
DROP VIEW [dbo].[FabricCodeDetailsView]
GO

/****** Object:  View [dbo].[FabricCodeDetailsView]    Script Date: 02/24/2014 17:04:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [dbo].[FabricCodeDetailsView]
AS
SELECT fc.[ID] AS Fabric
      ,fc.[Code] AS Code
      ,fc.[Name] AS Name
      ,ISNULL(fc.[Material], '') AS Material
      ,ISNULL(fc.[GSM], '') AS GSM
      ,ISNULL(fc.[Supplier], 0) AS SupplierID
      ,ISNULL(s.[Name], '') AS Supplier
      ,fc.[Country] AS CountryID
      ,c.[ShortName] AS Country
      ,ISNULL(fc.[DenierCount], '') AS DenierCount
      ,ISNULL(fc.[Filaments], '') AS Filaments
      ,ISNULL(fc.[NickName], '') AS NickName
      ,ISNULL(fc.[SerialOrder], '') AS SerialOrder
      ,ISNULL(fc.[FabricPrice], 0.00) AS FabricPrice
      ,ISNULL(fc.[LandedCurrency], 0) AS LandedCurrency
      ,ISNULL(fc.[Fabricwidth], '') AS FabricWidth
      ,ISNULL(fc.[Unit], 0) AS UnitID 
      ,ISNULL(u.[Name], '') AS Unit
      ,ISNULL(fc.[FabricColor], 0) AS FabricColorID
      ,ISNULL(ac.[Name], '') AS FabricColor 
      ,ISNULL(ac.[ColorValue], '#FFFFFF') AS ColorCode
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (ch.[Fabric]) FROM [dbo].[CostSheet] ch WHERE ch.[Fabric] = fc.[ID])) THEN 1 ELSE 0 END)) AS IsCostSheetWherethisFabricCode
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (pr.[FabricCode]) FROM [dbo].[Price] pr WHERE pr.[FabricCode] = fc.[ID])) THEN 1 ELSE 0 END)) AS IsPriceWherethisFabricCode
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (q.[Fabric]) FROM [dbo].[Quote] q WHERE q.[Fabric] = fc.[ID])) THEN 1 ELSE 0 END)) AS IsQuoteWherethisFabricCode
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (v.[FabricCode]) FROM [dbo].[VisualLayout] v WHERE v.[FabricCode] = fc.[ID])) THEN 1 ELSE 0 END)) AS IsVisualLayoutWherethisFabricCode
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (psf.[Fabric]) FROM [dbo].[PatternSupportFabric] psf WHERE psf.[Fabric] = fc.[ID])) THEN 1 ELSE 0 END)) AS IsPatternSupportFabricWherethisFabricCode
  FROM [Indico].[dbo].[FabricCode] fc
	LEFT OUTER JOIN [dbo].[Supplier] s
		ON fc.[Supplier] = s.[ID]
	JOIN [dbo].[Country] c
		ON fc.[Country] = c.[ID]
	LEFT OUTER JOIN [dbo].[Unit] u
		ON fc.[Unit] = u.[ID]
	LEFT OUTER JOIN [dbo].[AccessoryColor] ac
		ON fc.[FabricColor] = ac.[ID]

GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

/****** Object:  View [dbo].[ItemAttributesDetailsView]    Script Date: 02/25/2014 09:58:54 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ItemAttributesDetailsView]'))
DROP VIEW [dbo].[ItemAttributesDetailsView]
GO

/****** Object:  View [dbo].[ItemAttributesDetailsView]    Script Date: 02/25/2014 09:58:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[ItemAttributesDetailsView]
AS
SELECT ia.[ID] AS Attribute  
	  ,ia.[Name] AS Name
	  ,ia.[Description]    
      ,ia.[Item] AS ItemID      
      ,i.[Name] AS Item
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (iaa.[Parent]) FROM [dbo].[ItemAttribute] iaa WHERE iaa.[Parent] = ia.[ID])) THEN 1 ELSE 0 END)) AS IsItemAttributesSubWherethisFabricCode      
  FROM [Indico].[dbo].[ItemAttribute] ia
	JOIN [dbo].[Item] i
		ON ia.[Item] = i.[ID]	
  WHERE ia.[Parent] IS NULL
 

GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**


/****** Object:  View [dbo].[AccessoryDetailsView]    Script Date: 02/25/2014 10:28:24 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AccessoryDetailsView]'))
DROP VIEW [dbo].[AccessoryDetailsView]
GO


/****** Object:  View [dbo].[AccessoryDetailsView]    Script Date: 02/25/2014 10:28:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[AccessoryDetailsView]
AS
SELECT a.[ID] AS Accessory
      ,a.[Name] AS Name
      ,a.[Code] AS Code
      ,a.[AccessoryCategory] AS AccessoryCategoryID 
      ,ac.[Name] AS AccessoryCategory
      ,ISNULL(a.[Description], '') AS [Description]
      ,ISNULL(a.[Cost], 0.00) AS Cost
      ,ISNULL(a.[SuppCode], '') AS SuppCode
      ,a.[Unit] AS UnitID
      ,u.[Name] AS Unit
      ,ISNULL(a.[Supplier],0) AS SupplierID
      ,ISNULL(s.[Name], '') AS Supplier
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (pa.[Accessory]) FROM [dbo].[PatternAccessory] pa WHERE pa.[Accessory] = a.[ID])) THEN 1 ELSE 0 END)) AS IsPatternAccessoryWherethisAccessory     
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (psa.[Accessory]) FROM [dbo].[PatternSupportAccessory] psa WHERE psa.[Accessory] = a.[ID])) THEN 1 ELSE 0 END)) AS IsPatternSupportAccessorySubWherethisAccessory
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (vla.[Accessory]) FROM [dbo].[VisualLayoutAccessory] vla WHERE vla.[Accessory] = a.[ID])) THEN 1 ELSE 0 END)) AS IsVisualLayoutAccessorySubWherethisAccessory  
  FROM [Indico].[dbo].[Accessory] a
	JOIN [dbo].[AccessoryCategory] ac
		ON a.[AccessoryCategory] = ac.[ID]
	LEFT OUTER JOIN [dbo].[Unit] u
		ON a.[Unit] = u.[ID]
	LEFT OUTER JOIN [dbo].[Supplier] s
		ON a.[Supplier] = s.[ID]


GO


--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**


