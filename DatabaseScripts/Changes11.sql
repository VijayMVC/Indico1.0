DECLARE @MPageID int
DECLARE @PageID int
DECLARE @MenuItem int
DECLARE @RoleID int
DECLARE @ParentID int

SET @MPageID = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditIndimanPrice.aspx')
SET @ParentID = (SELECT [ID] FROM [dbo].[MenuItem] WHERE  [Page] = @MPageID AND [Parent] IS NULL)
SET @PageID = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddPriceList.aspx')  
INSERT INTO [dbo].[MenuItem] ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
VALUES(@PageID,'Add Price List', 'Add Price List', 1, @ParentID, 8, 0)

SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @PageID AND [Parent] = @ParentID)
SET @RoleID = (SELECT [ID] FROM [dbo].[Role] WHERE [Description]  = 'Indiman Administrator') 
INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @RoleID)  
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

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
		GROUP BY p.[Pattern], p.[FabricCode]) G			
			ON p.[Pattern] = G.PatternId
			AND p.[FabricCode] = G.FaricCodeId	
		--ORDER BY C.Name		


GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

