USE [Indico]
GO


DELETE FROM [dbo].[OrderDetailQty] 
FROM [dbo].[OrderDetailQty] odq
	JOIN [dbo].[OrderDetail] od
		ON odq.[OrderDetail] = od.[ID]
	JOIN [dbo].[Pattern] p
		ON od.[Pattern] = p.[ID]
	JOIN [dbo].[SizeSet] ss
		ON p.[SizeSet] = ss.[ID]
	JOIN [dbo].[Size] s
		ON ss.[ID] = s.[SizeSet]
WHERE s.[ID] IN (SELECT [ID] FROM [Indico].[dbo].[Size] WHERE [SizeSet] = (SELECT [SizeSet] 
																							FROM [dbo].[Pattern] 
																							WHERE [Number] = '3041') AND 
																								  [SizeName] IN ('32', '34', '36', '38', '40', '42', '44', '46', '48')) 


DELETE FROM [dbo].[SizeChart] 
FROM [dbo].[SizeChart] sc
	JOIN [dbo].[Pattern] p
		ON sc.[Pattern] = p.[ID]
	JOIN [dbo].[SizeSet] ss
		ON p.[SizeSet] = ss.[ID]
	JOIN [dbo].[Size] s
		ON ss.[ID] = s.[SizeSet]		
WHERE s.[ID] IN (SELECT [ID] FROM [Indico].[dbo].[Size] WHERE [SizeSet] = (SELECT [SizeSet] 
																							FROM [dbo].[Pattern] 
																							WHERE [Number] = '3041') AND 
																								  [SizeName] IN ('32', '34', '36', '38', '40', '42', '44', '46', '48')) 



DELETE FROM [dbo].[Size] 
WHERE [ID] IN ( SELECT [ID] FROM [Indico].[dbo].[Size] WHERE [SizeSet] = (SELECT [SizeSet] FROM [dbo].[Pattern]
																						   WHERE [Number] = '3041') AND 
																						         [SizeName] IN ('32', '34', '36', '38', '40', '42', '44', '46', '48')) 
 
	