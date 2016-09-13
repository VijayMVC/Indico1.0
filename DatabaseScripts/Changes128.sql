USE [Indico]
GO



/****** Object:  View [dbo].[ReturnInvoiceDetails]    Script Date: 03/11/2015 10:26:46 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnInvoiceDetails]'))
DROP VIEW [dbo].[ReturnInvoiceDetails]
GO

/****** Object:  View [dbo].[ReturnInvoiceDetails]    Script Date: 03/11/2015 10:26:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[ReturnInvoiceDetails]
AS

SELECT inv.[ID] AS 'Invoice'
      ,inv.[InvoiceNo] AS 'InvoiceNo'
      ,CONVERT(VARCHAR(30), inv.[InvoiceDate], 106)AS 'InvoiceDate'       
      ,dca.[CompanyName] AS 'ShipTo'
      ,ISNULL(inv.[AWBNo], '') AS 'AWBNo'
      ,CONVERT(VARCHAR(30), wpc.[WeekendDate], 106)AS 'ETD'    
      ,ISNULL(inv.[IndimanInvoiceNo],'') AS 'IndimanInvoiceNo'
      ,sm.[Name] AS 'ShipmentMode'
      ,ISNULL(CONVERT(VARCHAR(30), inv.[IndimanInvoiceDate], 106), '') AS 'IndimanInvoiceDate'  
      ,ISNULL(SUM(ino.[FactoryPrice]), 0.00) AS 'FactoryRate'   
      ,ISNULL(SUM(ino.[IndimanPrice]), 0.00) AS 'IndimanRate'   
      ,ISNULL(SUM(odq.[Qty]), 0) AS 'Qty'
      ,ISNULL((SUM( (odq.[Qty]) * (ino.[FactoryPrice]))),0.00) AS FactoryTotal
      ,ISNULL((SUM( (odq.[Qty]) * (ino.[IndimanPrice]))),0.00) AS IndimanTotal
	 ,[inv].[WeeklyProductionCapacity] AS 'WeeklyProductionCapacity'
	 ,ins.[Name] AS [Status]
	 ,bdca.[CompanyName] AS 'BillTo'	 
   FROM [Indico].[dbo].[InvoiceOrder] ino 
	LEFT OUTER JOIN [dbo].[OrderDetail] od
		ON ino.[OrderDetail] = od.[ID]
	LEFT OUTER JOIN [dbo].[OrderDetailQty] odq
		ON od.[ID] = odq.[OrderDetail]
	LEFT OUTER JOIN [dbo].[Invoice] inv
		ON ino.[Invoice] = inv.[ID]	
	LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
		ON inv.[ShipTo] = dca.[ID]
	LEFT OUTER JOIN [dbo].[ShipmentMode] sm
		ON inv.[ShipmentMode] = sm.[ID]
	LEFT OUTER JOIN [dbo].[WeeklyProductionCapacity] wpc
		ON inv.[WeeklyProductionCapacity] = wpc.[ID]
	LEFT OUTER JOIN [dbo].[InvoiceStatus] ins
		ON inv.[Status] = ins.[ID]
	LEFT OUTER JOIN [dbo].[DistributorClientAddress] bdca
		ON inv.[BillTo] = bdca.[ID]
	GROUP BY inv.[ID], inv.[InvoiceNo], inv.[InvoiceDate],inv.[AWBNo], wpc.[WeekendDate], inv.[IndimanInvoiceNo],sm.[Name], inv.[IndimanInvoiceDate], [inv].[WeeklyProductionCapacity],ins.[Name],bdca.[CompanyName],dca.[CompanyName]
  


GO


/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyAddressDetails]    Script Date: 03/12/2015 12:41:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetWeeklyAddressDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetWeeklyAddressDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetWeeklyAddressDetails]    Script Date: 03/12/2015 12:41:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[SPC_GetWeeklyAddressDetails] (	
@P_WeekEndDate datetime2(7),
@P_CompanyName NVARCHAR(255) = '',
@P_ShipmentMode int = 0 
)	
AS 
BEGIN
	
		SELECT	   od.[ID] AS OrderDetail
				  ,ot.[Name] AS OrderType
				  ,vl.[NamePrefix] + ISNULL(CAST(vl.[NameSuffix] AS nvarchar(255)),'') AS VisualLayout
				  ,od.[VisualLayout] AS VisualLayoutID
				  ,od.[Pattern] AS PatternID
				  ,p.[Number] + ' - ' + p.[NickName] AS Pattern
				  ,od.[FabricCode] AS FabricID
				  --,fc.[Code] + ' - ' + fc.[Name] AS Fabric
				  ,fc.[Code] AS FabricCode
				  ,fc.[Name] AS FabricName
				  ,fc.[Material] AS FabricMaterial				  
				  ,od.[VisualLayoutNotes] AS VisualLayoutNotes      
				  ,od.[Order] AS 'Order'
				  ,ISNULL(o.[Label], 0) AS Label
				  ,ISNULL(ods.[Name], 'New') AS OrderDetailStatus
				  ,ISNULL(od.[Status], 0) AS OrderDetailStatusID
				  ,od.[ShipmentDate] AS ShipmentDate
				  ,od.[SheduledDate] AS SheduledDate      
				  ,od.[RequestedDate] AS RequestedDate
				  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]),0) AS Quantity       
				  ,ISNULL(o.[OldPONo], '') AS 'PurONo'
				  ,c.[Name] AS Distributor
				  ,u.[GivenName] + ' ' + u.[FamilyName] AS Coordinator
				  ,cl.[Name] AS Client
				  ,os.[Name] AS OrderStatus
				  ,o.[Status] AS OrderStatusID				  
				  ,ISNULL(o.[ShipmentMode], 0) AS ShimentModeID
				  ,ISNULL(shm.[Name], 'AIR') AS ShipmentMode
				  ,ISNULL(dca.[CompanyName], '') AS 'CompanyName'
				  ,ISNULL(dca.[Address],'') AS 'Address'
				  ,ISNULL(dca.[Suburb],'')  AS 'Suberb' 
				  ,ISNULL(dca.[State],'') AS 'State'
				  ,ISNULL(dca.[PostCode],'')  AS 'PostCode'				 
				  ,ISNULL(coun.[ShortName],'') AS 'Country'
				  ,ISNULL(dca.[ContactName],'') + ' ' + ISNULL(dca.[ContactPhone],'') AS 'ContactDetails'
				  ,o.[IsWeeklyShipment] AS 'IsWeeklyShipment'
				  ,[IsAdelaideWareHouse] AS 'IsAdelaideWareHouse'
				  ,ISNULL(o.[DespatchToExistingClient], 0) AS 'ShipTo'
				  ,ISNULL(CAST((SELECT CASE
										WHEN (p.[SubItem] IS NULL)
											THEN  	('')
										ELSE (CAST((SELECT TOP 1 hsc.[Code] FROM [dbo].[HSCode] hsc WHERE hsc.[ItemSubCategory] = p.[SubItem] AND hsc.[Gender] = p.[Gender]) AS nvarchar(64)))
								END) AS nvarchar (64)), '') AS 'HSCode'
			  FROM [Indico].[dbo].[OrderDetail] od				
				LEFT OUTER JOIN [dbo].[VisualLayout] vl
					ON od.[VisualLayout] = vl.[ID]
				LEFT OUTER JOIN [dbo].[Pattern] p 
					ON od.[Pattern] = p.[ID]
				LEFT OUTER JOIN [dbo].[FabricCode] fc
					ON od.[FabricCode] = fc.[ID]
				LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
					ON od.[Status] = ods.[ID]
				LEFT OUTER JOIN [dbo].[OrderType] ot
					ON od.[OrderType] = ot.[ID]
				INNER JOIN [dbo].[Order] o
					ON od.[Order] = o.[ID]	
				LEFT OUTER JOIN [dbo].[Company] c
					ON c.[ID] = o.[Distributor]
				LEFT OUTER JOIN [dbo].[User] u
					ON c.[Coordinator] = u.[ID]
				LEFT OUTER JOIN [dbo].[Client] cl
					ON o.[Client] = cl.[ID]
				LEFT OUTER JOIN [dbo].[OrderStatus] os
					ON o.[Status] = os.[ID]				
				LEFT OUTER JOIN [dbo].[ShipmentMode] shm
					ON o.[ShipmentMode] = shm.[ID] 
				LEFT OUTER JOIN [dbo].[DistributorClientAddress] dca
					ON o.[DespatchToExistingClient] = dca.[ID]
				LEFT OUTER JOIN [dbo].[Country] coun
					ON dca.[Country] = coun.[ID]
			WHERE (od.[SheduledDate] BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 0, @P_WeekEndDate), 0) as DATE) AND DATEADD(day, 2, CONVERT (date, @P_WeekEndDate))) AND
				  (@P_CompanyName = '' OR dca.[CompanyName] = @P_CompanyName ) AND
				  (@P_ShipmentMode = 0 OR shm.[ID] = @P_ShipmentMode)
			ORDER BY cl.[Name]

	END 





GO

/****** Object:  View [dbo].[ReturnWeeklyAddressDetails]    Script Date: 03/12/2015 13:45:48 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnWeeklyAddressDetails]'))
DROP VIEW [dbo].[ReturnWeeklyAddressDetails]
GO


/****** Object:  View [dbo].[ReturnWeeklyAddressDetails]    Script Date: 03/12/2015 13:45:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[ReturnWeeklyAddressDetails]
AS
			SELECT
				  0 AS OrderDetail,
				  '' AS OrderType,
				  '' AS VisualLayout,
				  0 AS VisualLayoutID,
				  0 AS PatternID,
				  '' AS Pattern,
				  0 AS FabricID,
				  --'' AS Fabric,
				  '' AS FabricCode,
				  '' AS FabricName,
				  '' AS FabricMaterial,	
				  '' AS VisualLayoutNotes,      
				  0 AS 'Order',
				  0 AS Label,
				  '' AS OrderDetailStatus,
				  0 AS OrderDetailStatusID,
				  GETDATE() AS ShipmentDate,
				  GETDATE() AS SheduledDate,
				  GETDATE() AS RequestedDate,
				  0 AS Quantity,				 
				  '' AS 'PurONo',
				  '' AS Distributor,
				  '' AS Coordinator,
				  '' AS Client,
				  '' AS OrderStatus,
				  0 AS OrderStatusID,				  
				  0 AS ShimentModeID,
				  '' AS ShipmentMode,
				  '' AS 'CompanyName',
				  '' AS 'Address',
				  '' AS 'Suberb',
				  '' AS 'State',
				  '' AS 'PostCode',
				  '' AS 'Country',
				  '' AS 'ContactDetails',
				  CONVERT(bit,0) AS 'IsWeeklyShipment',
				  CONVERT(bit,0) AS 'IsAdelaideWareHouse',
				  0 AS 'ShipTo',
				  '' AS 'HSCode'	 


GO





