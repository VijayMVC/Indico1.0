USE [Indico] 
GO
--**---**--**-----**-----**-----** CREATE NEW TABLE FACTORYPRICEREMARKS--**-----**-----**-----**-----**-----**---
CREATE TABLE [dbo].[FactoryPriceRemarks](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Price] [int] NOT NULL,
	[Remarks] [nvarchar](512) NOT NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_FactoryPriceRemarks] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FactoryPriceRemarks]  WITH CHECK ADD  CONSTRAINT [FK_FactoryPriceRemarks_Price] FOREIGN KEY([Price])
REFERENCES [dbo].[Price] ([ID])
GO

ALTER TABLE [dbo].[FactoryPriceRemarks] CHECK CONSTRAINT [FK_FactoryPriceRemarks_Price]
GO

--**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**---


--**-----**-----**-----**-----**-----**--- ALTER TABLE DISTRIBUTOR --**-----**-----**-----**-----**-----**-----**-----

ALTER TABLE [dbo].[Company]
ADD SecondaryCoordinator INT NULL
GO

ALTER TABLE [dbo].[Company] WITH CHECK ADD CONSTRAINT [FK_SecondaryCoordinator_User] FOREIGN KEY ([SecondaryCoordinator])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_SecondaryCoordinator_User]
GO

--**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**---


--**-----**-----**-----**-----**-----**--- ALTER TABLE PRICE --**-----**-----**-----**-----**-----**-----**-----

ALTER TABLE [dbo].[Price]
ADD EnableForPriceList bit 
DEFAULT(1) NOT NULL 
GO
--**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**---

/****** Object:  View [dbo].[ExcelPriceLevelCostView]    Script Date: 12/21/2012 14:37:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[ExcelPriceLevelCostView]
AS

SELECT		p.ID AS 'PriceID',
			c.Name AS 'SportsCategory',
			(	SELECT c.Name + ',' AS [text()] 
				FROM Pattern p
					JOIN PatternOtherCategory poc 
						ON poc.Pattern = p.ID 
					JOIN Category c
						ON poc.Category = c.ID	
				WHERE Number = pt.Number FOR XML PATH('')) AS 'OtherCategories',
			p.[Pattern] AS 'PatternID',
			(	SELECT  i.Name
				FROM Item i  
				WHERE i.ID = SubItem) AS ItemSubCategoris,
			pt.[NickName],
			fc.[Name] AS FabricCodeName,	
			fc.[NickName] AS FabricCodenNickName,
			pt.[Number],	
			pt.ConvertionFactor	
	FROM	Indico.dbo.Price p
			JOIN Indico.dbo.Pattern pt
				ON p.Pattern = pt.ID
			JOIN Indico.dbo.FabricCode fc
				ON p.FabricCode = fc.ID
			JOIN Indico.dbo.Item i
				ON i.ID = pt.[SubItem]
			JOIN Indico.dbo.Category c
				ON pt.CoreCategory = C.ID
	INNER JOIN (
		SELECT p.[Pattern] AS PatternId,
				p.[FabricCode] AS FaricCodeId
		FROM	Indico.dbo.Price p
				JOIN Indico.dbo.PriceLevelCost plc
					ON p.ID	= plc.Price
				JOIN Indico.dbo.Pattern pt 
					ON p.Pattern = pt.ID 
		WHERE pt.IsActive = 1 AND p.[EnableForPriceList] = 1
		GROUP BY p.[Pattern], p.[FabricCode]) G			
			ON p.[Pattern] = G.PatternId
			AND p.[FabricCode] = G.FaricCodeId	
		--ORDER BY C.Name		


GO

--**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**-----**---


