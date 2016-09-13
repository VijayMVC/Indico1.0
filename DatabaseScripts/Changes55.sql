USE [Indico]
GO

--**--**--**--**--**--**--**--**--** Add new Column to VisualLayout Table [IsGenerated]--**--**--**--**--**--**--**--**--**--**--**--**
ALTER TABLE [dbo].[VisualLayout]
ADD [IsGenerated] [bit] NULL
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Upadte All columns to I[Isgenerated] = false --**--**--**--**--**--**--**--**--**

UPDATE [dbo].[VisualLayout] SET [IsGenerated] = 0 
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** ALTER column [IsGenerated] --**--**--**--**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[VisualLayout]
ALTER COLUMN [IsGenerated] [bit] NOT NULL
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**'

--**--**--**--**--**--** Remeovr OrderNumber From Order Table --**--**--**--**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[Order]
DROP COLUMN [OrderNumber]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--** Alter OrderDetailViewBO --**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 07/15/2013 12:59:54 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[OrderDetailsView]'))
DROP VIEW [dbo].[OrderDetailsView]
GO

/****** Object:  View [dbo].[OrderDetailsView]    Script Date: 07/15/2013 12:59:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OrderDetailsView]
AS
		SELECT --DISTINCT TOP 100 PERCENT
			co.[ID] AS CompanyId,
			co.[Name] AS CompanyName,
			o.[ID] AS OrderId,
			o.[Date],
			o.[CreatedDate] AS OrderCreatedDate,
			o.[DesiredDeliveryDate],
			o.[EstimatedCompletionDate],
			o.[OrderSubmittedDate],
			o.[ModifiedDate] AS OrderModifiedDate,
			o.[ShipmentDate] AS OrderShipmentDate,
			o.[IsTemporary],			
			o.[PurchaseOrderNo],
			o.[OldPONo] AS OldPurchaseOrderNo,			
			o.[Reservation] AS ReservationId,			
			cl.[ID] AS ClientId,
			cl.[Name] AS ClientName,
			u.[ID] AS UserId,
			u.[Username] AS Username,
			u.[GivenName] AS UserGivenName,
			u.[FamilyName] AS UserFamilyName,
			u.[Company] AS UserCompany,
			os.[ID] AS [StatusId],
			os.[Name] AS [Status]--,
		FROM dbo.[Order] o
			INNER JOIN dbo.[OrderStatus] os
				ON  os.[ID] = o.[Status]
			INNER JOIN dbo.[Company] co
				ON co.[ID] = o.[Distributor]
			INNER JOIN dbo.[Client] cl
				ON cl.[ID] = o.[Client]
			INNER JOIN dbo.[User] u
				ON u.[ID] = o.[Creator]			

GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Alter [SPC_GetWeeklyFirmOrders] --**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 07/15/2013 13:08:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyFirmOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 07/15/2013 13:08:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/********* ALTER STORED PROCEDURE [SPC_GetWeeklyFirmOrders]*************/
CREATE PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders] (	
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN
SELECT 		co.[ID] AS CompanyId,
			co.[Name] AS CompanyName,
			o.[ID] AS OrderId,
			o.[Date],
			o.[CreatedDate] AS OrderCreatedDate,
			o.[DesiredDeliveryDate],
			o.[EstimatedCompletionDate],
			o.[OrderSubmittedDate],
			o.[ModifiedDate] AS OrderModifiedDate,
			o.[ShipmentDate] AS OrderShipmentDate,
			o.[IsTemporary],			
			o.[PurchaseOrderNo],
			o.[OldPONo] AS OldPurchaseOrderNo,			
			o.[Reservation] AS ReservationId,			
			cl.[ID] AS ClientId,
			cl.[Name] AS ClientName,
			u.[ID] AS UserId,
			u.[Username] AS Username,
			u.[GivenName] AS UserGivenName,
			u.[FamilyName] AS UserFamilyName,
			u.[Company] AS UserCompany,
			os.[ID] AS [StatusId],
			os.[Name] AS [Status]--,
		FROM dbo.[Order] o
			INNER JOIN dbo.[OrderStatus] os
				ON  os.[ID] = o.[Status]
			INNER JOIN dbo.[Company] co
				ON co.[ID] = o.[Distributor]
			INNER JOIN dbo.[Client] cl
				ON cl.[ID] = o.[Client]
			INNER JOIN dbo.[User] u
				ON u.[ID] = o.[Creator]		
			WHERE  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate
		
END

GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Alter [SPC_GetWeeklyJacketOrders] --**--**--**--**--**--**--**--**--**--**--**--**


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 07/15/2013 13:10:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyJacketOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyJacketOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyJacketOrders]    Script Date: 07/15/2013 13:10:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/********* ALTER STORED PROCEDURE [SPC_GetWeeklyJacketOrders]*************/

