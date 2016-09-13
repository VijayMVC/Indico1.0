USE [Indico]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_ValidateField2]    Script Date: 3/30/2016 4:03:06 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ValidateField2]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ValidateField2]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ValidateField2]    Script Date: 3/30/2016 4:03:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPC_ValidateField2]
(
	@P_ID INT = 0,
	@P_TableName AS NVARCHAR(255) = '',
	@P_Field1 AS NVARCHAR(255) = '',
	@P_Value1 AS NVARCHAR(255) = '',
	@P_Field2 AS NVARCHAR(255) = '',
	@P_Value2 AS NVARCHAR(255) = ''
)
AS 

BEGIN

	DECLARE @RetVal int
	
	BEGIN TRY 
		DECLARE @sqlText1 nvarchar(4000);
		DECLARE @sqlText2 nvarchar(4000);
		DECLARE @result table (ID int)

		IF (@P_Field2 != '')
		BEGIN
			SET @sqlText2 = ' AND [' + @P_Field2 + '] = '+ @P_Value2
		END
		ELSE
		BEGIN
			SET @sqlText2 = ''
		END

		SET @sqlText1 = N'SELECT TOP 1 ID FROM dbo.[' + @P_TableName + '] WHERE [' + @P_Field1 + '] = ''' + @P_Value1  + ''' AND ( ( '+ CONVERT(VARCHAR(10), @P_ID) +' = 0 ) OR (ID != '+ CONVERT(VARCHAR(10), @P_ID) +' ) )' + @sqlText2
		
		INSERT INTO @result EXEC (@sqlText1)
		
		IF EXISTS (SELECT ID FROM @Result)
		BEGIN
			SET @RetVal = 0
		END
		ELSE
		BEGIN
		   SET @RetVal = 1
		END
	END TRY
	BEGIN CATCH	
		 --SELECT 
   --     ERROR_NUMBER() AS ErrorNumber
   --    ,ERROR_MESSAGE() AS ErrorMessage;
		SET @RetVal = 0				
	END CATCH

	SELECT @RetVal AS RetVal		
END



GO
