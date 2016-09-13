USE [Indico]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetReservationDetails]    Script Date: 07/02/2015 13:03:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetReservationDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetReservationDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetReservationDetails]    Script Date: 07/02/2015 13:03:44 ******/
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
						   (@P_Distributor = '' OR d.[ID] = @P_Distributor ) AND
						   (@P_Coordinator = '' OR cu.[ID] = @P_Coordinator)						   

		END
GO

--------- Added CreatorID  -----

/****** Object:  View [dbo].[QuotesDetailsView]    Script Date: 07/02/2015 18:08:56 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[QuotesDetailsView]'))
DROP VIEW [dbo].[QuotesDetailsView]
GO

/****** Object:  View [dbo].[QuotesDetailsView]    Script Date: 07/02/2015 18:08:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QuotesDetailsView]
AS

SELECT q.[ID] AS Quote
      ,q.[DateQuoted] AS DateQuoted
      ,q.[QuoteExpiryDate] AS QuoteExpiryDate
      ,q.[ClientEmail] AS ClietEMail
      ,q.[JobName] AS JobName      
      ,qs.[Name] AS [Status]
      ,q.[ContactName] AS ContactName
      ,u.[GivenName] + ' ' + u.[FamilyName] AS Creator
      ,u.ID AS CreatorID      
      ,ISNULL(c.[Name], '') AS Distributor
  FROM [Indico].[dbo].[Quote] q		
	JOIN [dbo].[QuoteStatus] qs
		ON q.[Status] = qs.[ID]
	JOIN [dbo].[User] u
		ON q.[Creator] = u.[ID] 
	LEFT OUTER JOIN [dbo].[Company] c
		ON q.[Distributor] = c.[ID]
		
GO

------- Added EmailAddress and type  -----
Danesh 
ALTER TABLE dbo.[DistributorClientAddress] ADD [AddressType] int NULL
GO

/****** Object:  View [dbo].[DistributorClientAddressDetailsView]    Script Date: 07/03/2015 12:10:36 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DistributorClientAddressDetailsView]'))
DROP VIEW [dbo].[DistributorClientAddressDetailsView]
GO

/****** Object:  View [dbo].[DistributorClientAddressDetailsView]    Script Date: 07/03/2015 12:10:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DistributorClientAddressDetailsView]
AS

	SELECT dca.[ID]
		  ,dca.[Address]
		  ,dca.[Suburb]
		  ,dca.[PostCode]
		  ,c.[ID] AS CountryID
		  ,c.[ShortName] AS Country
		  ,dca.[ContactName]
		  ,dca.[EmailAddress]
		  ,dca.[ContactPhone]
		  ,dca.[CompanyName]
		  ,dca.[AddressType]
		  ,ISNULL(dca.[State], '') AS [State]
		  ,ISNULL(dp.[Name], '') AS Port
		  ,ISNULL(dp.[ID], 0) AS PortID
		  ,ISNULL(dca.[Client], 0) AS DistributorID
		  ,ISNULL(cl.[Name], '') AS Distributor
	  FROM [Indico].[dbo].[DistributorClientAddress] dca
		JOIN [dbo].[Country] c
			ON dca.[Country] = c.[ID]
		LEFT OUTER JOIN [dbo].[DestinationPort] dp
			ON dca.[Port] = dp.[ID]
		LEFT OUTER JOIN [dbo].[Client] cl
			ON dca.[Client] = cl.[ID]
		
GO

  Master Data MenuItem scripts for Indico Coordinator -- 

INSERT INTO [dbo].[MenuItemRole]
           ([MenuItem],[Role])
     VALUES
           (	(SELECT TOP 1 ID FROM [dbo].[MenuItem] WHERE [Name]='Master Data' AND [Parent] IS NULL),
				(SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
			)
GO

INSERT INTO [dbo].[MenuItemRole]
           ([MenuItem],[Role])
     VALUES
           (	(SELECT ID FROM [dbo].[MenuItem] WHERE [Name]='Shipment Addresses'),
				(SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
			)
GO

DELETE FROM [dbo].[MenuItemRole]
      WHERE [MenuItem] = (SELECT ID FROM [dbo].[MenuItem] WHERE [Name]='Units')
      AND [Role] = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
GO

DELETE FROM [dbo].[MenuItemRole]
      WHERE [MenuItem] = (SELECT ID FROM [dbo].[MenuItem] WHERE [Name]='Suppliers')
      AND [Role] = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
GO

-- Pricing MenuItem correction scripts for Indico Coordinator -- 

DELETE FROM [dbo].[MenuItemRole]
      WHERE [MenuItem] = (SELECT ID FROM [dbo].[MenuItem] WHERE [Name]='Indico Prices'
							AND [Parent] = (SELECT TOP 1 [ID] FROM [dbo].[MenuItem] WHERE [Name]='Prices' ORDER BY ID DESC)
						)	
      AND [Role] = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
GO

DELETE FROM [dbo].[MenuItemRole]
      WHERE [MenuItem] = (SELECT ID FROM [dbo].[MenuItem] WHERE [Name]='Price Markups'
							AND [Parent] = (SELECT TOP 1 [ID] FROM [dbo].[MenuItem] WHERE [Name]='Prices' ORDER BY ID DESC)
						)	
      AND [Role] = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
GO

DELETE FROM [dbo].[MenuItemRole]
      WHERE [MenuItem] = (SELECT ID  = (SELECT TOP 1 [ID] FROM [dbo].[MenuItem] WHERE [Name]='Prices' ORDER BY ID DESC)
						)	
      AND [Role] = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
GO

DELETE FROM [dbo].[MenuItemRole]
      WHERE [MenuItem] = (SELECT ID FROM [dbo].[MenuItem] WHERE [Name]='Download to Excel'
							AND [Parent] = (SELECT TOP 1 [ID] FROM [dbo].[MenuItem] WHERE [Name]='Prices' ORDER BY ID DESC)
						)	
      AND [Role] = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
GO

INSERT INTO [dbo].[MenuItemRole]
           ([MenuItem],[Role])
     VALUES
           (	(SELECT TOP 1 ID FROM (SELECT TOP 2 ID FROM [dbo].[MenuItem] WHERE [Name]='Prices' ORDER BY ID ASC
				) a 
				ORDER BY ID  DESC
					),
				(SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
			)
GO

DECLARE @Prices_Menu_Item int
SET @Prices_Menu_Item = ( SELECT ID FROM [dbo].[MenuItem] 
            WHERE [Name]= 'Indiman Prices'  AND 
			[Parent] = (SELECT TOP 1 ID FROM (SELECT TOP 2 ID from [MenuItem] WHERE [Name]='Prices'  ORDER BY ID ASC
											) a 
						ORDER BY ID  DESC))

INSERT INTO [dbo].[MenuItemRole]
           ([MenuItem],[Role])
     VALUES ( @Prices_Menu_Item
            ,
				(SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')
			)
GO


---------------------------------------   Alter table DistributorClientAddress ---------------------------------------------------  

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DistributorClientAddress_Distributor]') AND parent_object_id = OBJECT_ID(N'[dbo].[DistributorClientAddress]'))
ALTER TABLE [dbo].[DistributorClientAddress] DROP CONSTRAINT [FK_DistributorClientAddress_Distributor]
GO

ALTER TABLE dbo.[DistributorClientAddress] DROP COLUMN [Distributor] 
GO

ALTER TABLE dbo.[DistributorClientAddress] ADD [Client] int NULL
GO

ALTER TABLE [dbo].[DistributorClientAddress]  WITH CHECK ADD  CONSTRAINT [FK_DistributorClientAddress_Client] FOREIGN KEY([Client])
REFERENCES [dbo].[Client] ([ID])
GO

ALTER TABLE [dbo].[DistributorClientAddress] CHECK CONSTRAINT [FK_DistributorClientAddress_Client]
GO

---------------------------------------  Alter table Order --------------------------------------------------- 

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_Label]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_Label]
GO

ALTER TABLE dbo.[Order] DROP COLUMN [Label] 
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_DespatchToExistingClient]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_DespatchToExistingClient]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Order_ShipToExistingClient]') AND parent_object_id = OBJECT_ID(N'[dbo].[Order]'))
ALTER TABLE [dbo].[Order] DROP CONSTRAINT [FK_Order_ShipToExistingClient]
GO

ALTER TABLE dbo.[Order] DROP COLUMN [ShipToExistingClient] 
GO

ALTER TABLE dbo.[Order] DROP COLUMN [DespatchToExistingClient] 
GO

ALTER TABLE dbo.[Order] ADD [BillingAddress] int NULL
GO

ALTER TABLE dbo.[Order] ADD [DespatchToAddress] int NULL
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_BillingAddress] FOREIGN KEY([BillingAddress])
REFERENCES [dbo].[DistributorClientAddress] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_BillingAddress]
GO

ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_DespatchToAddress] FOREIGN KEY([DespatchToAddress])
REFERENCES [dbo].[DistributorClientAddress] ([ID])
GO

ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_DespatchToAddress]
GO

---------------------------------------  Alter table OrderDetail --------------------------------------------------- 

ALTER TABLE dbo.[OrderDetail] ADD [Label] int NULL
GO

ALTER TABLE [dbo].[OrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetail_Label] FOREIGN KEY([Label])
REFERENCES [dbo].[Label] ([ID])
GO

ALTER TABLE [dbo].[OrderDetail] CHECK CONSTRAINT [FK_OrderDetail_Label]
GO