USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 05/30/2014 12:46:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ProductionCapacities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ProductionCapacities]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ProductionCapacities]    Script Date: 05/30/2014 12:46:20 ******/
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
						WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
						AND (o.[Reservation] IS NULL)
						AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold')))),
		-- Resevation order quantities
		(	 (SELECT ISNULL(SUM (r.[Qty]), 0)      
					FROM [dbo].[Reservation] r
					WHERE (r.[ShipmentDate] BETWEEN CAST(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate))))),
		-- Resevation quantities
		(	SELECT ISNULL(SUM(odq.Qty),0) 
							FROM [OrderDetail] od				
								JOIN OrderDetailQty odq 
									ON od.ID = odq.OrderDetail
								JOIN Reservation r
									ON od.Reservation = r.ID 
							WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
							AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold')))),
		-- Hold
		(	SELECT ISNULL(SUM(odq.[Qty]), 0) AS Hold
			 FROM [dbo].[OrderDetailQty] odq 
				JOIN [dbo].[OrderDetail] od
					ON	odq.[OrderDetail] = od.[ID]
				JOIN [dbo].[Order] o
					ON od.[Order] = o.[ID]
			 WHERE ((o.[Status] = (SELECT os.[ID] FROM [dbo].[OrderStatus] os WHERE os.[Name] = 'Indiman Hold')) OR
					((o.[Status] = (SELECT os.[ID] FROM [dbo].[OrderStatus] os WHERE os.[Name] = 'Indico Hold')))) AND
				   (od.[SheduledDate] > DATEADD(day, -7, @P_WeekEndDate) AND od.[SheduledDate] <= @P_WeekEndDate) AND
				   (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold')))),
		-- Less5Items
		(SELECT ISNULL(SUM(odq.[Qty]), 0)  AS Less5Items				 
										FROM dbo.[Order] o
											JOIN [OrderDetail] od
												ON o.[ID] = od.[Order]
											JOIN [OrderDetailQty] odq
												ON od.[ID] = odq.[OrderDetail]
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
														HAVING SUM(odq.Qty) <= 5)AND (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
														AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold')))),

		-- JacketsOrders
		(SELECT ISNULL(SUM(odq.[Qty]), 0) AS Jackets 				  
										FROM [Order] o
											JOIN OrderDetail od
												ON o.ID = od.[Order]
											JOIN [OrderDetailQty] odq
												ON od.[ID] = odq.[OrderDetail]
											JOIN Pattern p
												ON p.ID = od.Pattern
											JOIN Item i
												ON i.ID = p.Item
										WHERE i.Name IN('JACKET')AND i.Parent IS NULL
											AND  (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
											AND  (p.IsActive = 1)
											AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold')))),
						
		-- SampleOrders
		(SELECT ISNULL(SUM(odq.[Qty]), 0) AS Samples											 
							   FROM dbo.[Order] o
									JOIN OrderDetail od
										ON o.ID =od.[Order]
									JOIN [OrderDetailQty] odq
										ON od.[ID] = odq.[OrderDetail]
									LEFT OUTER JOIN  Reservation res
										ON o.Reservation=res.ID
							   WHERE od.OrderType = (SELECT [ID] FROM [Indico].[dbo].[OrderType] WHERE [Name] = 'SAMPLE')
									AND (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate)))
									AND (od.[Status] IS NULL  OR od.[Status] IN ((SELECT [ID] FROM [dbo].[OrderDetailStatus]  WHERE [Name] = 'ODS Printed' OR [Name] = 'On Hold'))))

	)
	
	SELECT * FROM @Capacities

END

GO


/****** Object:  StoredProcedure [dbo].[SPC_GetReservationDetails]    Script Date: 05/30/2014 13:31:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetReservationDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetReservationDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetReservationDetails]    Script Date: 05/30/2014 13:31:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROC [dbo].[SPC_GetReservationDetails](
@P_SearchText AS nvarchar(255),
@P_WeekEndDate AS datetime2(7) = NULL,
@P_Status AS nvarchar(255),
@P_Distributor AS nvarchar(255),
@P_Coordinator AS nvarchar(255)
)
AS

		BEGIN

					SELECT r.[ID]
						  ,RIGHT(CAST('RES-0000' + CAST(r.[ReservationNo] AS VARCHAR) AS VARCHAR), 10) AS ReservationNo     
						  ,r.[OrderDate] AS OrderDate
						  ,ISNULL(r.[Pattern], 0) AS PatternID
						  ,ISNULL(p.[Number] + ' - ' + p.[NickName], '') AS Pattern
						  ,r.[Coordinator] AS CoordinatorID
						  ,cu.[GivenName] + ' ' + cu.[FamilyName] AS Coordinator
						  ,r.[Distributor] AS DistributorID
						  ,d.[Name] AS Distributor      
						  ,ISNULL(r.[Client], '') AS Client
						  ,ISNULL(r.[ShipTo], 0) AS ShipToID
						  ,ISNULL(dca.[Address] + ' ' + dca.[Suburb] + ' ' + ISNULL(dca.[State], '') + ' ' + c.[ShortName] + ' ' + dca.[PostCode], '') AS ShipTo   
						  ,ISNULL(r.[ShipmentMode], 0) AS ShipmentModeID
						  ,ISNULL(sm.[Name], '') AS ShipmentMode
						  ,r.[ShipmentDate] AS ShipmentDate
						  ,r.[Qty] AS Qty
						  ,(SELECT ISNULL(SUM(odq.Qty),0)
								FROM [OrderDetail] od				
									JOIN OrderDetailQty odq 
										ON od.ID = odq.OrderDetail
									JOIN Reservation r
										ON od.Reservation = r.ID )	 AS UsedQty		
						  ,(SELECT r.[Qty] - (SELECT ISNULL(SUM(odq.Qty),0)
								FROM [OrderDetail] od				
									JOIN OrderDetailQty odq 
										ON od.ID = odq.OrderDetail
									JOIN Reservation r
										ON od.Reservation = r.ID )) AS Balance
						  ,ISNULL(r.[Notes], '') AS Notes
						  ,r.[DateCreated] AS DateCreated
						  ,r.[DateModified] AS DateModified
						  ,r.[Creator] AS CreatorID
						  ,rc.[GivenName] + ' ' + rc.[FamilyName] AS Creator
						  ,r.[Modifier] AS ModifierID
						  ,rm.[GivenName] + ' ' + rm.[FamilyName] AS Modifier
						  ,r.[Status] AS StatusID
						  ,rs.[Name] AS [Status]
					  FROM [Indico].[dbo].[Reservation] r
						LEFT OUTER JOIN [dbo].[Pattern] p
							ON r.[Pattern] = p.[ID]
						JOIN [dbo].[User] cu
							ON r.[Coordinator] = cu.[ID]
						JOIN [dbo].[Company] d
							ON r.[Distributor] = d.[ID]	
						LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
							ON r.[ShipTo] = dca.[ID]
						JOIN [dbo].[Country] c
							ON dca.[Country] = c.[ID] 		
						LEFT OUTER JOIN [dbo].[ShipmentMode] sm
							ON r.[ShipmentMode] = sm.[ID]	
						JOIN [dbo].[User] rc
							ON r.[Creator] = rc.[ID]
						JOIN [dbo].[User] rm
							ON r.[Modifier] = rm.[ID]
						JOIN [dbo].[ReservationStatus] rs
							ON r.[Status] = rs.[ID]
					WHERE (@P_SearchText = '' OR
						   r.[OrderDate] LIKE '%' + @P_SearchText + '%' OR
						   p.[Number] LIKE '%' + @P_SearchText + '%' OR
						   p.[NickName] LIKE '%' + @P_SearchText + '%' OR
						   (cu.[GivenName] + ' ' + cu.[FamilyName]) LIKE '%' + @P_SearchText + '%' OR
						   r.[Client] LIKE '%' + @P_SearchText + '%' OR
						   sm.[Name] LIKE '%' + @P_SearchText + '%' OR
						   rs.[Name] LIKE '%' + @P_SearchText + '%')AND
						   (@P_WeekEndDate IS NULL OR r.[ShipmentDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate))) AND
						   (@P_Status = '' OR rs.[Name] LIKE '%' + @P_Status + '%') AND
						   (@P_Distributor = '' OR d.[Name] LIKE '%' + @P_Distributor + '%') AND
						   (@P_Coordinator = '' OR (cu.[GivenName] + ' ' + cu.[FamilyName]) LIKE '%' + @P_Coordinator + '%')
						   
						   


		END

GO


/****** Object:  View [dbo].[ReservationDetailsView]    Script Date: 05/30/2014 13:36:27 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReservationDetailsView]'))
DROP VIEW [dbo].[ReservationDetailsView]
GO

/****** Object:  View [dbo].[ReservationDetailsView]    Script Date: 05/30/2014 13:36:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[ReservationDetailsView]
AS

SELECT 0 AS ID
      ,'' AS ReservationNo     
      ,GETDATE() AS OrderDate
      ,0 AS PatternID
      ,'' AS Pattern
      ,0 AS CoordinatorID
      ,'' AS Coordinator
      ,0 AS DistributorID
      ,'' AS Distributor      
      ,'' AS Client
      ,0 AS ShipToID
      ,'' AS ShipTo   
      ,0 AS ShipmentModeID
      ,'' AS ShipmentMode
      ,GETDATE() AS ShipmentDate
      ,0 AS Qty
       ,0 AS UsedQty
      ,0 AS Balance
      ,'' AS Notes
      ,GETDATE() AS DateCreated
      ,GETDATE() AS DateModified
      ,0 AS CreatorID
      ,'' AS Creator
      ,0 AS ModifierID
      ,'' AS Modifier
      ,0 AS StatusID
      ,'' AS [Status]
 GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewClientsDetails]    Script Date: 06/02/2014 14:05:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewClientsDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ViewClientsDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ViewClientsDetails]    Script Date: 06/02/2014 14:05:32 ******/
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
	--SET @StartOffset = (@P_Set - 1) * @P_MaxRows;
	-- Get Clients Details	
	 --WITH Clients AS
	-- (
		SELECT 
			--DISTINCT TOP (@P_Set * @P_MaxRows)
			CONVERT(int, ROW_NUMBER() OVER (
			ORDER BY 
				CASE 
					WHEN (@p_Sort = 0 AND @p_OrderBy = 0) THEN c.[Name]
				END ASC,
				CASE						
					WHEN (@p_Sort = 0 AND @p_OrderBy = 1) THEN c.[Name]
				END DESC,
				CASE 
					WHEN (@p_Sort = 1 AND @p_OrderBy = 0) THEN d.[Name]
				END ASC,
				CASE						
					WHEN (@p_Sort = 1 AND @p_OrderBy = 1) THEN d.[Name]
				END DESC,
				CASE 
					WHEN (@p_Sort = 2 AND @p_OrderBy = 0) THEN c.[Country]
				END ASC,
				CASE						
					WHEN (@p_Sort = 2 AND @p_OrderBy = 1) THEN c.[Country]
				END DESC,	
				CASE 
					WHEN (@p_Sort = 3 AND @p_OrderBy = 0) THEN c.[City]
				END ASC,
				CASE						
					WHEN (@p_Sort = 3 AND @p_OrderBy = 1) THEN c.[City]
				END DESC,
				CASE 
					WHEN (@p_Sort = 4 AND @p_OrderBy = 0) THEN c.[Email]
				END ASC,
				CASE						
					WHEN (@p_Sort = 4 AND @p_OrderBy = 1) THEN c.[Email]
				END DESC,	
				CASE 
					WHEN (@p_Sort = 5 AND @p_OrderBy = 0) THEN c.[Phone]
				END ASC,
				CASE						
					WHEN (@p_Sort = 5 AND @p_OrderBy = 1) THEN c.[Phone]
				END DESC		
				)) AS ID,
			   c.[ID] AS Client,
			   d.[Name] AS Distributor, 	   
			   c.[Name] AS Name	,
			   ISNULL(c.[Address], '') AS 'Address',
			   ISNULL(c.[Name], '') AS NickName,
			   ISNULL(c.[City], '') AS City,
			   ISNULL(c.[State], '') AS 'State',
			   ISNULL(c.[PostalCode], '') AS PostalCode,			   
			   ISNULL(c.[Country], 'Australia')AS Country,			     
			   ISNULL(c.[Phone], '') AS Phone,
			   ISNULL(c.[Email], '') AS Email,
			   u.[GivenName] + ' ' + u.[FamilyName] AS Creator,
			   c.[CreatedDate] AS CreatedDate  ,
			   um.[GivenName] + ' ' + um.[FamilyName] AS Modifier,
			   c.[ModifiedDate] AS ModifiedDate,
			   CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (v.[Client]) FROM [dbo].[VisualLayout] v WHERE v.[Client] = c.[ID])) THEN 1 ELSE 0 END)) AS VisualLayouts,
			   CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (o.[Client]) FROM [dbo].[Order] o WHERE o.[Client] = c.[ID])) THEN 1 ELSE 0 END)) AS 'Order'			  
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


/****** Object:  View [dbo].[ReturnClientsDetailsView]    Script Date: 06/02/2014 14:11:47 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnClientsDetailsView]'))
DROP VIEW [dbo].[ReturnClientsDetailsView]
GO

/****** Object:  View [dbo].[ReturnClientsDetailsView]    Script Date: 06/02/2014 14:11:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[ReturnClientsDetailsView]
AS
	SELECT 
		0 AS Client,	
		'' AS Distributor,		
		'' AS Name,
		'' AS 'Address',
		'' AS NickName,		
		'' AS City,
		'' AS 'State',
		'' AS PostalCode,		
		'' AS Country,
		'' AS Phone,		
		'' AS Email,		
		'' AS 'Creator',
		GETDATE() AS CreatedDate,
		'' AS Modifier,
		GETDATE() AS ModifiedDate,
		CONVERT(bit,0)AS VisualLayouts,
		CONVERT(bit,0)AS 'Order'				

GO


