--**--**--**--**--**--**--**--**--**--** Delete where size name is "OTHER" --**--**--**--**--**--**--**--**--**--**

DELETE [Indico].[dbo].[SizeChart] 
FROM [Indico].[dbo].[Size] s
	JOIN [Indico].[dbo].[SizeChart] sc
		ON s.ID = sc.Size 
WHERE s.SizeName = 'OTHER'
GO

DELETE [Indico].[dbo].[Size]
FROM [Indico].[dbo].[Size] s
WHERE s.SizeName = 'OTHER'
GO