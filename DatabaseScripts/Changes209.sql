USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetPatternDevelopments]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_GetPatternDevelopments]
GO

CREATE PROC [dbo].[SPC_GetPatternDevelopments]
AS 
BEGIN
	
	SELECT
		pd.ID, 
		pd.[Spec],
		pd.[LectraPattern],
		pd.[WhiteSample],
		pd.LogoPositioning,
		pd.Photo,
		pd.Fake3DVis,
		pd.NestedWireframe,
		pd.BySizeWireframe,
		pd.PreProd,
		pd.SpecChart,
		pd.FinalTemplate,
		pd.TemplateApproved,
		pd.Remarks,
		p.[NickName] AS [Description],
		p.Number AS PatternNumber,
		ISNULL(lm.GivenName + ' '+lm.FamilyName,'') AS LastModifier,
		pd.LastModified,
		ISNULL(cr.GivenName + ' ' + cr.FamilyName,'') AS Creator,
		pd.Created AS Created
	FROM [dbo].PatternDevelopment pd
		INNER JOIN [dbo].[Pattern] p
			ON p.ID = pd.Pattern
		LEFT OUTER JOIN [dbo].[User] lm
			ON pd.LastModifier = lm.ID
		INNER JOIN [dbo].[User] cr
			ON pd.Creator = cr.ID
	ORDER BY  pd.LastModified DESC

END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetCostSheetDetails]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_GetCostSheetDetails]
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
		PatternNumber nvarchar(64),
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
		IndimanModifiedDate datetime2 NULL,
		FabricID int NOT NULL
	)	
	
	DECLARE @CostSheetDetails TABLE
	(
		CostSheet int,
		PatternID int,
		PatternNumber nvarchar(64),
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
		IndimanModifiedDate datetime2 NULL,
		FabricID int NOT NULL			
	)
	
	INSERT INTO @CostSheets
		SELECT	ch.[ID] AS CostSheet
				,p.ID AS PatternID
				,p.[Number] AS PatternNumber
				,p.[NickName] AS Pattern
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
				ch.IndimanModifiedDate,
				fc.ID
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
	DECLARE @PatternNumber NVARCHAR(64);
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
	DECLARE @FabricID int;

	OPEN db_cursor;
	FETCH NEXT FROM db_cursor INTO @CostSheet, @PatternID, @PatternNumber, @Pattern, @Fabric, @Category, @SMV, @SMVRate, @HPCost, @LabelCost, @Packing, @Wastage, @Finance, @QuotedFOBCost
	, @DutyRate, @CONS1, @CONS2, @CONS3, @Rate1, @Rate2, @Rate3, @ExchangeRate, @InkCons, @InkRate, @SubCons, @PaperRate, @AirFregiht, @ImpCharges, @MGTOH
	, @IndicoOH, @Depr, @MarginRate, @QuotedCIF, @IndimanCIF, @ShowToIndico, @ModifiedDate, @IndimanModifiedDate,@FabricID;
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
			@PatternNumber,
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
			@IndimanModifiedDate,
			@FabricID		
		)		   

		   FETCH NEXT FROM db_cursor INTO @CostSheet, @PatternID,@PatternNumber, @Pattern, @Fabric, @Category, @SMV, @SMVRate, @HPCost, @LabelCost, @Packing, @Wastage, @Finance, @QuotedFOBCost
	, @DutyRate, @CONS1, @CONS2, @CONS3, @Rate1, @Rate2, @Rate3, @ExchangeRate, @InkCons, @InkRate, @SubCons, @PaperRate, @AirFregiht, @ImpCharges, @MGTOH
	, @IndicoOH, @Depr, @MarginRate, @QuotedCIF, @IndimanCIF, @ShowToIndico, @ModifiedDate, @IndimanModifiedDate,@FabricID;
	END;
	CLOSE db_cursor;
	DEALLOCATE db_cursor;
	
	SELECT * FROM @CostSheetDetails ORDER BY CostSheet
		  
 END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewOrderDetails]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_ViewOrderDetails]
GO


