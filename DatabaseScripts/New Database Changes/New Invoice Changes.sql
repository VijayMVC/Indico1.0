
/****** Object:  StoredProcedure [dbo].[SPC_CreateInvoice]    Script Date: 4/3/2017 4:24:25 PM ******/
DROP PROCEDURE [dbo].[SPC_CreateInvoice]
GO

/****** Object:  StoredProcedure [dbo].[SPC_CreateInvoice]    Script Date: 4/3/2017 4:24:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_CreateInvoice] 
	@WeeklyProductionCapacity int,
	@DistributorClientAddress int,
	@Port int =  NULL,
	@WeekEndDate datetime2(7),
	@ShipmentDate datetime2(7),
	@PaymentMethod int,
	@ShipmentMode int,
	@Creator int
AS
BEGIN

	DECLARE @InvoiceId int

	INSERT INTO [dbo].[Invoice]
        ([InvoiceNo]
        ,[InvoiceDate]
        ,[ShipTo]
        ,[AWBNo]
        ,[WeeklyProductionCapacity]
        ,[IndimanInvoiceNo]
        ,[ShipmentMode]
        ,[IndimanInvoiceDate]
        ,[Creator]
        ,[CreatedDate]
        ,[Modifier]
        ,[ModifiedDate]
        ,[Status]
        ,[ShipmentDate]
        ,[BillTo]
        ,[IsBillTo]
        ,[Bank]
		,[Port]
		,[PriceTerm])
    VALUES
        (''
		,GETDATE()
        ,@DistributorClientAddress
        ,NULL
        ,@WeeklyProductionCapacity
        ,NULL
        ,@ShipmentMode
        ,NULL
        ,@Creator
        ,GETDATE()
        ,@Creator
        ,GETDATE()
        ,(SELECT TOP 1 ID FROM [dbo].[InvoiceStatus] WHERE [Key] = 'PS')
        ,@ShipmentDate
        ,@DistributorClientAddress
        ,NULL
        ,1
		,@Port
		,@PaymentMethod)

	SET @InvoiceId = SCOPE_IDENTITY()

	INSERT INTO [dbo].[InvoiceOrderDetailItem]
			([Invoice]
			,[OrderDetail]
			,[FactoryPrice]
			,[IndimanPrice]
			,[OtherCharges]
			,[IsRemoved])
	SELECT  @InvoiceId,
			od.ID AS OrderDeatilId,
			0.0,
			0.0,
			0.0,
			0
	FROM [Indico].[dbo].[OrderDetail] od
		INNER JOIN [Indico].[dbo].[OrderDetailQty] odq
			ON od.[ID] = odq.[OrderDetail]		
	WHERE (od.[ShipmentDate] BETWEEN DATEADD(DAY, -6, CONVERT(DATE, @WeekEndDate)) AND CAST(@WeekEndDate as DATE)) AND odq.Qty != 0
		
	SELECT @InvoiceId
END		


GO







/****** Object:  StoredProcedure [dbo].[SPC_GetIndimanDetailInvoiceInfo]    Script Date: 4/3/2017 4:25:01 PM ******/
DROP PROCEDURE [dbo].[SPC_GetIndimanDetailInvoiceInfo]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetIndimanDetailInvoiceInfo]    Script Date: 4/3/2017 4:25:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_GetIndimanDetailInvoiceInfo] (	
	@P_InvoiceId int
)	
AS 
BEGIN
	
	IF OBJECT_ID('tempdb..#QtyInfo') IS NOT NULL DROP TABLE #QtyInfo
	
	SELECT iod.ID AS InvoiceOrderDetailItemID,
			SUM(odq.Qty) AS Qty INTO #QtyInfo
	FROM [dbo].[Invoice] invoice
	    INNER JOIN  [dbo].[InvoiceOrderDetailItem] iod
			ON invoice.ID = iod.Invoice
		INNER JOIN [Indico].[dbo].[OrderDetail] od
			ON iod.OrderDetail = od.ID
		INNER JOIN [Indico].[dbo].[OrderDetailQty] odq
			ON odq.OrderDetail = od.ID
	GROUP BY iod.ID
			
	SELECT DISTINCT
			invoice.InvoiceNo AS JkInvoiceNo,
			invoice.IndimanInvoiceNo AS IndimanInvoiceNo,
			invoice.IndimanInvoiceDate AS IndimanInvoiceDate,
			Invoice.AWBNo AS AWBNo,
			po.Name AS Port,
			sm.Name AS ShipmentMode,
			o.ID AS ID,
			od.ShipmentDate AS ShipmentDate,
			o.IsAdelaideWareHouse AS IsAdelaideWareHouse,
			o.Distributor AS Distributor,
			o.Client AS Client,
			j.Name AS dbo_JobName_Name,
			inv.IndimanPrice AS QuotedCIF,
			inv.OtherCharges AS OC,
			inv.OtherCharges AS IndimanOtherCharges,
			(inv.IndimanPrice + inv.OtherCharges) AS fp,
			qi.Qty AS SumOfQty,
			((inv.IndimanPrice + inv.OtherCharges) * qi.Qty) AS Val, 
			os.ID AS [Status],
			os.[Description] AS [Description],
			ot.Name AS dbo_OrderType_Name,
			dis.Name AS dbo_Company_Name,
			p.Number AS Number,
			i.Name AS dbo_Item_Name,
			vl.NamePrefix AS NamePrefix,
			fc.NickName AS NickName,
			od.DespatchTo AS DespatchTo,
			dca.CompanyName AS CompanyName,
			dca.[Address] AS [Address],
			dca.Suburb AS Suburb,
			dca.[State] AS [State],
			dca.PostCode AS PostCode,
			cn.ShortName AS ShortName,
			dca.ContactName AS ContactName,
			dca.ContactPhone AS ContactPhone,
			o.PurchaseOrderNo AS PurchaseOrderNo,
			fc.Filaments AS Filaments,
			(SELECT s.SizeName + '/' + CAST(odq.Qty AS nvarchar(5)) + ',' AS 'data()' 
			FROM [dbo].[OrderDetailQty] odq
				JOIN [dbo].[Size] s
					ON odq.Size = s.ID
			WHERE odq.OrderDetail = od.ID AND odq.Qty > 0
			FOR XML PATH('')
			) AS SizeQtys,
			(0) AS Freight,
			g.Name AS Gender

	FROM [dbo].[Invoice] invoice
	    INNER JOIN  [dbo].[InvoiceOrderDetailItem] inv
			ON invoice.ID = inv.Invoice
		INNER JOIN [Indico].[dbo].[DestinationPort] po
			ON invoice.Port = po.ID
		INNER JOIN [Indico].[dbo].[ShipmentMode] sm
			ON invoice.ShipmentMode = sm.ID
		INNER JOIN #QtyInfo qi
			ON inv.ID = qi.InvoiceOrderDetailItemID		
		INNER JOIN [Indico].[dbo].[OrderDetail] od
			ON inv.OrderDetail = od.ID
		INNER JOIN [Indico].[dbo].[Order] o
			ON od.[Order] = o.ID
		INNER JOIN [Indico].[dbo].[OrderStatus] os
			ON o.[Status] = os.ID
		INNER JOIN [Indico].[dbo].[Company] dis
			ON dis.[ID] = o.[Distributor]	
		INNER JOIN [Indico].[dbo].[DistributorClientAddress] dca
			ON invoice.ShipTo = dca.[ID]		
		INNER JOIN [Indico].[dbo].[Country] cn
			ON cn.[ID] = dca.[Country]				
		INNER JOIN [Indico].[dbo].[OrderType] ot
			ON od.[OrderType] = ot.[ID]
		INNER JOIN [Indico].[dbo].[VisualLayout] vl
			ON od.[VisualLayout] = vl.ID	
		INNER JOIN [Indico].[dbo].[Pattern] p
			ON od.Pattern = p.ID
		INNER JOIN [Indico].[dbo].[FabricCode] fc
			ON od.FabricCode = fc.ID
		LEFT OUTER JOIN [Indico].[dbo].[Gender] g
			ON p.Gender = g.ID
		LEFT OUTER JOIN [Indico].[dbo].[Item] i
			ON p.[SubItem] = i.ID
		INNER JOIN [Indico].[dbo].[Client] c
			ON o.Client = c.ID
		INNER JOIN [dbo].[JobName] j
			ON c.ID = j.Client
		LEFT OUTER JOIN [Indico].[dbo].[CostSheet] cs	
			ON p.ID = cs.Pattern
				AND fc.ID = cs.Fabric
	WHERE invoice.ID = @P_InvoiceId
