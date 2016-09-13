USE [Indico]
GO

/****** Object:  View [dbo].[GetNonAssignedPriceMarkupDistributorsView]    Script Date: 02/14/2013 15:48:55 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GetNonAssignedPriceMarkupDistributorsView]'))
DROP VIEW [dbo].[GetNonAssignedPriceMarkupDistributorsView]
GO

/****** Object:  View [dbo].[GetNonAssignedPriceMarkupDistributorsView]    Script Date: 02/14/2013 15:48:55 ******/
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
	WHERE c.[IsDistributor] = 1
		  AND dpm.[Distributor] IS NULL 
	

GO


