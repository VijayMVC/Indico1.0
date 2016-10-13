USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetBackOrdersWeeklySummary]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_GetBackOrdersWeeklySummary]
GO

CREATE PROC [dbo].[SPC_GetBackOrdersWeeklySummary]
    @P_FromETD datetime2(7) = NULL,
	@P_ToETD datetime2(7) = NULL
AS
BEGIN
	DECLARE @StartETD datetime2(7)
	DECLARE @EndETD datetime2(7)

	DECLARE @LastOD datetime2(7)
	SET @LastOD = (SELECT  TOP 1  od.ShipmentDate
							 FROM [dbo].[OrderDetail] od
								INNER JOIN [dbo].[Order] o
									ON od.[Order] = o.ID
								INNER JOIN [dbo].[OrderStatus] os
									ON o.[Status] = os.ID  
					WHERE os.ID != 28 AND os.ID != 18 
					ORDER BY od.ShipmentDate DESC)

	DECLARE @LastRes datetime2(7)
	SET @LastRes = (SELECT TOP 1  r.ShipmentDate FROM [dbo].[Reservation] r WHERE r.Qty >0 ORDER BY r.ShipmentDate DESC)
	
	IF (@P_FromETD IS NULL)
		SET @StartETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE CONVERT(date,WeekendDate) >= CONVERT(date,GETDATE()) ORDER BY WeekendDate)
	ELSE
		SET @StartETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE WeekendDate >= @P_FromETD ORDER BY WeekendDate)
	
	IF (@P_ToEtd IS NULL)
	BEGIN
		IF (@LastOD IS NOT NULL AND @LastOD > @StartETD)
		BEGIN
			SET @EndETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity]  WHERE WeekendDate >= @LastOD ORDER BY WeekendDate)
			IF (@LastRes IS NOT NULL AND @LastRes > @EndETD)
				SET @EndETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity]  WHERE WeekendDate >= @LastRes ORDER BY WeekendDate)
		END
		ELSE
			SET @EndETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity]  WHERE WeekendDate >= DATEADD(MONTH,2,@StartETD) ORDER BY WeekendDate)
	END
	ELSE
		SET @EndETD = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE WeekendDate >= @P_ToETD ORDER BY WeekendDate)
			
	IF OBJECT_ID('tempdb..#data1') IS NOT NULL
			DROP TABLE #data1
	SELECT  o.ID AS ID1,
			odq.Qty,
			od.ID AS OrderDetail,
			os.Name AS OrderStatusName,
			ods.Name AS OrderDetailStatusName,
			i.ItemType,
			ot.ID AS OrderTypeID,
			ot.Name AS OrderTypeName,
			--SUM(odq.Qty) AS QtySum,
			od.ShipmentDate INTO #data1
	FROM [dbo].[Order] o
		INNER JOIN [dbo].[OrderDetail] od
			ON o.ID = od.[Order]
		INNER JOIN [dbo].[OrderDetailQty] odq
			ON  odq.OrderDetail = od.ID
		INNER JOIN [dbo].[OrderType] ot
			ON od.OrderType = ot.ID
		INNER JOIN [dbo].[Pattern] p
			ON p.ID = od.Pattern
		INNER JOIN [dbo].[Item] i
			ON p.Item = i.ID
		INNER JOIN [OrderStatus] os
			ON o.[Status] = os.ID
		LEFT OUTER JOIN [OrderDetailStatus] ods
			ON od.[Status] = ods.ID
	WHERE od.ShipmentDate >= DATEADD(DAY,-6,@StartETD) AND od.ShipmentDate <= @EndETD AND os.ID NOT IN (18,22,23,24,28,31)

	IF OBJECT_ID('tempdb..#data2') IS NOT NULL
			DROP TABLE #data2
	SELECT	r.[Qty],
		i.ItemType,
		r.ShipmentDate INTO #data2
	FROM [dbo].[Reservation] r
		INNER JOIN [dbo].[Pattern] p
			ON p.ID = r.Pattern
		INNER JOIN [dbo].[Item] i
			ON p.Item = i.ID
	WHERE  r.ShipmentDate >= DATEADD(DAY,-6,@StartETD)
		AND r.ShipmentDate <= @EndETD

	SELECT 
		(CONVERT(nvarchar(2), ((YEAR( GETDATE() ) % 100 ))) + '/' + CONVERT(nvarchar(3), wpc.WeekNo)) AS WeekNumber,
		wpc.WeekNo ,
		wpc.WeekendDate,
		wpc.OrderCutOffDate,
		wpc.EstimatedDateOfDespatch,
		wpc.EstimatedDateOfArrival,
		ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND (OrderStatusName  != 'Indico Hold' AND OrderStatusName != 'Indiman Hold' 
					AND OrderStatusName != 'Factory Hold' AND OrderStatusName != 'On Hold')),0) AS PoloFirms,
		ISNULL((SELECT SUM(Qty) FROM #data2 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate), 0) AS PoloReservations,
		ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) 
				AND ShipmentDate <= wpc.WeekendDate AND (OrderStatusName = 'Indico Hold' OR OrderStatusName = 'Indiman Hold' 
					OR OrderStatusName = 'Factory Hold' OR OrderDetailStatusName = 'On Hold')), 0) AS PoloHolds,
		ISNULL(wpcd1.TotalCapacity, 0) AS PoloCapacity,
		ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND ItemType = 2), 0) AS OuterWareFirms,
		ISNULL(wpcd2.TotalCapacity,0) AS OuterwareCapacity,
		--ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate AND Qty <= 5),0) AS Qty,
		ISNULL((SELECT SUM(t.Qty) FROM (SELECT SUM(Qty) AS Qty FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) AND ShipmentDate <= wpc.WeekendDate  GROUP BY #data1.OrderDetail HAVING SUM(Qty) <= 5) t), 0) AS UptoFiveItems,
		ISNULL((wpcd1.FivePcsCapacity + wpcd2.FivePcsCapacity), 0) AS UptoFiveItemsCapacity,
		ISNULL((SELECT SUM(Qty) FROM #data1 WHERE ShipmentDate >= DATEADD(DAY, -6, wpc.WeekendDate) 
				AND ShipmentDate <= wpc.WeekendDate AND OrderTypeName LIKE '%SAMPLE%'), 0) AS [Samples],
		ISNULL((wpcd1.SampleCapacity +  wpcd2.SampleCapacity), 0) AS SampleCapacity
	FROM WeeklyProductionCapacity wpc
		LEFT OUTER JOIN WeeklyProductionCapacityDetails wpcd1
			ON wpcd1.WeeklyProductionCapacity = wpc.ID AND wpcd1.ItemType = 1
		LEFT OUTER JOIN WeeklyProductionCapacityDetails wpcd2
			ON wpcd2.WeeklyProductionCapacity = wpc.ID AND wpcd2.ItemType = 2
	WHERE wpc.WeekendDate >= @StartETD AND wpc.WeekendDate <= @EndETD
	--WHERE DATEPART(WEEK,wpc.WeekendDate) >= DATEPART(WEEK,@StartETD) AND DATEPART(YEAR,wpc.WeekendDate) >= DATEPART(YEAR,@StartETD)
	--	AND DATEPART(WEEK,wpc.WeekendDate) <= DATEPART(WEEK,@EndETD) AND DATEPART(YEAR,wpc.WeekendDate) <= DATEPART(YEAR,@EndETD)
END


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

ALTER TABLE [dbo].[Label]
ADD IsActive bit

ALTER TABLE [dbo].[Label] ADD CONSTRAINT DF_Label_IsActive DEFAULT  1 FOR IsActive

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
	DECLARE @JobName int
	DECLARE @Distributor int
	SET @JobName = @P_JobName
	SET @Distributor = @P_Distributor

	SET @Client = (SELECT TOP 1 cl.ID FROM [dbo].[Client] cl
						INNER JOIN [dbo].[JobName] jn
							ON cl.ID = jn.Client
					WHERE jn.ID = @JobName)

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
				WHERE cl.Name = @ClientName AND di.ID = @Distributor)
	BEGIN
		INSERT INTO [dbo].[Client] (Name,Distributor,[Description],FOCPenalty)
			SELECT TOP 1 Name,@Distributor,[Description],FOCPenalty 
			FROM [dbo].[Client] 
			WHERE ID = @Client
		SET @Client = SCOPE_IDENTITY() 
	END
	ELSE 
	BEGIN
		SET @Client = (SELECT TOP 1 cl.ID FROM [dbo].[Company] di
							INNER JOIN  [dbo].[Client] cl
								ON cl.Distributor = di.ID
				WHERE cl.Name = @ClientName AND di.ID = @Distributor)
	END
	
	UPDATE [dbo].[JobName] SET Client = @Client WHERE ID = @JobName
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_TransferDistributor]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_TransferDistributor]
GO


