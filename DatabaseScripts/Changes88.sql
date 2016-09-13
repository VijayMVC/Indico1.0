USE [Indico]
GO

/****** Object:  View [dbo].[ReservationDetailsView]    Script Date: 02/27/2014 12:52:19 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReservationDetailsView]'))
DROP VIEW [dbo].[ReservationDetailsView]
GO

/****** Object:  View [dbo].[ReservationDetailsView]    Script Date: 02/27/2014 12:52:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[ReservationDetailsView]
AS

SELECT r.[ID]
      ,RIGHT(CAST('RES-0000' + CAST(r.[ReservationNo] AS VARCHAR) AS VARCHAR), 10) AS ReservationNo
      ,r.[IsRepeat] AS IsRepeat
      ,r.[OrderDate] AS OrderDate
      ,ISNULL(r.[Pattern], 0) AS PatternID
      ,ISNULL(p.[Number] + ' - ' + p.[NickName], '') AS Pattern
      ,r.[Coordinator] AS CoordinatorID
      ,cu.[GivenName] + ' ' + cu.[FamilyName] AS Coordinator
      ,r.[Distributor] AS DistributorID
      ,d.[Name] AS Distributor
      ,r.[Client] AS ClientID
      ,c.[Name] AS Client
      ,ISNULL(r.[ShipTo], '') AS ShipTo
      ,ISNULL(r.[DestinationPort], 0) AS DestinationPortID
      ,ISNULL(dp.[Name], '') AS DestinationPort
      ,ISNULL(r.[ShipmentMode], 0) AS ShipmentModeID
      ,ISNULL(sm.[Name], '') AS ShipmentMode
      ,r.[ShipmentDate] AS ShipmentDate
      ,r.[Qty] AS Qty
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
	JOIN [dbo].[Client] c
		ON r.[Client] = c.[ID]
	LEFT OUTER JOIN [dbo].[DestinationPort] dp
		ON r.[DestinationPort] = dp.[ID]
	LEFT OUTER JOIN [dbo].[ShipmentMode] sm
		ON r.[ShipmentMode] = sm.[ID]
	JOIN [dbo].[User] rc
		ON r.[Creator] = rc.[ID]
	JOIN [dbo].[User] rm
		ON r.[Modifier] = rm.[ID]
	JOIN [dbo].[ReservationStatus] rs
		ON r.[Status] = rs.[ID]

GO


--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**

ALTER TABLE [dbo].[DistributorClientAddress]
ALTER COLUMN [Port] [int] NULL
GO

ALTER TABLE [dbo].[DistributorClientAddress]  WITH CHECK ADD  CONSTRAINT [FK_DistributorAddressr_Port] FOREIGN KEY([Port])
REFERENCES [dbo].[DestinationPort] ([ID])
GO

ALTER TABLE [dbo].[DistributorClientAddress] CHECK CONSTRAINT [FK_DistributorAddressr_Port]
GO

--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**--***-**
