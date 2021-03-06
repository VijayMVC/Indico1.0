USE [Indico]
GO

/****** Object:  View [dbo].[IndicoCIFPriceView]    Script Date: 01/04/2016 13:46:48 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IndicoCIFPriceView]'))
DROP VIEW [dbo].[IndicoCIFPriceView]
GO

/****** Object:  View [dbo].[IndicoCIFPriceView]    Script Date: 01/04/2016 13:46:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[IndicoCIFPriceView]
AS
	SELECT	c.ID AS CostSheetId,
			ca.Name AS CoreCategory,
			i.Name AS ItemCategory,
			p.ID AS PatternId,
			p.Number AS PatternCode,
			p.NickName AS PatternNickName,
			f.ID AS FabricId,
			f.Code AS FabricCode,
			f.Name AS FabricName,
			CAST (ISNULL((	SELECT TOP 1 ROUND(f.FabricPrice, 2) --(psf.FabConstant * f.FabricPrice , 2) 
							FROM PatternSupportFabric psf LEFT OUTER JOIN FabricCode f ON psf.Fabric = f.ID 
							WHERE psf.CostSheet = c.ID ), 0.0)AS DECIMAL(12,2)) AS FabricPrice,
			ISNULL(c.FOBFactor,0.0) AS ConversionFactor,
			ISNULL(c.QuotedCIF, 0.0) AS IndimanPrice,
			ISNULL(c.QuotedFOBCost, 0.0 ) AS QuotedFOBPrice,
			CAST ( ISNULL(
				ROUND (
					(p.SMV * c.SMVRate) +
					( SELECT SUM( ROUND( psf.FabConstant * f.FabricPrice , 2) ) FROM PatternSupportFabric psf LEFT OUTER JOIN FabricCode f ON psf.Fabric = f.ID WHERE psf.CostSheet = c.ID ) + 
					( SELECT SUM( ROUND( psa.AccConstant * a.Cost , 2) ) FROM PatternSupportAccessory psa LEFT OUTER JOIN Accessory a ON psa.Accessory = a.ID WHERE psa.CostSheet = c.ID ) + 
					c.HPCost + 
					c.LabelCost + 
					c.Other + 
					( ( ( SELECT SUM( ROUND( psa.AccConstant * a.Cost , 2) ) FROM PatternSupportAccessory psa LEFT OUTER JOIN Accessory a ON psa.Accessory = a.ID WHERE psa.CostSheet = c.ID ) + 
						c.HPCost + 
						c.LabelCost + 
						c.Other ) * 0.03 ) + 
					( ( ( SELECT SUM( ROUND( psf.FabConstant * f.FabricPrice , 2) ) FROM PatternSupportFabric psf LEFT OUTER JOIN FabricCode f ON psf.Fabric = f.ID WHERE psf.CostSheet = c.ID ) + 
						( SELECT SUM( ROUND( psa.AccConstant * a.Cost , 2) ) FROM PatternSupportAccessory psa LEFT OUTER JOIN Accessory a ON psa.Accessory = a.ID WHERE psa.CostSheet = c.ID ) + 
						c.HPCost + 
						c.LabelCost + 
						c.Other ) * 0.04 ), 2)
			, 0.0 ) AS DECIMAL(12,2)) AS FOBCost,
			ISNULL((SELECT TOP 1 (u.GivenName + ' ' + u.FamilyName) As LastModifier
				FROM IndimanCostSheetRemarks ir
				JOIN [User] u
				ON ir.Modifier = u.ID
				WHERE CostSheet = c.ID ORDER BY ir.ID DESC), 
				(SELECT GivenName + ' ' + u.FamilyName AS LastModifier FROM [User] WHERE ID = c.Modifier)
				) AS LastModifier,
			ISNULL((SELECT TOP 1 ModifiedDate FROM IndimanCostSheetRemarks WHERE CostSheet = c.ID  ORDER BY ID DESC), c.CreatedDate) AS ModifiedDate,
			ISNULL((SELECT TOP 1 Remarks FROM IndimanCostSheetRemarks WHERE CostSheet = c.ID  ORDER BY ID DESC),'') AS Remarks,
			CAST ( ISNULL(	
					ROUND(
						(
							ISNULL(c.QuotedCIF, 0.0) - 
							(
								(SELECT CASE WHEN (ISNULL(c.ExchangeRate,0) > 0 ) THEN ( c.QuotedFOBCost / c.ExchangeRate) ELSE 0 END) + 
								(((SELECT CASE WHEN (ISNULL(c.ExchangeRate,0) > 0 ) THEN ( c.QuotedFOBCost / c.ExchangeRate) ELSE 0 END) * c.DutyRate) / 100) + 
								(c.CONS1 * c.Rate1) + 
								(c.CONS2 * c.Rate2) + 
								(c.CONS3 * c.Rate3) + 
								(c.InkCons * c.InkRate * 1.02) + 
								(c.SubCons * 1.1 * c.PaperRate * 1.2) + 
								c.AirFregiht + c.ImpCharges + c.MGTOH + c.IndicoOH + c.Depr
							)
						), 2)
				, 0.0) AS DECIMAL(12,2)) AS ActMgn,
			CAST ( ISNULL(	
				 ROUND(
					(
						( SELECT CASE WHEN (ISNULL(c.QuotedCIF, 0)>0 ) THEN 
							(1 - 
								(
									ROUND( (
										(SELECT CASE WHEN (ISNULL(c.ExchangeRate,0) > 0 ) THEN ( c.QuotedFOBCost / c.ExchangeRate) ELSE 0 END) + 
										(((SELECT CASE WHEN (ISNULL(c.ExchangeRate,0) > 0 ) THEN ( c.QuotedFOBCost / c.ExchangeRate) ELSE 0 END) * c.DutyRate) / 100) + 
										(c.CONS1 * c.Rate1) + 
										(c.CONS2 * c.Rate2) + 
										(c.CONS3 * c.Rate3) + 
										(c.InkCons * c.InkRate * 1.02) + 
										(c.SubCons * 1.1 * c.PaperRate * 1.2) + 
										c.AirFregiht + c.ImpCharges + c.MGTOH + c.IndicoOH + c.Depr
									) , 2)
									/ c.QuotedCIF
								)
							) * 100 ELSE 0 END 
						) 
				), 2)
			,0.0) AS DECIMAL(12,2)) AS QuotedMp 						
	FROM CostSheet c
		JOIN Pattern p
			ON c.Pattern = p.ID
		JOIN FabricCode f
			ON c.Fabric = f.ID
		JOIN [User] u
			ON c.Modifier = u.ID	
		LEFT OUTER JOIN Category ca
			ON ca.ID = p.CoreCategory
		LEFT OUTER JOIN Item i
			ON i.ID = p.Item	
	WHERE p.IsActive = 1		
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

------------------- Updating '016' Fabric Prices --------------------------------

UPDATE c 
	SET c.QuotedFOBCost = CAST (
					CEILING(
					 ISNULL(
									ROUND (
										(p.SMV * SMVRate) +
										( SELECT SUM( ROUND( ISNULL(psf.FabConstant * f.FabricPrice, 0) , 2) ) FROM PatternSupportFabric psf LEFT OUTER JOIN FabricCode f ON psf.Fabric = f.ID WHERE psf.CostSheet = c.ID ) + 
										( SELECT SUM( ROUND( ISNULL(psa.AccConstant * a.Cost, 0) , 2) ) FROM PatternSupportAccessory psa LEFT OUTER JOIN Accessory a ON psa.Accessory = a.ID WHERE psa.CostSheet = c.ID ) + 
										c.HPCost + 
										c.LabelCost + 
										c.Other + 
										( ( ( SELECT SUM( ROUND( ISNULL(psa.AccConstant * a.Cost, 0) , 2) ) FROM PatternSupportAccessory psa LEFT OUTER JOIN Accessory a ON psa.Accessory = a.ID WHERE psa.CostSheet = c.ID ) + 
											c.HPCost + 
											c.LabelCost + 
											c.Other ) * 0.03 ) + 
										( ( ( SELECT SUM( ROUND( ISNULL(psf.FabConstant * f.FabricPrice, 0) , 2) ) FROM PatternSupportFabric psf LEFT OUTER JOIN FabricCode f ON psf.Fabric = f.ID WHERE psf.CostSheet = c.ID ) + 
											( SELECT SUM( ROUND( ISNULL(psa.AccConstant * a.Cost, 0) , 2) ) FROM PatternSupportAccessory psa LEFT OUTER JOIN Accessory a ON psa.Accessory = a.ID WHERE psa.CostSheet = c.ID ) + 
											c.HPCost + 
											c.LabelCost + 
											c.Other ) * 0.04 ), 2)
								, 0.0 ) * 20) / 20 AS DECIMAL(12,2))
	FROM [dbo].CostSheet  c
	JOIN Pattern p
			ON c.Pattern = p.ID
		JOIN FabricCode f
			ON c.Fabric = f.ID
		JOIN [User] u
			ON c.Modifier = u.ID	
		LEFT OUTER JOIN Category ca
			ON ca.ID = p.CoreCategory
		LEFT OUTER JOIN Item i
			ON i.ID = p.Item	
	WHERE p.IsActive = 1 
	AND ISNULL(p.SMV,0) > 0
	AND f.[Code] LIKE '%F016%'
	
GO		
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

-------------------- Inserting AddEditFabricCode.aspx Menu item ------------------------

DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

DECLARE @FactoryAdministrator int
DECLARE @IndimanAdministrator int

SET @FactoryAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')
SET @IndimanAdministrator = (SELECT ID FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/AddEditFabricCode.aspx','Fabric Code','Fabric Code')	 
SET @PageId = SCOPE_IDENTITY()

SET @MenuItemMenuId =  (SELECT ID FROM [dbo].[MenuItem] WHERE 
						(Page = (SELECT ID FROM [dbo].Page WHERE Name = '/ViewPatterns.aspx')
						AND Parent IS NULL)
						)

INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Fabric Code', 'Fabric Code', 1, @MenuItemMenuId, 14, 0)
SET @MenuItemId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, @IndimanAdministrator)			
GO	 
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[FabricCode]
	ALTER COLUMN [Name] nvarchar(255) NOT NULL
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  Table [dbo].[PatternCompressionImage]    Script Date: 1/14/2016 4:53:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[PatternCompressionImage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Filename] [nvarchar](255) NULL,
	[Extension] [varchar](10) NULL,
 CONSTRAINT [PK_PatternCompressionImage] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternCompressionImage', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The filename of the image' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternCompressionImage', @level2type=N'COLUMN',@level2name=N'Filename'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The file extension of the image' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternCompressionImage', @level2type=N'COLUMN',@level2name=N'Extension'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PatternCompressionImage'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

ALTER TABLE [dbo].[Pattern]
	ADD [PatternCompressionImage] int NULL
GO

ALTER TABLE [dbo].[Pattern]  WITH CHECK ADD  CONSTRAINT [FK_Pattern_PatternCompressionImage] FOREIGN KEY([PatternCompressionImage])
REFERENCES [dbo].[PatternCompressionImage] ([ID])
GO

ALTER TABLE [dbo].[Pattern] CHECK CONSTRAINT [FK_Pattern_PatternCompressionImage]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

------------------- Inserting costsheets to pattern - fabric combinations --------

  INSERT INTO [dbo].CostSheet 
 ( [Pattern], Fabric, SMVRate, HPCost, LabelCost, Other, Wastage, Finance, FOBExp, DutyRate,InkCons, InkRate,PaperRate, MarginRate, ExchangeRate, AirFregiht,
   ImpCharges, MGTOH, IndicoOH, Depr, CM, JKFOBCost, Creator, CreatedDate, Modifier, ModifiedDate )
  SELECT DISTINCT
		vl.[Pattern],
		vl.[FabricCode] AS Fabric,
		0.15 AS SMVRate,
		1.15 AS HPCost,
		0.10 AS LabelCost,
		0.30 AS Other,
		3.0 AS Wastage,
		4.0 AS Finance,		
		0 AS FOBExp,
		5.0 AS DutyRate,
		0.017 AS InkCons,
		80 AS InkRate,
		0.8 AS PaperRate,
		12.5 AS MarginRate,
		0.7 AS ExchangeRate,
		1.15 AS AirFregiht,
		0.35 AS ImpCharges,
		1.83 AS MGTOH,
		0.56 AS IndicoOH,
		0.2 AS Depr,		
		0 AS CM,
		0 AS JKFOBCost,
		1 AS Creator,
		GETDATE() AS CreatedDate,
		1 AS Modifier,
		GETDATE() AS ModifiedDate
  FROM [dbo].[VisualLayout] vl
	LEFT OUTER JOIN [dbo].CostSheet c
  ON vl.Pattern = c.Pattern And vl.FabricCode = c.Fabric
	INNER JOIN [dbo].[FabricCode] f
		ON vl.FabricCode = f.ID
	INNER JOIN [dbo].Pattern p
		ON vl.Pattern = p.ID
  WHERE c.ID IS NULL  -- AND p.IsActive = 1
	 			