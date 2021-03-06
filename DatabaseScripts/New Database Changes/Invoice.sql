-- Invoice Changes 


USE [Indico]
GO

----------------------ALTERING TABLE 

ALTER TABLE [dbo].[Invoice] ALTER COLUMN [InvoiceNo] [nvarchar](64) NULL
ALTER TABLE [dbo].[Invoice] ALTER COLUMN [InvoiceDate] [datetime2](7) NULL
ALTER TABLE [dbo].[Invoice] ALTER COLUMN [ShipTo] INT NULL
ALTER TABLE [dbo].[Invoice] ALTER COLUMN [Bank] INT NULL

-------------------------------------------------------------- TABLES

IF OBJECT_ID('dbo.InvoiceOrderDetailItem', 'U') IS NOT NULL 
  DROP TABLE  [dbo].[InvoiceOrderDetailItem]
GO

--IF OBJECT_ID('dbo.InvoiceStatus', 'U') IS NOT NULL 
--  DROP TABLE  [dbo].[InvoiceStatus]
--GO

CREATE TABLE [dbo].[InvoiceOrderDetailItem](
 [ID] [int] IDENTITY(1,1) NOT NULL,
 [Invoice] [int] NULL,
 [OrderDetail] [int] NOT NULL,
 [OrderDetailQuantity] [int] NOT NULL,
 [Order] [int] NOT NULL,
 [FactoryPrice] [decimal](8, 2) NULL,
 [IndimanPrice] [decimal](8, 2) NULL,
 [OtherCharges] [decimal](8,2) NULL,
 [SizeQty] [int] NULL,
 [SizeSrn] [int] NULL,
 [SizeName] [nvarchar](255) NULL,
 [IsRemoved] [bit] NOT NULL 
 CONSTRAINT [PK_InvoiceOrderDetailItem] PRIMARY KEY CLUSTERED 
(
 [ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[InvoiceOrderDetailItem]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceOrderDetailItem_Invoice] FOREIGN KEY([Invoice])
REFERENCES [dbo].[Invoice] ([ID])
GO

ALTER TABLE [dbo].[InvoiceOrderDetailItem] CHECK CONSTRAINT [FK_InvoiceOrderDetailItem_Invoice]
GO

ALTER TABLE [dbo].[InvoiceOrderDetailItem]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceOrderDetailItem_OrderDetail] FOREIGN KEY([OrderDetail])
REFERENCES [dbo].[OrderDetail] ([ID])
GO

ALTER TABLE [dbo].[InvoiceOrderDetailItem] CHECK CONSTRAINT [FK_InvoiceOrderDetailItem_OrderDetail]
GO

ALTER TABLE [dbo].[InvoiceOrderDetailItem]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceOrderDetailItem_OrderDetailQuantity] FOREIGN KEY([OrderDetailQuantity])
REFERENCES [dbo].[OrderDetailQty] ([ID])
GO

ALTER TABLE [dbo].[InvoiceOrderDetailItem] CHECK CONSTRAINT [FK_InvoiceOrderDetailItem_OrderDetailQuantity]
GO

ALTER TABLE [dbo].[InvoiceOrderDetailItem]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceOrderDetailItem_Oreder] FOREIGN KEY([Order])
REFERENCES [dbo].[Order] ([ID])
GO

ALTER TABLE [dbo].[InvoiceOrderDetailItem] WITH CHECK ADD CONSTRAINT [DF_InvoiceOrderDetailItem_IsRemoved] DEFAULT (0) FOR [IsRemoved]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrderDetailItem', @level2type=N'COLUMN',@level2name=N'ID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the menu item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrderDetailItem', @level2type=N'COLUMN',@level2name=N'Invoice'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The ID of the Role' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrderDetailItem', @level2type=N'COLUMN',@level2name=N'OrderDetail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Factory Price' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrderDetailItem', @level2type=N'COLUMN',@level2name=N'FactoryPrice'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indiman Price' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrderDetailItem', @level2type=N'COLUMN',@level2name=N'IndimanPrice'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Size Qty' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrderDetailItem', @level2type=N'COLUMN',@level2name=N'SizeQty'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ODQ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrderDetailItem', @level2type=N'COLUMN',@level2name=N'OrderDetailQuantity'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'O' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrderDetailItem', @level2type=N'COLUMN',@level2name=N'Order'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Removed' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrderDetailItem', @level2type=N'COLUMN',@level2name=N'IsRemoved'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Size Srn' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceOrderDetailItem', @level2type=N'COLUMN',@level2name=N'SizeSrn'
GO


