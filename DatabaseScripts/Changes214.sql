USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

ALTER TABLE [dbo].[Label]
ADD IsActive bit

ALTER TABLE [dbo].[Label] ADD CONSTRAINT DF_Label_IsActive DEFAULT  1 FOR IsActive;

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetPoloOrdersForGivenWeek]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_GetPoloOrdersForGivenWeek]
GO

CREATE PROC [dbo].[SPC_GetPoloOrdersForGivenWeek]
	@P_Year int,
	@P_WeekNumber int,
	@P_type int = 1
AS
BEGIN 
	DECLARE @Year int
	DECLARE @WeekNumber int
	DECLARE @Type int
	SET @Year = @P_Year
	SET @WeekNumber = @P_WeekNumber
	SET @Type = @P_Type
	DECLARE @WeekEndDate datetime2(7)
	SET @WeekEndDate = (SELECT TOP 1 WeekendDate FROM [dbo].[WeeklyProductionCapacity] WHERE DATEPART(YEAR,WeekendDate) = @Year AND WeekNo = @WeekNumber)
	DECLARE @WeekStartDate datetime2(7)
	SET @WeekStartDate = DATEADD(DAY, -6, @WeekEndDate)

	IF @Type = 7  -- Reservations 
		BEGIN
			IF OBJECT_ID('tempdb..#res1') IS NOT NULL
			BEGIN
				DROP TABLE #res1
			END

			SELECT	CONVERT(nvarchar(4),@Year) + '/' + CONVERT(nvarchar(2),@WeekNumber) AS [Week],
			('PO-'+CAST(o.ID as nvarchar(47))) AS PurchaseOrderNumber,
			o.ID AS [Order],
			p.Number+' - '+p.NickName AS Pattern,
			p.ID AS PatternID,
			o.[Date] AS OrderDate,
			r.ShipmentDate AS ETD,
			coo.GivenName + ' '+ coo.FamilyName AS Coodinator,
			ot.Name AS OrderType,
			d.Name AS Distributor,
			r.Client,
			r.[Qty] AS OrgQty,
			(SELECT ISNULL(SUM(odq.Qty),0)
				FROM [OrderDetail] od				
					JOIN OrderDetailQty odq 
						ON od.ID = odq.OrderDetail
					JOIN Reservation r
						ON od.Reservation = r.ID ) AS UsedQty,
			 pt.Name AS PrintType,
			 rs.Name AS [Status],
			 p.SMV AS SMV,
			 ISNULL((p.SMV * r.Qty), 0) AS TotalSMV INTO #res1
		FROM [dbo].[Reservation] r
			LEFT OUTER JOIN [dbo].[Order] o
				ON o.Reservation = r.ID
			LEFT OUTER JOIN [dbo].[Pattern] p
				ON p.ID = r.Pattern
			INNER JOIN [dbo].[User] coo
				ON r.Coordinator = coo.ID
			INNER JOIN [dbo].[Company] d
				ON r.Distributor = d.ID
			INNER JOIN [dbo].[PrinterType] pt
				ON p.PrinterType = pt.ID
			INNER JOIN [dbo].[ReservationStatus] rs
				ON r.[Status] = rs.ID
			LEFT OUTER JOIN [dbo].[OrderDetail] od
				ON od.Reservation = r.ID
			LEFT OUTER JOIN [dbo].[OrderType] ot
				ON od.OrderType = ot.ID
		WHERE  r.ShipmentDate >= @WeekStartDate AND r.ShipmentDate <= @WeekEndDate 

		SELECT d.*,(d.OrgQty-d.UsedQty) AS BalQty FROM #res1 d 
	
	END
	ELSE IF @type = 3 -- firm orders and reservations
	BEGIN
		IF OBJECT_ID('tempdb..#firm') IS NOT NULL
		BEGIN
			DROP TABLE #firm
		END
		SELECT	CONVERT(nvarchar(4),@Year) + '/' + CONVERT(nvarchar(2),@WeekNumber) AS [Week],
			o.ID AS [Order],
			('PO-'+CAST(o.ID as nvarchar(47))) AS PurchaseOrderNumber,
			vl.NamePrefix AS Product,
			vl.ID AS ProductID,
			p.Number+' - '+p.NickName AS Pattern,
			p.ID AS PatternID,
			fc.Code + ' - '+fc.Name AS Fabric,
			fc.ID AS FabricID ,
			o.[Date] AS OrderDate,
			od.ShipmentDate AS ETD,
			coo.GivenName + ' '+ coo.FamilyName AS Coodinator,
			ot.Name AS OrderType,
			d.Name AS Distributor,
			c.Name AS Client,
			jn.Name AS JobName,
			ISNULL(SUM(odq.Qty), 0) AS Qty,
			pl.Name AS ProductionLine,
			COALESCE(i.Name,'') AS ItemSubCat,
			pt.Name AS PrintType,
			COALESCE(dca.CompanyName,'') AS ShipTo,
			COALESCE(dp.Name, '') AS Port,
			COALESCE(sm.Name,'') AS Mode,
			COALESCE(os.Name, '') AS [Status],
			p.SMV,
			(p.SMV * ISNULL(SUM(odq.Qty), 0)) AS TotalSMV,
			vl.CreatedDate ProductCreatedDate INTO #firm
		FROM [dbo].[Order] o
			INNER JOIN [dbo].[OrderDetail] od
				ON od.[Order] = o.ID
			INNER JOIN [dbo].[OrderStatus] os
				ON o.[Status] = os.ID
			INNER JOIN [dbo].[VisualLayout] vl
				ON od.VisualLayout = vl.ID 
			INNER JOIN [dbo].[Pattern] p
				ON vl.Pattern = p.ID
			INNER JOIN [dbo].[Item] it
				ON p.Item = it.ID
			LEFT OUTER JOIN [dbo].[FabricCode] fc
				ON vl.FabricCode = fc.ID
			INNER JOIN [dbo].[JobName] jn
				ON vl.Client = jn.ID
			LEFT OUTER JOIN [dbo].[Client] c
				ON jn.Client = c.ID
			INNER JOIN [dbo].[Company] d
				ON c.Distributor = d.ID
			LEFT OUTER JOIN [dbo].[User] coo
				ON d.Coordinator = coo.ID
			INNER JOIN [dbo].[OrderType] ot
				ON od.OrderType = ot.ID
			INNER JOIN [dbo].[OrderDetailQty] odq
				ON odq.OrderDetail = od.ID
			LEFT OUTER JOIN [dbo].[ProductionLine] pl
				ON p.ProductionLine = pl.ID
			LEFT OUTER JOIN [dbo].[Item] i
				ON p.SubItem = i.ID
			INNER JOIN [dbo].[PrinterType] pt
				ON p.PrinterType = pt.ID
			LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
				ON od.DespatchTo = dca.ID
			LEFT OUTER JOIN [dbo].[DestinationPort] dp
				ON dca.Port= dp.ID
			LEFT OUTER JOIN [dbo].[ShipmentMode] sm
				ON o.ShipmentMode = sm.ID
			LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
				ON od.[Status] = ods.ID
			WHERE od.ShipmentDate >= @WeekStartDate AND od.ShipmentDate <= @WeekEndDate AND it.ItemType = 1 AND os.ID NOT IN (18,22,23,24,28,31)

			GROUP BY vl.NamePrefix,o.ID,vl.ID,p.Number,p.NickName,p.ID,fc.Code,fc.Name,fc.ID,o.[Date],od.ShipmentDate,coo.GivenName,coo.FamilyName ,ot.Name,
			d.Name, c.Name,jn.Name,pl.Name,i.Name,pt.Name,dp.Name,sm.Name,ods.Name,os.Name,it.ItemType,p.SMV,o.ID,vl.ID,p.ID,fc.ID,dca.CompanyName,vl.CreatedDate

			IF OBJECT_ID('tempdb..#resTemp') IS NOT NULL
				DROP TABLE #resTemp

			SELECT	CONVERT(nvarchar(4),@Year) + '/' + CONVERT(nvarchar(2),@WeekNumber) AS [Week],
			('PO-'+CAST(o.ID as nvarchar(47))) AS PurchaseOrderNumber,
			o.ID AS [Order],
			p.Number+' - '+p.NickName AS Pattern,
			p.ID AS PatternID,
			o.[Date] AS OrderDate,
			r.ShipmentDate AS ETD,
			coo.GivenName + ' '+ coo.FamilyName AS Coodinator,
			ot.Name AS OrderType,
			d.Name AS Distributor,
			r.Client,
			r.[Qty] AS OrgQty,
			(SELECT ISNULL(SUM(odq.Qty),0)
				FROM [OrderDetail] od				
					JOIN OrderDetailQty odq 
						ON od.ID = odq.OrderDetail
					JOIN Reservation r
						ON od.Reservation = r.ID ) AS UsedQty,
				pt.Name AS PrintType,
				rs.Name AS [Status],
				p.SMV AS SMV,
				ISNULL((p.SMV * odq.Qty), 0) AS TotalSMV INTO #resTemp
		FROM [dbo].[Reservation] r
			LEFT OUTER JOIN [dbo].[Order] o
				ON o.Reservation = r.ID
			LEFT OUTER JOIN [dbo].[Pattern] p
				ON p.ID = r.Pattern
			--INNER JOIN [dbo].[Item] i
			--	ON p.Item = i.ID
			INNER JOIN [dbo].[User] coo
				ON r.Coordinator = coo.ID
			INNER JOIN [dbo].[Company] d
				ON r.Distributor = d.ID
			INNER JOIN [dbo].[PrinterType] pt
				ON p.PrinterType = pt.ID
			INNER JOIN [dbo].[ReservationStatus] rs
				ON r.[Status] = rs.ID
			LEFT OUTER JOIN [dbo].[OrderDetail] od
				ON od.Reservation = r.ID
			LEFT OUTER JOIN [dbo].[OrderType] ot
				ON od.OrderType = ot.ID
			LEFT OUTER JOIN [dbo].[OrderDetailQty] odq
				ON odq.OrderDetail = od.ID
		WHERE  r.ShipmentDate >= @WeekStartDate AND r.ShipmentDate <= @WeekEndDate 

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res
		SELECT d.*,(d.OrgQty-d.UsedQty) AS BalQty INTO #res FROM #resTemp d

		INSERT INTO #firm ([Week],[Order],PurchaseOrderNumber,Product,ProductID,Pattern,PatternID,Fabric,FabricID,OrderDate,ETD,Coodinator,OrderType,Distributor,
					Client,Qty,ProductionLine,ItemSubCat,PrintType,ShipTo,Port,Mode,[Status],SMV,TotalSMV)
			SELECT 
				d.[Week],ISNULL(d.[Order], 0),ISNULL(d.PurchaseOrderNumber,''),'',0,d.Pattern,d.PatternID,'',0,ISNULL(d.OrderDate,''),ISNULL(d.ETD,''),ISNULL(d.Coodinator,''),ISNULL(d.OrderType,''),d.Distributor
					,d.Client,d.OrgQty,'','',ISNULL(d.PrintType,''),'','','',ISNULL(d.[Status],''),ISNULL(d.SMV,0.0),ISNULL(d.TotalSMV,0.0)
			FROM #res d
		SELECT * FROM #firm
	END
	ELSE IF @Type = 8
	BEGIN
		EXEC [dbo].[SPC_GetShipmentsForGivenWeek] @WeekStartDate,@WeekEndDate
	END
	ELSE
	BEGIN
		IF OBJECT_ID('tempdb..#data') IS NOT NULL
			DROP TABLE #data
		SELECT
			CONVERT(nvarchar(4),@Year) + '/' + CONVERT(nvarchar(2),@WeekNumber) AS [Week],
			o.ID AS [Order],
			('PO-'+CAST(o.ID as nvarchar(47))) AS PurchaseOrderNumber,
			vl.NamePrefix AS Product,
			vl.ID AS ProductID,
			p.Number+' - '+p.NickName AS Pattern,
			p.ID AS PatternID,
			fc.Code + ' - '+fc.Name AS Fabric,
			fc.ID AS FabricID ,
			o.[Date] AS OrderDate,
			od.ShipmentDate AS ETD,
			coo.GivenName + ' '+ coo.FamilyName AS Coodinator,
			ot.Name AS OrderType,
			d.Name AS Distributor,
			c.Name AS Client,
			jn.Name AS JobName,
			ISNULL(SUM(odq.Qty), 0) AS Qty,
			pl.Name AS ProductionLine,
			COALESCE(i.Name,'') AS ItemSubCat,
			pt.Name AS PrintType,
			COALESCE(dca.CompanyName,'') AS ShipTo,
			COALESCE(dp.Name, '') AS Port,
			COALESCE(sm.Name,'') AS Mode,
			COALESCE(os.Name, '') AS [Status],
			it.ItemType AS ItemType,
			p.SMV,
			(p.SMV * ISNULL(SUM(odq.Qty), 0)) AS TotalSMV,
			vl.CreatedDate ProductCreatedDate INTO #data
		FROM [dbo].[Order] o
			INNER JOIN [dbo].[OrderDetail] od
				ON od.[Order] = o.ID
			INNER JOIN [dbo].[OrderStatus] os
				ON o.[Status] = os.ID
			INNER JOIN [dbo].[VisualLayout] vl
				ON od.VisualLayout = vl.ID 
			INNER JOIN [dbo].[Pattern] p
				ON vl.Pattern = p.ID
			INNER JOIN [dbo].[Item] it
				ON p.Item = it.ID
			LEFT OUTER JOIN [dbo].[FabricCode] fc
				ON vl.FabricCode = fc.ID
			INNER JOIN [dbo].[JobName] jn
				ON vl.Client = jn.ID
			LEFT OUTER JOIN [dbo].[Client] c
				ON jn.Client = c.ID
			INNER JOIN [dbo].[Company] d
				ON c.Distributor = d.ID
			LEFT OUTER JOIN [dbo].[User] coo
				ON d.Coordinator = coo.ID
			INNER JOIN [dbo].[OrderType] ot
				ON od.OrderType = ot.ID
			LEFT OUTER JOIN [dbo].[OrderDetailQty] odq
				ON odq.OrderDetail = od.ID
			LEFT OUTER JOIN [dbo].[ProductionLine] pl
				ON p.ProductionLine = pl.ID
			LEFT OUTER JOIN [dbo].[Item] i
				ON p.SubItem = i.ID
			INNER JOIN [dbo].[PrinterType] pt
				ON p.PrinterType = pt.ID
			LEFT OUTER JOIN [dbo].[Company] st
				ON o.ShipTo = st.ID
			LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
				ON od.DespatchTo = dca.ID
			LEFT OUTER JOIN [dbo].[DestinationPort] dp
				ON dca.Port= dp.ID
			LEFT OUTER JOIN [dbo].[ShipmentMode] sm
				ON o.ShipmentMode = sm.ID
			LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
				ON od.[Status] = ods.ID
			WHERE od.ShipmentDate >= @WeekStartDate AND od.ShipmentDate <= @WeekEndDate AND os.ID NOT IN (18,22,23,24,28,31)
			GROUP BY vl.NamePrefix,o.ID,vl.ID,p.Number,p.NickName,p.ID,fc.Code,fc.Name,fc.ID,o.[Date],od.ShipmentDate,coo.GivenName,coo.FamilyName ,ot.Name,
			d.Name, c.Name,jn.Name,pl.Name,i.Name,pt.Name,dp.Name,sm.Name,ods.Name,os.Name,it.ItemType,p.SMV,o.ID,vl.ID,p.ID,fc.ID,dca.CompanyName,vl.CreatedDate

			SELECT * FROM #data
			WHERE 
				(@Type = 1 AND ([Status]  != 'Indico Hold' AND [Status] != 'Indiman Hold' 
					AND [Status] != 'Factory Hold' AND [Status] != 'On Hold'))
				OR
				(@Type = 2 AND ([Status]  = 'Indico Hold' OR [Status] = 'Indiman Hold' 
					OR [Status] = 'Factory Hold' OR [Status] = 'On Hold'))
				OR
				(@Type = 4  AND ItemType = 2)
				OR
				(@Type = 5 AND Qty<=5)
				OR
				(@Type = 6 AND OrderType LIKE '%SAMPLE%')
				
	END
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
					ON dca.Suburb=dcac.Suburb AND dca.PostCode=dcac.PostCode AND dca.Country=dcac.Country AND dca.Distributor=@Distributor
			WHERE jn.ID = @JobName AND dcac.ID IS NULL AND o.BillingAddress <> 105 AND dca.[Address] != 'tba' 


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
					ON dca.Suburb=dcac.Suburb AND dca.PostCode=dcac.PostCode AND dca.Country=dcac.Country AND dca.Distributor=@Distributor
				LEFT OUTER JOIN #billingAddresses ba
					ON ba.ID = o.DespatchToAddress
			WHERE jn.ID = @JobName AND ba.ID IS NULL AND dcac.ID IS NULL AND o.DespatchToAddress <> 105 AND dca.[Address] != 'tba' 

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
					ON dca.Suburb=dcac.Suburb AND dca.PostCode=dcac.PostCode AND dca.Country=dcac.Country AND dca.Distributor=@Distributor
				LEFT OUTER JOIN #billingAddresses ba
					ON ba.ID = od.DespatchTo
				LEFT OUTER JOIN #despatchAddresses da
					ON ba.ID = od.DespatchTo
			WHERE jn.ID = @JobName AND  ba.ID IS NULL AND da.ID IS NULL AND dcac.ID IS NULL AND od.DespatchTo <> 105 AND dca.[Address] != 'tba' 


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
				LEFT OUTER JOIN [dbo].[DistributorLabel] ddl
					ON ddl.Distributor = @Distributor
				LEFT OUTER JOIN [dbo].[Label] dul
					ON ddl.Label = dul.ID AND dul.Name = l.Name AND dul.LabelImagePath = l.LabelImagePath
			WHERE jn.ID = @JobName AND dl.Distributor = @ClientDistributor AND dul.ID IS NULL
	
		CREATE TABLE #labels(ID int)

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


-- order clone page
DECLARE @PageId int

DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

DECLARE @IndimanAdministrator int
DECLARE @IndicoCoordinator int
DECLARE @IndicoAdministrator int

SET @IndimanAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @IndicoCoordinator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Coordinator')

-- Page
INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/CloneOrder.aspx','Clone Order','Clone Order')	 
SET @PageId = SCOPE_IDENTITY()

-- Parent Menu Item
SELECT @MenuItemMenuId = Parent FROM [dbo].[MenuItem] WHERE Name = 'Payment Terms'

--Menu Item					
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Clone Order', 'Clone Order', 1, @MenuItemMenuId, 13, 0)
SET @MenuItemId = SCOPE_IDENTITY()

-- Menu Item Role
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndicoCoordinator)

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/* Object:  StoredProcedure [dbo].[SPC_CloneOrder]    Script Date: 10/24/2016 1:34:39 PM */
DROP PROCEDURE [dbo].[SPC_CloneOrder]
GO

/* Object:  StoredProcedure [dbo].[SPC_CloneOrder]    Script Date: 10/24/2016 1:34:39 PM */
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
		,[Qty]
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