USE [Indico] 
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SplitINComma]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[SplitINComma]
GO


CREATE FUNCTION SplitINComma(@splitString VARCHAR(255))
RETURNS @tmpTable TABLE(OtherCategories VARCHAR(255))
AS
BEGIN 
 DECLARE @isTemp VARCHAR(255)
	
	WHILE LEN(@splitString)>0
		BEGIN 
			SET @isTemp = LEFT(@splitString,ISNULL(NULLIF(CHARINDEX(',',@splitString)-1,-1),LEN(@splitString)))
			SET @splitString = SUBSTRING(@splitString,ISNULL(NULLIF(CHARINDEX(',',@splitString),0),LEN(@splitString))+1,								LEN(@splitString))
			INSERT INTO @tmpTable VALUES(@isTemp)
		END 
	RETURN
END 
GO