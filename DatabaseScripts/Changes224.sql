USE Indico
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

		IF NOT EXISTS(SELECT jn.ID FROM [dbo].[Client] c
						INNER JOIN [dbo].[JobName] jn
							ON jn.Client = c.ID
					  WHERE c.ID = @Client)
		BEGIN
			DELETE [dbo].[Client] WHERE ID = @Client
		END
	END

	IF @P_VisualLayout > 0 AND @P_ToJobName > 0
	BEGIN
		DECLARE @JobName int;
		SET @JobName = (SELECT TOP 1 jn.ID FROM [dbo].[JobName] jn -- Get the JobName of the VL
				INNER JOIN [dbo].[VisualLayout] vl ON vl.Client = jn.ID)
		UPDATE vl

		SET vl.Client = @P_ToJobName -- Update the VL
		FROM [dbo].[VisualLayout] vl
			WHERE ID = @P_VisualLayout

		IF NOT EXISTS (SELECT ID FROM [dbo].[VisualLayout] vl WHERE Client = @JobName) -- Delete JobName if no VLs related 
		BEGIN
			DELETE [dbo].[JobName] WHERE ID = @JobName
		END

	END
END



GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--


UPDATE od                  --Set IsWeeklyShipment to true on all OrderDetails where WeeklyShipment is null and Despatchto is ad warehouse
SET od.IsWeeklyShipment = 1
FROM [dbo].[OrderDetail] od
WHERE od.IsWeeklyShipment IS NULL AND od.DespatchTo = 105

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

DELETE WeeklyProductionCapacityDetails WHERE ID IN(313,626)  -- Delete wrong week
DELETE WeeklyProductionCapacity WHERE ID = 313

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
		(CONVERT(nvarchar(2), ((YEAR( wpc.WeekendDate ) % 100 ))) + '/' + CONVERT(nvarchar(3), wpc.WeekNo)) AS WeekNumber,
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
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GetOrderDetaildForGivenWeekView]'))  --changed notes
	DROP VIEW [dbo].[GetOrderDetaildForGivenWeekView]
GO