CREATE PROCEDURE [dbo].[SPC_GetWeeklyJacketOrders] (	
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN
SELECT DISTINCT  co.[ID] AS CompanyId,
			co.[Name] AS CompanyName,
			o.[ID] AS OrderId,
			o.[Date],
			o.[CreatedDate] AS OrderCreatedDate,
			o.[DesiredDeliveryDate],
			o.[EstimatedCompletionDate],
			o.[OrderSubmittedDate],
			o.[ModifiedDate] AS OrderModifiedDate,
			o.[ShipmentDate] AS OrderShipmentDate,
			o.[IsTemporary],			
			o.[PurchaseOrderNo],
			o.[OldPONo] AS OldPurchaseOrderNo,			
			o.[Reservation] AS ReservationId,			
			cl.[ID] AS ClientId,
			cl.[Name] AS ClientName,
			u.[ID] AS UserId,
			u.[Username] AS Username,
			u.[GivenName] AS UserGivenName,
			u.[FamilyName] AS UserFamilyName,
			u.[Company] AS UserCompany,
			os.[ID] AS [StatusId],
			os.[Name] AS [Status]--,
		FROM dbo.[Order] o
			INNER JOIN dbo.[OrderStatus] os
				ON  os.[ID] = o.[Status]
			INNER JOIN dbo.[Company] co
				ON co.[ID] = o.[Distributor]
			INNER JOIN dbo.[Client] cl
				ON cl.[ID] = o.[Client]
			INNER JOIN dbo.[User] u
				ON u.[ID] = o.[Creator]
			INNER JOIN 	dbo.[OrderDetail] od 
				ON o.ID = od.[Order]
			INNER JOIN [dbo].[Pattern] p
				ON p.[ID] = od.[Pattern]		
	WHERE  p.[Item] = (SELECT [ID] FROM [Indico].[dbo].[Item] WHERE Name = 'JACKET' AND Parent IS NULL)
		    AND  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate
				
END 


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--** Alter [SPC_GetWeeklyLessFiveItemOrders] --**--**--**--**--**--**--**--**--**--**--**--**


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 07/15/2013 13:12:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyLessFiveItemOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyLessFiveItemOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyLessFiveItemOrders]    Script Date: 07/15/2013 13:12:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_GetWeeklyLessFiveItemOrders] (		
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN
SELECT  	co.[ID] AS CompanyId,
			co.[Name] AS CompanyName,
			o.[ID] AS OrderId,
			o.[Date],
			o.[CreatedDate] AS OrderCreatedDate,
			o.[DesiredDeliveryDate],
			o.[EstimatedCompletionDate],
			o.[OrderSubmittedDate],
			o.[ModifiedDate] AS OrderModifiedDate,
			o.[ShipmentDate] AS OrderShipmentDate,
			o.[IsTemporary],			
			o.[PurchaseOrderNo],
			o.[OldPONo] AS OldPurchaseOrderNo,			
			o.[Reservation] AS ReservationId,			
			cl.[ID] AS ClientId,
			cl.[Name] AS ClientName,
			u.[ID] AS UserId,
			u.[Username] AS Username,
			u.[GivenName] AS UserGivenName,
			u.[FamilyName] AS UserFamilyName,
			u.[Company] AS UserCompany,
			os.[ID] AS [StatusId],
			os.[Name] AS [Status]--,
		FROM dbo.[Order] o
			INNER JOIN dbo.[OrderStatus] os
				ON  os.[ID] = o.[Status]
			INNER JOIN dbo.[Company] co
				ON co.[ID] = o.[Distributor]
			INNER JOIN dbo.[Client] cl
				ON cl.[ID] = o.[Client]
			INNER JOIN dbo.[User] u
				ON u.[ID] = o.[Creator]
			LEFT OUTER JOIN Reservation r
				ON o.[Reservation] = r.[ID]
		WHERE o.ID IN(SELECT o.ID
							 FROM dbo.[Order] o
								  JOIN OrderDetail od 
									   ON o.ID = od.[Order] 
								  JOIN OrderDetailQty odq
									   ON od.ID = odq.OrderDetail
							GROUP BY o.ID
							HAVING SUM(odq.Qty) <= 5						
							UNION					
							SELECT o.ID	
							FROM dbo.[Order] o
								  JOIN OrderDetail od 
									   ON o.ID = od.[Order] 
								  JOIN OrderDetailQty odq
									   ON od.ID = odq.OrderDetail
								  JOIN Reservation res 
									   ON o.Reservation = res.ID
							GROUP BY o.ID
							HAVING SUM(odq.Qty) <= 5)
				AND  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate
END


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Alter [SPC_GetWeeklyReservationOrders] --**--**--**--**--**--**--**--**--**--**--**--**


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 07/15/2013 13:15:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyReservationOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyReservationOrders]    Script Date: 07/15/2013 13:15:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_GetWeeklyReservationOrders] (		
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN
SELECT DISTINCT  co.[ID] AS CompanyId,
			co.[Name] AS CompanyName,
			o.[ID] AS OrderId,
			o.[Date],
			o.[CreatedDate] AS OrderCreatedDate,
			o.[DesiredDeliveryDate],
			o.[EstimatedCompletionDate],
			o.[OrderSubmittedDate],
			o.[ModifiedDate] AS OrderModifiedDate,
			o.[ShipmentDate] AS OrderShipmentDate,
			o.[IsTemporary],			
			o.[PurchaseOrderNo],
			o.[OldPONo] AS OldPurchaseOrderNo,			
			o.[Reservation] AS ReservationId,			
			cl.[ID] AS ClientId,
			cl.[Name] AS ClientName,
			u.[ID] AS UserId,
			u.[Username] AS Username,
			u.[GivenName] AS UserGivenName,
			u.[FamilyName] AS UserFamilyName,
			u.[Company] AS UserCompany,
			os.[ID] AS [StatusId],
			os.[Name] AS [Status]--,
		FROM dbo.[Order] o
			INNER JOIN dbo.[OrderStatus] os
				ON  os.[ID] = o.[Status]
			INNER JOIN dbo.[Company] co
				ON co.[ID] = o.[Distributor]
			INNER JOIN dbo.[Client] cl
				ON cl.[ID] = o.[Client]
			INNER JOIN dbo.[User] u
				ON u.[ID] = o.[Creator]
			INNER JOIN 	dbo.[OrderDetail] od 
				ON o.ID = od.[Order]	
			INNER JOIN [Reservation] r
				ON o.[Reservation] = r.[ID]
				WHERE  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate					

END
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Alter [ReturnVisualLayoutDetailsView] --**--**--**--**--**--**--**--**--**--**--**--**


/****** Object:  View [dbo].[ReturnVisualLayoutDetailsView]    Script Date: 07/15/2013 14:19:11 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnVisualLayoutDetailsView]'))
DROP VIEW [dbo].[ReturnVisualLayoutDetailsView]
GO

/****** Object:  View [dbo].[ReturnVisualLayoutDetailsView]    Script Date: 07/15/2013 14:19:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ReturnVisualLayoutDetailsView]
AS
	SELECT 
		0 AS VisualLayout,
		'' AS Name,
		'' AS 'Description',
		'' AS Pattern,
		'' AS Fabric,
		'' AS Client,
		'' AS Distributor,
		'' AS Coordinator,
		'' AS NNPFilePath,
		GETDATE() AS CreatedDate,
		CONVERT(bit,0)AS IsCommonProduct,
		CONVERT(bit,0)AS IsGeneratedProduct,
		CONVERT(bit,0)AS OrderDetails


GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

----**--**--**--**--**--**--**--**--** Alter [SPC_ViewVisualLayoutDetails] --**--**--**--**--**--**--**--**--**--**--**--**


--/****** Object:  StoredProcedure [dbo].[SPC_ViewVisualLayoutDetails]    Script Date: 07/15/2013 14:17:35 ******/
--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewVisualLayoutDetails]') AND type in (N'P', N'PC'))
--DROP PROCEDURE [dbo].[SPC_ViewVisualLayoutDetails]
--GO

