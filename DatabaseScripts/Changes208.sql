USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

UPDATE [dbo].[VisualLayout]
SET IsActive = 1
GO

UPDATE [dbo].[VisualLayout]
SET IsActive = 0
WHERE NamePrefix LIKE '%(X)%'
GO

UPDATE [dbo].[VisualLayout]
SET IsEmbroidery = 0
WHERE NamePrefix LIKE '%VL%'
GO

UPDATE [dbo].[VisualLayout]
SET IsEmbroidery = 1
WHERE NamePrefix LIKE '%CS%'
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--