/****** Object:  View [dbo].[GetMeasureLocForPatternSizeView]    Script Date: 06/28/2013 11:13:40 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GetMeasureLocForPatternSizeView]'))
DROP VIEW [dbo].[GetMeasureLocForPatternSizeView]
GO

/****** Object:  View [dbo].[GetMeasurementLocationsForPatternSizeView]    Script Date: 06/28/2013 11:04:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[GetMeasureLocForPatternSizeView]
AS	SELECT	p.ID AS Pattern, 
			s.[ID] AS Size, 
			s.[SizeName],
			s.[SeqNo], 
			ml.[Key], 
			ml.[Name], 
			sc.[Val]
	FROM [dbo].[SizeChart] sc
		JOIN [dbo].[Pattern] p
			ON sc.Pattern = p.ID
		JOIN [dbo].[MeasurementLocation] ml
			ON sc.[MeasurementLocation] = ml.ID	
		JOIN [dbo].[Size] s
			ON sc.[Size] = s.ID		
	--WHERE p.Number = '621'
	--ORDER BY s.[SeqNo], ml.[Key]

GO