--/****** Object:  StoredProcedure [dbo].[SPC_ViewVisualLayoutDetails]    Script Date: 07/15/2013 14:17:35 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO



--CREATE PROCEDURE [dbo].[SPC_ViewVisualLayoutDetails]
--(
--	@P_SearchText AS NVARCHAR(255) = '',
--	@P_MaxRows AS int = 20,
--	@P_Set AS int = 0,
--	@P_Sort AS int = 0, --0 CreatedDate,--1 Name, --2 Pattern, --3 Fabric, --4 Client, --5 Distributor, --6 Coordinator
--	@P_OrderBy AS bit = 1,  -- 0 ASC , -- 1 DESC
--	@P_RecCount int OUTPUT,
--	@P_Coordinator AS NVARCHAR(255) = '',
--	@P_Distributor AS NVARCHAR(255) = '',
--	@P_Client AS NVARCHAR(255) = '',
--	@P_IsCommon AS int = 2
--)
--AS
--BEGIN
--	-- Get the patterns	
--	SET NOCOUNT ON
--	DECLARE @StartOffset int;
--	SET @StartOffset = (@P_Set - 1) * @P_MaxRows;
	
--	WITH VisualLayout AS
--	(
--		SELECT 
--			DISTINCT TOP (@P_Set * @P_MaxRows)
--			CONVERT(int, ROW_NUMBER() OVER (
--			ORDER BY 
--				CASE 
--					WHEN (@p_Sort = 0 AND @p_OrderBy = 0) THEN v.[CreatedDate]
--				END ASC,
--				CASE						
--					WHEN (@p_Sort = 0 AND @p_OrderBy = 1) THEN v.[CreatedDate]
--				END DESC,
--				CASE 
--					WHEN (@p_Sort = 1 AND @p_OrderBy = 0) THEN v.[NamePrefix]
--				END ASC,
--				CASE						
--					WHEN (@p_Sort = 1 AND @p_OrderBy = 1) THEN v.[NamePrefix]
--				END DESC,
--				CASE 
--					WHEN (@p_Sort = 2 AND @p_OrderBy = 0) THEN p.[Number]
--				END ASC,
--				CASE						
--					WHEN (@p_Sort = 2 AND @p_OrderBy = 1) THEN p.[Number]
--				END DESC,	
--				CASE 
--					WHEN (@p_Sort = 3 AND @p_OrderBy = 0) THEN f.[Name]
--				END ASC,
--				CASE						
--					WHEN (@p_Sort = 3 AND @p_OrderBy = 1) THEN f.[Name]
--				END DESC,
--				CASE 
--					WHEN (@p_Sort = 4 AND @p_OrderBy = 0) THEN c.[Name]
--				END ASC,
--				CASE						
--					WHEN (@p_Sort = 4 AND @p_OrderBy = 1) THEN c.[Name]
--				END DESC,	
--				CASE 
--					WHEN (@p_Sort = 5 AND @p_OrderBy = 0) THEN d.[Name]
--				END ASC,
--				CASE						
--					WHEN (@p_Sort = 5 AND @p_OrderBy = 1) THEN d.[Name]
--				END DESC,
--				CASE 
--					WHEN (@p_Sort = 6 AND @p_OrderBy = 0) THEN u.[GivenName]
--				END ASC,
--				CASE						
--					WHEN (@p_Sort = 6 AND @p_OrderBy = 1) THEN u.[GivenName]
--				END DESC					
--				)) AS ID,
--			   v.[ID] AS VisualLayout,
--			   v.[NamePrefix] + '' + ISNULL(CAST(v.[NameSuffix] AS NVARCHAR(64)), '') AS Name,
--			   ISNULL(v.[Description], '') AS 'Description',
--			   p.[Number] AS Pattern,
--			   f.[Name] AS Fabric,
--			   ISNULL(c.[Name], '') AS Client,
--			   ISNULL(d.[Name], '') AS Distributor,
--			   ISNULL(u.[GivenName] + ' '+ u.[FamilyName], '') AS Coordinator,
--			   ISNULL(v.[NNPFilePath], '') AS NNPFilePath,
--			   v.[CreatedDate] AS CreatedDate,
--			   v.[IsCommonProduct] AS IsCommonProduct,
--			   v.[IsGenerated] AS IsGeneratedProduct,
--			  CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (od.[VisualLayout]) FROM [dbo].[OrderDetail] od WHERE od.[VisualLayout] = v.[ID])) THEN 1 ELSE 0 END)) AS OrderDetails
--		FROM [dbo].[VisualLayout] v
--			JOIN [dbo].[Pattern] p
--				ON v.[Pattern] = p.[ID]
--			JOIN [dbo].[FabricCode] f
--				ON v.[FabricCode] = f.[ID]
--			LEFT OUTER JOIN [dbo].[Client] c
--				ON v.[Client] = c.[ID]
--			LEFT OUTER JOIN [dbo].[Company] d
--				ON c.[Distributor] = d.[ID]
--			LEFT OUTER JOIN [dbo].[User] u
--				ON d.[Coordinator] = u.[ID]
--		WHERE (@P_SearchText = '' OR
--			   v.[NamePrefix]  LIKE '%' + @P_SearchText + '%' OR
--			   v.[NameSuffix]  LIKE '%' + @P_SearchText + '%' OR
--			   v.[Description] LIKE '%' + @P_SearchText + '%' OR
--			   p.[Number] LIKE '%' + @P_SearchText + '%' OR
--			   c.[Name] LIKE '%' + @P_SearchText + '%' OR
--			   d.[Name] LIKE '%' + @P_SearchText + '%' OR
--			   u.[GivenName] LIKE '%' + @P_SearchText + '%' OR
--			   u.[FamilyName] LIKE '%' + @P_SearchText + '%')
--			   AND (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName])  LIKE + '%' + @P_Coordinator + '%')
--			   AND(@P_Distributor = '' OR  d.[Name] LIKE '%' + @P_Distributor + '%')
--			   AND(@P_Client = '' OR c.[Name] LIKE '%' + @P_SearchText + '%')
--			   AND(@P_IsCommon = 2 OR v.[IsCommonProduct] = CONVERT(bit,@P_IsCommon))			   
--		)
--	SELECT * FROM VisualLayout WHERE ID > @StartOffset
	
--	IF @P_Set = 1
--	BEGIN	
--		SELECT @P_RecCount = COUNT (vl.ID)
--		FROM (
--			SELECT DISTINCT	v.ID
--		FROM [dbo].[VisualLayout] v
--			JOIN [dbo].[Pattern] p
--				ON v.[Pattern] = p.[ID]
--			JOIN [dbo].[FabricCode] f
--				ON v.[FabricCode] = f.[ID]
--			LEFT OUTER JOIN [dbo].[Client] c
--				ON v.[Client] = c.[ID]
--			LEFT OUTER JOIN [dbo].[Company] d
--				ON c.[Distributor] = d.[ID]
--			LEFT OUTER JOIN [dbo].[User] u
--				ON d.[Coordinator] = u.[ID]
--		WHERE (@P_SearchText = '' OR
--			   v.[NamePrefix]  LIKE '%' + @P_SearchText + '%' OR
--			   v.[NameSuffix]  LIKE '%' + @P_SearchText + '%' OR
--			   v.[Description] LIKE '%' + @P_SearchText + '%' OR
--			   p.[Number] LIKE '%' + @P_SearchText + '%' OR
--			   c.[Name] LIKE '%' + @P_SearchText + '%' OR
--			   d.[Name] LIKE '%' + @P_SearchText + '%' OR
--			   u.[GivenName] LIKE '%' + @P_SearchText + '%' OR
--			   u.[FamilyName] LIKE '%' + @P_SearchText + '%')
--			   AND (@P_Coordinator = '' OR (u.[GivenName] + ' ' + u.[FamilyName]) LIKE + '%' + @P_Coordinator + '%')
--			   AND(@P_Distributor = '' OR  d.[Name] LIKE +'%' + @P_Distributor + '%')
--			   AND(@P_Client = '' OR c.[Name] LIKE +'%' + @P_SearchText + '%')
--			   AND(@P_IsCommon = 2 OR v.[IsCommonProduct] = CONVERT(bit,@P_IsCommon))	
--		)vl
--	END
--	ELSE
--	BEGIN
--		SET @P_RecCount = 0
--	END
--END

--GO

----**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**-**-**-**--**-**-**-**--**-**-**-** ALTER RESERVATION COLUMN Pattern --**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

ALTER TABLE [dbo].[Reservation]
ALTER COLUMN [Pattern] [int] NULL
GO

----**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**-**-**-**--**-**-**-**--**-**-**-** ALTER SPC_ProductionCapacities --**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**


/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 07/16/2013 12:24:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ProductionCapacities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ProductionCapacities]
GO


/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 07/16/2013 12:24:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_ProductionCapacities] (	
	
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN

	DECLARE @Capacities TABLE
	(
		Firms int,
		ResevationOrders int,
		Resevations int,
		Holds int,
		Less5Items int,
		Jackets int,
		Samples int
	)
	
	INSERT INTO @Capacities
	VALUES
	(
		-- Firm Orders
		(	SELECT  ISNULL(SUM(odq.Qty),0) AS Firms  
			FROM [Order] o
				JOIN OrderDetail od
					ON o.ID = od.[Order]  
				JOIN OrderDetailQty odq 
					ON od.ID = odq.OrderDetail 
						WHERE o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate
						AND o.[Reservation] IS NULL),
		-- Resevation order quantities
		(	SELECT ISNULL(SUM(odq.Qty),0) AS ResevationOrders
			FROM [Order] o
				JOIN OrderDetail od
					ON o.ID = od.[Order]  
				JOIN OrderDetailQty odq 
					ON od.ID = odq.OrderDetail
				JOIN Reservation r
					ON o.Reservation = r.ID 
			WHERE o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate),
		-- Resevation quantities
		(	SELECT ISNULL(SUM(r.Qty), 0) AS Resevations 
			FROM [Order] o
				JOIN Reservation r
					ON o.Reservation = r.ID 
			WHERE o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate),
		-- Hold
		0,
		-- Less5Items
		(SELECT ISNULL(COUNT(o.ID),0) AS Less5Items 
		FROM dbo.[Order] o
		WHERE o.ID IN (	 SELECT o.ID	
						 FROM dbo.[Order] o
							  JOIN OrderDetail od 
								   ON o.ID = od.[Order] 
							  JOIN OrderDetailQty odq
								   ON od.ID = odq.OrderDetail
						GROUP BY o.ID
						HAVING SUM(odq.Qty) <= 5
						UNION
						SELECT o.ID	
						FROM dbo.[Order] o
							  JOIN OrderDetail od 
								   ON o.ID = od.[Order] 
							  JOIN OrderDetailQty odq
								   ON od.ID = odq.OrderDetail
							  JOIN Reservation res 
								   ON o.Reservation = res.ID
						GROUP BY o.ID
						HAVING SUM(odq.Qty) <= 5)AND o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) 
												AND o.DesiredDeliveryDate <= @P_WeekEndDate),

		-- JacketsOrders
		(	SELECT  ISNULL(COUNT(o.ID), 0) AS Jackets  
			FROM [Order] o
				JOIN OrderDetail od
					ON o.ID = od.[Order]  
				JOIN Pattern p
					ON p.ID = od.Pattern
				JOIN Item i
					ON i.ID = p.Item
			WHERE i.Name IN('PANT','JACKET','WINDCHEATER')AND i.Parent IS NULL
				AND  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate
				AND p.IsActive = 1),
				
		-- SampleOrders
		(  SELECT ISNULL(COUNT(*), 0) AS Samples 
	       FROM dbo.[Order] o
                JOIN OrderDetail od
					ON o.ID =od.[Order]
				LEFT OUTER JOIN  Reservation res
					ON o.Reservation=res.ID
		   WHERE od.OrderType = (SELECT [ID] FROM [Indico].[dbo].[OrderType] WHERE [Name] = 'SAMPLE')
				AND o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate)

	)
	
	SELECT * FROM @Capacities

END


GO

----**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**-**-**-**--**-**-**-**--**-**-**-** ALTER SPC_GetWeeklyFirmOrders --**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 07/16/2013 12:40:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyFirmOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyFirmOrders]    Script Date: 07/16/2013 12:40:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/********* ALTER STORED PROCEDURE [SPC_GetWeeklyFirmOrders]*************/
CREATE PROCEDURE [dbo].[SPC_GetWeeklyFirmOrders] (	
	@P_WeekEndDate datetime2(7)
)
AS
BEGIN
SELECT 		co.[ID] AS CompanyId,
			co.[Name] AS CompanyName,
			o.[ID] AS OrderId,
			o.[Date],
			o.[CreatedDate] AS OrderCreatedDate,
			o.[DesiredDeliveryDate],
			o.[EstimatedCompletionDate],
			o.[OrderSubmittedDate],
			o.[ModifiedDate] AS OrderModifiedDate,
			o.[ShipmentDate] AS OrderShipmentDate,
			o.[IsTemporary],			
			o.[PurchaseOrderNo],
			o.[OldPONo] AS OldPurchaseOrderNo,			
			o.[Reservation] AS ReservationId,			
			cl.[ID] AS ClientId,
			cl.[Name] AS ClientName,
			u.[ID] AS UserId,
			u.[Username] AS Username,
			u.[GivenName] AS UserGivenName,
			u.[FamilyName] AS UserFamilyName,
			u.[Company] AS UserCompany,
			os.[ID] AS [StatusId],
			os.[Name] AS [Status]--,
		FROM dbo.[Order] o
			INNER JOIN dbo.[OrderStatus] os
				ON  os.[ID] = o.[Status]
			INNER JOIN dbo.[Company] co
				ON co.[ID] = o.[Distributor]
			INNER JOIN dbo.[Client] cl
				ON cl.[ID] = o.[Client]
			INNER JOIN dbo.[User] u
				ON u.[ID] = o.[Creator]		
			WHERE  o.DesiredDeliveryDate >= DATEADD(day, -7, @P_WeekEndDate) AND o.DesiredDeliveryDate <= @P_WeekEndDate
			AND o.[Reservation] IS NULL
		
END


GO

----**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**



