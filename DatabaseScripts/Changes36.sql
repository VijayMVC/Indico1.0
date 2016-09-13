USE [Indico]
GO

ALTER TABLE [dbo].[User]
ADD [HaveAccessForHTTPPost] [bit] NULL
GO
--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**

 
/****** Object:  StoredProcedure [dbo].[SPC_ReturnUserLogin]    Script Date: 04/02/2013 09:35:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SPC_ReturnUserLogin] (	
	@P_Username varchar(255),
	@P_Password varchar(255)
)
AS
BEGIN
	SELECT	DISTINCT
			u.[ID],
			u.[Company],
			u.[IsDistributor],
			u.[Status],
			u.[Username],
			u.[Password],
			u.[GivenName],
			u.[FamilyName],
			u.[EmailAddress],
			u.[PhotoPath],
			u.[Creator],
			u.[CreatedDate],
			u.[Modifier],
			u.[ModifiedDate],
			u.[IsActive],
			u.[IsDeleted],
			u.[Guid],
			u.[MobileTelephoneNumber],
			u.[HomeTelephoneNumber],
			u.[OfficeTelephoneNumber],
			u.[DateLastLogin],
			u.[HaveAccessForHTTPPost]
			--u.[Credits]--, 
			--u.[DistributorLabel]
	FROM	[dbo].[User] u
	WHERE 	u.Username = @P_Username 
			AND u.[Password] = CONVERT(varchar(255), HashBytes('SHA1', @P_Password))
			AND u.IsDeleted != 1
END

GO
--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**

--**-**-**--**--**-**-**--**--**-**-**--** ALTER TABLE PatternTemplateImage --**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**
ALTER TABLE [dbo].[PatternTemplateImage] 
ADD [ImageOrder] [int] NULL
GO
--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**

--**-**-**--**--**-**-**--**--**-**-**--** Update Pattern Template Image ImageOrder Column --**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**
--SELECT * FROM [dbo].[PatternTemplateImage] WHERE [IsHero] = 0 AND [ImageOrder] IS NULL
DECLARE @PatID AS int

SET @PatID = (SELECT [ID] FROM [dbo].[PatternTemplateImage] WHERE [Pattern] = 290 AND [Filename] = '052_302')

UPDATE [dbo].[PatternTemplateImage] SET [ImageOrder] = 1 WHERE [Pattern] = 290 AND [ID] = @PatID
GO

DECLARE @PatID AS int

SET @PatID = (SELECT [ID] FROM [dbo].[PatternTemplateImage] WHERE [Pattern] = 290 AND [Filename] = '052_953')

UPDATE [dbo].[PatternTemplateImage] SET [ImageOrder] = 2 WHERE [Pattern] = 290 AND [ID] = 10
GO

DECLARE @PatID AS int

SET @PatID = (SELECT [ID] FROM [dbo].[PatternTemplateImage] WHERE [Pattern] = 296 AND [Filename] = '060_937')

UPDATE [dbo].[PatternTemplateImage] SET [ImageOrder] = 1 WHERE [Pattern] = 296 AND [ID] = 12
GO

DECLARE @PatID AS int

SET @PatID = (SELECT [ID] FROM [dbo].[PatternTemplateImage] WHERE [Pattern] = 1046 AND [Filename] = '3070-front_710')

UPDATE [dbo].[PatternTemplateImage] SET [ImageOrder] = 1 WHERE [Pattern] = 1046 AND [ID] = 86
GO

DECLARE @PatID AS int

SET @PatID = (SELECT [ID] FROM [dbo].[PatternTemplateImage] WHERE [Pattern] = 1046 AND [Filename] = '3116-1_978')

UPDATE [dbo].[PatternTemplateImage] SET [ImageOrder] = 2 WHERE [Pattern] = 1046 AND [ID] = 88
GO

--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**--**-**-**--**
