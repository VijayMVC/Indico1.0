USE [Indico]
GO

/****** Object:  View [dbo].[VisualLayoutClients]    Script Date: 01/09/2013 13:19:01 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VisualLayoutClients]'))
DROP VIEW [dbo].[VisualLayoutClients]
GO

CREATE VIEW [dbo].[VisualLayoutClients]
AS
	SELECT DISTINCT	c.[ID],
					c.[Name] 
	FROM	[dbo].[Client] c
			JOIN [dbo].[VisualLayout] v
				ON c.[ID] = v.[Client] 
GO

/****** Object:  View [dbo].[VisualLayoutDistributors]    Script Date: 01/09/2013 13:23:04 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VisualLayoutDistributors]'))
DROP VIEW [dbo].[VisualLayoutDistributors]
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
GO

/****** Object:  View [dbo].[VisualLayoutCoordinators]    Script Date: 01/09/2013 13:22:37 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VisualLayoutCoordinators]'))
DROP VIEW [dbo].[VisualLayoutCoordinators]
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
GO