CREATE PROCEDURE [dbo].[SPC_ViewOrderDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',
	@P_LogCompanyID AS int = 0,
	@P_Status AS nvarchar(255),
	@P_Coordinator AS int = 0,
	@P_Distributor AS int = 0,
	@P_Client AS int = 0,
	@P_SelectedDate1 AS datetime2(7) = NULL,
	@P_SelectedDate2 AS datetime2(7) = NULL,
	@P_DistributorClientAddress AS int = 0	 
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @orderid AS int;
	DECLARE @status AS TABLE ( ID int )
	
	IF (ISNUMERIC(@P_SearchText) = 1) 
		BEGIN
			SET @orderid = CONVERT(INT, @P_SearchText)		
		END
	ELSE
		BEGIN	
			SET @orderid = 0
		END;
	
	INSERT INTO @status (ID) SELECT DATA FROM [dbo].Split(@P_Status,',');
	
	SELECT 			
		   od.[ID] AS OrderDetail
		  ,(ISNULL(od.EditedPrice, 0)  + ( od.DistributorSurcharge  * ISNULL(od.EditedPrice, 0) / 100  ) ) AS EditedPrice
		  ,ot.[Name] AS OrderType		  
		  ,(vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),'') ) AS VisualLayout		  
		  ,ISNULL(od.[VisualLayout],0) AS VisualLayoutID		  
		   ,vl.Pattern AS PatternID		  
		   ,p.Number + ' - ' + p.NickName AS Pattern		  
		  ,vl.FabricCode AS FabricID
		   , f.[Code] + ' - ' + f.[Name] AS Fabric		  
		    ,CASE WHEN	(ISNULL(od.[VisualLayoutNotes],'') = '') AND
						(ISNULL(o.[Notes],'') = '') AND
						(ISNULL(od.EditedPriceRemarks,'') = '') AND
						(ISNULL(od.FactoryInstructions,'') = '')
			THEN 0	
			ELSE 1 
			END
			AS HasNotes
		  
		  ,o.[ID] AS 'Order'
		  ,ISNULL(ods.[Name], 'New') AS OrderDetailStatus
		  ,ISNULL(od.[Status], 0) AS OrderDetailStatusID
		  ,od.[ShipmentDate] AS ShipmentDate
		  ,od.[SheduledDate] AS SheduledDate      
		  ,od.[RequestedDate] AS RequestedDate
		  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]),0) AS Quantity      
		  ,(SELECT DATEDIFF(day, od.[RequestedDate], od.[SheduledDate])) AS 'DateDiffrence'
		  ,ISNULL(o.[OldPONo], '') AS 'PurONo'
		  ,c.[Name] AS Distributor
		  ,u.[GivenName] + ' ' + u.[FamilyName] AS Coordinator		  
		  ,ISNULL (cl.Name, '') AS Client
		  ,ISNULL (j.Name, '') AS JobName		  
		  ,os.[Name] AS OrderStatus
		  ,o.[Status] AS OrderStatusID
		  ,urc.[GivenName] + ' ' + urc.[FamilyName] AS Creator
		  ,o.[Creator] AS CreatorID
		  ,o.[CreatedDate] AS CreatedDate
		  ,urm.[GivenName] + ' ' + urm.[FamilyName] AS Modifier
		  ,o.[ModifiedDate] AS ModifiedDate
		  ,ISNULL(pm.[Name], '') AS PaymentMethod
		  ,ISNULL(sm.[Name], '') AS ShipmentMethod
		  ,od.[IsWeeklyShipment]  AS WeeklyShipment
		  --,od.[IsCourierDelivery]  AS CourierDelivery
		  --,od.[IsAdelaideWareHouse] AS AdelaideWareHouse
		  --,od.[IsFollowingAddress] AS FollowingAddress
		  ,ISNULL(bdca.[CompanyName], '') AS BillingAddress
		  ,ISNULL(ddca.[CompanyName] , '') AS ShippingAddress
		  ,ISNULL(CASE WHEN od.IsWeeklyShipment = 1 THEN 'ADELAIDE' ELSE ddp.[Name] END, '') AS DestinationPort
		  ,ISNULL(vl.[ResolutionProfile], 0 ) AS ResolutionProfile
		  ,o.[IsAcceptedTermsAndConditions] AS IsAcceptedTermsAndConditions
		  --,od.Surcharge
		  ,cl.FOCPenalty
		  ,ISNULL(dta.CompanyName, '') AS DespatchTo --newly added
	  FROM [dbo].[OrderDetail] od	
		INNER JOIN [dbo].[PaymentMethod] pm
			ON od.[PaymentMethod] = pm.[ID]
		INNER JOIN [dbo].[ShipmentMode] sm
			ON od.[ShipmentMode] = sm.[ID]					
		INNER JOIN [dbo].[VisualLayout] vl
			ON od.[VisualLayout] = vl.[ID]	
		INNER JOIN [dbo].[OrderType] ot
			ON od.[OrderType] = ot.[ID]		
		LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
			ON od.[Status] = ods.[ID]

		INNER JOIN  [dbo].[Order] o	
			ON o.[ID] = od.[Order]			
		INNER JOIN [dbo].[OrderStatus] os
			ON o.[Status] = os.[ID]					
		INNER JOIN [dbo].[User] urc
			ON o.[Creator] = urc.[ID]
		INNER JOIN [dbo].[User] urm
			ON o.[Modifier] = urm.[ID]	
				
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] bdca
			ON o.[BillingAddress] = bdca.[ID]

		LEFT OUTER JOIN [dbo].[DistributorClientAddress] ddca
			ON o.[DespatchToAddress] = ddca.[ID]
		LEFT OUTER JOIN [dbo].[DestinationPort] ddp
			ON ddca.[Port] = ddp.[ID] 	
			
		INNER JOIN [dbo].[Pattern] p
			ON vl.[Pattern] = p.[ID]
		INNER JOIN [dbo].[FabricCode] f
			ON vl.FabricCode = f.[ID]
		INNER JOIN [dbo].[JobName] j
			ON vl.[Client] = j.[ID]
		INNER JOIN [dbo].[Client] cl
			ON j.[Client] = cl.[ID]	
		INNER JOIN [dbo].[Company] c
			ON cl.Distributor = c.[ID]
		LEFT OUTER JOIN [dbo].[User] u
			ON c.[Coordinator] = u.[ID]
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] dta
			ON dta.ID = od.DespatchTo
	WHERE (@P_SearchText = '' OR
			o.[ID] = @orderid OR
		   o.[OldPONo] LIKE '%' + @P_SearchText + '%' OR
		   u.[GivenName]  LIKE '%' + @P_SearchText + '%' OR
		   u.[FamilyName] LIKE '%' + @P_SearchText + '%' OR		  
		   vl.[NamePrefix] LIKE '%' + @P_SearchText + '%' OR 
		   vl.[NameSuffix] LIKE '%' + @P_SearchText + '%' OR 
		   ods.[Name] LIKE '%' + @P_SearchText + '%' OR 
		   ot.[Name] LIKE '%' + @P_SearchText + '%' OR
		   c.[Name] LIKE '%' + @P_SearchText + '%' OR 
		   cl.[Name] LIKE '%' + @P_SearchText + '%'   
			) AND
		   (@P_Status = '' OR  (os.[ID] IN (SELECT ID FROM @status)) )  AND											   
		  (@P_LogCompanyID = 0 OR c.[ID] = @P_LogCompanyID)	AND
		  (@P_Coordinator = 0 OR c.[Coordinator] = @P_Coordinator ) AND				  
		  (@P_Distributor = 0 OR cl.Distributor = @P_Distributor)	AND
		  (@P_Client = 0 OR cl.[ID] = @P_Client) AND				  
		  (@P_DistributorClientAddress = 0 OR o.[BillingAddress] = @P_DistributorClientAddress) AND
		  ((@P_SelectedDate1 IS NULL AND @P_SelectedDate2 IS NULL) OR (o.[Date] BETWEEN @P_SelectedDate1 AND @P_SelectedDate2))	
	--ORDER BY o.[ID] DESC
