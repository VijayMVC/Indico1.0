USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_CreateInvoice]    Script Date: 3/16/2017 3:45:08 PM ******/
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
           ,[Bank])
     VALUES
           (''
		   ,GETDATE()
           ,@DistributorClientAddress
           ,''
           ,@WeeklyProductionCapacity
           ,''
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
           ,NULL)

		SET @InvoiceId = SCOPE_IDENTITY()

		INSERT INTO [dbo].[InvoiceOrderDetailItem]
			   ([Invoice]
			   ,[OrderDetail]
			   ,[OrderDetailQuantity]
			   ,[Order]
			   ,[FactoryPrice]
			   ,[IndimanPrice]
			   ,[OtherCharges]
			   ,[IsRemoved])
		SELECT  @InvoiceId,
				od.ID AS OrderDeatilId,
				odq.Qty,
				od.[Order] AS OrderId,
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

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  StoredProcedure [dbo].[SPC_GetInvoiceOrderDetailItems]    Script Date: 3/16/2017 3:45:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_GetInvoiceOrderDetailItems] 
	@InvoiceId int = NULL
AS
BEGIN
	
	SELECT 	invoice.ID AS InvoiceID,
			inv.ID,
			o.ID AS OrderId,
			od.ID AS OrderDetailId,
			ot.[Name] AS OrderType,
			dis.[Name] AS Distributor,
			c.[Name] AS Client,
			'PO-' + CAST(o.ID AS nvarchar(47)) AS PurchaseOrder,
			vl.[NamePrefix],
			o.[ID] AS PurchaseOrder,
			p.[Number] + ' - ' + p.[NickName] AS Pattern,
			fc.[Code] + ' - ' + fc.[NickName] AS Fabric,
			fc.[Filaments] AS Material,
			g.Name AS Gender,
			ag.Name AS AgeGroup,
			'' AS SleeveShape,
			'' AS SleeveLength,
			COALESCE(i.[Name], '') AS ItemSubGroup,
			inv.OrderDetailQuantity AS Quantity,
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
			'' AS FactoryNotes,
			'' AS IndimanNotes,
			COALESCE(cs.QuotedFOBCost, 0.0) AS JKFOBCostSheetPrice,
			COALESCE(cs.QuotedCIF, 0.0) AS IndimanCIFCostSheetPrice,
			ISNULL(CAST((SELECT CASE
								WHEN (p.[SubItem] IS NULL)
									THEN  	('')
								ELSE (CAST((SELECT TOP 1 hsc.[Code] FROM [Indico].[dbo].[HSCode] hsc WHERE hsc.[ItemSubCategory] = p.[SubItem] AND hsc.[Gender] = p.[Gender]) AS nvarchar(64)))
						END) AS nvarchar (64)), '') AS HSCode,
			ISNULL(CAST((SELECT CASE
								WHEN (p.[SubItem] IS NULL)
									THEN  	('')
								ELSE (CAST((SELECT it.[Name] FROM [Indico].[dbo].[Item] it WHERE it.[ID] = i.[Parent]) AS nvarchar(64)))
						END) AS nvarchar (64)), '') AS ItemName
	FROM [dbo].[Invoice] invoice
	    INNER JOIN  [dbo].[InvoiceOrderDetailItem] inv
			ON invoice.ID = inv.Invoice
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
	WHERE invoice.ID = @InvoiceId
END
GO


