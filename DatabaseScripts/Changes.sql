USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_CloneOrder]    Script Date: 11/4/2016 3:17:20 PM ******/
DROP PROCEDURE [dbo].[SPC_CloneOrder]
GO

/****** Object:  StoredProcedure [dbo].[SPC_CloneOrder]    Script Date: 11/4/2016 3:17:20 PM ******/
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
		,'0' --[Qty]
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




--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