END
GO



/****** Object:  StoredProcedure [dbo].[SPC_GetInvoiceOrderDetailItems]    Script Date: 4/3/2017 4:25:21 PM ******/
DROP PROCEDURE [dbo].[SPC_GetInvoiceOrderDetailItems]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetInvoiceOrderDetailItems]    Script Date: 4/3/2017 4:25:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_GetInvoiceOrderDetailItems] 
	@InvoiceId int = NULL
AS
BEGIN

	IF OBJECT_ID('tempdb..#QtyInfo') IS NOT NULL DROP TABLE #QtyInfo
	
	SELECT inv.ID AS InvoiceOrderDetailItemID,
			SUM(odq.Qty) AS Qty INTO #QtyInfo
	FROM [dbo].[Invoice] invoice

	    INNER JOIN  [dbo].[InvoiceOrderDetailItem] inv
			ON invoice.ID = inv.Invoice
		INNER JOIN [Indico].[dbo].[OrderDetail] od
			ON inv.OrderDetail = od.ID
		INNER JOIN [Indico].[dbo].[OrderDetailQty] odq
			ON odq.OrderDetail = od.ID
	GROUP BY inv.ID

		
			
SELECT 
			invoice.ID AS InvoiceID,
			inv.ID AS InvoiceOrderDetailItemID,
			o.ID AS OrderId,
			od.ID AS OrderDetailId,
			ot.[Name] AS OrderType,
			dis.[Name] AS Distributor,
			c.[Name] AS Client,
			'PO-' + CAST(o.ID AS nvarchar(47)) AS PurchaseOrder,
			vl.[NamePrefix] AS VisualLayout,
			p.[Number] + ' - ' + p.[NickName] AS Pattern,
			fc.[Code] + ' - ' + fc.[NickName] AS Fabric,
			fc.[Filaments] AS Material,
			g.Name AS Gender,
			ag.Name AS AgeGroup,
			'' AS SleeveShape,
			'' AS SleeveLength,
			COALESCE(i.[Name], '') AS ItemSubGroup,
			os.Name AS [Status],
			COALESCE(
				(SELECT TOP 1 
					'http://gw.indiman.net/IndicoData/PatternTemplates/' + CAST(pti.Pattern AS nvarchar(8)) + '/' + pti.[Filename] + pti.Extension
				FROM [Indico].[dbo].[PatternTemplateImage] pti WHERE p.ID = pti.Pattern AND pti.IsHero = 1
				), '' 
			) AS PatternImagePath,
			COALESCE(
				(SELECT TOP 1 
					'http://gw.indiman.net/IndicoData/VisualLayout/' + CAST(vl.ID AS nvarchar(8)) + '/' + im.[Filename] + im.Extension
				FROM [Indico].[dbo].[Image] im WHERE vl.ID = im.VisualLayout AND im.IsHero = 1
				), '' 
			) AS VLImagePath,
			p.[Number],
			inv.OtherCharges,
			inv.FactoryPrice,
			inv.IndimanPrice,
			'' AS FactoryNotes,
			'' AS IndimanNotes,
			COALESCE(cs.QuotedFOBCost, 0.0) AS FactoryCostsheetPrice,
			COALESCE(cs.QuotedCIF, 0.0) AS IndimanCostsheetPrice,
			ISNULL(CAST((SELECT CASE
								WHEN (p.[SubItem] IS NULL)
									THEN  	('')
								ELSE (CAST((SELECT TOP 1 hsc.[Code] FROM [Indico].[dbo].[HSCode] hsc WHERE hsc.[ItemSubCategory] = p.[SubItem] AND hsc.[Gender] = p.[Gender]) AS nvarchar(64)))
						END) AS nvarchar (64)), '') AS HSCode,
			ISNULL(CAST((SELECT CASE
								WHEN (p.[SubItem] IS NULL)
									THEN  	('')
								ELSE (CAST((SELECT it.[Name] FROM [Indico].[dbo].[Item] it WHERE it.[ID] = i.[Parent]) AS nvarchar(64)))
						END) AS nvarchar (64)), '') AS ItemName,
			inv.IsRemoved,
			qi.Qty
	FROM [dbo].[Invoice] invoice
	    INNER JOIN  [dbo].[InvoiceOrderDetailItem] inv
			ON invoice.ID = inv.Invoice
		INNER JOIN #QtyInfo qi
			ON inv.ID = qi.InvoiceOrderDetailItemID		
		INNER JOIN [Indico].[dbo].[OrderDetail] od
			ON inv.OrderDetail = od.ID
		INNER JOIN [Indico].[dbo].[Order] o
			ON od.[Order] = o.ID
		INNER JOIN [Indico].[dbo].[OrderStatus] os
			ON o.[Status] = os.ID
		INNER JOIN [Indico].[dbo].[Company] dis
			ON dis.[ID] = o.[Distributor]		
		INNER JOIN [Indico].[dbo].[OrderType] ot
			ON od.[OrderType] = ot.[ID]
		INNER JOIN [Indico].[dbo].[VisualLayout] vl
			ON od.[VisualLayout] = vl.ID	
		INNER JOIN [Indico].[dbo].[Pattern] p
			ON od.Pattern = p.ID
		INNER JOIN [Indico].[dbo].[FabricCode] fc
			ON od.FabricCode = fc.ID
		LEFT OUTER JOIN [Indico].[dbo].[Gender] g
			ON p.Gender = g.ID
		LEFT OUTER JOIN [Indico].[dbo].[AgeGroup] ag
			ON p.AgeGroup = ag.ID
		LEFT OUTER JOIN [Indico].[dbo].[Item] i
			ON p.[SubItem] = i.ID
		INNER JOIN [Indico].[dbo].[Client] c
			ON o.Client = c.ID
		LEFT OUTER JOIN [Indico].[dbo].[ShipmentMode] sm
			ON sm.[ID] = od.ShipmentMode
		LEFT OUTER JOIN [Indico].[dbo].[PaymentMethod] pm
			ON pm.[ID] = od.PaymentMethod	
		LEFT OUTER JOIN [Indico].[dbo].[CostSheet] cs	
			ON p.ID = cs.Pattern
				AND fc.ID = cs.Fabric
	WHERE invoice.ID = @InvoiceId AND inv.IsRemoved = 0