----------------------------------------------------------------------- 


CREATE TABLE [dbo].[InvoiceStatus](
 [ID] [int] IDENTITY(1,1) NOT NULL,
 [Key] [nvarchar](64) NOT NULL,
 [Name] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_InvoiceStatus] PRIMARY KEY CLUSTERED 
(
 [ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceStatus', @level2type=N'COLUMN',@level2name=N'ID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The key of the status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceStatus', @level2type=N'COLUMN',@level2name=N'Key'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceStatus', @level2type=N'COLUMN',@level2name=N'Name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceStatus'
GO



----------------------------------------------------------------------- SPS


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetShipmentKeys]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetShipmentKeys]
GO

CREATE PROCEDURE [dbo].[SPC_GetShipmentKeys] 
	@WeekId int
AS
BEGIN

	DECLARE @WeekEndDate datetime2(7)
	SET @WeekEndDate = (SELECT TOP 1 WeekEndDate FROM [dbo].[WeeklyProductionCapacity] WHERE ID = @WeekId)

 SELECT 
	dp.ID,
	dp.[Name] AS DestinationPort,
	dca.CompanyName AS ShipTo,
	od.ShipmentDate,
	sm.[Name] AS ShipmentMethod,
	dca.CompanyName, 
	pm.[Name] AS PriceTerm,
	sm.ID AS ShipmentModeID,
	dca.ID AS ShipToID,
	pm.ID AS PriceTermID,
	dp.ID AS PortID,
	SUM(odq.Qty) AS Qty
 FROM [dbo].[Order] o
	INNER JOIN [dbo].[OrderDetail] od
		ON od.[Order] = o.ID
	INNER JOIN [dbo].[OrderDetailQty] odq
		ON odq.[OrderDetail] = od.ID
	LEFT OUTER JOIN [dbo].[ShipmentMode] sm
		ON od.ShipmentMode = sm.ID
	LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
		ON od.DespatchTo = dca.ID
	LEFT OUTER JOIN [dbo].[DestinationPort] dp
		ON dca.Port= dp.ID
	LEFT OUTER JOIN [dbo].[PaymentMethod] pm
		ON od.PaymentMethod = pm.ID
 WHERE  od.ShipmentDate  <= @WeekEndDate AND od.ShipmentDate >= DATEADD(DAY,-6,@WeekEndDate) 
 GROUP BY dp.ID,dp.Name,od.ShipmentDate,sm.Name,dca.CompanyName,pm.Name,sm.ID,dca.ID,pm.ID
 ORDER BY dca.CompanyName

END


GO


----------------------------------------------------------------------- 


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetInvoiceOrderDetailItems]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetInvoiceOrderDetailItems]
GO

CREATE PROCEDURE [dbo].[SPC_GetInvoiceOrderDetailItems] 
	@Distributor int =  NULL,
	@Port int =  NULL,
	@ShipmentDate datetime2(7) =  NULL,
	@PaymentMethod int =  NULL,
	@Invoice int = NULL,
	@ShipmentMode int = NULL,
	@Creator int = NULL
