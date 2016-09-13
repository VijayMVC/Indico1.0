USE [Indico]
GO

/****** Object:  View [dbo].[DistributorClientAddressDetailsView]    Script Date: 07/16/2014 11:12:39 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DistributorClientAddressDetailsView]'))
DROP VIEW [dbo].[DistributorClientAddressDetailsView]
GO

/****** Object:  View [dbo].[DistributorClientAddressDetailsView]    Script Date: 07/16/2014 11:12:40 ******/
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
		  ,dca.[ContactPhone]
		  ,dca.[CompanyName]
		  ,ISNULL(dca.[State], '') AS [State]
		  ,ISNULL(dp.[Name], '') AS Port
		  ,ISNULL(dp.[ID], 0) AS PortID
	  FROM [Indico].[dbo].[DistributorClientAddress] dca
		JOIN [dbo].[Country] c
			ON dca.[Country] = c.[ID]
		LEFT OUTER JOIN [dbo].[DestinationPort] dp
			ON dca.[Port] = dp.[ID]
		

GO


DECLARE @Page AS int
DECLARE @Parent_Page AS int
DECLARE @Parent AS int
DECLARE @MenuItem AS int
DECLARE @Role AS int 
DECLARE @Position AS int


INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/ViewShipmentAddresses.aspx','Shipment Addresses','Shipment Addresses')

SET @Page = SCOPE_IDENTITY()

SET @Parent_Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAgeGroups.aspx')

SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Parent_Page AND [Parent] IS NULL)

SET @Position = (SELECT MAX([Position]) + 1 FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator ')


INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES
           (@Page, 'Shipment Addresses', 'Shipment Addresses', 1, @Parent, @Position, 1)



SET @MenuItem = SCOPE_IDENTITY()

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO







