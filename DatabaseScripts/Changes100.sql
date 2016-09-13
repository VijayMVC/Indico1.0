USE [Indico]
GO


/****** Object:  StoredProcedure [dbo].[SPC_GetPrice]    Script Date: 06/04/2014 10:53:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetPrice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_GetPrice]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetPrice]    Script Date: 06/04/2014 10:53:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/

CREATE PROC [dbo].[SPC_GetPrice](
@P_PatternNumber AS nvarchar(255),
@P_FabricNickName AS nvarchar(255) 
)
AS
BEGIN

SELECT (ISNULL( (SELECT ISNULL(pr.[ID], 0) AS RetVal      
	  FROM [dbo].[Price] pr
		JOIN [dbo].[Pattern] p
			ON pr.[Pattern] = p.[ID]
		JOIN [dbo].[FabricCode] fc
			ON pr.[fabricCode] = fc.[ID]
	  WHERE p.[Number] = @P_PatternNumber AND fc.[NickName] = @P_FabricNickName), 0)) AS RetVal
 
 END


GO


