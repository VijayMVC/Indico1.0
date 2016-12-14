USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_DeletePattern]') AND type in (N'P', N'PC'))
      DROP PROCEDURE [dbo].[SPC_DeletePattern]
GO

CREATE PROC [dbo].[SPC_DeletePattern]
	@PatternID int
AS 
BEGIN
	IF @PatternID >0
	BEGIN
		DELETE [dbo].[PatternAccessory] WHERE Pattern = @PatternID

		SELECT  ID INTO #PatternDevalopments FROM [dbo].[PatternDevelopment] WHERE Pattern = @PatternID

		DELETE pdh
		FROM [dbo].[PatternDevelopmentHistory] pdh
			INNER JOIN #PatternDevalopments pd
				ON pd.ID = pdh.PatternDevelopment

		DELETE pd
		FROM [dbo].[PatternDevelopment] pd
			INNER JOIN #PatternDevalopments pds
				ON pd.ID = pds.ID

		DELETE [dbo].[PatternAccessory] WHERE Pattern = @PatternID

		DELETE [dbo].[PatternItemAttributeSub] WHERE Pattern = @PatternID

		DELETE [dbo].[PatternOtherCategory] WHERE Pattern = @PatternID

		DELETE [dbo].[PatternTemplateImage] WHERE Pattern = @PatternID

		DELETE [dbo].[Price] WHERE Pattern = @PatternID

		DELETE [dbo].[Product] WHERE Pattern = @PatternID

		DELETE [dbo].[Reservation] WHERE Pattern = @PatternID

		DELETE [dbo].[SizeChart] WHERE Pattern = @PatternID

		DELETE [dbo].[PatternHistory] WHERE Pattern = @PatternID

		DELETE [dbo].[Pattern] WHERE ID = @PatternID
	END
END



GO