CREATE VIEW [dbo].[GetOrderDetaildForGivenWeekView]
AS
SELECT			o.ID AS OrderId,
				od.ID AS OrderDetailId,
				o.ShipmentDate AS OrderShipmentDate,
				od.ShipmentDate AS OrderDetailShipmentDate,
				ot.[Name] AS OrderType,
				dis.[Name] AS Distributor,
				CASE 
					WHEN dis.IncludeAsMYOBInvoice = 1
						THEN ISNULL(dis.JobName, '')
						ELSE 'Wholesale'
				END AS JobName,
				c.[Name] AS Client,
				'PO-' + CAST(o.ID AS nvarchar(47)) AS PurchaseOrder,
				vl.[NamePrefix],
				p.[Number] + ' - ' + p.[NickName] AS Pattern,
				fc.[Code] + ' - ' + fc.[NickName] AS Fabric,
				fc.[Filaments] AS Material,
				g.Name AS Gender,
				ag.Name AS AgeGroup,
				'' AS SleeveShape,
				'' AS SleeveLength,
				COALESCE(i.[Name], '') AS ItemSubGroup,
				s.SizeName,
				odq.Qty AS Quentity,
				os.Name AS [Status],
				0 AS PrintedCount,
				COALESCE(
					(SELECT TOP 1 
						'http://gw.indiman.net/IndicoData/PatternTemplates/' + CAST(pti.Pattern AS nvarchar(8)) + '/' + pti.[Filename] + pti.Extension
					FROM [dbo].[PatternTemplateImage] pti WHERE p.ID = pti.Pattern AND pti.IsHero = 1
					), '' 
				) AS PatternImagePath,
				COALESCE(
					(SELECT TOP 1 
						'http://gw.indiman.net/IndicoData/VisualLayout/' + CAST(vl.ID AS nvarchar(8)) + '/' + im.[Filename] + im.Extension
					FROM [dbo].[Image] im WHERE vl.ID = im.VisualLayout AND im.IsHero = 1
					), '' 
				) AS VLImagePath,
				p.[Number],
				0.0 AS OtherCharges,
				od.EditedPriceRemarks AS Notes,
				p.PatternNotes AS PatternInvoiceNotes,
				od.VisualLayoutNotes AS ProductNotes,
				COALESCE(cs.QuotedFOBCost, 0.0) AS JKFOBCostSheetPrice,
				COALESCE(cs.QuotedCIF, 0.0) AS IndimanCIFCostSheetPrice,
				ISNULL(CAST((SELECT CASE
									WHEN (p.[SubItem] IS NULL)
										THEN  	('')
									ELSE (CAST((SELECT TOP 1 hsc.[Code] FROM [dbo].[HSCode] hsc WHERE hsc.[ItemSubCategory] = p.[SubItem] AND hsc.[Gender] = p.[Gender]) AS nvarchar(64)))
							END) AS nvarchar (64)), '') AS HSCode,
				ISNULL(CAST((SELECT CASE
									WHEN (p.[SubItem] IS NULL)
										THEN  	('')
									ELSE (CAST((SELECT it.[Name] FROM [dbo].[Item] it WHERE it.[ID] = i.[Parent]) AS nvarchar(64)))
							END) AS nvarchar (64)), '') AS ItemName,
				o.PurchaseOrderNo,
				dca.ID AS DistributorClientAddressID, --new
				dca.CompanyName AS DistributorClientAddressName,
				COALESCE(dp.Name, '') AS DestinationPort,
			    COALESCE(sm.Name, '') AS ShipmentMode,
			    COALESCE(pm.Name,'') AS PaymentMethod 
	FROM [dbo].[OrderDetail] od
		INNER JOIN [dbo].[Order] o
			ON od.[Order] = o.ID
		INNER JOIN [dbo].[OrderStatus] os
			ON o.[Status] = os.ID
		INNER JOIN [dbo].[Company] dis
			ON dis.[ID] = o.[Distributor]		
		INNER JOIN [dbo].[OrderType] ot
			ON od.[OrderType] = ot.[ID]
		INNER JOIN [dbo].[VisualLayout] vl
			ON od.[VisualLayout] = vl.ID	
		INNER JOIN [dbo].[Pattern] p
			ON od.Pattern = p.ID
		INNER JOIN [dbo].[SizeSet] ss
			ON p.SizeSet = ss.ID
		INNER JOIN [dbo].[Size] s
			ON s.SizeSet = ss.ID
		INNER JOIN [dbo].[FabricCode] fc
			ON od.FabricCode = fc.ID
		LEFT OUTER JOIN [dbo].[Gender] g
			ON p.Gender = g.ID
		LEFT OUTER JOIN [dbo].[AgeGroup] ag
			ON p.AgeGroup = ag.ID
		LEFT OUTER JOIN [dbo].[Item] i
			ON p.[SubItem] = i.ID
		INNER JOIN [dbo].[JobName] c
			ON o.Client = c.ID	
		LEFT OUTER JOIN [dbo].[CostSheet] cs	
			ON p.ID = cs.Pattern
				AND fc.ID = cs.Fabric
		INNER JOIN [dbo].[OrderDetailQty] odq
			ON od.ID = odq.OrderDetail
				AND odq.Size = s.ID
		INNER JOIN [dbo].[DistributorClientAddress] dca
			ON od.[DespatchTo] = dca.[ID]
		LEFT OUTER JOIN [dbo].[DestinationPort] dp
			ON dca.[Port] = dp.[ID]
		LEFT OUTER JOIN [dbo].[ShipmentMode] sm
			ON od.[ShipmentMode] = sm.[ID] 
		LEFT OUTER JOIN [dbo].[PaymentMethod] pm
			ON od.[PaymentMethod] = pm.[ID]
WHERE odq.Qty != 0 AND os.ID NOT IN (18,22,23,24,28,31)--o.[Status] != 28 AND o.[Status] != 18

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

-- remove unused data
DELETE FROM [dbo].ArtWorktAccessory
DELETE FROM [dbo].ArtWork

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_DeletePattern]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_DeletePattern]
GO

CREATE PROC [dbo].[SPC_DeletePattern]
	@PatternID int
AS 
BEGIN
	IF @PatternID >0
	BEGIN
		DELETE [dbo].[PatternAccessory] WHERE Pattern = @PatternID

		SELECT  ID INTO #PatternDevalopments FROM [dbo].[PatternDevelopment] WHERE Pattern = @PatternID

		DELETE pdh
		FROM [dbo].[PatternDevelopmentHistory] pdh
			INNER JOIN #PatternDevalopments pd
				ON pd.ID = pdh.PatternDevelopment

		DELETE pd
		FROM [dbo].[PatternDevelopment] pd
			INNER JOIN #PatternDevalopments pds
				ON pd.ID = pds.ID

		DELETE [dbo].[PatternAccessory] WHERE Pattern = @PatternID

		DELETE [dbo].[PatternItemAttributeSub] WHERE Pattern = @PatternID

		DELETE [dbo].[PatternOtherCategory] WHERE Pattern = @PatternID

		DELETE [dbo].[PatternTemplateImage] WHERE Pattern = @PatternID

		DELETE [dbo].[Price] WHERE Pattern = @PatternID

		DELETE [dbo].[Product] WHERE Pattern = @PatternID

		DELETE [dbo].[Reservation] WHERE Pattern = @PatternID

		DELETE [dbo].[SizeChart] WHERE Pattern = @PatternID

		DELETE [dbo].[Pattern] WHERE ID = @PatternID
	END
END


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
