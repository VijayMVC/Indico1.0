USE [Indico]
GO

/****** Object:  View [dbo].[ReturnDownloadPriceListView]    Script Date: 05/21/2013 12:16:42 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[ReturnDownloadPriceListView]'))
DROP VIEW [dbo].[ReturnDownloadPriceListView]
GO

/****** Object:  View [dbo].[ReturnDownloadPriceListView]    Script Date: 05/21/2013 11:41:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--- ALTER VIew "[ReturnDownloadPriceListView]"------

CREATE VIEW [dbo].[ReturnDownloadPriceListView]
AS
	SELECT 
		0 AS Distributor,
		0 AS Label,
		'' AS Name,
		'' AS PriceTerm,
		CONVERT(bit,0)AS EditedPrice,
		0.0 AS CreativeDesign,
		0.0 AS StudioDesign,
		0.0 AS ThirdPartyDesign,
		0.0 AS Position1,
		0.0 AS Position2,
		0.0 AS Position3,
		'' AS 'FileName',
		GETDATE() AS CreatedDate
		
GO

/****** Object:  StoredProcedure [dbo].[SPC_ReturnDownloadPriceList]    Script Date: 05/21/2013 12:17:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ReturnDownloadPriceList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ReturnDownloadPriceList]
GO

/****** Object:  View [dbo].[SPC_ReturnDownloadPriceList]    Script Date: 05/21/2013 11:41:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_ReturnDownloadPriceList]
(
	@P_Type AS int = 0 -- 0 - all, 1 - distributor, 2 - label
)
AS
SELECT * FROM (

	SELECT
	    pl.[ID] AS 'Distributor',
	    0 AS 'Label',
		ISNULL(c.[Name],'PLATINUM') AS 'Name',
		 pt.[Name] AS 'PriceTerm',
		 pl.[EditedPrice] AS 'EditedPrice',
		 pl.[CreativeDesign] AS 'CreativeDesign',
		 pl.[StudioDesign] AS 'StudioDesign',
		 pl.[ThirdPartyDesign] AS 'ThirdPartyDesign',
		 pl.[Position1] AS 'Position1',
		 pl.[Position2] AS 'Position2',
		 pl.[Position3] AS 'Position3',
		 pl.[FileName] AS 'FileName',
		 pl.[CreatedDate] AS 'CreatedDate'
	FROM [dbo].[PriceListDownloads] pl
		LEFT OUTER JOIN [dbo].[Company] c
			ON pl.[Distributor] = c.[ID]
		JOIN [dbo].[PriceTerm] pt
			ON pl.[PriceTerm] = pt.[ID]
	WHERE (@P_Type = 0 OR @P_Type = 1)
			
	UNION

	SELECT
		 0 AS Distributor,
		 lpl.[ID] AS Label,
		 pml.[Name] AS 'Name',
		 pt.[Name] AS 'PriceTerm',
		 lpl.[EditedPrice] AS 'EditedPrice',
		 lpl.[CreativeDesign] AS 'CreativeDesign',
		 lpl.[StudioDesign] AS 'StudioDesign',
		 lpl.[ThirdPartyDesign] AS 'ThirdPartyDesign',
		 lpl.[Position1] AS 'Position1',
		 lpl.[Position2] AS 'Position2',
		 lpl.[Position3] AS 'Position3',
		 lpl.[FileName] AS 'FileName',
		 lpl.[CreatedDate] AS 'CreatedDate'
	FROM [dbo].[LabelPriceListDownloads] lpl
		JOIN [dbo].[PriceMarkupLabel] pml
			ON [lpl].[Label] = pml.[ID]
		JOIN [dbo].[PriceTerm] pt
			ON lpl.[PriceTerm] = pt.[ID]
	WHERE (@P_Type = 0 OR @P_Type = 2)	
		
) AS ReturnDownloadPriceList
GO
