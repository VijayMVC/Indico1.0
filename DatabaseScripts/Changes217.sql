USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_TransferAddressesAndLabels]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_TransferAddressesAndLabels]
GO


CREATE PROC [dbo].[SPC_TransferAddressesAndLabels]
	@P_JobName int,
	@P_Distributor int,
	@P_VisualLayout int
AS
BEGIN

	DECLARE @JobName int
	DECLARE @Distributor int
	DECLARE @VisualLayout int = 0
	DECLARE @Client int 
	DECLARE @ClientDistributor int 
	SET @JobName = @P_JobName
	SET @Distributor = @P_Distributor
	SET @VisualLayout = @P_VisualLayout

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

	CREATE TABLE #oldBillingAddresses (ID int , New int)
	CREATE TABLE #oldcurAddresses (ID int , New int)
	CREATE TABLE #oldDespatchAddresses (ID int , New int)

	INSERT INTO #oldBillingAddresses (ID,New)
		SELECT DISTINCT o.BillingAddress,dcac.ID AS New
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
		WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND dcac.ID IS NOT NULL AND o.BillingAddress <> 105 

	INSERT INTO #oldDespatchAddresses (ID,New) 
		SELECT DISTINCT o.DespatchToAddress,dcac.ID
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
			LEFT OUTER JOIN #oldBillingAddresses ba
				ON ba.ID = dcac.ID
		WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND ba.ID IS NULL AND dcac.ID IS NOT NULL AND o.DespatchToAddress <> 105

	INSERT INTO #oldcurAddresses (ID,New) 
		SELECT DISTINCT od.DespatchTo,dcac.ID
		FROM [dbo].[OrderDetail] od
			INNER JOIN [dbo].[VisualLayout] vl
				ON vl.ID = od.VisualLayout
			INNER JOIN [dbo].[JobName] jn
				ON vl.Client = jn.ID
			INNER JOIN [dbo].[DistributorClientAddress] dca
				ON od.DespatchTo = dca.ID
			LEFT OUTER JOIN [dbo].[DistributorClientAddress] dcac
				ON dca.Suburb=dcac.Suburb AND dca.PostCode=dcac.PostCode AND dca.Country=dcac.Country AND dca.Distributor=@Distributor
			LEFT OUTER JOIN #oldBillingAddresses ba
				ON ba.ID = dcac.ID
			LEFT OUTER JOIN #oldDespatchAddresses da
				ON da.ID = dcac.ID
		WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND  ba.ID IS NULL AND da.ID IS NULL AND da.ID IS NULL AND dcac.ID IS NOT NULL AND od.DespatchTo <> 105 
	
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
		WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND dcac.ID IS NULL AND o.BillingAddress <> 105 


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
		WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND ba.ID IS NULL AND dcac.ID IS NULL AND o.DespatchToAddress <> 105

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
				ON da.ID = od.DespatchTo
		WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND  ba.ID IS NULL AND da.ID IS NULL AND dcac.ID IS NULL AND od.DespatchTo <> 105 

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
	WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND nba.New IS NOT NULL AND nba.ID IS NOT NULL

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
	WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND nda.New IS NOT NULL AND nda.ID IS NOT NULL

	UPDATE od
	SET od.DespatchTo = nca.New
	FROM [dbo].[OrderDetail] od
		INNER JOIN [dbo].[VisualLayout] vl
			ON vl.ID = od.VisualLayout
		INNER JOIN [dbo].[JobName] jn
			ON vl.Client = jn.ID
		INNER JOIN #newcurAddresses nca
			ON nca.ID = od.DespatchTo
	WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND nca.New IS NOT NULL AND nca.ID IS NOT NULL


	UPDATE o
	SET o.BillingAddress = nba.New 
	FROM [dbo].[Order] o
		INNER JOIN [dbo].[OrderDetail] od
			ON od.[Order] =o.ID
		INNER JOIN [dbo].[VisualLayout] vl
			ON vl.ID = od.VisualLayout
		INNER JOIN [dbo].[JobName] jn
			ON vl.Client = jn.ID
		INNER JOIN #oldBillingAddresses nba
			ON nba.ID = o.BillingAddress
	WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND nba.New IS NOT NULL AND nba.ID IS NOT NULL

	UPDATE o
	SET o.DespatchToAddress = nda.New 
	FROM [dbo].[Order] o
		INNER JOIN [dbo].[OrderDetail] od
			ON od.[Order] =o.ID
		INNER JOIN [dbo].[VisualLayout] vl
			ON vl.ID = od.VisualLayout
		INNER JOIN [dbo].[JobName] jn
			ON vl.Client = jn.ID
		INNER JOIN #oldDespatchAddresses nda
			ON nda.ID = o.DespatchToAddress
	WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND nda.New IS NOT NULL AND nda.ID IS NOT NULL

	UPDATE od
	SET od.DespatchTo = nca.New
	FROM [dbo].[OrderDetail] od
		INNER JOIN [dbo].[VisualLayout] vl
			ON vl.ID = od.VisualLayout
		INNER JOIN [dbo].[JobName] jn
			ON vl.Client = jn.ID
		INNER JOIN #oldcurAddresses nca
			ON nca.ID = od.DespatchTo
	WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND nca.New IS NOT NULL AND nca.ID IS NOT NULL

	DROP TABLE #billingAddresses
	DROP TABLE #newBillingAddresses

	DROP TABLE #despatchAddresses
	DROP TABLE #newDespatchAddresses

	DROP TABLE #curAddresses
	DROP TABLE #newcurAddresses

	DROP TABLE #oldBillingAddresses
	DROP TABLE #oldDespatchAddresses
	DROP TABLE #oldcurAddresses

	CREATE TABLE #labelstemp (ID int)
	CREATE TABLE #labelsold (ID int,New int)

	--from all orderdetails

	INSERT INTO #labelsold (ID,New)
	SELECT l.ID,dll.ID AS Name FROM [dbo].[JobName] jn
		INNER JOIN  [dbo].[VisualLayout] vl
			ON vl.Client = jn.ID
		INNER JOIN [dbo].[OrderDetail] od
			ON od.VisualLayout = vl.ID
		INNER JOIN [dbo].[Label] l
			ON od.Label = l.ID
		LEFT OUTER  JOIN [dbo].[DistributorLabel] dl
			ON dl.Distributor = @Distributor
		LEFT OUTER JOIN [dbo].[Label] dll
			ON dl.Label = dll.ID AND l.Name = dll.Name
	WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND dll.ID IS NOT  NULL

	INSERT INTO #labelstemp 
		SELECT DISTINCT l.ID FROM [dbo].[JobName] jn
			INNER JOIN  [dbo].[VisualLayout] vl
				ON vl.Client = jn.ID
			INNER JOIN [dbo].[OrderDetail] od
				ON od.VisualLayout = vl.ID
			INNER JOIN [dbo].[Label] l
				ON od.Label = l.ID
			LEFT OUTER  JOIN [dbo].[DistributorLabel] dl
				ON dl.Distributor = @Distributor
			LEFT OUTER JOIN [dbo].[Label] dll
				ON dl.Label = dll.ID AND l.Name = dll.Name
		WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND dll.ID IS  NULL
		
	CREATE TABLE #labels(ID int)

	INSERT INTO #labels (ID)
		SELECT DISTINCT lt.ID FROM #labelstemp lt
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
	WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND nl.New IS NOT NULL AND nl.ID IS NOT NULL

	UPDATE od
	SET od.Label = nl.New
	FROM [dbo].[Order] o
		INNER JOIN [dbo].[OrderDetail] od
			ON od.[Order] = o.ID
		INNER JOIN [dbo].[VisualLayout] vl
			ON od.VisualLayout = vl.ID
		INNER JOIN [dbo].[JobName] jn
			ON vl.Client = jn.ID
 		INNER JOIN #labelsold nl
			ON nl.ID = od.Label
	WHERE (@VisualLayout =0 OR vl.ID = @VisualLayout) AND jn.ID = @JobName AND nl.New IS NOT NULL AND nl.ID IS NOT NULL

	DROP TABLE #labels
	DROP TABLE #labelstemp
	DROP TABLE #labelsold
	DROP TABLE #newLabels

END


GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--