AS
BEGIN
	
	IF (@Invoice IS NULL)
	BEGIN
	
		DECLARE @WeeklyProductionCapacity int
		SET @WeeklyProductionCapacity = (SELECT TOP 1 ID FROM [dbo].[WeeklyProductionCapacity] WHERE WeekendDate = @ShipmentDate)

		DECLARE @NewInvoiceID int
		DECLARE @ExistingInvoice int
		SET @ExistingInvoice = (SELECT TOP 1 ID  FROM [dbo].[Invoice] WHERE 
			ShipTo =  @Distributor AND WeeklyProductionCapacity = @WeeklyProductionCapacity AND  ShipmentMode = @ShipmentMode AND ShipmentDate = @ShipmentDate )

		IF @ExistingInvoice > 0
			SET @NewInvoiceID = @ExistingInvoice
		ELSE 
		BEGIN
			DECLARE @Preshipped int
			SET @Preshipped = (SELECT TOP 1 ID FROM [dbo].[InvoiceStatus] WHERE [Key]= 'PS')
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
			   (NULL
			   ,NULL
			   ,@Distributor
			   ,NULL
			   ,@WeeklyProductionCapacity
			   ,NULL
			   ,@ShipmentMode
			   ,NULL
			   ,@Creator
			   ,GETDATE()
			   ,@Creator
			   ,GETDATE()
			   ,@Preshipped
			   ,@ShipmentDate
			   ,NULL
			   ,NULL
			   ,NULL)

		
			SET @NewInvoiceID = SCOPE_IDENTITY()
		END

		IF OBJECT_ID('tempdb..#InvoiceItems') IS NOT NULL DROP TABLE #InvoiceItems

		SELECT
			  'PO-' + CAST(o.ID AS nvarchar(47)) AS PurchaseOrderNumber
			 ,ROW_NUMBER() OVER(ORDER BY o.ID) AS Sequance
			 ,o.ID AS OrderID
			 ,od.ID AS OrderDetailID
			 ,odq.ID AS OrderDetailQuantityID
			 ,ot.[Name] AS OrderType
			 ,vl.NamePrefix AS VisualLayout
			 ,p.Number + ' ' + p.NickName AS Pattern
			 ,dca.[CompanyName] AS Distributor
			 ,c.[Name] AS Client
			 ,fc.NickName AS Fabric
			 ,g.[Name] AS Gender
			 ,ISNULL(ag.[Name], '') AS AgeGroup
			 ,s.SizeName AS SizeDescription
			 ,odq.Qty AS SizeQuantity
			 ,s.SeqNo AS SizeSrNumber
			 ,cs.JKFOBCost AS CostsheetPrice
			 ,0.0 AS FactoryPrice
			 ,0.0 AS OtherCharges
			 ,0.0 AS IndimanPrice
			 ,0.0  AS TotalPrice
			 ,0.0 AS Amount
			 ,od.FactoryInstructions AS Notes
			 ,dp.[Name] AS Port
			 ,od.ShipmentDate
			 ,pm.[Name] PaymentMethod
			 ,0 AS Processed  INTO #InvoiceItems
			FROM [dbo].[Order] o
				INNER JOIN [dbo].[OrderDetail] od
					ON od.[Order] = o.ID
				INNER JOIN [dbo].[OrderType] ot
					ON od.OrderType = ot.ID
				LEFT OUTER JOIN [dbo].[VisualLayout] vl
					ON od.VisualLayout = vl.ID
				INNER JOIN [dbo].[Pattern] p
					ON vl.Pattern = p.ID
				LEFT OUTER JOIN [dbo].[JobName] jn
					ON vl.Client = jn.ID
				LEFT OUTER JOIN [dbo].[Client] c
					ON jn.Client = c.ID
				INNER JOIN [dbo].[Company] d
					ON c.Distributor = d.ID
				LEFT OUTER JOIN [dbo].[FabricCode] fc
					ON vl.FabricCode = fc.ID
				INNER JOIN [dbo].[Gender] g
					ON p.Gender = g.ID
				LEFT OUTER JOIN [dbo].[AgeGroup] ag
					ON p.AgeGroup = ag.ID
				INNER JOIN [dbo].[OrderDetailQty] odq
					ON odq.OrderDetail = od.ID
				INNER JOIN [Size] s
					ON odq.Size = s.ID
				LEFT OUTER JOIN [dbo].[CostSheet] cs
					ON cs.Pattern = p.ID AND cs.Fabric = fc.ID
				LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
					ON od.DespatchTo = dca.ID
				LEFT OUTER JOIN [dbo].[DestinationPort] dp
					ON dca.Port= dp.ID
				LEFT OUTER JOIN [dbo].[PaymentMethod] pm
					ON od.PaymentMethod = pm.ID
				INNER JOIN [dbo].[OrderStatus] os
					ON o.[Status] = os.ID
			WHERE odq.Qty > 0 AND  os.ID NOT IN (18,22,23,24,28,31) AND (
				dca.[ID] = @Distributor AND dp.ID  = @Port AND od.ShipmentDate = @ShipmentDate AND pm.ID = @PaymentMethod
			)

			DECLARE @MidTable TABLE (OrderID int, OrderDetailID int, OrderDetailQuantityID int )
			DECLARE @CurrentQuantity int
			DECLARE @Index int = 0
			DECLARE @Id int

			WHILE (SELECT COUNT(*) FROM #InvoiceItems WHERE Processed = 0) > 0
			BEGIN
				SET @CurrentQuantity = (SELECT TOP 1  SizeQuantity FROM #InvoiceItems WHERE  Processed = 0)
				SET @Id = (SELECT TOP 1  Sequance FROM #InvoiceItems WHERE  Processed = 0)
			
				WHILE @Index < @CurrentQuantity
				BEGIN
					INSERT INTO @MidTable (OrderID, OrderDetailID, OrderDetailQuantityID) (SELECT TOP 1 OrderID, OrderDetailID, OrderDetailQuantityID FROM #InvoiceItems WHERE  Processed = 0)
					SET @Index = @Index + 1
				END

				SET @Index = 0

				UPDATE ii 
				SET Processed = 1
				FROM #InvoiceItems ii
				WHERE Sequance = @Id 
			END

			
			MERGE [dbo].[InvoiceOrderDetailItem]  AS T
			USING (SELECT 
				ii.*,
				iodi.ID AS InvoiceOrderDI
			FROM @MidTable mt
				INNER JOIN #InvoiceItems ii
					ON mt.OrderDetailID = ii.OrderDetailID-- AND mt.OrderDetailQuantityID = ii.OrderDetailQuantityID
				LEFT OUTER JOIN [dbo].[InvoiceOrderDetailItem] iodi
					ON mt.OrderDetailID = iodi.OrderDetail AND iodi.IsRemoved = 0
			) AS S

			ON (S.InvoiceOrderDI = T.ID) 
			WHEN NOT MATCHED
				THEN INSERT(OrderDetail, FactoryPrice, IndimanPrice, SizeQty, SizeSrn, SizeName, [Order], [OrderDetailQuantity], [Invoice]) 
					VALUES(S.OrderDetailID, 0.0, 0.0, S.SizeQuantity, S.SizeSrNumber, S.SizeDescription, S.OrderID, S.OrderDetailQuantityID, @NewInvoiceID);

			SELECT DISTINCT iodi.ID AS InvoiceOrderDetailItemID , iodi.Invoice , ii.* FROM [dbo].[InvoiceOrderDetailItem] iodi
				INNER JOIN #InvoiceItems ii
					ON  iodi.OrderDetail = ii.OrderDetailID AND iodi.[Order] = ii.OrderID AND iodi.[OrderDetailQuantity] = ii.OrderDetailQuantityID AND iodi.IsRemoved = 0

	END
	ELSE
	BEGIN
		SELECT
			  'PO-' + CAST(o.ID AS nvarchar(47)) AS PurchaseOrderNumber
			 ,ROW_NUMBER() OVER(ORDER BY o.ID) AS Sequance
			 ,o.ID AS OrderID
			 ,od.ID AS OrderDetailID
			 ,odq.ID AS OrderDetailQuantityID
			 ,ot.[Name] AS OrderType
			 ,vl.NamePrefix AS VisualLayout
			 ,p.Number + ' ' + p.NickName AS Pattern
			 ,dca.[CompanyName] AS Distributor
			 ,c.[Name] AS Client
			 ,fc.NickName AS Fabric
			 ,g.[Name] AS Gender
			 ,ISNULL(ag.[Name], '') AS AgeGroup
			 ,s.SizeName AS SizeDescription
			 ,odq.Qty AS SizeQuantity
			 ,s.SeqNo AS SizeSrNumber
			 ,cs.JKFOBCost AS CostsheetPrice
			 ,iodi.FactoryPrice AS FactoryPrice
			 ,iodi.[OtherCharges] AS OtherCharges
			 ,iodi.[IndimanPrice] AS IndimanPrice
			 ,iodi.FactoryPrice + iodi.[OtherCharges]  AS TotalPrice
			 ,iodi.FactoryPrice + iodi.[OtherCharges] AS Amount
			 ,od.FactoryInstructions AS Notes
			 ,dp.[Name] AS Port
			 ,od.ShipmentDate
			 ,pm.[Name] PaymentMethod
			 ,0 AS Processed
			 ,iodi.ID AS InvoiceOrderDetailItemID
			 ,iodi.Invoice
			FROM [dbo].[Order] o
				INNER JOIN [dbo].[OrderDetail] od
					ON od.[Order] = o.ID
				INNER JOIN [dbo].[InvoiceOrderDetailItem] iodi
					ON iodi.OrderDetail = od.ID
				INNER JOIN [dbo].[OrderType] ot
					ON od.OrderType = ot.ID
				LEFT OUTER JOIN [dbo].[VisualLayout] vl
					ON od.VisualLayout = vl.ID
				INNER JOIN [dbo].[Pattern] p
					ON vl.Pattern = p.ID
				LEFT OUTER JOIN [dbo].[JobName] jn
					ON vl.Client = jn.ID
				LEFT OUTER JOIN [dbo].[Client] c
					ON jn.Client = c.ID
				INNER JOIN [dbo].[Company] d
					ON c.Distributor = d.ID
				LEFT OUTER JOIN [dbo].[FabricCode] fc
					ON vl.FabricCode = fc.ID
				INNER JOIN [dbo].[Gender] g
					ON p.Gender = g.ID
				LEFT OUTER JOIN [dbo].[AgeGroup] ag
					ON p.AgeGroup = ag.ID
				INNER JOIN [dbo].[OrderDetailQty] odq
					ON odq.OrderDetail = od.ID
				INNER JOIN [Size] s
					ON odq.Size = s.ID
				LEFT OUTER JOIN [dbo].[CostSheet] cs
					ON cs.Pattern = p.ID AND cs.Fabric = fc.ID
				LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
					ON od.DespatchTo = dca.ID
				LEFT OUTER JOIN [dbo].[DestinationPort] dp
					ON dca.Port= dp.ID
				LEFT OUTER JOIN [dbo].[PaymentMethod] pm
					ON od.PaymentMethod = pm.ID
				INNER JOIN [dbo].[OrderStatus] os
					ON o.[Status] = os.ID
			WHERE odq.Qty > 0 AND  os.ID NOT IN (18,22,23,24,28,31) AND iodi.[Invoice] = @Invoice AND iodi.IsRemoved = 0
	END
END
GO

-------------------------------------------------------------------------- VIEWS


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[NewShipmentOrderDetailSizeQtyView]'))
	DROP VIEW [dbo].[NewShipmentOrderDetailSizeQtyView]
GO

CREATE VIEW [dbo].[NewShipmentOrderDetailSizeQtyView]
AS

SELECT 
	  'PO-' + CAST(o.ID AS nvarchar(47)) AS PurchaseOrderNumber
	 ,ot.[Name] AS OrderType
	 ,vl.NamePrefix AS VisualLayout
	 ,p.Number + ' ' + p.NickName AS Pattern
	 ,dca.[CompanyName] AS Distributor
	 ,c.[Name] AS Client
	 ,fc.NickName AS Fabric
	 ,g.[Name] AS Gender
	 ,ISNULL(ag.[Name], '') AS AgeGroup
	 ,s.SizeName AS SizeDescription
	 ,odq.Qty AS SizeQuantity
	 ,s.SeqNo AS SizeSrNumber
	 ,cs.JKFOBCost AS CostsheetPrice
	 ,0.0 AS FactoryPrice
     ,0.0 AS TotalPrice
     ,0.0 AS Amount
	 ,od.FactoryInstructions AS Notes
	 ,dp.[Name] AS Port
	 ,od.ShipmentDate
	 ,pm.[Name] PaymentMethod
FROM [dbo].[Order] o
	INNER JOIN [dbo].[OrderDetail] od
		ON od.[Order] = o.ID
	INNER JOIN [dbo].[OrderType] ot
		ON od.OrderType = ot.ID
	LEFT OUTER JOIN [dbo].[VisualLayout] vl
		ON od.VisualLayout = vl.ID
	INNER JOIN [dbo].[Pattern] p
		ON vl.Pattern = p.ID
	LEFT OUTER JOIN [dbo].[JobName] jn
		ON vl.Client = jn.ID
	LEFT OUTER JOIN [dbo].[Client] c
		ON jn.Client = c.ID
	INNER JOIN [dbo].[Company] d
		ON c.Distributor = d.ID
	LEFT OUTER JOIN [dbo].[FabricCode] fc
		ON vl.FabricCode = fc.ID
	INNER JOIN [dbo].[Gender] g
		ON p.Gender = g.ID
	LEFT OUTER JOIN [dbo].[AgeGroup] ag
		ON p.AgeGroup = ag.ID
	INNER JOIN [dbo].[OrderDetailQty] odq
		ON odq.OrderDetail = od.ID
	INNER JOIN [Size] s
		ON odq.Size = s.ID
	LEFT OUTER JOIN [dbo].[CostSheet] cs
		ON cs.Pattern = p.ID AND cs.Fabric = fc.ID
	LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
		ON od.DespatchTo = dca.ID
	LEFT OUTER JOIN [dbo].[DestinationPort] dp
		ON dca.Port= dp.ID
	LEFT OUTER JOIN [dbo].[PaymentMethod] pm
		ON od.PaymentMethod = pm.ID
	INNER JOIN [dbo].[OrderStatus] os
		ON o.[Status] = os.ID
	WHERE odq.Qty > 0 AND  os.ID NOT IN (18,22,23,24,28,31)
GO


