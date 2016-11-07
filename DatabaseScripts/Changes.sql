USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_CloneOrder]    Script Date: 11/4/2016 3:17:20 PM ******/
DROP PROCEDURE [dbo].[SPC_CloneOrder]
GO

/****** Object:  StoredProcedure [dbo].[SPC_CloneOrder]    Script Date: 11/4/2016 3:17:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_CloneOrder]
(
 @P_UserID int,
 @P_ID int,
 @P_OrderIDs nvarchar(64)
)
AS 

BEGIN

 DECLARE @RetVal int
 DECLARE @Saved_Order_ID int
 DECLARE @Saved_Order_Detail_ID int

  BEGIN TRY
  -- Clone Order
  
  INSERT INTO [dbo].[Order]
  SELECT  GETDATE() AS[Date]
           ,[Client]
           ,[Distributor]
           ,GETDATE() AS [OrderSubmittedDate]
           ,DATEADD(day,28,GETDATE()) AS [EstimatedCompletionDate]
           ,GETDATE() AS [CreatedDate]
           ,GETDATE() AS [ModifiedDate]
           ,DATEADD(day,26,GETDATE()) AS [ShipmentDate]
           ,(SELECT ID FROM [dbo].OrderStatus WHERE Name = 'NEW') AS [Status]
           ,@P_UserID AS [Creator]
           ,[Modifier]
           ,[PaymentMethod]
           ,[OrderUsage]
           ,[PurchaseOrderNo]
           ,[Converted]
           ,[OldPONo]
           ,[Invoice]
           ,[IsTemporary]
           ,[ShipmentMode]
           ,[ShipTo]
           ,[DespatchTo]
           ,[IsWeeklyShipment]
           ,[IsCourierDelivery]
           ,[IsAdelaideWareHouse]
           ,[IsMentionAddress]
           ,[IsFollowingAddress]
           ,[Reservation]
           ,[IsShipToDistributor]
           ,[IsShipExistingDistributor]
           ,[IsShipNewClient]
           ,[IsDespatchDistributor]
           ,[IsDespatchExistingDistributor]
           ,[IsDespatchNewClient]
           ,[DeliveryOption]
           ,[IsDateNegotiable]
           ,[Notes]
           ,[IsAcceptedTermsAndConditions]
           ,[AddressType]
           ,[MYOBCardFile]
           ,[DeliveryCharges]
           ,[ArtWorkCharges]
           ,[OtherCharges]
           ,[OtherChargesDescription]
           ,[IsOtherDelivery]
           ,[OtherDeliveryDescription]
           ,[BillingAddress]
           ,[DespatchToAddress]
           ,[IsGSTExcluded] 
		   FROM [dbo].[Order] WHERE ID = @P_ID
       
	   SET @Saved_Order_ID = SCOPE_IDENTITY()

	   --Cloning Order Details

	   DECLARE @TempOrderDetail TABLE
		(
		 ID int
		 )

	   INSERT INTO @TempOrderDetail SELECT DATA FROM [dbo].Split(@P_OrderIDs,',') 
   
   DECLARE db_cursor CURSOR LOCAL FAST_FORWARD
					FOR SELECT * FROM @TempOrderDetail; 
	DECLARE @OrderDetail INT;

	OPEN db_cursor;
	FETCH NEXT FROM db_cursor INTO @OrderDetail WHILE @@FETCH_STATUS = 0  
	BEGIN

	INSERT INTO [dbo].[OrderDetail]
	SELECT [OrderType]
      ,[VisualLayout]
      ,[Pattern]
      ,[FabricCode]
      ,[VisualLayoutNotes]
      ,[NameAndNumbersFilePath]
      ,@Saved_Order_ID AS [Order]
      ,NULL AS [Status]
      ,DATEADD(day,26,GETDATE()) AS [ShipmentDate]
      ,DATEADD(day,28,GETDATE()) AS [SheduledDate]
      ,[IsRepeat]
      ,DATEADD(day,28,GETDATE()) AS[RequestedDate]
      ,[EditedPrice]
      ,[EditedPriceRemarks]
      ,[Reservation]
      ,[PhotoApprovalReq]
      ,[IsRequiredNamesNumbers]
      ,[IsBrandingKit]
      ,[IsLockerPatch]
      ,[ArtWork]
      ,[Label]
      ,[PaymentMethod]
      ,[ShipmentMode]
      ,[IsWeeklyShipment]
      ,[IsCourierDelivery]
      ,[DespatchTo]
      ,[PromoCode]
      ,[FactoryInstructions]
      ,[Surcharge]
      ,[DistributorSurcharge]
	  FROM [dbo].[OrderDetail] WHERE ID = @OrderDetail	  

	   SET @Saved_Order_Detail_ID = SCOPE_IDENTITY()

	  INSERT INTO [dbo].OrderDetailQty 
	  SELECT 
		@Saved_Order_Detail_ID AS [OrderDetail]
		,[Size]
		,'0' --[Qty]
		FROM [dbo].OrderDetailQty WHERE [OrderDetail] = @OrderDetail
		
	 FETCH NEXT FROM db_cursor INTO @OrderDetail
	END
	CLOSE db_cursor;
	DEALLOCATE db_cursor;
    
   SET @RetVal = 1
  
  END TRY
 BEGIN CATCH
 
  SET @RetVal = 0
  
 END CATCH
 SELECT @RetVal AS RetVal  
END



GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_TransferProductOrJobName]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_TransferProductOrJobName] 
GO

CREATE PROC [dbo].[SPC_TransferProductOrJobName] 
	@P_VisualLayout int = 0,
	@P_JobName int = 0,
	@P_ToDistributor int = 0,
	@P_ToJobName int = 0
AS
BEGIN

	DECLARE @FromDistributor int = 0

	SET @FromDistributor = (SELECT TOP 1 d.ID FROM [dbo].[Company] d
									INNER JOIN [dbo].[Client] c
										ON c.Distributor = d.ID
									INNER JOIN [dbo].[JobName] jn
										ON jn.Client = c.ID
									INNER JOIN [dbo].[VisualLayout] vl
										ON vl.Client = jn.ID
							WHERE (@P_VisualLayout = 0 OR vl.ID = @P_VisualLayout) AND (@P_JobName = 0 OR @P_JobName = jn.ID))


	DECLARE @ToDistributor int

	IF @P_ToDistributor = 0
		SET @ToDistributor =  (SELECT TOP 1 d.ID 
							   FROM [dbo].[Company] d
									INNER JOIN [dbo].[Client] c
										ON c.Distributor = d.ID
									INNER JOIN [dbo].[JobName] jn
										ON c.ID = jn.Client
								WHERE jn.ID = @P_ToJobName) 
	ELSE SET @ToDistributor = @P_ToDistributor

	IF @FromDistributor !=  @ToDistributor
	BEGIN
	
		CREATE TABLE #Transfers
		(
			[Order] int,
			[OrderDetail] int,
			[Copy] bit,
			[Label] int,
			[BillingAddress] int,
			[DespatchAddress] int,
			[CAddress] int,
			[NewLabel] int,
			[NewBillingAddress] int,
			[NewDespatchAddress] int,
			[NewCAddress] int
		)

		INSERT INTO #Transfers ([Order], [OrderDetail],Label,[BillingAddress],[DespatchAddress],[CAddress])
			SELECT
			o.ID AS  [Order],
			od.ID AS [OrderDetail],
			od.Label AS [Label],
			o.BillingAddress AS BillingAddress,
			o.DespatchToAddress AS DespatchAddress,
			od.DespatchTo  AS CAddress
			FROM [dbo].[Order] o
				INNER JOIN [dbo].[OrderDetail] od
					ON od.[Order] = o.ID
				INNER JOIN [dbo].[VisualLayout] vl
					ON od.VisualLayout = vl.ID
				INNER JOIN [dbo].[JobName] jn
					ON vl.Client = jn.ID
			WHERE (@P_JobName = 0 OR jn.ID = @P_JobName) AND (@P_VisualLayout = 0 OR vl.ID = @P_VisualLayout)
	
		CREATE TABLE #NewLabels (ID int,New int)

		UPDATE tfs
		SET tfs.NewLabel = ol.ID
		FROM [dbo].[Label] l
			INNER JOIN #Transfers tfs
				ON l.ID = tfs.Label
			LEFT OUTER JOIN [dbo].[DistributorLabel] odl
				ON odl.Distributor = @ToDistributor
			LEFT OUTER JOIN [dbo].[Label] ol
				ON odl.Label = ol.ID AND l.Name = ol.Name
		WHERE ol.ID IS NOT NULL

		MERGE INTO [dbo].[Label] AS t
		USING (SELECT DISTINCT  l.ID,l.Name,l.LabelImagePath,l.IsSample 
			   FROM [dbo].[Label] l
					INNER JOIN #Transfers tfs
						ON l.ID = tfs.Label
					LEFT OUTER JOIN [dbo].[DistributorLabel] odl
						ON odl.Distributor = @ToDistributor
					LEFT OUTER JOIN [dbo].[Label] ol
						ON odl.Label = ol.ID AND l.Name = ol.Name
				WHERE ol.ID IS NULL AND tfs.NewLabel IS NULL ) AS s
		ON 1=0 
		WHEN NOT MATCHED THEN INSERT (Name,LabelImagePath,IsSample)
		VALUES (s.Name,s.LabelImagePath,s.IsSample)
		OUTPUT s.[ID] AS ID,inserted.id AS New INTO #NewLabels;

		UPDATE t
		SET t.NewLabel = nl.New ,t.Copy = 1
		FROM  #Transfers t
		INNER JOIN #NewLabels nl
			ON t.Label = nl.ID


		INSERT INTO [dbo].[DistributorLabel]  (Distributor,Label)  
		SELECT DISTINCT @ToDistributor,t.NewLabel FROM #Transfers t
		WHERE t.Label IS NOT NULL AND t.Label >0
			AND t.Copy IS NOT NULL AND t.Copy = 1
			and T.NewLabel IS NOT NULL AND t.NewLabel >0


		UPDATE od
		SET od.Label = t.NewLabel
		FROM [dbo].[OrderDetail] od
			INNER JOIN [#Transfers] t
				ON t.OrderDetail = od.ID
		WHERE t.Label IS NOT NULL AND t.Label >0 AND t.NewLabel IS NOT NULL AND t.NewLabel > 0


		UPDATE #Transfers SET Copy = NULL 

		CREATE TABLE #NewBillingAddresses (ID int ,New int)

		UPDATE tfs
		SET tfs.NewBillingAddress = oba.ID
		FROM [dbo].[Order] o
			INNER JOIN #Transfers tfs
				ON tfs.[Order] = o.ID
			LEFT OUTER JOIN [dbo].[OrderDetail] od
				ON tfs.OrderDetail = od.ID
			LEFT OUTER JOIN [dbo].[DistributorClientAddress] ba
				ON o.BillingAddress = ba.ID
			LEFT OUTER JOIN [dbo].[DistributorClientAddress] oba
				ON oba.Distributor = @ToDistributor AND oba.CompanyName = ba.CompanyName AND oba.[Address] = ba.[Address] AND oba.PostCode = ba.PostCode

		MERGE INTO [dbo].[DistributorClientAddress] AS t
		USING (SELECT DISTINCT dca.ID,dca.[Address],dca.Suburb,dca.PostCode,dca.Country,dca.ContactName,dca.ContactPhone,dca.CompanyName,dca.[State],dca.Port,dca.EmailAddress,dca.AddressType,dca.Client,dca.IsAdelaideWarehouse,dca.Distributor 
				FROM [dbo].[DistributorClientAddress] dca
				INNER JOIN #Transfers trf
					ON dca.ID = trf.BillingAddress
				LEFT OUTER JOIN [dbo].[DistributorClientAddress] odca
					ON odca.Distributor = @ToDistributor AND odca.CompanyName = dca.CompanyName AND odca.[Address] = dca.[Address] AND odca.PostCode = dca.PostCode
				WHERE odca.ID IS NULL AND trf.NewBillingAddress IS NULL AND dca.ID != 105 ) AS s
		ON 1=0 
		WHEN NOT MATCHED THEN INSERT ([Address],Suburb,PostCode,Country,ContactName,ContactPhone,CompanyName,[State],Port,EmailAddress,AddressType,Client,IsAdelaideWarehouse,Distributor)
		VALUES (s.[Address],s.Suburb,s.PostCode,s.Country,s.ContactName,s.ContactPhone,s.CompanyName,s.[State],s.Port,s.EmailAddress,s.AddressType,s.Client,s.IsAdelaideWarehouse,@ToDistributor)
		OUTPUT s.[ID] AS ID,inserted.id AS New INTO #NewBillingAddresses ;

		UPDATE t
		SET t.NewBillingAddress = nba.New ,t.Copy = 1
		FROM  #Transfers t
		INNER JOIN #NewBillingAddresses nba
			ON t.BillingAddress = nba.ID

		UPDATE o
		SET o.BillingAddress = t.NewBillingAddress
		FROM [dbo].[Order] o
			INNER JOIN [#Transfers] t
				ON t.[Order] = o.ID
		WHERE t.BillingAddress IS NOT NULL AND t.BillingAddress >0
			 AND t.NewBillingAddress IS NOT NULL AND t.NewBillingAddress > 0

		CREATE TABLE #NewDespatchAddresses (ID int ,New int)

		UPDATE tfs
		SET tfs.NewDespatchAddress = oda.ID
		FROM [dbo].[Order] o
			INNER JOIN #Transfers tfs
				ON tfs.[Order] = o.ID
			LEFT OUTER JOIN [dbo].[OrderDetail] od
				ON tfs.OrderDetail = od.ID
			LEFT OUTER JOIN [dbo].[DistributorClientAddress] da
				ON o.DespatchToAddress = da.ID
			LEFT OUTER JOIN [dbo].[DistributorClientAddress] oda
				ON oda.Distributor = @ToDistributor AND oda.CompanyName = da.CompanyName AND oda.[Address] = da.[Address] AND oda.PostCode = da.PostCode

		MERGE INTO [dbo].[DistributorClientAddress] AS t
		USING (SELECT DISTINCT dca.ID,dca.[Address],dca.Suburb,dca.PostCode,dca.Country,dca.ContactName,dca.ContactPhone,dca.CompanyName,dca.[State],dca.Port,dca.EmailAddress,dca.AddressType,dca.Client,dca.IsAdelaideWarehouse,dca.Distributor 
				FROM [dbo].[DistributorClientAddress] dca
				INNER JOIN #Transfers trf
					ON dca.ID = trf.DespatchAddress
				LEFT OUTER JOIN [dbo].[DistributorClientAddress] odca
					ON odca.Distributor = @ToDistributor AND odca.CompanyName = dca.CompanyName AND odca.[Address] = dca.[Address] AND odca.PostCode = dca.PostCode
				WHERE odca.ID IS NULL AND trf.NewDespatchAddress IS NULL AND dca.ID != 105 ) AS s
		ON 1=0 
		WHEN NOT MATCHED THEN INSERT ([Address],Suburb,PostCode,Country,ContactName,ContactPhone,CompanyName,[State],Port,EmailAddress,AddressType,Client,IsAdelaideWarehouse,Distributor)
		VALUES (s.[Address],s.Suburb,s.PostCode,s.Country,s.ContactName,s.ContactPhone,s.CompanyName,s.[State],s.Port,s.EmailAddress,s.AddressType,s.Client,s.IsAdelaideWarehouse,@ToDistributor)
		OUTPUT s.[ID] AS ID,inserted.id AS New INTO #NewDespatchAddresses ;

		UPDATE t
		SET t.NewDespatchAddress = nba.New ,t.Copy = 1
		FROM  #Transfers t
		INNER JOIN #NewDespatchAddresses nba
			ON t.DespatchAddress = nba.ID

		UPDATE o
		SET o.DespatchToAddress = t.NewDespatchAddress
		FROM [dbo].[Order] o
			INNER JOIN [#Transfers] t
				ON t.[Order] = o.ID
		WHERE t.DespatchAddress IS NOT NULL AND t.DespatchAddress >0
			 AND t.NewDespatchAddress IS NOT NULL AND t.NewDespatchAddress > 0


		CREATE TABLE #NewCAddresses (ID int ,New int)

		UPDATE tfs
		SET tfs.[NewCAddress] = oca.ID
		FROM [dbo].[Order] o
			INNER JOIN #Transfers tfs
				ON tfs.[Order] = o.ID
			LEFT OUTER JOIN [dbo].[OrderDetail] od
				ON tfs.OrderDetail = od.ID
			LEFT OUTER JOIN [dbo].[DistributorClientAddress] ca
				ON od.DespatchTo = ca.ID
			LEFT OUTER JOIN [dbo].[DistributorClientAddress] oca
				ON oca.Distributor = @ToDistributor AND oca.CompanyName = ca.CompanyName AND oca.[Address] = ca.[Address] AND oca.PostCode = ca.PostCode

		MERGE INTO [dbo].[DistributorClientAddress] AS t
		USING (SELECT DISTINCT dca.ID,dca.[Address],dca.Suburb,dca.PostCode,dca.Country,dca.ContactName,dca.ContactPhone,dca.CompanyName,dca.[State],dca.Port,dca.EmailAddress,dca.AddressType,dca.Client,dca.IsAdelaideWarehouse,dca.Distributor 
				FROM [dbo].[DistributorClientAddress] dca
				INNER JOIN #Transfers trf
					ON dca.ID = trf.CAddress
				LEFT OUTER JOIN [dbo].[DistributorClientAddress] odca
					ON odca.Distributor = @ToDistributor AND odca.CompanyName = dca.CompanyName AND odca.[Address] = dca.[Address] AND odca.PostCode = dca.PostCode
				WHERE odca.ID IS NULL AND trf.NewCAddress IS NULL AND dca.ID != 105 ) AS s
		ON 1=0 
		WHEN NOT MATCHED THEN INSERT ([Address],Suburb,PostCode,Country,ContactName,ContactPhone,CompanyName,[State],Port,EmailAddress,AddressType,Client,IsAdelaideWarehouse,Distributor)
		VALUES (s.[Address],s.Suburb,s.PostCode,s.Country,s.ContactName,s.ContactPhone,s.CompanyName,s.[State],s.Port,s.EmailAddress,s.AddressType,s.Client,s.IsAdelaideWarehouse,@ToDistributor)
		OUTPUT s.[ID] AS ID,inserted.id AS New INTO #newCAddresses ;

		UPDATE t
		SET t.NewCAddress = nba.New ,t.Copy = 1
		FROM  #Transfers t
		INNER JOIN #NewCAddresses nba
			ON t.CAddress = nba.ID

		UPDATE od
		SET od.DespatchTo = t.NewCAddress
		FROM [dbo].[OrderDetail] od
			INNER JOIN [#Transfers] t
				ON t.[OrderDetail] = od.ID
		WHERE t.CAddress IS NOT NULL AND t.CAddress >0
			 AND t.NewCAddress IS NOT NULL AND t.NewCAddress > 0

		DROP TABLE #NewLabels
		DROP TABLE #NewBillingAddresses
		DROP TABLE #NewDespatchAddresses
		DROP TABLE #NewCAddresses
		DROP TABLE #Transfers

	END



	IF @P_VisualLayout = 0  AND @P_JobName > 0
	BEGIN
		DECLARE @ClientName nvarchar(250)
		DECLARE @Client int

		SET @Client = (SELECT TOP 1 cl.ID FROM [dbo].[Client] cl
							INNER JOIN [dbo].[JobName] jn
								ON cl.ID = jn.Client
						WHERE jn.ID = @P_JobName)

		SET @ClientName = (SELECT TOP 1 cl.Name FROM [dbo].[Client] cl
								WHERE cl.ID = @Client)
	

		IF NOT EXISTS (SELECT cl.ID FROM [dbo].[Company] di
								INNER JOIN  [dbo].[Client] cl
									ON cl.Distributor = di.ID
					WHERE cl.Name = @ClientName AND di.ID = @ToDistributor)
		BEGIN
			INSERT INTO [dbo].[Client] (Name,Distributor,[Description],FOCPenalty)
				SELECT TOP 1 Name,@ToDistributor,[Description],FOCPenalty 
				FROM [dbo].[Client] 
				WHERE ID = @Client
			SET @Client = SCOPE_IDENTITY() 
		END
		ELSE 
		BEGIN
			SET @Client = (SELECT TOP 1 cl.ID FROM [dbo].[Company] di
								INNER JOIN  [dbo].[Client] cl
									ON cl.Distributor = di.ID
					WHERE cl.Name = @ClientName AND di.ID = @ToDistributor)
		END
	
		UPDATE [dbo].[JobName] SET Client = @Client WHERE ID = @P_JobName
	END

	IF @P_VisualLayout > 0 AND @P_ToJobName > 0
	BEGIN
		UPDATE vl
		SET vl.Client = @P_ToJobName
		FROM [dbo].[VisualLayout] vl
			WHERE ID = @P_VisualLayout
	END


END


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_TransferAddressesAndLabels]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_TransferAddressesAndLabels]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_TransferJobName]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_TransferJobName]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_TransferVisualLayout]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_TransferVisualLayout]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

UPDATE dca
SET dca.CompanyName = 'TBA'
FROM [dbo].[DistributorClientAddress] dca
	WHERE dca.CompanyName = 'TO BE ADVISED'
GO

SELECT d.ID INTO #TempDistributors
FROM [dbo].[Company] d
	LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
		ON dca.Distributor = d.ID AND dca.CompanyName = 'tba'
WHERE dca.ID IS NULL

INSERT INTO [dbo].[DistributorClientAddress] ([Address]
      ,[Suburb]
      ,[PostCode]
      ,[Country]
      ,[ContactName]
      ,[ContactPhone]
      ,[CompanyName]
      ,[State]
      ,[Port]
      ,[EmailAddress]
      ,[AddressType]
      ,[Client]
      ,[IsAdelaideWarehouse]
      ,[Distributor])
	SELECT 'TBA','TBA','TBA',14,'TBA','TBA','TBA','TBA',NULL,'TBA',0,NULL,0,td.ID 
	FROM #TempDistributors td
DROP TABLE #TempDistributors

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--


UPDATE o
SET o.BillingAddress = dca.ID
FROM [dbo].[Order] o
	INNER JOIN [dbo].[OrderDetail] od
		ON od.[Order] = o.ID
	INNER JOIN [dbo].[VisualLayout] vl
		ON od.VisualLayout = vl.ID
	INNER JOIN [dbo].[JobName] jn
		ON vl.Client = jn.ID
	INNER JOIN [dbo].[Client] c
		ON jn.Client = c.ID
	INNER JOIN [dbo].[Company] d
		ON c.Distributor = d.ID
	INNER JOIN [dbo].[DistributorClientAddress] dca
		ON dca.Distributor = d.ID
WHERE o.BillingAddress IS NULL AND dca.CompanyName = 'TBA'

UPDATE o
SET o.DespatchToAddress = dca.ID
FROM [dbo].[Order] o
	INNER JOIN [dbo].[OrderDetail] od
		ON od.[Order] = o.ID
	INNER JOIN [dbo].[VisualLayout] vl
		ON od.VisualLayout = vl.ID
	INNER JOIN [dbo].[JobName] jn
		ON vl.Client = jn.ID
	INNER JOIN [dbo].[Client] c
		ON jn.Client = c.ID
	INNER JOIN [dbo].[Company] d
		ON c.Distributor = d.ID
	INNER JOIN [dbo].[DistributorClientAddress] dca
		ON dca.Distributor = d.ID
WHERE o.DespatchToAddress IS NULL AND dca.CompanyName = 'TBA'

UPDATE o
SET o.BillingAddress = dca.ID
FROM [dbo].[Order] o
	INNER JOIN [dbo].[OrderDetail] od
		ON od.[Order] = o.ID
	INNER JOIN [dbo].[VisualLayout] vl
		ON od.VisualLayout = vl.ID
	INNER JOIN [dbo].[JobName] jn
		ON vl.Client = jn.ID
	INNER JOIN [dbo].[Client] c
		ON jn.Client = c.ID
	INNER JOIN [dbo].[Company] d
		ON c.Distributor = d.ID
	INNER JOIN [dbo].[DistributorClientAddress] dca
		ON dca.Distributor = d.ID
WHERE o.BillingAddress = 105 AND dca.CompanyName = 'TBA'

UPDATE o
SET o.DespatchToAddress = dca.ID
FROM [dbo].[Order] o
	INNER JOIN [dbo].[OrderDetail] od
		ON od.[Order] = o.ID
	INNER JOIN [dbo].[VisualLayout] vl
		ON od.VisualLayout = vl.ID
	INNER JOIN [dbo].[JobName] jn
		ON vl.Client = jn.ID
	INNER JOIN [dbo].[Client] c
		ON jn.Client = c.ID
	INNER JOIN [dbo].[Company] d
		ON c.Distributor = d.ID
	INNER JOIN [dbo].[DistributorClientAddress] dca
		ON dca.Distributor = d.ID
WHERE o.DespatchToAddress = 105 AND dca.CompanyName = 'TBA'


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--


UPDATE o
SET o.DespatchToAddress = 1487
FROM [dbo].[Order] o
WHERE o.DespatchToAddress = 416


UPDATE o
SET o.BillingAddress = 1487
FROM [dbo].[Order] o
WHERE o.BillingAddress = 416


UPDATE o
SET o.DespatchToAddress = 1487
FROM [dbo].[Order] o
WHERE o.DespatchToAddress = 254

UPDATE o
SET o.BillingAddress = 1487
FROM [dbo].[Order] o
WHERE o.BillingAddress = 254

-- IDM Sports 
UPDATE o
SET o.DespatchToAddress = 905
FROM [dbo].[Order] o
WHERE o.DespatchToAddress = 1069


UPDATE o
SET o.BillingAddress = 905
FROM [dbo].[Order] o
WHERE o.BillingAddress = 1069


UPDATE o
SET o.DespatchToAddress = 905
FROM [dbo].[Order] o
WHERE o.DespatchToAddress = 1506

UPDATE o
SET o.BillingAddress = 905
FROM [dbo].[Order] o
WHERE o.BillingAddress = 1506


DELETE [dbo].[DistributorClientAddress] WHERE ID IN(1069,1506)

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
