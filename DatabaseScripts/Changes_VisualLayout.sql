USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

ALTER TABLE dbo.[VisualLayout] ADD IsActive BIT NOT NULL 
CONSTRAINT [DF_VisualLayout_IsActive] DEFAULT ((1))
GO

ALTER TABLE dbo.[VisualLayout] ADD IsEmbroidery BIT NOT NULL 
CONSTRAINT [DF_VisualLayout_IsEmbroidery] DEFAULT ((0))
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
