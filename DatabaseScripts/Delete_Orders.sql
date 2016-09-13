USE [Indico]
GO


DELETE FROM [dbo].[PackingListSizeQty]
	FROM [dbo].[PackingListSizeQty] plsq
		JOIN [dbo].[PackingList] pl
			ON plsq.[PackingList] = pl.[ID]
		JOIN [dbo].[OrderDetail] od
			ON pl.[OrderDetail] = od.[ID]
		JOIN [dbo].[Order] o
			ON od.[Order] = o.[ID]


DELETE [dbo].[PackingListCartonItem]
	FROM [dbo].[PackingListCartonItem] plc
		JOIN [dbo].[PackingList] pl
			ON plc.[PackingList] = pl.[ID]
		JOIN [dbo].[OrderDetail] od
			ON pl.[OrderDetail] = od.[ID]
		JOIN [dbo].[Order] o
			ON od.[Order] = o.[ID]
			

DELETE [dbo].[PackingList]
	FROM [dbo].[PackingList] pl
		JOIN [dbo].[OrderDetail] od
			ON pl.[OrderDetail] = od.[ID]
		JOIN [dbo].[Order] o
			ON od.[Order] = o.[ID]
	
DELETE [dbo].[OrderDetailQty]
	FROM [dbo].[OrderDetailQty] odq
		JOIN [dbo].[OrderDetail] od
			ON odq.[OrderDetail] = od.[ID]
		JOIN [dbo].[Order] o
			ON od.[Order] = o.[ID]

DELETE [dbo].[FactoryOrderDetial]
	FROM [dbo].[FactoryOrderDetial] fod
		JOIN [dbo].[OrderDetail] od
			ON fod.[OrderDetail] = od.[ID]
		JOIN [dbo].[Order] o
			ON od.[Order] = o.[ID]			

DELETE [dbo].[OrderDetail]
	FROM [dbo].[OrderDetail] od			
		JOIN [dbo].[Order] o
			ON od.[Order] = o.[ID]
			
DELETE FROM [dbo].[Order]