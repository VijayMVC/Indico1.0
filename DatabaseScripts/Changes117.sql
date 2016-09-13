USE [Indico]
GO

/****** Object:  View [dbo].[FabricCodeDetailsView]    Script Date: 11/14/2014 12:47:24 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[FabricCodeDetailsView]'))
DROP VIEW [dbo].[FabricCodeDetailsView]
GO

/****** Object:  View [dbo].[FabricCodeDetailsView]    Script Date: 11/14/2014 12:47:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[FabricCodeDetailsView]
AS
SELECT
      fc.[ID] AS Fabric
	  ,fc.[Code] AS Code
      ,fc.[Name] AS Name
      ,ISNULL(fc.[Material], '') AS Material
      ,ISNULL(fc.[GSM], '') AS GSM
      ,ISNULL(fc.[Supplier], 0) AS SupplierID
      ,ISNULL(s.[Name], '') AS Supplier
      ,fc.[Country] AS CountryID
      ,c.[ShortName] AS Country
      ,ISNULL(fc.[DenierCount], '') AS DenierCount
      ,ISNULL(fc.[Filaments], '') AS Filaments
      ,ISNULL(fc.[NickName], '') AS NickName
      ,ISNULL(fc.[SerialOrder], '') AS SerialOrder
      ,ISNULL(fc.[FabricPrice], 0.00) AS FabricPrice
      ,ISNULL(fc.[LandedCurrency], 0) AS LandedCurrency
      ,ISNULL(fc.[Fabricwidth], '') AS FabricWidth
      ,ISNULL(fc.[Unit], 0) AS UnitID 
      ,ISNULL(u.[Name], '') AS Unit
      ,ISNULL(fc.[FabricColor], 0) AS FabricColorID
      ,ISNULL(ac.[Name], '') AS FabricColor 
      ,ISNULL(ac.[ColorValue], '#FFFFFF') AS ColorCode
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (ch.[Fabric]) FROM [dbo].[CostSheet] ch WHERE ch.[Fabric] = fc.[ID])) THEN 1 ELSE 0 END)) AS IsCostSheetWherethisFabricCode
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (pr.[FabricCode]) FROM [dbo].[Price] pr WHERE pr.[FabricCode] = fc.[ID])) THEN 1 ELSE 0 END)) AS IsPriceWherethisFabricCode
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (q.[Fabric]) FROM [dbo].[QuoteDetail] q WHERE q.[Fabric] = fc.[ID])) THEN 1 ELSE 0 END)) AS IsQuoteWherethisFabricCode
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (v.[FabricCode]) FROM [dbo].[VisualLayout] v WHERE v.[FabricCode] = fc.[ID])) THEN 1 ELSE 0 END)) AS IsVisualLayoutWherethisFabricCode
      ,CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (psf.[Fabric]) FROM [dbo].[PatternSupportFabric] psf WHERE psf.[Fabric] = fc.[ID])) THEN 1 ELSE 0 END)) AS IsPatternSupportFabricWherethisFabricCode
  FROM [Indico].[dbo].[FabricCode] fc
	LEFT OUTER JOIN [dbo].[Supplier] s
		ON fc.[Supplier] = s.[ID]
	JOIN [dbo].[Country] c
		ON fc.[Country] = c.[ID]
	LEFT OUTER JOIN [dbo].[Unit] u
		ON fc.[Unit] = u.[ID]
	LEFT OUTER JOIN [dbo].[AccessoryColor] ac
		ON fc.[FabricColor] = ac.[ID]



GO