END

GO





/****** Object:  StoredProcedure [dbo].[SPC_GetInvoiceOrderDetails]    Script Date: 4/3/2017 4:25:53 PM ******/
DROP PROCEDURE [dbo].[SPC_GetInvoiceOrderDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetInvoiceOrderDetails]    Script Date: 4/3/2017 4:25:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/

CREATE PROC [dbo].[SPC_GetInvoiceOrderDetails]
(
	@P_Invoice int,
	@P_ShipTo int,
	@P_IsNew AS bit = 1,
	@P_WeekEndDate datetime2(7), --- OrderDetail Table Shipment Date
	@P_ShipmentMode int
)
AS BEGIN

	IF(@P_IsNew = 1)

			BEGIN
						SELECT od.[ID] AS OrderDetail
							  ,ot.[Name] AS OrderType
							  ,vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),'') AS VisualLayout
							  ,od.[VisualLayout] AS VisualLayoutID
							  ,od.[Pattern] AS PatternID
							  ,p.[Number] + ' - ' + p.[NickName] AS Pattern
							  ,od.[FabricCode] AS FabricID
							  ,fc.[Code] + ' - ' + fc.[Name] AS Fabric							   
							  ,od.[Order] AS 'Order'	
							  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]),0) AS Quantity       
							  ,ISNULL(o.[OldPONo], '') AS 'PurONo'
							  ,c.[Name] AS Distributor
							  ,u.[GivenName] + ' ' + u.[FamilyName] AS Coordinator
							  ,cl.[Name] AS Client							 
							  ,(SELECT CASE
										WHEN (ISNULL((SELECT TOP 1 co.[QuotedFOBCost] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00) = 0.00)
											THEN  	(ISNULL((SELECT TOP 1 co.[JKFOBCost] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00))
										ELSE (ISNULL((SELECT TOP 1 co.[QuotedFOBCost] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00))
								END) AS 'FactoryRate'														  
							  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]), 0) AS 'Qty'
							  ,g.[Name] AS 'Gender'
							  ,ISNULL(ag.[Name], '') AS 'AgeGroup'
							  ,(SELECT CASE
										WHEN (ISNULL((SELECT TOP 1 co.[QuotedCIF] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00) = 0.00)
											THEN  	(ISNULL((SELECT TOP 1 co.[IndimanCIF] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00))
										ELSE (ISNULL((SELECT TOP 1 co.[QuotedCIF] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00))
								END) AS 'IndimanRate'	
							  ,0 AS 'InvoiceOrder'
							  ,dca.[CompanyName] + '  ' + dca.[Address] + '  ' + dca.[Suburb] + '  ' + dca.[PostCode] + '  ' + co.[ShortName] AS ShipmentAddress
							  ,sm.[Name] AS ShipmentMode
							  ,ISNULL(dp.[Name], '') AS DestinationPort
							  ,ISNULL(pm.[Name], '') AS ShipmentTerm
							  ,ISNULL((SELECT [ID] FROM [dbo].[CostSheet] cs WHERE cs.[Pattern] = od.[Pattern] AND cs.[Fabric] = od.[FabricCode]), 0) AS CostSheet
						  FROM [Indico].[dbo].[OrderDetail] od
							JOIN [dbo].[Order] o
								ON od.[Order] = o.[ID]
							JOIN [dbo].[VisualLayout] vl
								ON od.[VisualLayout] = vl.[ID]
							JOIN [dbo].[Pattern] p 
								ON od.[Pattern] = p.[ID]
							JOIN [dbo].[FabricCode] fc
								ON od.[FabricCode] = fc.[ID]						
							JOIN [dbo].[OrderType] ot
								ON od.[OrderType] = ot.[ID]
							JOIN [dbo].[Company] c
								ON c.[ID] = o.[Distributor]
							JOIN [dbo].[User] u
								ON c.[Coordinator] = u.[ID]
							JOIN [dbo].[Client] cl
								ON o.[Client] = cl.[ID]	
							JOIN [dbo].[Gender] g
								ON p.[Gender] = g.[ID]
							LEFT OUTER JOIN [dbo].[AgeGroup] ag
								ON p.[AgeGroup] = ag.[ID]							
							JOIN [dbo].[DistributorClientAddress] dca
								ON o.[BillingAddress] = dca.[ID]
							JOIN [dbo].[Country] co
								ON dca.[Country] = co.[ID]
							JOIN [dbo].[ShipmentMode] sm
								ON o.[ShipmentMode] = sm.[ID]
							LEFT OUTER JOIN [dbo].[DestinationPort] dp
								ON dca.[Port] = dp.[ID] 	
							LEFT OUTER JOIN [dbo].[PaymentMethod] pm
								ON o.[PaymentMethod] = pm.[ID] 							
						WHERE (@P_ShipTo = 0 OR o.[BillingAddress] = @P_ShipTo) AND
							  (@P_ShipmentMode = 0 OR o.[ShipmentMode] = @P_ShipmentMode) AND
							  (od.[ShipmentDate] = @P_WeekEndDate) AND
							  (o.[Status] IN (SELECT [ID] FROM [dbo].[OrderStatus] WHERE [Name] = 'Indiman Submitted' OR [Name] = 'In Progress' OR [Name] = 'Partialy Completed' OR [Name] = 'Completed'))
			END
	ELSE
			BEGIN
			
						SELECT od.[ID] AS OrderDetail
							  ,ot.[Name] AS OrderType
							  ,vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),'') AS VisualLayout
							  ,od.[VisualLayout] AS VisualLayoutID
							  ,od.[Pattern] AS PatternID
							  ,p.[Number] + ' - ' + p.[NickName] AS Pattern
							  ,od.[FabricCode] AS FabricID
							  ,fc.[Code] + ' - ' + fc.[Name] AS Fabric							      
							  ,od.[Order] AS 'Order'	
							  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]),0) AS Quantity       
							  ,ISNULL(o.[OldPONo], '') AS 'PurONo'
							  ,c.[Name] AS Distributor
							  ,u.[GivenName] + ' ' + u.[FamilyName] AS Coordinator
							  ,cl.[Name] AS Client							 
							  ,ISNULL(iod.[FactoryPrice], 0.00) AS 'FactoryRate'
							  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]), 0) AS 'Qty'
							  ,g.[Name] AS 'Gender'
							  ,ISNULL(ag.[Name], '') AS 'AgeGroup'							  
							  ,(SELECT CASE 
									WHEN (ISNULL(iod.[IndimanPrice], 0.00) = 0.00 )
									THEN 
										(SELECT CASE
											WHEN (ISNULL((SELECT TOP 1 co.[QuotedCIF] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00) = 0.00)
												THEN  	(ISNULL((SELECT TOP 1 co.[IndimanCIF] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00))
											ELSE (ISNULL((SELECT TOP 1 co.[QuotedCIF] FROM [dbo].[CostSheet] co WHERE co.[Pattern] = od.[Pattern]AND co.[Fabric] = od.[FabricCode]), 0.00))											
									     END) 
									ELSE (ISNULL(iod.[IndimanPrice],0.00))
									END) AS 'IndimanRate'
							  ,iod.[ID] AS 'InvoiceOrder'
							  ,dca.[CompanyName] + '  ' + dca.[Address] + '  ' + dca.[Suburb] + '  ' + dca.[PostCode] + '  ' + co.[ShortName] AS ShipmentAddress
							  ,sm.[Name] AS ShipmentMode
							  ,ISNULL(dp.[Name], '') AS DestinationPort
							  ,ISNULL(pm.[Name], '') AS ShipmentTerm
							  ,ISNULL((SELECT [ID] FROM [dbo].[CostSheet] cs WHERE cs.[Pattern] = od.[Pattern] AND cs.[Fabric] = od.[FabricCode]), 0) AS CostSheet
						 FROM [Indico].[dbo].[OrderDetail] od
							JOIN [dbo].[Order] o
								ON od.[Order] = o.[ID]
							JOIN [dbo].[VisualLayout] vl
								ON od.[VisualLayout] = vl.[ID]
							JOIN [dbo].[Pattern] p 
								ON od.[Pattern] = p.[ID]
							JOIN [dbo].[FabricCode] fc
								ON od.[FabricCode] = fc.[ID]						
							JOIN [dbo].[OrderType] ot
								ON od.[OrderType] = ot.[ID]
							JOIN [dbo].[Company] c
								ON c.[ID] = o.[Distributor]
							JOIN [dbo].[User] u
								ON c.[Coordinator] = u.[ID]
							JOIN [dbo].[Client] cl
								ON o.[Client] = cl.[ID]	
							JOIN [dbo].[Gender] g
								ON p.[Gender] = g.[ID]
							LEFT OUTER JOIN [dbo].[AgeGroup] ag
								ON p.[AgeGroup] = ag.[ID]
							JOIN [dbo].[InvoiceOrder] iod
								ON od.[ID] = iod.[OrderDetail]	
							JOIN [dbo].[DistributorClientAddress] dca
								ON o.[BillingAddress] = dca.[ID]
							JOIN [dbo].[Country] co
								ON dca.[Country] = co.[ID]
							JOIN [dbo].[ShipmentMode] sm
								ON o.[ShipmentMode] = sm.[ID]
							LEFT OUTER JOIN [dbo].[DestinationPort] dp
								ON dca.[Port] = dp.[ID] 	
							LEFT OUTER JOIN [dbo].[PaymentMethod] pm
								ON o.[PaymentMethod] = pm.[ID] 			
						WHERE /*(@P_ShipTo = 0 OR o.[ShipTo] = @P_ShipTo) AND*/
							  (@P_Invoice = 0 OR iod.[Invoice] = @P_Invoice) /*AND
							  (@P_ShipmentMode = 0 OR i.[ShipmentMode] = @P_ShipmentMode) AND
							  (od.[ShipmentDate] = @P_WeekEndDate)*/
			END
		
END

GO
