USE [Indico]
GO

-- Removing duplicated IsHero record.. 2015-01-06
UPDATE [dbo].[PatternTemplateImage]
SET IsHero = 0
WHERE  ID = 633
