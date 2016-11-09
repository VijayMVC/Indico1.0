USE Indico
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
			vl.CreatedDate ProductCreatedDate,
			(CASE WHEN od.IsBrandingKit = 1 THEN 'Yes'ELSE 'No' END) AS IsBrandingKit,
			(CASE WHEN od.PhotoApprovalReq = 1 THEN 'Yes'ELSE 'No' END) AS PhotoApproval,
			ISNULL(ods.Name,'') AS DetailStatus INTO #firm
		FROM [dbo].[Order] o
			INNER JOIN [dbo].[OrderDetail] od
				ON od.[Order] = o.ID
			LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
				ON od.[Status] = ods.ID
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
			WHERE od.ShipmentDate >= @WeekStartDate AND od.ShipmentDate <= @WeekEndDate AND it.ItemType = 1 AND os.ID NOT IN (18,22,23,24,28,31)

			GROUP BY vl.NamePrefix,o.ID,vl.ID,p.Number,p.NickName,p.ID,fc.Code,fc.Name,fc.ID,o.[Date],od.ShipmentDate,coo.GivenName,coo.FamilyName ,ot.Name,
			d.Name, c.Name,jn.Name,pl.Name,i.Name,pt.Name,dp.Name,sm.Name,ods.Name,os.Name,it.ItemType,p.SMV,o.ID,vl.ID,p.ID,fc.ID,dca.CompanyName,vl.CreatedDate,od.IsBrandingKit,od.PhotoApprovalReq

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
			vl.CreatedDate ProductCreatedDate,
			(CASE WHEN od.IsBrandingKit = 1 THEN 'Yes'ELSE 'No' END) AS IsBrandingKit,
			(CASE WHEN od.PhotoApprovalReq = 1 THEN 'Yes'ELSE 'No' END) AS PhotoApproval,
			ISNULL(ods.Name,'') AS DetailStatus  INTO #data
		FROM [dbo].[Order] o
			INNER JOIN [dbo].[OrderDetail] od
				ON od.[Order] = o.ID
			LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
				ON od.[Status] = ods.ID
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
			WHERE od.ShipmentDate >= @WeekStartDate AND od.ShipmentDate <= @WeekEndDate AND os.ID NOT IN (18,22,23,24,28,31)
			GROUP BY vl.NamePrefix,o.ID,vl.ID,p.Number,p.NickName,p.ID,fc.Code,fc.Name,fc.ID,o.[Date],od.ShipmentDate,coo.GivenName,coo.FamilyName ,ot.Name,
			d.Name, c.Name,jn.Name,pl.Name,i.Name,pt.Name,dp.Name,sm.Name,ods.Name,os.Name,it.ItemType,p.SMV,o.ID,vl.ID,p.ID,fc.ID,dca.CompanyName,vl.CreatedDate,od.IsBrandingKit,od.PhotoApprovalReq

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
