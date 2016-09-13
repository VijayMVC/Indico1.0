SET NOCOUNT ON
 DECLARE @OrderTable TABLE (
	[OrderNumber] [nvarchar](64) NULL,
	[Date] [datetime2](7)  NULL,
	[DesiredDeliveryDate] [datetime2](7)  NULL,
	[Client] [int]  NULL,
	[Distributor] [int]  NULL,
	[OrderSubmittedDate] [datetime2](7)  NULL,
	[EstimatedCompletionDate] [datetime2](7)  NULL,
	[CreatedDate] [datetime2](7)  NULL,
	[ModifiedDate] [datetime2](7)  NULL,
	[DestinationPort] [int] NULL,
	[ShipmentMode] [int] NULL,
	[ShipmentDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Creator] [int] NULL,
	[Modifier] [int] NULL,
	[PaymentMethod] [int] NULL,
	[OrderUsage] [nvarchar](255) NULL,
	[ShippingAddress] [nvarchar](255) NULL,
	[PurchaseOrderNo] [int] NULL,
	[ShipTo] [nvarchar](512) NULL,
	[Converted] [bit] NULL,
	[OldPONo] [nvarchar](255) NULL,
	[PhotoApprovalReq] [bit] NULL,
	[Invoice] [int] NULL,
	[Printer] [int] NULL,
	[IsTemporary] [bit] NULL,
	[ContactCompanyName] [nvarchar](255) NULL,
	[ContactName] [nvarchar](255) NULL,
	[ContactNumber] [nvarchar](255) NULL,
	[AltContactName] [nvarchar](255) NULL,
	[AltContactNumber] [nvarchar](255) NULL,
	[DeliveryMethod] [int] NULL,
	[DeliveryAddress] [nvarchar](255) NULL,
	[DeliveryCity] [nvarchar](255) NULL,
	[DeliveryPostCode] [nvarchar](255) NULL,
	[IsRepeat] [bit] NULL,
	[Reservation] [int] NULL) 
	
DECLARE @OrderDetail TABLE(
	[OrderType] [int] NULL,
	[VisualLayout] [int] NULL,
	[Pattern] [int] NULL,
	[FabricCode] [int] NULL,
	[VisualLayoutNotes] [nvarchar](255) NULL,
	[NameAndNumbersFilePath] [nvarchar](255) NULL,
	[Order] [int] NULL,
	[Label] [int] NULL)

DECLARE @Id AS int
DECLARE @OrderNumber  AS nvarchar(255)
DECLARE @ProductID AS int
DECLARE @EmployeeID AS int
DECLARE @Notes  AS nvarchar(255)
DECLARE @DateCreated AS DATETIME
DECLARE @OrderDate AS DATETIME
DECLARE @OrderTypeID AS int
DECLARE @DestinationPortID AS int
DECLARE @ShipmentModeID AS int
DECLARE @ShipmentDate AS int
DECLARE @StatusID AS int
DECLARE @DateUpdated AS DATETIME
DECLARE @CreatedBy AS int
DECLARE @UpdatedBy AS int
DECLARE @EstimatedCompletionDate AS DATETIME
DECLARE @PaymentMethodID AS int
DECLARE @OrderUsage AS nvarchar(255)
DECLARE @ShippingAddress AS nvarchar(255)
DECLARE @PONo AS int
DECLARE @ShipTo AS int
DECLARE @Converted AS bit
DECLARE @OldPONo AS nvarchar(255)
DECLARE @PrinterID AS int
DECLARE @InvoiceNumber AS int
DECLARE @OrderID AS int

DECLARE @found AS bit
DECLARE OrderCursor CURSOR FAST_FORWARD FOR 
SELECT [ID]
      ,[OrderNumber]
      ,[ProductID]
      ,[EmployeeID]
      ,[Notes]
      ,[DateCreated]
      ,[OrderDate]
      ,[OrderTypeID]
      ,[DestinationPortID]
      ,[ShipmentModeID]
      ,[ShipmentDate]
      ,[StatusID]
      ,[DateUpdated]
      ,[CreatedBy]
      ,[UpdatedBy]
      ,[EstimatedCompletionDate]
      ,[PaymentMethodID]
      ,[OrderUsage]
      ,[ShippingAddress]
      ,[PONo]
      ,[ShipTo]
      ,[Converted]
      ,[OldPONo]
   --  ,[PAR]
   --   ,[NTP]
   --   ,[LabelID]
      ,[Shipped]     
      ,[InvoiceNumber]
      ,[PrinterID]
  FROM [OPS].[dbo].[tbl_Order]
	ORDER BY op.[ProductNumber], op.[DateCreated]
OPEN OrderCursor 
	FETCH NEXT FROM OrderCursor INTO @Id, @OrderNumber, @ProductID, @EmployeeID, @Notes,@DateCreated,@OrderDate,										 @OrderTypeID, @DestinationPortID, @ShipmentModeID, @ShipmentDate,@StatusID, 
									 @DateUpdated, @CreatedBy,@UpdatedBy,@EstimatedCompletionDate,@PaymentMethodID,
									 @OrderUsage,@ShippingAddress,@PONo,@ShipTo,@Converted,@OldPONo,@PrinterID,
									 @InvoiceNumber
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		SET @found = 1 
		
		IF (EXISTS(SELECT ID FROM OPS.dbo.tbl_DestinationPort  WHERE ID = @DestinationPortID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_ShipmentMode WHERE ID = @ShipmentModeID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_OrderStatus  WHERE ID = @StatusID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Printer WHERE ID = @PrinterID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_PaymentMethod  WHERE ID = @PaymentMethodID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Product WHERE ID =@ProductID))
		BEGIN
			INSERT INTO @OrderTable(OrderNumber, [Date], DesiredDeliveryDate, Client, Distributor, OrderSubmittedDate,EstimatedCompletionDate, 
				ShipmentDate, [Status], Creator, Modifier, PaymentMethod, OrderUsage, ShippingAddress, PurchaseOrderNo, ShipTo, Converted, OldPONo, 
				PhotoApprovalReq, Invoice, Printer, IsTemporary, ContactCompanyName, ContactName, AltContactName, AltContactNumber, DeliveryMethod, 
				DeliveryAddress , DeliveryCity, DeliveryCity, IsRepeat, Reservation)
			  
			VALUES (@OrderNumber,
					(SELECT GETDATE()),
					(SELECT GETDATE ()),
					NULL,
					NULL,
					@ORDER)				 
			
				SET @OrderID = SCOPE_IDENTITY ()	
			INSERT INTO @OrderDetail (OrderType, VisualLayout, Pattern, FabricCode, VisualLayoutNotes, NameAndNumbersFilePath, [Order], Label) 
			VALUES()
		END
			  
		FETCH NEXT FROM OrderCursor INTO @Id, @ProductNumber, @PatternId, @ResolutionProfileID, @ColourProfileID,												@ContactID, @Notes, @DateCreated, @FabricCodesID, @DistributorID, 
												@EmployeeID, @PrinterID	
END 

INSERT INTO Indico.dbo.VisualLayout 
SELECT * FROM @VisualLayout WHERE Coordinator IS NOT NULL

CLOSE OrderCursor 
DEALLOCATE OrderCursor
	
GO
