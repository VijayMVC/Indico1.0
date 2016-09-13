use [Indico] 
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
ALTER TABLE [Indico].[dbo].[Company]
ALTER COLUMN [Address1] NVARCHAR(128) NULL

ALTER TABLE [Indico].[dbo].[Company]
ALTER COLUMN[City] NVARCHAR(68) NULL

ALTER TABLE [Indico].[dbo].[Company]
ALTER COLUMN[State] NVARCHAR(20) NULL

ALTER TABLE [Indico].[dbo].[Company]
ALTER COLUMN[Postcode] NVARCHAR(20) NULL

ALTER TABLE [Indico].[dbo].[Company]
ALTER COLUMN[Phone1] NVARCHAR(20) NULL

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
/********** Add new column to the Pattern Table***********/
ALTER TABLE [dbo].[Pattern] ADD [IsActiveWS] BIT NOT NULL DEFAULT(0)

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
/********** Update Pattern table column***********/
DECLARE @ID AS int
DECLARE @GarmentSpecStatus AS nvarchar(255) 
DECLARE PatternUpdateCursor CURSOR FAST_FORWARD FOR 
SELECT [ID]      
      ,[GarmentSpecStatus]     
FROM [dbo].[Pattern]
WHERE [GarmentSpecStatus] = ''

OPEN PatternUpdateCursor 
	FETCH NEXT FROM PatternUpdateCursor INTO @ID, @GarmentSpecStatus 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 	
		UPDATE  [dbo].[Pattern] SET [GarmentSpecStatus]='Spec Missing' WHERE [ID]= @ID
		FETCH NEXT FROM PatternUpdateCursor INTO @ID, @GarmentSpecStatus
	END 
CLOSE PatternUpdateCursor 
DEALLOCATE PatternUpdateCursor

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
/********** CREATE TABLE SAVE REMARKS FOR INDIMAN REMARKS ***********/

/****** Object:  Table [dbo].[IndimanPriceRemarks]    Script Date: 11/05/2012 17:14:55 ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[IndimanPriceRemarks](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Price] [int] NOT NULL,
	[Remarks] [nvarchar](512) NOT NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_IndimanPriceRemarks] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[IndimanPriceRemarks]  WITH CHECK ADD  CONSTRAINT [FK_IndimanPriceRemarks_Price] FOREIGN KEY([Price])
REFERENCES [dbo].[Price] ([ID])
GO

ALTER TABLE [dbo].[IndimanPriceRemarks] CHECK CONSTRAINT [FK_IndimanPriceRemarks_Price]
GO

