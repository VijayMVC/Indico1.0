USE [Indico]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Client_Type]') AND parent_object_id = OBJECT_ID(N'[dbo].[Client]'))
ALTER TABLE [dbo].[Client] DROP CONSTRAINT [FK_Client_Type]
GO

ALTER TABLE [dbo].[Client]
DROP COLUMN [Type]
GO

ALTER TABLE [dbo].[Client]
DROP COLUMN [Title]
GO 

ALTER TABLE [dbo].[Client]
DROP COLUMN [FirstName]
GO

ALTER TABLE [dbo].[Client]
DROP COLUMN [LastName]
GO

ALTER TABLE [dbo].[Client]
ALTER COLUMN [Address1] [nvarchar](255) NULL
GO

SP_RENAME '[Indico].[dbo].[Client].[Address1]', 'Address'
GO

ALTER TABLE [dbo].[Client]
DROP COLUMN [Address2]
GO

ALTER TABLE [dbo].[Client]
ALTER COLUMN [City] [nvarchar](255) NULL
GO

ALTER TABLE [dbo].[Client]
ALTER COLUMN [State] [nvarchar](255) NULL
GO

ALTER TABLE [dbo].[Client]
ALTER COLUMN [PostalCode] [nvarchar](255) NULL
GO

ALTER TABLE [dbo].[Client]
ALTER COLUMN [Country] [nvarchar](255) NULL

ALTER TABLE [dbo].[Client]
ALTER COLUMN [Phone1] [nvarchar](255) NULL
GO

SP_RENAME  '[Indico].[dbo].[Client].[Phone1]', 'Phone'
GO

ALTER TABLE [dbo].[Client]
DROP COLUMN [Phone2]
GO

ALTER TABLE [dbo].[Client]
DROP COLUMN [Mobile]
GO

ALTER TABLE [dbo].[Client]
DROP COLUMN [Fax]
GO

ALTER TABLE [dbo].[Client]
DROP COLUMN [Web]
GO

ALTER TABLE [dbo].[Client]
DROP COLUMN [NickName]
GO

ALTER TABLE [dbo].[Client]
DROP COLUMN [EmailSent]
GO

ALTER TABLE [dbo].[Company]
ADD [IsActive] [bit] DEFAULT 1
GO

ALTER TABLE [dbo].[Company]
ADD [IsDelete] [bit] DEFAULT 0
GO

UPDATE [dbo].[Company] SET [IsActive] = 1
GO

UPDATE [dbo].[Company] SET [IsDelete] = 0
GO

/****** Object:  View [dbo].[GetNonAssignedPriceMarkupDistributorsView]    Script Date: 04/29/2013 16:32:26 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GetNonAssignedPriceMarkupDistributorsView]'))
DROP VIEW [dbo].[GetNonAssignedPriceMarkupDistributorsView]
GO

/****** Object:  View [dbo].[GetNonAssignedPriceMarkupDistributorsView]    Script Date: 04/29/2013 16:32:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[GetNonAssignedPriceMarkupDistributorsView]
AS

	SELECT c.[ID], 
		   c.[Name] 
	FROM [dbo].[Company] c
		LEFT OUTER JOIN [dbo].[DistributorPriceMarkup] dpm
		ON c.[ID] = dpm.[Distributor] 
	WHERE c.[IsDistributor] = 1 AND
		  c.[IsActive] = 1 AND
		  c.[IsDelete] = 0 AND
		  dpm.[Distributor] IS NULL 
	


GO

/****** Object:  View [dbo].[VisualLayoutDistributors]    Script Date: 04/30/2013 11:20:02 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VisualLayoutDistributors]'))
DROP VIEW [dbo].[VisualLayoutDistributors]
GO

/****** Object:  View [dbo].[VisualLayoutDistributors]    Script Date: 04/30/2013 11:20:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VisualLayoutDistributors]
AS
	SELECT DISTINCT dis.[ID],
					dis.[Name]	  
	FROM	[dbo].[Company] dis
			JOIN [dbo].[Client] c
				ON c.[Distributor] = dis.[ID]
			JOIN [dbo].[VisualLayout] v
				ON v.[Client] = c.[ID]
	WHERE dis.[IsActive] = 1 AND
		  dis.[IsDelete] = 0

GO


/****** Object:  View [dbo].[VisualLayoutCoordinators]    Script Date: 04/30/2013 11:20:39 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VisualLayoutCoordinators]'))
DROP VIEW [dbo].[VisualLayoutCoordinators]
GO

/****** Object:  View [dbo].[VisualLayoutCoordinators]    Script Date: 04/30/2013 11:20:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VisualLayoutCoordinators]
AS
	SELECT DISTINCT  u.[ID],
		u.[GivenName],
		u.[FamilyName] 	  
	FROM	[dbo].[User] u
			JOIN [dbo].[Company] dis
				ON dis.[Coordinator] = u.[ID]
			JOIN [dbo].[Client] c
				ON c.[Distributor] = dis.[ID]
			JOIN [dbo].[VisualLayout] v
			ON v.[Client] = c.[ID]
	WHERE dis.[IsActive] = 1 AND
		  dis.[IsDelete] = 0	

GO