END

GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/Transfers.aspx','Transfer Job Names And Products','Transfer Job Names And Products')	 
SET @PageId = SCOPE_IDENTITY()

 SET @MenuItemMenuId =(SELECT TOP 1 mi.ID FROM [dbo].[MenuItem] mi
						INNER JOIN [dbo].[Page] p
							ON mi.[Page] = p.ID
						WHERE mi.Name = 'Manage' AND mi.Parent IS NULL )
			
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Transfers', 'Transfer Job Names And Products', 1, @MenuItemMenuId, 7, 1)
SET @MenuItemId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 5)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 7)

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_TransferJobName]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_TransferJobName]
GO

CREATE PROC [dbo].[SPC_TransferJobName]
	@P_JobName int,
	@P_Distributor int
AS
BEGIN
	DECLARE @Client int 
	DECLARE @ClientDistributor int 
	DECLARE @ClientName nvarchar(64)

	SET @Client = (SELECT TOP 1 cl.ID FROM [dbo].[Client] cl 
						INNER JOIN [dbo].[JobName] jn
							ON cl.ID = jn.Client
				   WHERE jn.ID = @P_JobName)

	SET @ClientDistributor = (SELECT TOP 1 d.ID 
							FROM [dbo].[Client] c
								INNER JOIN [dbo].[Company] d
									ON c.Distributor = d.ID
							WHERE c.ID = @Client)

	SET @ClientName = (SELECT TOP 1 cl.Name FROM [dbo].[Client] cl 
						    WHERE cl.ID = @Client)



	IF NOT EXISTS (SELECT cl.ID FROM [dbo].[Company] di
							INNER JOIN  [dbo].[Client] cl
								ON cl.Distributor = di.ID
			   WHERE cl.Name = @ClientName AND di.ID = @P_Distributor)
	BEGIN
		INSERT INTO [dbo].[Client] (Name,Distributor,[Description],FOCPenalty)
			SELECT TOP 1 Name,@P_Distributor,[Description],FOCPenalty 
			FROM [dbo].[Client] 
			WHERE ID = @Client
		SET @Client = SCOPE_IDENTITY()
	END
	ELSE 
	BEGIN
		SET @Client = (SELECT TOP 1 cl.ID FROM [dbo].[Company] di
							INNER JOIN  [dbo].[Client] cl
								ON cl.Distributor = di.ID
			   WHERE cl.Name = @ClientName AND di.ID = @P_Distributor)
	END

	UPDATE [dbo].[JobName] SET Client = @Client WHERE ID = @P_JobName
END
GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_TransferVisualLayout]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_TransferVisualLayout]
GO

CREATE PROC [dbo].[SPC_TransferVisualLayout]
	@P_VisualLayout int,
	@P_JobName int
AS
BEGIN
	UPDATE [dbo].[VisualLayout] SET Client = @P_JobName WHERE ID = @P_VisualLayout
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--




