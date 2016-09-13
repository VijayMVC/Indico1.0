USE [Indico]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

-- shifting VLs (VL37037 & VL37038) from Troy to Travis..

  UPDATE [dbo].Client SET Distributor = '1435'
  WHERE ID = '11006'

  GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

  /****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 5/12/2016 1:28:44 PM ******/
DROP PROCEDURE [dbo].[SPC_ViewOrderDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewOrderDetails]    Script Date: 5/12/2016 1:28:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_ViewOrderDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',
	@P_LogCompanyID AS int = 0,
	@P_Status AS nvarchar(255),
	@P_Coordinator AS int = 0,
	@P_Distributor AS int = 0,
	@P_Client AS int = 0,
	@P_SelectedDate1 AS datetime2(7) = NULL,
	@P_SelectedDate2 AS datetime2(7) = NULL,
	@P_DistributorClientAddress AS int = 0	 
)
AS
BEGIN

	SET NOCOUNT ON
	DECLARE @orderid AS int;
	DECLARE @status AS TABLE ( ID int )
	
	IF (ISNUMERIC(@P_SearchText) = 1) 
		BEGIN
			SET @orderid = CONVERT(INT, @P_SearchText)		
		END
	ELSE
		BEGIN	
			SET @orderid = 0
		END;
	
	INSERT INTO @status (ID) SELECT DATA FROM [dbo].Split(@P_Status,',');
	
	SELECT 			
		   od.[ID] AS OrderDetail
		  ,ISNULL(od.EditedPrice, 0) AS EditedPrice
		  ,ot.[Name] AS OrderType
		  --,ISNULL(vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),''),'') AS VisualLayout		  
		  ,(SELECT CASE 
			 WHEN od.VisualLayout IS NOT NULL THEN ISNULL(vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),''),'') 			 
			 ELSE ISNULL(aw.ReferenceNo ,'')
			END)
		  AS VisualLayout		  
		  ,ISNULL(od.[VisualLayout],0) AS VisualLayoutID
		  --,od.[Pattern] AS PatternID
		   ,(SELECT CASE 
			WHEN  (ISNULL(od.[VisualLayout],0)>0) 
			THEN vl.Pattern
			ELSE od.Pattern
			END ) AS PatternID
		  --,p.[Number] + ' - ' + p.[NickName] AS Pattern
		   ,(SELECT CASE 
			WHEN  (ISNULL(od.[VisualLayout],0)>0) 
			THEN ( SELECT ( Number + ' - ' + NickName) FROM [dbo].Pattern WHERE ID = vl.Pattern )
			ELSE  ( SELECT ( Number + ' - ' + NickName) FROM [dbo].Pattern WHERE ID = od.Pattern )
			END ) AS Pattern
		  --,od.[FabricCode] AS FabricID
		  ,(SELECT CASE 
			WHEN  (ISNULL(od.[VisualLayout],0)>0) 
			THEN vl.FabricCode
			ELSE od.FabricCode
			END ) AS FabricID
		  --,fc.[Code] + ' - ' + fc.[Name] AS Fabric
		   ,(SELECT CASE 
			WHEN  (ISNULL(od.[VisualLayout],0)>0) 
			THEN ( SELECT ( [Code] + ' - ' + [Name]) FROM [dbo].FabricCode WHERE ID = vl.FabricCode )
			ELSE  ( SELECT ( [Code] + ' - ' + [Name]) FROM [dbo].FabricCode WHERE ID = od.FabricCode )
			END ) AS Fabric
		  ,ISNULL(od.[VisualLayoutNotes],'') AS VisualLayoutNotes      
		  ,od.[Order] AS 'Order'
		  --,ISNULL(o.[Label], 0) AS Label
		  ,ISNULL(ods.[Name], 'New') AS OrderDetailStatus
		  ,ISNULL(od.[Status], 0) AS OrderDetailStatusID
		  ,od.[ShipmentDate] AS ShipmentDate
		  ,od.[SheduledDate] AS SheduledDate      
		  ,od.[RequestedDate] AS RequestedDate
		  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]),0) AS Quantity      
		  ,(SELECT DATEDIFF(day, od.[RequestedDate], od.[SheduledDate])) AS 'DateDiffrence'
		  ,ISNULL(o.[OldPONo], '') AS 'PurONo'
		  ,c.[Name] AS Distributor
		  ,u.[GivenName] + ' ' + u.[FamilyName] AS Coordinator
		  --,cl.[Name] AS Client
		  ,ISNULL ( (SELECT cl.Name From [dbo].JobName j
			INNER JOIN [dbo].Client cl
				ON j.Client = cl.ID
			WHERE j.ID = vl.Client), '') AS Client
		  ,os.[Name] AS OrderStatus
		  ,o.[Status] AS OrderStatusID
		  ,urc.[GivenName] + ' ' + urc.[FamilyName] AS Creator
		  ,o.[Creator] AS CreatorID
		  ,o.[CreatedDate] AS CreatedDate
		  ,urm.[GivenName] + ' ' + urm.[FamilyName] AS Modifier
		  ,o.[ModifiedDate] AS ModifiedDate
		  ,ISNULL(pm.[Name], '') AS PaymentMethod
		  ,ISNULL(sm.[Name], '') AS ShipmentMethod
		  ,o.[IsWeeklyShipment]  AS WeeklyShiment
		  ,o.[IsCourierDelivery]  AS CourierDelivery
		  ,o.[IsAdelaideWareHouse] AS AdelaideWareHouse
		  ,o.[IsFollowingAddress] AS FollowingAddress
		  ,ISNULL(bdca.[CompanyName] + ' ' + bdca.[Address] + ' ' + bdca.[Suburb] + ' ' + ISNULL(bdca.[State], '') + ' ' + bco.[ShortName] + ' ' + bdca.[PostCode], '') 
		  AS BillingAddress
		  ,ISNULL(ddca.[CompanyName] 
		  --+ ' ' + ddca.[Address] + ' ' + ddca.[Suburb] + ' ' + ISNULL(ddca.[State], '') + ' ' + dco.[ShortName] + ' ' + ddca.[PostCode]
		  , '') 
		  AS ShippingAddress
		  ,ISNULL(ddp.[Name], '') AS DestinationPort
		  ,ISNULL(vl.[ResolutionProfile], 0 ) AS ResolutionProfile
		  ,o.[IsAcceptedTermsAndConditions] AS IsAcceptedTermsAndConditions
		  ,od.Surcharge
		  ,cl.FOCPenalty 
	  FROM [dbo].[Order] o				
		LEFT OUTER JOIN [dbo].[OrderStatus] os
			ON o.[Status] = os.[ID]
		--LEFT OUTER JOIN [dbo].[Company] c
		--	ON o.[Distributor] = c.[ID]
		--LEFT OUTER JOIN [dbo].[User] u
		--	ON c.[Coordinator] = u.[ID]	
		--LEFT OUTER JOIN [dbo].[JobName] j
		--	ON o.[Client] = j.[ID]
		--LEFT OUTER JOIN [dbo].[Client] cl
		--	ON j.[Client] = cl.[ID]					
		LEFT OUTER JOIN [dbo].[User] urc
			ON o.[Creator] = urc.[ID]
		LEFT OUTER JOIN [dbo].[User] urm
			ON o.[Modifier] = urm.[ID]		
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] bdca
			ON o.[BillingAddress] = bdca.[ID]		
		LEFT OUTER JOIN [dbo].[Country] bco
			ON bdca.[Country] = bco.[ID]		
		LEFT OUTER JOIN [dbo].[DestinationPort] bdp
			ON bdca.[Port] = bdp.[ID] 			
		INNER JOIN [dbo].[OrderDetail] od				
			ON o.[ID] = od.[Order]
		LEFT OUTER JOIN [dbo].[DistributorClientAddress] ddca
			ON od.[DespatchTo] = ddca.[ID]
		LEFT OUTER JOIN [dbo].[Country] dco
			ON ddca.[Country] = dco.[ID]
		LEFT OUTER JOIN [dbo].[DestinationPort] ddp
			ON ddca.[Port] = ddp.[ID] 				
		LEFT OUTER JOIN [dbo].[PaymentMethod] pm
			ON od.[PaymentMethod] = pm.[ID]
		LEFT OUTER JOIN [dbo].[ShipmentMode] sm
			ON od.[ShipmentMode] = sm.[ID]					
		LEFT OUTER JOIN [dbo].[VisualLayout] vl
			ON od.[VisualLayout] = vl.[ID]
		LEFT OUTER JOIN [dbo].[ArtWork] aw
			ON od.[ArtWork] = aw.[ID]
		--LEFT OUTER JOIN [dbo].[Pattern] p 
		--	ON od.[Pattern] = p.[ID]
		--LEFT OUTER JOIN [dbo].[FabricCode] fc
		--	ON od.[FabricCode] = fc.[ID]
		LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
			ON od.[Status] = ods.[ID]
		LEFT OUTER JOIN [dbo].[OrderType] ot
			ON od.[OrderType] = ot.[ID]	
		INNER JOIN [dbo].[JobName] j
			ON vl.[Client] = j.[ID]
		INNER JOIN [dbo].[Client] cl
			ON j.[Client] = cl.[ID]	
		INNER JOIN [dbo].[Company] c
			ON cl.Distributor = c.[ID]
		LEFT OUTER JOIN [dbo].[User] u
			ON c.[Coordinator] = u.[ID]
	WHERE (@P_SearchText = '' OR
			o.[ID] = @orderid OR
		   o.[OldPONo] LIKE '%' + @P_SearchText + '%' OR
		   u.[GivenName]  LIKE '%' + @P_SearchText + '%' OR
		   u.[FamilyName] LIKE '%' + @P_SearchText + '%' OR
		   --p.[Number] LIKE '%' + @P_SearchText + '%' OR 
		   --p.[NickName] LIKE '%' + @P_SearchText + '%' OR
		   vl.[NamePrefix] LIKE '%' + @P_SearchText + '%' OR 
		   vl.[NameSuffix] LIKE '%' + @P_SearchText + '%' OR 
		   ods.[Name] LIKE '%' + @P_SearchText + '%' OR 
		   ot.[Name] LIKE '%' + @P_SearchText + '%' OR
		   c.[Name] LIKE '%' + @P_SearchText + '%' OR 
		   cl.[Name] LIKE '%' + @P_SearchText + '%' --OR					
		   --fc.[Code] LIKE '%' + @P_SearchText + '%' OR 
		   --fc.[Name] LIKE '%' + @P_SearchText + '%'  
			)AND
		   (@P_Status = '' OR  (os.[ID] IN (SELECT ID FROM @status)) )  AND											   
		  (@P_LogCompanyID = 0 OR c.[ID] = @P_LogCompanyID)	AND
		  (@P_Coordinator = 0 OR c.[Coordinator] = @P_Coordinator ) AND				  
		  (@P_Distributor = 0 OR o.Distributor = @P_Distributor)	AND
		  (@P_Client = 0 OR o.[Client] = @P_Client) AND				  
		  (@P_DistributorClientAddress = 0 OR o.[BillingAddress] = @P_DistributorClientAddress) AND
		  ((@P_SelectedDate1 IS NULL AND @P_SelectedDate2 IS NULL) OR (o.[Date] BETWEEN @P_SelectedDate1 AND @P_SelectedDate2))
	--ORDER BY o.[ID] DESC			
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_ValidateField2]    Script Date: 3/30/2016 4:03:06 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ValidateField2]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ValidateField2]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ValidateField2]    Script Date: 3/30/2016 4:03:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_ValidateField2]
(
	@P_ID INT = 0,
	@P_TableName AS NVARCHAR(255) = '',
	@P_Field1 AS NVARCHAR(255) = '',
	@P_Value1 AS NVARCHAR(255) = '',
	@P_Field2 AS NVARCHAR(255) = '',
	@P_Value2 AS NVARCHAR(255) = ''
)
AS 

