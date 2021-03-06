USE [Indico]
GO

/****** Object:  View [dbo].[UsersDetailsView]    Script Date: 10/05/2015 13:11:23 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[UsersDetailsView]'))
DROP VIEW [dbo].[UsersDetailsView]
GO

/****** Object:  View [dbo].[UsersDetailsView]    Script Date: 10/05/2015 13:11:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[UsersDetailsView]
AS

SELECT u.[ID] AS [User]
      ,c.[Name] AS Company
      ,u.[IsDistributor] AS IsDistributor
      ,us.[Name] AS [Status]
      ,u.[Status] AS StatusID
      ,u.[GivenName] + ' ' + u.[FamilyName] AS Name   
      ,u.[UserName] AS UserName       
      ,u.[EmailAddress] AS Email      
      ,u.[IsActive] AS IsActive
      ,u.[IsDeleted] AS IsDeleted      
      ,r.[ID] AS [Role]
      ,r.Name AS [RoleName]
      ,ct.[Name] AS CompanyType       
  FROM [Indico].[dbo].[User] u
	JOIN [dbo].[UserStatus] us
		ON u.[Status] = us.[ID]	
	JOIN [dbo].[Company] c
		ON u.[Company] = c.[ID]
	JOIN [dbo].[UserRole] ur
		ON u.[ID] = ur.[User]
	JOIN [dbo].[Role] r
		ON ur.[Role] = r.[ID]
	JOIN [dbo].[CompanyType] ct
		ON c.[Type] = ct.[ID]
  WHERE [u].[Status] NOT IN (4)




GO


