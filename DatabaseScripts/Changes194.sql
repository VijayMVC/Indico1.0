USE [Indico]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetCostSheetDetails]    Script Date: 6/9/2016 4:54:04 PM ******/
DROP PROCEDURE [dbo].[SPC_GetCostSheetDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetCostSheetDetails]    Script Date: 6/9/2016 4:54:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SPC_GetCostSheetDetails] (	
@P_SearchText nvarchar(max) 
)	
AS 
BEGIN
	
	DECLARE @CostSheets TABLE
	(
		CostSheet int,
		PatternID int,
		Pattern nvarchar(MAX),
		Fabric nvarchar(MAX),
		Category nvarchar(MAX),
		SMV decimal(8,2),
		SMVRate decimal(8,3),
		HPCost decimal(8,2),
		LabelCost decimal(8,2),
		Packing decimal(8,2),
		Wastage decimal(8,2),
		Finance decimal(8,2),
		QuotedFOBCost decimal(8,2),
		DutyRate decimal(8,2),
		CONS1 decimal(8,2),
		CONS2 decimal(8,2),
		CONS3 decimal(8,2),
		Rate1 decimal(8,2),
		Rate2 decimal(8,2),
		Rate3 decimal(8,2),
		ExchangeRate decimal(8,2),
		InkCons decimal(8,3),
		InkRate decimal(8,2),
		SubCons decimal(8,2),
		PaperRate decimal(8,2),
		AirFregiht decimal(8,2),
		ImpCharges decimal(8,2),
		MGTOH decimal(8,2),
		IndicoOH decimal(8,2),
		Depr decimal(8,2),
		MarginRate decimal(8,2),
		QuotedCIF decimal(8,2),
		IndimanCIF decimal(8,2),
		ShowToIndico bit NOT NULL,
		ModifiedDate datetime2 NULL, 
		IndimanModifiedDate datetime2 NULL
	)	
	
	DECLARE @CostSheetDetails TABLE
	(
		CostSheet int,
		PatternID int,
		Pattern nvarchar(MAX),
		Fabric nvarchar(MAX),
		QuotedFOBCost decimal(8,2),
		QuotedCIF decimal(8,2),
		QuotedMP decimal(8,2),
		ExchangeRate decimal(8,2),
		Category nvarchar(MAX),
		SMV decimal(8,2),
		SMVRate decimal(8,3),
		CalculateCM decimal(8,2),
		TotalFabricCost decimal(8,2),
		TotalAccessoriesCost decimal(8,2),
		HPCost decimal(8,2),		
		LabelCost decimal(8,2),
		CM decimal(8,2),
		JKFOBCost decimal(8,2),
		Roundup decimal(8,2),
		DutyRate decimal(8,2),
		SubCons decimal(8,2),
		MarginRate decimal(8,2),
		Duty decimal(8,2),
		FOBAUD decimal(8,2),
		AirFregiht decimal(8,2),
		ImpCharges decimal(8,2),
		Landed decimal(8,2),
		MGTOH decimal(8,2),
		IndicoOH decimal(8,2),
		InkCost decimal(8,2),
		PaperCost decimal(8,2),
		ShowToIndico bit NOT NULL,
		ModifiedDate datetime2 NULL, 
		IndimanModifiedDate datetime2 NULL				
	)
	
	INSERT INTO @CostSheets
		SELECT	ch.[ID] AS CostSheet
				,p.ID AS PatternID
				,p.[Number] + ' - ' + p.[NickName] AS Pattern
				,fc.[Code] + ' - ' + fc.[Name]  AS Fabric 
				,ISNULL(cat.[Name], '') AS Category,
				p.SMV ,
				SMVRate ,
				HPCost ,
				LabelCost ,
				Other AS Packing,
				Wastage ,
				Finance ,
				QuotedFOBCost ,
				DutyRate ,
				CONS1 ,
				CONS2 ,
				CONS3 ,
				Rate1 ,
				Rate2 ,
				Rate3 ,
				ExchangeRate ,
				InkCons ,
				InkRate ,
				SubCons ,
				PaperRate ,
				AirFregiht ,
				ImpCharges ,
				MGTOH ,
				IndicoOH ,
				Depr ,
				MarginRate ,
				QuotedCIF ,
				IndimanCIF,
				ch.ShowToIndico,
				ch.ModifiedDate, 
				ch.IndimanModifiedDate
		 FROM [dbo].[CostSheet] ch
			INNER JOIN [dbo].[Pattern] p
				ON ch.[Pattern] = p.[ID]
			INNER JOIN [dbo].[FabricCode] fc
				ON ch.[Fabric] = fc.[ID]
			INNER JOIN [dbo].[Category] cat
				ON p.[CoreCategory] = cat.[ID]
			WHERE p.[IsActive] = 1 AND (
										@P_SearchText = '' OR
											(
												p.[Number] LIKE '%' + @P_SearchText +'%' OR
												fc.[Code] LIKE '%' + @P_SearchText +'%' OR
												fc.[Name] LIKE '%' + @P_SearchText +'%' OR
												cat.[Name] LIKE '%' + @P_SearchText +'%'
											)
										)
	
	DECLARE db_cursor CURSOR LOCAL FAST_FORWARD
					FOR SELECT * FROM @CostSheets; 
	DECLARE @CostSheet INT;
	DECLARE @PatternID INT;
	DECLARE @Pattern NVARCHAR(MAX);
	DECLARE @Fabric NVARCHAR(MAX);
	DECLARE @Category NVARCHAR(MAX);
	DECLARE @SMV decimal(8,2);
	DECLARE @SMVRate decimal(8,3);
	DECLARE @HPCost decimal(8,2);
	DECLARE @LabelCost decimal(8,2);
	DECLARE @Packing decimal(8,2);
	DECLARE @Wastage decimal(8,2);
	DECLARE @Finance decimal(8,2);
	DECLARE @QuotedFOBCost decimal(8,2);
	DECLARE @DutyRate decimal(8,2);
	DECLARE @CONS1 decimal(8,2);
	DECLARE @CONS2 decimal(8,2);
	DECLARE @CONS3 decimal(8,2);
	DECLARE @Rate1 decimal(8,2);
	DECLARE @Rate2 decimal(8,2);
	DECLARE @Rate3 decimal(8,2);
	DECLARE @ExchangeRate decimal(8,2);
	DECLARE @InkCons decimal(8,3);
	DECLARE @InkRate decimal(8,2);
	DECLARE @SubCons decimal(8,2);
	DECLARE @PaperRate decimal(8,2);
	DECLARE @AirFregiht decimal(8,2);
	DECLARE @ImpCharges decimal(8,2);
	DECLARE @MGTOH decimal(8,2);
	DECLARE @IndicoOH decimal(8,2);
	DECLARE @Depr decimal(8,2);
	DECLARE @MarginRate decimal(8,2);
	DECLARE @QuotedCIF decimal(8,2);
	DECLARE @IndimanCIF decimal(8,2);
	DECLARE @ShowToIndico bit;
	DECLARE @ModifiedDate datetime2;
	DECLARE @IndimanModifiedDate datetime2;

	OPEN db_cursor;
	FETCH NEXT FROM db_cursor INTO @CostSheet, @PatternID, @Pattern, @Fabric, @Category, @SMV, @SMVRate, @HPCost, @LabelCost, @Packing, @Wastage, @Finance, @QuotedFOBCost
	, @DutyRate, @CONS1, @CONS2, @CONS3, @Rate1, @Rate2, @Rate3, @ExchangeRate, @InkCons, @InkRate, @SubCons, @PaperRate, @AirFregiht, @ImpCharges, @MGTOH
	, @IndicoOH, @Depr, @MarginRate, @QuotedCIF, @IndimanCIF, @ShowToIndico, @ModifiedDate, @IndimanModifiedDate;
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		 --Do stuff with scalar values
		DECLARE @calCM decimal(8,2)
		DECLARE @totalFabricCost decimal(8,2)
		DECLARE @totalAcccCost decimal(8,2)
				
		DECLARE @subWastage decimal(8,2)		
		DECLARE @subFinance decimal(8,2)
		DECLARE @fobCost decimal(8,2)
		DECLARE @quotedFOB decimal(8,2)
		
		DECLARE @roundUp decimal(8,2)
		DECLARE @cost1 decimal(8,2)
		DECLARE @cost2 decimal(8,2)
		DECLARE @cost3 decimal(8,2)
		
		DECLARE @fobAUD decimal(8,2)
		DECLARE @duty decimal(8,2)
		DECLARE @inkCost decimal(8,2)
		DECLARE @paperCost decimal(8,2)

		DECLARE @landed decimal(8,2)
		DECLARE @calMgn decimal(8,2)
		DECLARE @calMp decimal(8,2)		
		DECLARE @actMgn decimal(8,2)
		DECLARE @quotedMp decimal(8,2)
		   		
		SET @calCM = @SMV * @SMVRate
		SET @totalFabricCost = ( SELECT SUM( ROUND( psf.FabConstant * f.FabricPrice , 2) ) FROM PatternSupportFabric psf LEFT OUTER JOIN FabricCode f ON psf.Fabric = f.ID WHERE psf.CostSheet = @CostSheet )
		SET @totalAcccCost = ( SELECT SUM( ROUND( psa.AccConstant * a.Cost , 2) ) FROM PatternSupportAccessory psa LEFT OUTER JOIN Accessory a ON psa.Accessory = a.ID WHERE psa.CostSheet = @CostSheet )
		SET @subWastage = ( ( @totalAcccCost + @HPCost + @LabelCost + @Packing ) * 0.03 )
		SET @subFinance = ( ( @totalFabricCost + @totalAcccCost + @HPCost + @LabelCost + @Packing ) * 0.04 )
		SET @fobCost = @calCM + @totalFabricCost + @totalAcccCost + @HPCost + @LabelCost + @Packing + @subWastage + @subFinance
		SET @quotedFOB = ISNULL(@QuotedFOBCost, @fobCost)
		SET @roundUp = @quotedFOB - @fobCost
		SET @cost1 = @CONS1 * @Rate1
		SET @cost2 = @CONS2 * @Rate2
		SET @cost3 = @CONS3 * @Rate3
		SET @fobAUD = ( SELECT CASE WHEN (ISNULL(@ExchangeRate,0) > 0 ) THEN ( @quotedFOB / @ExchangeRate) ELSE 0 END )  -- ( @quotedFOB / @ExchangeRate)
		SET @duty = (@fobAUD * @DutyRate) / 100
		SET @inkCost = @InkCons * @InkRate * 1.02
		SET @paperCost = @SubCons * 1.1 * @PaperRate * 1.2
		SET @landed = @fobAUD + @duty + @cost1 + @cost2 + @cost3 + @inkCost + @paperCost + @AirFregiht + @ImpCharges + @MGTOH + @IndicoOH + @Depr
		SET @calMgn = @IndimanCIF - @landed
		SET @calMp = ( SELECT CASE WHEN (ISNULL(@IndimanCIF, 0)> 0 ) THEN (1 - (@landed / @IndimanCIF)) * 100 ELSE 0 END )		
		SET @actMgn = @QuotedCIF - @landed
		SET @quotedMp = ( SELECT CASE WHEN (ISNULL(@QuotedCIF, 0)>0 ) THEN (1 - (@landed / @QuotedCIF)) * 100 ELSE 0 END )
		
		INSERT INTO @CostSheetDetails
		VALUES
		(
			@CostSheet,
			@PatternID,
			@Pattern,
			@Fabric,
			ISNULL(@quotedFOB,0),
			ISNULL(@QuotedCIF,0),
			ISNULL(@quotedMp,0),
			ISNULL(@ExchangeRate,0),
			@Category,
			@SMV,
			ISNULL(@SMVRate,0),
			ISNULL(@calCM,0),
			ISNULL(@totalFabricCost,0),
			ISNULL(@totalAcccCost,0),
			@HPCost,
			@LabelCost,
			ISNULL(@calCM,0),
			ISNULL(@fobCost,0),
			ISNULL(@roundUp,0),
			@DutyRate,
			ISNULL(@SubCons,0),
			@MarginRate,
			ISNULL(@duty,0),
			ISNULL(@fobAUD,0),
			@AirFregiht,
			@ImpCharges,
			ISNULL(@landed,0),
			@MGTOH,
			@IndicoOH,
			@inkCost,
			ISNULL(@paperCost,0),
			@ShowToIndico,
			@ModifiedDate,
			@IndimanModifiedDate		
		)		   

		   FETCH NEXT FROM db_cursor INTO @CostSheet, @PatternID, @Pattern, @Fabric, @Category, @SMV, @SMVRate, @HPCost, @LabelCost, @Packing, @Wastage, @Finance, @QuotedFOBCost
	, @DutyRate, @CONS1, @CONS2, @CONS3, @Rate1, @Rate2, @Rate3, @ExchangeRate, @InkCons, @InkRate, @SubCons, @PaperRate, @AirFregiht, @ImpCharges, @MGTOH
	, @IndicoOH, @Depr, @MarginRate, @QuotedCIF, @IndimanCIF, @ShowToIndico, @ModifiedDate, @IndimanModifiedDate;
	END;
	CLOSE db_cursor;
	DEALLOCATE db_cursor;
	
	SELECT * FROM @CostSheetDetails ORDER BY CostSheet
		  
 END
 

