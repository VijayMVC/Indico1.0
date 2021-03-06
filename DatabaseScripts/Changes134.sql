USE [Indico]
GO

-------------- Adding new Column to Order -----------------------------------

ALTER TABLE [dbo].[Order] 
ADD DeliveryCharges DECIMAL(8,2) NULL 
DEFAULT 0

GO

ALTER TABLE [dbo].[Order] 
ADD ArtWorkCharges DECIMAL(8,2) NULL 
DEFAULT 0 

GO

ALTER TABLE [dbo].[Order] 
ADD OtherCharges DECIMAL(8,2) NULL 
DEFAULT 0 

GO

ALTER TABLE [dbo].[Order] 
ADD OtherChargesDescription NVARCHAR(255) NULL 

GO

-------------- Updating Indiman Prices -----------------------------------

/****** Object:  StoredProcedure [dbo].[SPC_UpdatePrice]    Script Date: 05/25/2015 17:05:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_UpdatePrice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_UpdatePrice]
GO


/****** Object:  StoredProcedure [dbo].[SPC_UpdatePrice]    Script Date: 05/25/2015 17:05:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_UpdatePrice]
(
	@P_PriceFactor DECIMAL,
	@P_Ceiling DECIMAL	
)
AS 

BEGIN

	DECLARE @RetVal int
	
	BEGIN TRY

		UPDATE   [dbo].[PriceLevelCost]
		SET [IndimanCost] =  CEILING(([IndimanCost]/@P_PriceFactor) / @P_Ceiling)*@P_Ceiling

		SET @RetVal = 1
		
	END TRY
	BEGIN CATCH	
		SET @RetVal = 0		
	END CATCH
	SELECT @RetVal AS RetVal		
END

GO

-----------------------------------------------------------------


/****** Object:  Table [dbo].[MYOBCardFile]    Script Date: 04/29/2015 11:06:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MYOBCardFile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Description] [nvarchar](256) NULL
 CONSTRAINT [PK_MYOBCardFile] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MYOBCardFile', @level2type=N'COLUMN',@level2name=N'ID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the MYOBCardFile' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MYOBCardFile', @level2type=N'COLUMN',@level2name=N'Name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The description of the MYOBCardFile' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MYOBCardFile', @level2type=N'COLUMN',@level2name=N'Description'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MYOBCardFile'
GO

-----------------------------------------------------------------

INSERT INTO [dbo].[MYOBCardFile] ([Name])	 VALUES ('CASH SALE - Andrea Gilmore')
INSERT INTO [dbo].[MYOBCardFile] ([Name])	 VALUES ('CASH SALE - Juanita Aguero')
INSERT INTO [dbo].[MYOBCardFile] ([Name])	 VALUES ('CASH SALE - Travis Eddie')
INSERT INTO [dbo].[MYOBCardFile] ([Name])	 VALUES ('CASH SALE - Troy Beard')
INSERT INTO [dbo].[MYOBCardFile] ([Name])	 VALUES ('Big V Basketball')
INSERT INTO [dbo].[MYOBCardFile] ([Name])	 VALUES ('Big V Contra')
INSERT INTO [dbo].[MYOBCardFile] ([Name])	 VALUES ('National Print & Supply')
INSERT INTO [dbo].[MYOBCardFile] ([Name])	 VALUES ('Oztag Merchandise Pty Ltd')

-----------------------------------------------------------------

ALTER TABLE [dbo].[Order] ADD [MYOBCardFile] INT NULL
CONSTRAINT [FK_Order_MYOBCardFile] FOREIGN KEY ([MYOBCardFile]) REFERENCES [MYOBCardFile];

-----------------------------------------------------------------

