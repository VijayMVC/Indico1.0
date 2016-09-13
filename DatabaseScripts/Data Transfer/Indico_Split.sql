USE [Indico]
GO

/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 06/25/2012 15:50:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Split]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Split]
GO

/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 06/25/2012 15:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[Split]
(
	@RowData nvarchar(2000),
	@SplitOn nvarchar(5)
)  
RETURNS @RtnValue table 
(
	Id int identity(1,1),
	Data nvarchar(100)
) 
AS  
BEGIN 
	Declare @Cnt int
	SET @Cnt = 1
	
	WHILE (Charindex(@SplitOn,@RowData)>0)
	BEGIN
		INSERT INTO @RtnValue (data)
		SELECT Data = ltrim(rtrim(Substring(@RowData,1,Charindex(@SplitOn,@RowData)-1)))
		SET @RowData = Substring(@RowData,Charindex(@SplitOn,@RowData)+1,len(@RowData))
		SET @Cnt = @Cnt + 1
	END
	
	INSERT INTO @RtnValue (data)
	SELECT Data = ltrim(rtrim(@RowData))
	Return
END
GO