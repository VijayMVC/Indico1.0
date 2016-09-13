SET NOCOUNT ON

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
DECLARE @ShipmentDate AS DATETIME
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
DECLARE @VisualLayoutID AS int
DECLARE @TODAY AS DATETIME2(7)
SET @TODAY = GETDATE()

DECLARE @found AS bit
DECLARE OrderCursor CURSOR FAST_FORWARD FOR 
SELECT [ID]
      ,[OrderNumber]
      ,[ProductID]
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
      ,[InvoiceNumber]
      ,[PrinterID]
  FROM [OPS].[dbo].[tbl_Order]
	--ORDER BY op.[ProductNumber], op.[DateCreated]
OPEN OrderCursor 
	FETCH NEXT FROM OrderCursor INTO @Id, @OrderNumber, @ProductID, @Notes,@DateCreated,@OrderDate,															 @OrderTypeID, @DestinationPortID, @ShipmentModeID, @ShipmentDate,@StatusID, 
									 @DateUpdated, @CreatedBy,@UpdatedBy,@EstimatedCompletionDate,@PaymentMethodID,
									 @OrderUsage,@ShippingAddress,@PONo,@ShipTo,@Converted,@OldPONo,@PrinterID,
									 @InvoiceNumber
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		SET @found = 1 
		
		IF (EXISTS(SELECT ID FROM OPS.dbo.tbl_DestinationPort  WHERE ID = @DestinationPortID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_ShipmentMode WHERE ID = @ShipmentModeID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_OrderStatus  WHERE ID = @StatusID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_PaymentMethod  WHERE ID = @PaymentMethodID))
		
		BEGIN
			INSERT INTO Indico.dbo.[Order] (OrderNumber ,[Date] , DesiredDeliveryDate , Client , Distributor ,														OrderSubmittedDate,EstimatedCompletionDate ,CreatedDate , ModifiedDate , 
											DestinationPort , ShipmentMode ,ShipmentDate , [Status] , Creator ,Modifier ,
											PaymentMethod , OrderUsage ,ShippingAddress , PurchaseOrderNo , ShipTo , 
											Converted , OldPONo ,PhotoApprovalReq , Invoice , Printer ,IsTemporary ,
											ContactCompanyName , ContactName ,ContactNumber ,AltContactName ,
											AltContactNumber ,DeliveryMethod ,DeliveryAddress ,DeliveryCity ,
											DeliveryPostCode ,IsRepeat ,Reservation) 
			  
			VALUES (	@OrderNumber,
						@TODAY,
						@TODAY,
						1,
						1,
						CAST(@OrderDate AS DATETIME2),
						ISNULL(CAST(@EstimatedCompletionDate AS DATETIME2),(SELECT GETDATE())),
						CAST(@DateCreated AS DATETIME2),
						CAST(@DateUpdated AS DATETIME2),
					(	SELECT TOP 1 1 ID FROM Indico.dbo.DestinationPort idp 
													WHERE idp.Name = 
												   (SELECT TOP 1 Name FROM OPS.dbo.tbl_DestinationPort odp
													WHERE odp.ID = @DestinationPortID)),
					(	SELECT TOP 1 ID FROM Indico.dbo.ShipmentMode ism 
													WHERE ism.Name = 
												   (SELECT TOP 1 Name FROM OPS.dbo.tbl_ShipmentMode osm
													WHERE osm.ID = @ShipmentModeID)),
													
						CAST(@ShipmentDate AS DATETIME2),
						
					(	SELECT TOP 1 ID FROM Indico.dbo.OrderStatus ios 
													WHERE ios.Name = 
												   (SELECT TOP 1 Name FROM OPS.dbo.tbl_OrderStatus oos
													WHERE oos.ID = @StatusID)),
						ISNULL(@CreatedBy ,1),
						ISNULL(@UpdatedBy ,1),
					(	SELECT TOP 1 ID FROM Indico.dbo.PaymentMethod ipm 
													WHERE ipm.Name = 
												   (SELECT TOP 1 Name FROM OPS.dbo.tbl_PaymentMethod  opm
													WHERE opm.ID = @PaymentMethodID)),
									
						@OrderUsage,
						@ShippingAddress,
						@PONo,
						@ShipTo,
						@Converted,
						@OldPONo,
						NULL,
						ISNULL((SELECT TOP 1 ID FROM Indico.dbo.Invoice iin 
														WHERE iin.InvoiceNo =
													   (SELECT TOP 1 oin.InvoiceNumber FROM OPS.dbo.tbl_Invoice oin
														WHERE oin.ID = @InvoiceNumber)),NULL),
						ISNULL((SELECT TOP 1 ID FROM Indico.dbo.Printer p
														WHERE P.Name =
													   (SELECT TOP 1 op.Name FROM OPS.dbo.tbl_Printer op
														WHERE op.ID=@PrinterID)),1),
						0,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						0,
						NULL
				 )	
						
			
				SET @OrderID = SCOPE_IDENTITY ()
				SET @VisualLayoutID = (SELECT vm.[NewId] FROM Indico.dbo.VisualLayoutMapping vm
																		WHERE vm.OldId = @ProductID)
												
			INSERT INTO @OrderDetail (OrderType , VisualLayout , Pattern , FabricCode , VisualLayoutNotes ,													  NameAndNumbersFilePath , [Order] ,Label) 
			VALUES(
					(	SELECT TOP 1 ID FROM Indico.dbo.OrderType iot
												WHERE iot.Name =
											   (SELECT TOP 1 Name FROM OPS.dbo.tbl_OrderType  oot
												WHERE oot.ID = @OrderTypeID)),
						@VisualLayoutID,
					(	SELECT ivl.Pattern FROM Indico.dbo.VisualLayout ivl WHERE ivl.ID = @VisualLayoutID),
					(	SELECT ivl.FabricCode  FROM Indico.dbo.VisualLayout ivl WHERE ivl.ID = @VisualLayoutID),
						@Notes,
						NULL,
						@OrderID,
						NULL
				  )
		END
			  
		FETCH NEXT FROM OrderCursor INTO @Id, @OrderNumber, @ProductID, @Notes,@DateCreated,@OrderDate,															 @OrderTypeID, @DestinationPortID, @ShipmentModeID, @ShipmentDate,@StatusID, 
										 @DateUpdated, @CreatedBy,@UpdatedBy,@EstimatedCompletionDate,@PaymentMethodID,
									     @OrderUsage,@ShippingAddress,@PONo,@ShipTo,@Converted,@OldPONo,@PrinterID,
										 @InvoiceNumber	
END 
INSERT INTO Indico.dbo.OrderDetail 
SELECT * FROM @OrderDetail
CLOSE OrderCursor 
DEALLOCATE OrderCursor
	

GO

