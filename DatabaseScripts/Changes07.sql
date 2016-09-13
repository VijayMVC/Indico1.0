USE [Indico]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--- ALTER VIew "[ClientOrderDetailsView]"------

ALTER VIEW [dbo].[ClientOrderDetailsView]
AS
	SELECT --DISTINCT TOP 100 PERCENT
		od.[ID] AS OrderDetailId,
		co.[ID] AS CompanyId,
		co.[Name] AS CompanyName,
		o.[ID] AS OrderId,
		o.[Date],
		o.[DesiredDeliveryDate],
		o.[OrderNumber],
		o.[IsTemporary],
		cl.[ID] AS ClientId,
		cl.[Name] AS ClientName,
		ot.[ID] AS OrderTypeId,
		ot.[Name] AS OrderType,
		vl.[ID] AS VisualLayoutId,
		vl.[NamePrefix] AS NamePrefix,
		vl.[NameSuffix] As NameSuffix,
		p.[ID] AS PatternId,
		p.[Number] AS PatternNumber,
		fc.[ID] AS FabricId,
		fc.[Name] AS Fabric,
		fc.[NickName] AS FabricNickName,
		os.[ID] AS [StatusId],
		os.[Name] AS [Status]
	FROM dbo.[Order] o
		INNER JOIN dbo.[OrderStatus] os
			ON  os.[ID] = o.[Status]
		INNER JOIN dbo.[OrderDetail] od
			ON o.ID = od.[Order] 
		INNER JOIN dbo.[OrderType] ot
			ON ot.[ID] = od.[OrderType]
		INNER JOIN dbo.[VisualLayout] vl
			ON vl.[ID] = od.[VisualLayout]
		INNER JOIN dbo.[Pattern] p
			ON p.[ID] = vl.[Pattern]
		INNER JOIN dbo.[FabricCode] fc
			ON fc.[ID] = vl.[FabricCode]
		INNER JOIN dbo.[Company] co   
			ON co.[ID] = o.[Distributor]
		INNER JOIN dbo.[Client] cl
			ON cl.[ID] = o.[Client]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
UPDATE [dbo].[MenuItem] SET Name = 'Indico Prices' WHERE Name = 'Indico Price'
UPDATE [dbo].[MenuItem] SET Name = 'Factory Prices' WHERE Name = 'Factory Prices'
GO

-- Alter View LastRecordOfVisullayoutPrefixVL--

ALTER VIEW [dbo].[LastRecordOfVisullayoutPrefixVL]
 AS
	SELECT TOP 1 [ID]
			,[NamePrefix]
			,[NameSuffix]
	  FROM [Indico].[dbo].[VisualLayout]
	  WHERE NamePrefix = 'VL' AND NameSuffix IS NOT NULL
	  ORDER BY [CreatedDate] DESC
GO

--Alter View LastRecordOfVisullayoutPrefixDY --

ALTER VIEW [dbo].[LastRecordOfVisullayoutPrefixDY]
 AS
	  SELECT TOP 1 [ID] 
			,[NamePrefix]
			,[NameSuffix]
	  FROM [Indico].[dbo].[VisualLayout]
	  WHERE NamePrefix = 'DY' AND NameSuffix IS NOT NULL
	  ORDER BY [CreatedDate] DESC
GO

---Alter View LastRecordOfVisullayoutPrefixCS--

ALTER VIEW [dbo].[LastRecordOfVisullayoutPrefixCS]
AS
	SELECT TOP 1 [ID]
			,[NamePrefix]
			,[NameSuffix]
	  FROM [Indico].[dbo].[VisualLayout]
	  WHERE NamePrefix = 'CS' AND NameSuffix IS NOT NULL
	  ORDER BY [CreatedDate] DESC
GO

ALTER TABLE dbo.VisualLayout
	ALTER COLUMN Coordinator int NULL
GO

ALTER TABLE dbo.VisualLayout
	ALTER COLUMN Client int NULL
GO

ALTER TABLE dbo.VisualLayout
	ALTER COLUMN Distributor int NULL
GO