CREATE PROCEDURE [dbo].[SPC_TransferDistributor]
	@P_FromDistributor int,
	@P_ToDistributor int
AS
	BEGIN
		IF (@P_FromDistributor > 0 AND @P_ToDistributor > 0)
		BEGIN

			UPDATE [dbo].[Client] SET Distributor = @P_ToDistributor
				WHERE Distributor = @P_FromDistributor

			UPDATE [dbo].[DistributorClientAddress]
				SET Distributor = @P_ToDistributor
			WHERE Distributor = @P_FromDistributor

			UPDATE [dbo].[DistributorLabel]
				SET Distributor = @P_ToDistributor
			WHERE Distributor = @P_FromDistributor

		END
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

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_TransferAddressesAndLabels]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_TransferAddressesAndLabels]
GO


CREATE PROC [dbo].[SPC_TransferAddressesAndLabels]
	@P_JobName int,
	@P_Distributor int
AS
BEGIN
	BEGIN TRANSACTION [Transaction]
	BEGIN TRY

		DECLARE @JobName int
		DECLARE @Distributor int
		DECLARE @Client int 
		DECLARE @ClientDistributor int 
		SET @JobName = @P_JobName
		SET @Distributor = @P_Distributor

		SET @Client = (SELECT TOP 1 cl.ID FROM [dbo].[Client] cl
							INNER JOIN [dbo].[JobName] jn
								ON cl.ID = jn.Client
					   WHERE jn.ID = @JobName)

		SET @ClientDistributor = (SELECT TOP 1 d.ID
								FROM [dbo].[Client] c
									INNER JOIN [dbo].[Company] d
										ON c.Distributor = d.ID
								WHERE c.ID = @Client)
	
		CREATE TABLE #billingAddresses (ID int)
		CREATE TABLE #newBillingAddresses (ID int , New int)

		CREATE TABLE #despatchAddresses (ID int)
		CREATE TABLE #newDespatchAddresses (ID int, New int)

		CREATE TABLE #curAddresses (ID int)
		CREATE TABLE #newcurAddresses (ID int , New int)

	
		INSERT INTO #billingAddresses (ID) 
			SELECT DISTINCT o.BillingAddress
			FROM [dbo].[Order] o 
				INNER JOIN [dbo].[OrderDetail] od
					ON od.[Order] =o.ID
				INNER JOIN [dbo].[VisualLayout] vl
					ON vl.ID = od.VisualLayout
				INNER JOIN [dbo].[JobName] jn
					ON vl.Client = jn.ID
				INNER JOIN [dbo].[DistributorClientAddress] dca
					ON o.BillingAddress = dca.ID
				LEFT OUTER JOIN [dbo].[DistributorClientAddress] dcac
					ON dca.Suburb=dcac.Suburb AND 
						dca.PostCode=dcac.PostCode AND dca.Country=dcac.Country AND dca.ContactName=dcac.ContactName AND
						dca.ContactPhone=dcac.ContactPhone AND dca.CompanyName=dcac.CompanyName AND dca.[State]=dcac.[State] AND
						dca.Port=dcac.Port AND dca.EmailAddress=dcac.EmailAddress AND dca.AddressType=dcac.AddressType AND 
						dca.Client=dcac.Client AND dca.IsAdelaideWarehouse=dcac.IsAdelaideWarehouse AND dca.Distributor= @Distributor
			WHERE jn.ID = @JobName AND dcac.ID IS NULL


		INSERT INTO #despatchAddresses (ID) 
			SELECT DISTINCT o.DespatchToAddress
			FROM [dbo].[Order] o 
				INNER JOIN [dbo].[OrderDetail] od
					ON od.[Order] =o.ID
				INNER JOIN [dbo].[VisualLayout] vl
					ON vl.ID = od.VisualLayout
				INNER JOIN [dbo].[JobName] jn
					ON vl.Client = jn.ID
				INNER JOIN [dbo].[DistributorClientAddress] dca
					ON o.DespatchToAddress = dca.ID
				LEFT OUTER JOIN [dbo].[DistributorClientAddress] dcac
					ON dca.Suburb=dcac.Suburb AND 
						dca.PostCode=dcac.PostCode AND dca.Country=dcac.Country AND dca.ContactName=dcac.ContactName AND
						dca.ContactPhone=dcac.ContactPhone AND dca.CompanyName=dcac.CompanyName AND dca.[State]=dcac.[State] AND
						dca.Port=dcac.Port AND dca.EmailAddress=dcac.EmailAddress AND dca.AddressType=dcac.AddressType AND 
						dca.Client=dcac.Client AND dca.IsAdelaideWarehouse=dcac.IsAdelaideWarehouse AND dca.Distributor= @Distributor
				LEFT OUTER JOIN #billingAddresses ba
					ON ba.ID = o.DespatchToAddress
			WHERE jn.ID = @JobName AND ba.ID IS NULL AND dcac.ID IS NULL

		INSERT INTO #curAddresses (ID) 
			SELECT DISTINCT od.DespatchTo
			FROM [dbo].[OrderDetail] od
				INNER JOIN [dbo].[VisualLayout] vl
					ON vl.ID = od.VisualLayout
				INNER JOIN [dbo].[JobName] jn
					ON vl.Client = jn.ID
				INNER JOIN [dbo].[DistributorClientAddress] dca
					ON od.DespatchTo = dca.ID
				LEFT OUTER JOIN [dbo].[DistributorClientAddress] dcac
					ON dca.Suburb=dcac.Suburb AND 
						dca.PostCode=dcac.PostCode AND dca.Country=dcac.Country AND dca.ContactName=dcac.ContactName AND
						dca.ContactPhone=dcac.ContactPhone AND dca.CompanyName=dcac.CompanyName AND dca.[State]=dcac.[State] AND
						dca.Port=dcac.Port AND dca.EmailAddress=dcac.EmailAddress AND dca.AddressType=dcac.AddressType AND 
						dca.Client=dcac.Client AND dca.IsAdelaideWarehouse=dcac.IsAdelaideWarehouse AND dca.Distributor=@Distributor
				LEFT OUTER JOIN #billingAddresses ba
					ON ba.ID = od.DespatchTo
				LEFT OUTER JOIN #despatchAddresses da
					ON ba.ID = od.DespatchTo
			WHERE jn.ID = @JobName AND  ba.ID IS NULL AND da.ID IS NULL AND dcac.ID IS NULL


		MERGE INTO [dbo].[DistributorClientAddress] AS t
		USING (SELECT dca.ID,[Address],Suburb,PostCode,Country,ContactName,ContactPhone,CompanyName,[State],Port,EmailAddress,AddressType,Client,IsAdelaideWarehouse,Distributor 
					FROM [dbo].[DistributorClientAddress] dca
					INNER JOIN #billingAddresses ba
						ON dca.ID = ba.ID) AS s
		ON 1=0 
		WHEN not matched THEN INSERT ([Address],Suburb,PostCode,Country,ContactName,ContactPhone,CompanyName,[State],Port,EmailAddress,AddressType,Client,IsAdelaideWarehouse,Distributor)
		VALUES (s.[Address],s.Suburb,s.PostCode,s.Country,s.ContactName,s.ContactPhone,s.CompanyName,s.[State],s.Port,s.EmailAddress,s.AddressType,s.Client,s.IsAdelaideWarehouse,@Distributor)
		OUTPUT s.[ID] AS ID,inserted.id AS New INTO #newBillingAddresses ;


		MERGE INTO [dbo].[DistributorClientAddress] AS t
		USING (SELECT dca.ID,[Address],Suburb,PostCode,Country,ContactName,ContactPhone,CompanyName,[State],Port,EmailAddress,AddressType,Client,IsAdelaideWarehouse,Distributor 
					FROM [dbo].[DistributorClientAddress] dca
					INNER JOIN #despatchAddresses da
						ON dca.ID = da.ID) AS s
		ON 1=0 
		WHEN not matched THEN INSERT ([Address],Suburb,PostCode,Country,ContactName,ContactPhone,CompanyName,[State],Port,EmailAddress,AddressType,Client,IsAdelaideWarehouse,Distributor)
		VALUES (s.[Address],s.Suburb,s.PostCode,s.Country,s.ContactName,s.ContactPhone,s.CompanyName,s.[State],s.Port,s.EmailAddress,s.AddressType,s.Client,s.IsAdelaideWarehouse,@Distributor)
		OUTPUT s.[ID] AS ID,  inserted.id AS New INTO #newDespatchAddresses ;

		MERGE INTO [dbo].[DistributorClientAddress] AS t
		USING (SELECT dca.ID,[Address],Suburb,PostCode,Country,ContactName,ContactPhone,CompanyName,[State],Port,EmailAddress,AddressType,Client,IsAdelaideWarehouse,Distributor 
					FROM [dbo].[DistributorClientAddress] dca
					INNER JOIN #curAddresses ca
						ON dca.ID = ca.ID) AS s
		ON 1=0 
		WHEN not matched THEN INSERT ([Address],Suburb,PostCode,Country,ContactName,ContactPhone,CompanyName,[State],Port,EmailAddress,AddressType,Client,IsAdelaideWarehouse,Distributor)
		VALUES (s.[Address],s.Suburb,s.PostCode,s.Country,s.ContactName,s.ContactPhone,s.CompanyName,s.[State],s.Port,s.EmailAddress,s.AddressType,s.Client,s.IsAdelaideWarehouse,@Distributor)
		OUTPUT s.[ID] AS ID,  inserted.id AS New INTO #newcurAddresses ;

		UPDATE o
		SET o.BillingAddress = nba.New 
		FROM [dbo].[Order] o
			INNER JOIN [dbo].[OrderDetail] od
				ON od.[Order] =o.ID
			INNER JOIN [dbo].[VisualLayout] vl
				ON vl.ID = od.VisualLayout
			INNER JOIN [dbo].[JobName] jn
				ON vl.Client = jn.ID
			INNER JOIN #newBillingAddresses nba
				ON nba.ID = o.BillingAddress
		WHERE jn.ID = @JobName AND nba.New IS NOT NULL AND nba.ID IS NOT NULL

		UPDATE o
		SET o.DespatchToAddress = nda.New 
		FROM [dbo].[Order] o
			INNER JOIN [dbo].[OrderDetail] od
				ON od.[Order] =o.ID
			INNER JOIN [dbo].[VisualLayout] vl
				ON vl.ID = od.VisualLayout
			INNER JOIN [dbo].[JobName] jn
				ON vl.Client = jn.ID
			INNER JOIN #newDespatchAddresses nda
				ON nda.ID = o.DespatchToAddress
		WHERE jn.ID = @JobName AND nda.New IS NOT NULL AND nda.ID IS NOT NULL

		UPDATE od
		SET od.DespatchTo = nca.New
		FROM [dbo].[OrderDetail] od
			INNER JOIN [dbo].[VisualLayout] vl
				ON vl.ID = od.VisualLayout
			INNER JOIN [dbo].[JobName] jn
				ON vl.Client = jn.ID
			INNER JOIN #newcurAddresses nca
				ON nca.ID = od.DespatchTo
		WHERE jn.ID = @JobName AND nca.New IS NOT NULL AND nca.ID IS NOT NULL

		DROP TABLE #billingAddresses
		DROP TABLE #newBillingAddresses

		DROP TABLE #despatchAddresses
		DROP TABLE #newDespatchAddresses

		DROP TABLE #curAddresses
		DROP TABLE #newcurAddresses

		CREATE TABLE #labelstemp (ID int)

		INSERT INTO #labelstemp
			SELECT DISTINCT l.ID 
			FROM [dbo].[OrderDetail] od
				INNER JOIN [dbo].[VisualLayout] vl
					ON vl.ID = od.VisualLayout
				INNER JOIN [dbo].[JobName] jn
					ON vl.Client = jn.ID
				INNER JOIN [dbo].[Label] l
					ON od.Label = l.ID
				INNER JOIN [dbo].[DistributorLabel] dl
					ON l.ID = dl.Label
			WHERE jn.ID = @JobName AND dl.Distributor = @ClientDistributor
	
		CREATE TABLE #labels(ID int)

		SELECT lt.ID,DL.Distributor,DL.Label FROM #labelstemp lt
				LEFT OUTER JOIN [dbo].[DistributorLabel] dl
					ON lt.ID = dl.Label and DL.Distributor = @Distributor
		WHERE dl.Label IS NULL

		INSERT INTO #labels (ID)
			SELECT lt.ID FROM #labelstemp lt
					LEFT OUTER JOIN [dbo].[DistributorLabel] dl
						ON lt.ID = dl.Label and DL.Distributor = @Distributor
			WHERE dl.Label IS NULL

		CREATE TABLE #newLabels (ID int , New int)
	
		MERGE INTO [dbo].[Label] AS t
		USING (SELECT l.ID,l.Name,l.LabelImagePath,l.IsSample 
					FROM [dbo].[Label] l
					INNER JOIN #labels lbs
						ON l.ID = lbs.ID) AS s
		ON 1=0 
		WHEN NOT MATCHED THEN INSERT (Name,LabelImagePath,IsSample)
		VALUES (s.Name,s.LabelImagePath,s.IsSample)
		OUTPUT s.[ID] AS ID,inserted.id AS New INTO #newLabels;

		INSERT INTO [dbo].[DistributorLabel] (Label,Distributor)
			SELECT nl.New,@Distributor 
			FROM #newLabels nl

		UPDATE od
		SET od.Label = nl.New
		FROM [dbo].[Order] o
			INNER JOIN [dbo].[OrderDetail] od
				ON od.[Order] = o.ID
			INNER JOIN [dbo].[VisualLayout] vl
				ON od.VisualLayout = vl.ID
			INNER JOIN [dbo].[JobName] jn
				ON vl.Client = jn.ID
 			INNER JOIN #newLabels nl
				ON nl.ID = od.Label
		WHERE jn.ID = @JobName AND nl.New IS NOT NULL AND nl.ID IS NOT NULL

		DROP TABLE #labels
		DROP TABLE #labelstemp
		DROP TABLE #newLabels

		COMMIT TRANSACTION [Transaction]

	END TRY
	BEGIN CATCH
	  ROLLBACK TRANSACTION [Transaction]
	END CATCH
END


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--