GO


/****** Object:  StoredProcedure [dbo].[SPC_ViewDistributorsDetails]    Script Date: 5/30/2016 2:33:30 PM ******/
DROP PROCEDURE [dbo].[SPC_ViewDistributorsDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewDistributorsDetails]    Script Date: 2016-05-30 02:42:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_ViewDistributorsDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',
	--@P_MaxRows AS int = 20,
	--@P_Set AS int = 0,
	--@P_Sort AS int = 0, --0 Name, --1 NickName, --2 PrimaryCoordinator, --3 SecondaryCoordinator
	--@P_OrderBy AS bit = 0,  -- 0 ASC , -- 1 DESC
	--@P_RecCount int OUTPUT,
	@P_PCoordinator AS NVARCHAR(255) = '',
	@P_SCoordinator AS NVARCHAR(255) = ''
)
AS
BEGIN

	SET NOCOUNT ON
	--DECLARE @StartOffset int;
	--SET @StartOffset = (@P_Set - 1) * @P_MaxRows;
 -- Get Distributor Details	
	--WITH Distributors AS
	--(
			SELECT 
				--DISTINCT TOP (@P_Set * @P_MaxRows)
				--CONVERT(int, ROW_NUMBER() OVER (
				--ORDER BY 
				--	CASE 
				--		WHEN (@p_Sort = 0 AND @p_OrderBy = 0) THEN d.[Name]
				--	END ASC,
				--	CASE						
				--		WHEN (@p_Sort = 0 AND @p_OrderBy = 1) THEN d.[Name]
				--	END DESC,
				--	CASE 
				--		WHEN (@p_Sort = 1 AND @p_OrderBy = 0) THEN d.[NickName]
				--	END ASC,
				--	CASE						
				--		WHEN (@p_Sort = 1 AND @p_OrderBy = 1) THEN d.[NickName]
				--	END DESC,
				--	CASE 
				--		WHEN (@p_Sort = 2 AND @p_OrderBy = 0) THEN u.[GivenName]
				--	END ASC,
				--	CASE						
				--		WHEN (@p_Sort = 2 AND @p_OrderBy = 1) THEN u.[GivenName]
				--	END DESC,	
				--	CASE 
				--		WHEN (@p_Sort = 3 AND @p_OrderBy = 0) THEN sc.[GivenName]
				--	END ASC,
				--	CASE						
				--		WHEN (@p_Sort = 3 AND @p_OrderBy = 1) THEN sc.[GivenName]
				--	END DESC		
				--	))
					ROW_NUMBER() OVER (ORDER BY d.ID) AS ID,
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
					CASE	WHEN (EXISTS(SELECT TOP 1 ID FROM [dbo].[User] WHERE [Company] = d.[ID])) OR					
								  (EXISTS(SELECT TOP 1 [Distributor] FROM [dbo].[DistributorLabel] WHERE [Distributor] = d.[ID])) OR								  
								  (EXISTS(SELECT TOP 1 ID FROM [dbo].[Client] WHERE [Distributor] = d.[ID])) OR 
								  (EXISTS(SELECT TOP 1 ID FROM [dbo].[DistributorClientAddress] WHERE [Distributor] = d.[ID])) 
					THEN 0	
					ELSE 1 
					END
					AS CanDelete
				    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (cl.[Distributor]) FROM [dbo].[Client] cl WHERE cl.[Distributor] = d.[ID])) THEN 1 ELSE 0 END)) AS Clients,
				 --   CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (dl.[Distributor]) FROM [dbo].[DistributorLabel] dl WHERE dl.[Distributor] = d.[ID])) THEN 1 ELSE 0 END)) AS DistributorLabels,
				 --   CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (dplc.[ID]) FROM [dbo].[DistributorPriceLevelCost] dplc WHERE dplc.[Distributor] = d.[ID])) THEN 1 ELSE 0 END)) AS DistributorPriceLevelCosts,
				 --   CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (dpm.[Distributor]) FROM [dbo].[DistributorPriceMarkup] dpm WHERE dpm.[Distributor] = d.[ID])) THEN 1 ELSE 0 END)) AS DistributorPriceMarkups,
				 --   CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (od.[DespatchTo]) FROM [dbo].[Order] od WHERE od.[DespatchTo] = d.[ID])) THEN 1 ELSE 0 END)) AS DespatchTo,
				 --   CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (o.[Distributor]) FROM [dbo].[Order] o WHERE o.[Distributor] = d.[ID])) THEN 1 ELSE 0 END)) AS 'Order',
				 --   CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (os.[ShipTo]) FROM [dbo].[Order] os WHERE os.[ShipTo] = d.[ID])) THEN 1 ELSE 0 END)) AS ShipTo			
			FROM [dbo].[Company] d
			INNER JOIN [dbo].[User] u
				ON d.[Coordinator] = u.[ID]
			LEFT OUTER JOIN [dbo].[User] sc
				ON d.[SecondaryCoordinator] = sc.[ID]
			INNER JOIN [dbo].[Country] c
				ON d.[Country] = c.[ID]
			JOIN [dbo].[CompanyType] t
				ON d.[Type] = t.[ID]
			LEFT OUTER JOIN [dbo].[User] ow
				ON d.[Owner] = ow.[ID]
			INNER JOIN [dbo].[User] cr
				ON d.[Creator] = cr.[ID]
			INNER JOIN [dbo].[User] cm
				ON d.[Modifier] = cm.[ID]	 
			WHERE (d.[IsDistributor] = 1 AND
				   --d.[IsActive] = 1 AND 
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
		--SET @P_RecCount = 0
	--END
	
END


GO




--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