BEGIN

	DECLARE @RetVal int
	
	BEGIN TRY 
		DECLARE @sqlText1 nvarchar(4000);
		DECLARE @sqlText2 nvarchar(4000);
		DECLARE @result table (ID int)

		IF (@P_Field2 != '')
		BEGIN
			SET @sqlText2 = ' AND [' + @P_Field2 + '] = '+ @P_Value2
		END
		ELSE
		BEGIN
			SET @sqlText2 = ''
		END

		SET @sqlText1 = N'SELECT TOP 1 ID FROM dbo.[' + @P_TableName + '] WHERE [' + @P_Field1 + '] = ''' + @P_Value1  + ''' AND ( ( '+ CONVERT(VARCHAR(10), @P_ID) +' = 0 ) OR (ID != '+ CONVERT(VARCHAR(10), @P_ID) +' ) )' + @sqlText2
		
		INSERT INTO @result EXEC (@sqlText1)
		
		IF EXISTS (SELECT ID FROM @Result)
		BEGIN
			SET @RetVal = 0
		END
		ELSE
		BEGIN
		   SET @RetVal = 1
		END
	END TRY
	BEGIN CATCH	
		 --SELECT 
   --     ERROR_NUMBER() AS ErrorNumber
   --    ,ERROR_MESSAGE() AS ErrorMessage;
		SET @RetVal = 0				
	END CATCH

	SELECT @RetVal AS RetVal		
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_ViewClientsDetails]    Script Date: 5/12/2016 6:11:58 PM ******/
DROP PROCEDURE [dbo].[SPC_ViewClientsDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewClientsDetails]    Script Date: 5/12/2016 6:11:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_ViewClientsDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',
	@P_MaxRows AS int = 20,
	@P_Set AS int = 0,
	@P_Sort AS int = 0, --0 Name, --1 Distributor, --2 Country, --3 City, --4 Email, --5 Phone
	@P_OrderBy AS bit = 0,  -- 0 ASC , -- 1 DESC
	@P_RecCount int OUTPUT,
	@P_Distributor AS NVARCHAR(255) = ''
)
AS
BEGIN 
	SET NOCOUNT ON
	DECLARE @StartOffset int;
	DECLARE @Is_Distributor bit;
	DECLARE @Distributor_ID int;
	
	IF @P_Distributor LIKE '%DIS%'
		BEGIN
		SET @Is_Distributor = 1
		SET @Distributor_ID = CONVERT(INT, REPLACE(@P_Distributor,'DIS','' ))	
		END
	ELSE 
		BEGIN 
			IF(@P_Distributor LIKE '%COD%')
			SET @Is_Distributor = 0
			SET @Distributor_ID = CONVERT(INT, REPLACE(@P_Distributor,'COD','' ))
		END

	--SET @StartOffset = (@P_Set - 1) * @P_MaxRows;
	-- Get Clients Details	
	 --WITH Clients AS
	-- (
		SELECT 
			--DISTINCT TOP (@P_Set * @P_MaxRows)
			--CONVERT(int, ROW_NUMBER() OVER (
			--ORDER BY 
			--	CASE 
			--		WHEN (@p_Sort = 0 AND @p_OrderBy = 0) THEN j.[Name]
			--	END ASC,
			--	CASE						
			--		WHEN (@p_Sort = 0 AND @p_OrderBy = 1) THEN j.[Name]
			--	END DESC,
			--	CASE 
			--		WHEN (@p_Sort = 1 AND @p_OrderBy = 0) THEN d.[Name]
			--	END ASC,
			--	CASE						
			--		WHEN (@p_Sort = 1 AND @p_OrderBy = 1) THEN d.[Name]
			--	END DESC,
			--	CASE 
			--		WHEN (@p_Sort = 2 AND @p_OrderBy = 0) THEN j.[Country]
			--	END ASC,
			--	CASE						
			--		WHEN (@p_Sort = 2 AND @p_OrderBy = 1) THEN j.[Country]
			--	END DESC,	
			--	CASE 
			--		WHEN (@p_Sort = 3 AND @p_OrderBy = 0) THEN j.[City]
			--	END ASC,
			--	CASE						
			--		WHEN (@p_Sort = 3 AND @p_OrderBy = 1) THEN j.[City]
			--	END DESC,
			--	CASE 
			--		WHEN (@p_Sort = 4 AND @p_OrderBy = 0) THEN j.[Email]
			--	END ASC,
			--	CASE						
			--		WHEN (@p_Sort = 4 AND @p_OrderBy = 1) THEN j.[Email]
			--	END DESC,	
			--	CASE 
			--		WHEN (@p_Sort = 5 AND @p_OrderBy = 0) THEN j.[Phone]
			--	END ASC,
			--	CASE						
			--		WHEN (@p_Sort = 5 AND @p_OrderBy = 1) THEN j.[Phone]
			--	END DESC		
			--	)) AS ID,
				0 AS ID,
			   j.[ID] AS Client,
			   c.[Name] AS Distributor, 	   
			   j.[Name] AS Name	,
			   ISNULL(j.[Address], '') AS 'Address',
			   ISNULL(j.[Name], '') AS NickName,
			   ISNULL(j.[City], '') AS City,
			   ISNULL(j.[State], '') AS 'State',
			   ISNULL(j.[PostalCode], '') AS PostalCode,			   
			   ISNULL(j.[Country], 'Australia')AS Country,			     
			   ISNULL(j.[Phone], '') AS Phone,
			   ISNULL(j.[Email], '') AS Email,
			   u.[GivenName] + ' ' + u.[FamilyName] AS Creator,
			   j.[CreatedDate] AS CreatedDate  ,
			   um.[GivenName] + ' ' + um.[FamilyName] AS Modifier,
			   j.[ModifiedDate] AS ModifiedDate,
			   CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (v.[Client]) FROM [dbo].[VisualLayout] v WHERE v.[Client] = j.[ID])) THEN 1 ELSE 0 END)) AS VisualLayouts,
			   /*CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (o.[Client]) FROM [dbo].[Order] o WHERE o.[Client] = j.[ID])) THEN 1 ELSE 0 END)) AS 'Order'*/			  
			   CONVERT(bit, 0) AS [Order]
		FROM [dbo].[JobName] j
		LEFT OUTER JOIN [dbo].[Client] c
			ON j.[Client] = c.[ID]
		LEFT OUTER JOIN [dbo].[Company] d
			ON c.[Distributor] = d.[ID]	
		JOIN [dbo].[User] u
			ON j.[Creator] = u.[ID]
		JOIN [dbo].[User] um
			ON j.[Modifier] = um.[ID]
		WHERE (@P_SearchText = '' OR
				j.[Name] LIKE '%' + @P_SearchText + '%' OR
				c.[Name] LIKE '%' + @P_SearchText + '%' --OR
				--j.[Country] LIKE '%' + @P_SearchText + '%' OR
				--j.[Phone] LIKE '%' + @P_SearchText + '%' OR
				--j.[Email] LIKE '%' + @P_SearchText + '%' OR  
				--j.[City] LIKE '%' + @P_SearchText + '%'
				)
				AND (@P_Distributor = '' OR ( 
										(@Is_Distributor = 1 AND d.[ID] = @Distributor_ID ) OR
										(@Is_Distributor = 0 AND d.[Coordinator] = @Distributor_ID)
										)
					 )
	--)
	--SELECT * FROM Clients WHERE ID > @StartOffset
	
	/*IF @P_Set = 1
	BEGIN	
		SELECT @P_RecCount = COUNT (cl.ID)
		FROM (
			SELECT DISTINCT	c.ID
			FROM [dbo].[Client] c
		JOIN [dbo].[Company] d
			ON c.[Distributor] = d.[ID]
		JOIN [dbo].[User] u
			ON c.[Creator] = u.[ID]
		JOIN [dbo].[User] um
			ON c.[Modifier] = um.[ID]
		WHERE (@P_SearchText = '' OR
				c.[Name] LIKE '%' + @P_SearchText + '%' OR
				d.[Name] LIKE '%' + @P_SearchText + '%' OR
				c.[Country] LIKE '%' + @P_SearchText + '%' OR
				c.[Phone] LIKE '%' + @P_SearchText + '%' OR
				c.[Email] LIKE '%' + @P_SearchText + '%' OR  
				c.[City] LIKE '%' + @P_SearchText + '%')
				AND (@P_Distributor = '' OR d.[Name] LIKE '%' + @P_Distributor + '%')			  
			  )cl
	END
	ELSE
	BEGIN*/
		SET @P_RecCount = 0
	--END
END


GO


